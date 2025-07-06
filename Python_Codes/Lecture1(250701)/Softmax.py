import numpy as np
import matplotlib.pyplot as plt
from datasets import load_dataset
from transformers import BertTokenizer, BertModel
import torch

# Look Up Table (LUT)
def LUT(sel_mult):
    if sel_mult == 0:
        return 1            # 1
    elif sel_mult == 1:
        return 0.5          # 1/2
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
        out_0 = in_1 - np.log2(in_0)

    # Scaling via selected LUT constant
    out_0 = out_0 * LUT(sel_mult)

    # Exponential approximation via 2^x
    # It can approximate to add and shift operation
    out_1 = 2 ** (out_0)

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

def basic_softmax(x):
    x = np.array(x, dtype=np.float32)
    exp_x = np.exp(x, dtype=np.float32)
    return exp_x / np.sum(exp_x)

def get_bert_logits(sentences):
    # 사전학습된 BERT 모델과 토크나이저 로드
    tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
    model = BertModel.from_pretrained('bert-base-uncased')
    model.eval()

    # 문장 인코딩
    inputs = tokenizer(sentences, return_tensors='pt', padding=True, truncation=True)
    with torch.no_grad():
        outputs = model(**inputs)
    
    # [CLS] 토큰 벡터 사용 (batch_size, hidden_size)
    cls_embeddings = outputs.last_hidden_state[:, 0, :].numpy()

    return cls_embeddings

def main():
    # 1. SST-2 문장 샘플 불러오기
    dataset = load_dataset("glue", "sst2", split="train[:5]")
    sentences = dataset["sentence"]

    print("Sample sentences from SST-2:")
    for s in sentences:
        print("-", s)
    print()

    # 2. BERT 임베딩 벡터 생성
    cls_vectors = get_bert_logits(sentences)
    print(f"BERT CLS embeddings shape: {cls_vectors.shape}")

    # 3. Softmax 비교
    for idx, vec in enumerate(cls_vectors):
        print(f"\nSample {idx+1}:")
        print("Input vector (rounded):", np.round(vec[:8], 3), "...")  # 일부만 출력

        approx_result = approx2_softmax(vec)
        basic_result = basic_softmax(vec)

        print("Approximate Softmax:", np.round(approx_result, 4))
        print("Standard Softmax   :", np.round(basic_result, 4))
        print("Errors             :", (basic_result-approx_result)/basic_result)
        print("-" * 50)

if __name__ == "__main__":
    main()
