import types
import torch
from torch import nn
import numpy as np
import datasets
from transformers import BertTokenizer
from transformers import BertForSequenceClassification
from FlashD import flash_D
from Attention_Baseline import attention


def bert_self_attention_flashd_forward(
    self, hidden_states: torch.Tensor, attention_mask=None
):
    mixed_query_layer = self.query(hidden_states)
    mixed_key_layer = self.key(hidden_states)
    mixed_value_layer = self.value(hidden_states)

    def shape(x):
        return x.view(
            x.size(0), -1, self.num_attention_heads, self.attention_head_size
        ).transpose(1, 2)

    query_layer = shape(mixed_query_layer)
    key_layer = shape(mixed_key_layer)
    value_layer = shape(mixed_value_layer)

    B, heads, T, Dh = query_layer.shape
    flashd_outputs = torch.zeros_like(query_layer)

    if attention_mask is not None:
        mask = attention_mask.squeeze(1).squeeze(1)
        mask_np = mask.cpu().numpy()
    else:
        mask_np = None

    for b in range(B):
        for h in range(heads):
            Q_np = query_layer[b, h].detach().cpu().numpy()
            K_np = key_layer[b, h].detach().cpu().numpy()
            V_np = value_layer[b, h].detach().cpu().numpy()
            if mask_np is not None:
                V_masked = V_np.copy()
                V_masked[mask_np[b] < 0] = 0
                out_np = flash_D(Q_np, K_np, V_masked)
            else:
                out_np = flash_D(Q_np, K_np, V_np)
            flashd_outputs[b, h] = torch.tensor(
                out_np, dtype=query_layer.dtype, device=query_layer.device
            )

    context_layer = (
        flashd_outputs.transpose(1, 2)
        .contiguous()
        .view(B, T, self.num_attention_heads * self.attention_head_size)
    )
    return context_layer, None


def bert_self_attention_approx_forward(
    self,
    hidden_states,
    attention_mask=None,
    head_mask=None,
    encoder_hidden_states=None,
    encoder_attention_mask=None,
    past_key_value=None,
    output_attentions=False,
):
    mixed_query_layer = self.query(hidden_states)
    mixed_key_layer = self.key(hidden_states)
    mixed_value_layer = self.value(hidden_states)

    def shape(x):
        return x.view(
            x.size(0), -1, self.num_attention_heads, self.attention_head_size
        ).transpose(1, 2)

    query_layer = shape(mixed_query_layer)
    key_layer = shape(mixed_key_layer)
    value_layer = shape(mixed_value_layer)

    B, heads, T, Dh = query_layer.shape
    flashd_outputs = torch.zeros_like(query_layer)

    if attention_mask is not None:
        mask = attention_mask.squeeze(1).squeeze(1)
        mask_np = mask.cpu().numpy()
    else:
        mask_np = None

    for b in range(B):
        for h in range(heads):
            Q_np = query_layer[b, h].detach().cpu().numpy()
            K_np = key_layer[b, h].detach().cpu().numpy()
            V_np = value_layer[b, h].detach().cpu().numpy()
            if mask_np is not None:
                V_masked = V_np.copy()
                V_masked[mask_np[b] < 0] = 0
                out_np = attention(Q_np, K_np, V_masked)
            else:
                out_np = attention(Q_np, K_np, V_np)
            flashd_outputs[b, h] = torch.tensor(
                out_np, dtype=query_layer.dtype, device=query_layer.device
            )

    context_layer = (
        flashd_outputs.transpose(1, 2)
        .contiguous()
        .view(B, T, self.num_attention_heads * self.attention_head_size)
    )
    return context_layer, None


def evaluate_SST2_flashD():
    dataset = datasets.load_dataset("glue", "sst2", split="validation")
    tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")

    baseline_model = BertForSequenceClassification.from_pretrained(
        "textattack/bert-base-uncased-SST-2"
    ).eval()

    flashd_model = BertForSequenceClassification.from_pretrained(
        "textattack/bert-base-uncased-SST-2"
    ).eval()
    for layer in flashd_model.bert.encoder.layer:
        layer.attention.self.forward = types.MethodType(
            bert_self_attention_flashd_forward, layer.attention.self
        )

    approx_model = BertForSequenceClassification.from_pretrained(
        "textattack/bert-base-uncased-SST-2"
    ).eval()
    for layer in approx_model.bert.encoder.layer:
        layer.attention.self.forward = types.MethodType(
            bert_self_attention_approx_forward, layer.attention.self
        )

    correct_baseline = 0
    correct_flashd = 0
    correct_approx = 0
    match_count = 0

    for i, item in enumerate(dataset):
        inputs = tokenizer(item["sentence"], return_tensors="pt")
        label = item["label"]

        with torch.no_grad():
            out_base = baseline_model(**inputs).logits
            out_flash = flashd_model(**inputs).logits
            out_approx = approx_model(**inputs).logits

        pred_base = out_base.argmax(dim=-1).item()
        pred_flash = out_flash.argmax(dim=-1).item()
        pred_approx = out_approx.argmax(dim=-1).item()

        if pred_base == label:
            correct_baseline += 1
        if pred_flash == label:
            correct_flashd += 1
        if pred_approx == label:
            correct_approx += 1
        if pred_base == pred_flash:
            match_count += 1
        if pred_base == pred_approx:
            same1 = "O"
        else:
            same1 = "X"
        if pred_base == pred_flash:
            same2 = "O"
        else:
            same2 = "X"
        print(
            f"[{i:3d}] Base:{pred_base} FlashD:{pred_flash} Approx:{pred_approx} Label:{label} {same2}{same1}"
        )

    total = len(dataset)
    print("\n===== Evaluation Results =====")
    print(
        f"Baseline BERT Accuracy : {correct_baseline/total*100:.2f}% ({correct_baseline}/{total})"
    )
    print(
        f"FLASH-D BERT Accuracy  : {correct_flashd/total*100:.2f}% ({correct_flashd}/{total})"
    )
    print(
        f"Approx BERT Accuracy  : {correct_approx/total*100:.2f}% ({correct_approx}/{total})"
    )
    print(
        f"Prediction Match Rate  : {match_count/total*100:.2f}% ({match_count}/{total})"
    )


if __name__ == "__main__":
    evaluate_SST2_flashD()
