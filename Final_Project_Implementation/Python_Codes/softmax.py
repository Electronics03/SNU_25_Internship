from transformers import BertModel, BertTokenizer, BertConfig
import torch
import numpy as np

# 모델 설정
config = BertConfig.from_pretrained("bert-base-uncased", output_hidden_states=True)
model = BertModel.from_pretrained("bert-base-uncased", config=config)
model.eval()

tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
inputs = tokenizer("ChatGPT is optimizing transformer hardware.", return_tensors="pt")

with torch.no_grad():
    outputs = model(**inputs, output_hidden_states=True)

# Hidden states → Query/Key → logits
hidden_states = outputs.hidden_states[1]
layer = model.encoder.layer[0].attention.self
W_Q, b_Q = layer.query.weight, layer.query.bias
W_K, b_K = layer.key.weight, layer.key.bias

Q = torch.matmul(hidden_states, W_Q.T) + b_Q
K = torch.matmul(hidden_states, W_K.T) + b_K

Q = Q.view(1, -1, 12, 64).transpose(1, 2)
K = K.view(1, -1, 12, 64).transpose(1, 2)

logits = torch.matmul(Q, K.transpose(-2, -1)) / (64**0.5)

logits_np = logits[0, 0].detach().numpy()
print(logits_np)
np.save("logits_fp32.npy", logits_np)
