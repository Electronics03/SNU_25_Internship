import numpy as np
import matplotlib.pyplot as plt
from datasets import load_dataset
from transformers import BertTokenizer, BertForSequenceClassification
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
    logits_tensor = torch.tensor(x)
    probs_tensor = torch.softmax(logits_tensor, dim=-1)
    return probs_tensor.numpy()


def main():
    # 1️ 모델 준비
    model_name = 'textattack/bert-base-uncased-SST-2'
    tokenizer = BertTokenizer.from_pretrained(model_name)
    model = BertForSequenceClassification.from_pretrained(model_name)
    model.eval()

    # 2️ SST-2 데이터셋 샘플 100개
    dataset = load_dataset("glue", "sst2", split="validation")
    sentences = dataset["sentence"]
    true_labels = np.array(dataset["label"])

    print(f"Loaded {len(sentences)} SST-2 samples.")

    # 3️ 문장 토크나이즈
    inputs = tokenizer(sentences, return_tensors='pt', padding=True, truncation=True)

    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits.numpy()

    # 4️ 예측 라벨 비교
    correct_basic = 0
    correct_approx = 0
    match_count = 0

    for idx, logit in enumerate(logits):
        std_probs = basic_softmax(logit)
        approx_probs = approx2_softmax(logit)

        std_label = np.argmax(std_probs)
        approx_label = np.argmax(approx_probs)
        true_label = true_labels[idx]

        # Accuracy 측정
        if std_label == true_label:
            correct_basic += 1
        if approx_label == true_label:
            correct_approx += 1

        # Softmax 버전 간 예측 라벨 일치 여부
        if std_label == approx_label:
            match_count += 1

        # 선택적으로 상세 출력
        if idx < 5:  # 처음 5개만 출력 예시
            print(f"Sample {idx+1}: {sentences[idx]}")
            print(f"True Label: {true_label}")
            print(f"Logits: {np.round(logit, 3)}")
            print(f"Standard Softmax Probs: {np.round(std_probs, 4)} → Label: {std_label}")
            print(f"Approximate Softmax Probs: {np.round(approx_probs, 4)} → Label: {approx_label}")
            print(f"Labels Match? {std_label == approx_label}")
            print("-" * 60)

    # 5️ 전체 정확도 요약
    total = len(sentences)
    acc_basic = correct_basic / total * 100
    acc_approx = correct_approx / total * 100
    label_match_rate = match_count / total * 100

    print("\n=== Evaluation Results ===")
    print(f"Standard Softmax Accuracy : {acc_basic:.2f}%")
    print(f"Approximate Softmax Accuracy: {acc_approx:.2f}%")
    print(f"Label Match Rate (Std vs Approx): {label_match_rate:.2f}%")

if __name__ == "__main__":
    main()