import numpy as np
import datasets
from transformers import BertTokenizer
from transformers import BertForSequenceClassification
import torch


# Look Up Table (LUT)
def LUT(sel_mult):
    if sel_mult == 0:
        return 1  # 1
    elif sel_mult == 1:
        return 0.5  # 1/2
    elif sel_mult == 2:
        return 1.442695041  # log2(e)
    elif sel_mult == 3:
        return 2.570882563  # alpha*log2(e)


def RU(in_0, in_1, sel_mux, sel_mult):
    # Subtraction or log2-based normalization
    if sel_mux:
        # sel_mux = True: simple difference for shift (x_i - max(x))
        out_0 = in_1 - in_0
    else:
        # sel_mux = False: log2 correction (log2(exp_sum) - y_i)
        # Ensuring input is positive for log2 domain
        out_0 = in_1 - log2_approx(in_0)

    # Scaling via selected LUT constant
    out_0 = out_0 * LUT(sel_mult)

    # Exponential approximation via 2^x
    # It can approximate to add and shift operation
    out_1 = pow2_approx(out_0)

    return [out_0, out_1]


def approx2_softmax(x):
    x = np.array(x, dtype=np.float32)
    y = np.empty(x.size, dtype=np.float32)
    output = np.empty(x.size, dtype=np.float32)

    # Stage 1: Max-subtraction and exponentiation approximation
    x_max = np.max(x)
    sum_exp = 0
    for i in range(x.size):
        out = RU(x_max, x[i], True, 2)
        y[i] = out[0]
        sum_exp += out[1]

    # Stage 2: Normalization
    for i in range(y.size):
        out = RU(sum_exp, y[i], False, 0)
        output[i] = out[1]

    return output


def log2_approx(x):
    w = int(np.floor(np.log2(x)))
    x_prime = x / (2**w)
    log2_x = w + (x_prime - 1)
    return log2_x


def pow2_approx(x):
    x = np.array(x)
    u = np.floor(x).astype(int)
    v = x - u
    pow2_x = (1 + v) * (2.0**u)
    return pow2_x


def baseline_softmax_Pytorch_FP32(x):
    logits_tensor = torch.tensor(x)
    probs_tensor = torch.softmax(logits_tensor, dim=-1)
    # Using pytorch softmax
    return probs_tensor.numpy()


def get_SST2_BERT_logits():
    # 1. Model Preparation
    model_name = "textattack/bert-base-uncased-SST-2"
    # Model name to load
    tokenizer = BertTokenizer.from_pretrained(model_name)
    # Load the tokenizer compatible with the model
    # Returns a tokenizer object
    model = BertForSequenceClassification.from_pretrained(model_name)
    # Load the BERT model fine-tuned on SST-2
    # Returns a model object

    model.eval()  # Set the model to evaluation mode

    # 2. Load all SST-2 validation samples
    # SST-2 samples are available via Hugging Face
    # Use load_dataset from datasets
    dataset = datasets.load_dataset("glue", "sst2", split="validation")
    # "validation" → loads 872 evaluation samples
    sentences = dataset["sentence"]
    # Sentence samples
    true_labels = np.array(dataset["label"])
    # Ground truth labels

    print(f"Loaded {len(sentences)} SST-2 samples.")
    # Confirm loading of the entire dataset

    # 3. Tokenize sentences
    inputs = tokenizer(sentences, return_tensors="pt", padding=True, truncation=True)
    # Use the loaded tokenizer
    # inputs = {
    #       "input_ids": Tensor1,
    #       "attention_mask": Tensor2
    #   }
    # Tensor1: token ID sequences for each sentence
    # Tensor2: attention mask indicating which tokens are padding (0) vs real (1)
    # Returns a dictionary (Key-Value pairs)

    with torch.no_grad():
        # Disable gradient tracking in this block
        # Turns off autograd engine
        # No backpropagation is performed
        # Used only for inference (prediction)
        outputs = model(
            input_ids=inputs["input_ids"],
            attention_mask=inputs["attention_mask"],
        )
        # outputs = SequenceClassifierOutput(
        #       loss=None (or value),
        #       logits=Tensor,
        #       hidden_states=None,
        #       attentions=None
        #   )
        # logits is a tensor containing predicted score vectors for each sentence
        logits = outputs.logits.numpy()
        # Convert the tensor to a NumPy array

    return [logits, true_labels]


def evaluate_SST2_softmax_accuracy():
    logits, true_labels = get_SST2_BERT_logits()
    # Compare predicted labels
    correct_basic = 0
    correct_approx = 0
    match_count = 0

    for idx, logit in enumerate(logits):
        std_probs = baseline_softmax_Pytorch_FP32(logit)
        approx_probs = approx2_softmax(logit)
        std_label = np.argmax(std_probs)
        approx_label = np.argmax(approx_probs)
        true_label = true_labels[idx]

        # Measure accuracy
        # Compare with ground truth
        if std_label == true_label:
            correct_basic += 1
            print("[O", end="")
        else:
            print("[X", end="")

        if approx_label == true_label:
            correct_approx += 1
            print("O]", end="")
        else:
            print("X]", end="")

        if idx % 20 == 19:
            print()

        # Check label agreement between standard and approximate softmax
        if std_label == approx_label:
            match_count += 1

    # Summary of overall accuracy
    total = len(logits)
    acc_basic = correct_basic / total * 100
    acc_approx = correct_approx / total * 100
    label_match_rate = match_count / total * 100

    print("\n=====Evaluation Results=====")
    print(f"Standard Softmax Accuracy : {acc_basic:.3f}% ({correct_basic}/{total})")
    print(f"Approximate Softmax Accuracy: {acc_approx:.3f}% ({correct_approx}/{total})")
    print(
        f"Label Match Rate (Std vs Approx): {label_match_rate:.3f}% ({match_count}/{total})"
    )


if __name__ == "__main__":
    evaluate_SST2_softmax_accuracy()
