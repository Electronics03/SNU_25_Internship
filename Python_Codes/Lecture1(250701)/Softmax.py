import numpy as np
import matplotlib.pyplot as plt
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
    model_name = "textattack/bert-base-uncased-SST-2"
    # 모델이름
    tokenizer = BertTokenizer.from_pretrained(model_name)
    # 모델에 맞는 토크나이저를 준비
    # 토크나이저 객체를 반환하는 함수
    model = BertForSequenceClassification.from_pretrained(model_name)
    # SST-2에 맞춰 fine-tune된 BERT 모델 다운로드 후 변수에 저장
    # 모델 객체를 반환하는 함수

    model.eval()  # Evaluation 모드

    # 2️ SST-2 데이터셋 샘플 모두 가져오기
    # SST-2 데이터셋 샘플은 Hugging Face에서 가져올 수 있다.
    # from datasets import load_dataset으로 load_dataset 사용
    dataset = datasets.load_dataset("glue", "sst2", split="validation")
    # "validation"-> 검증용 데이터 872개를 가져옴
    sentences = dataset["sentence"]
    # 문장 샘플데이터
    true_labels = np.array(dataset["label"])
    # 정답 샘플데이터

    print(f"Loaded {len(sentences)} SST-2 samples.")
    # 데이터셋 샘플을 모두 가져왔음

    # 3️ 문장 토크나이즈
    inputs = tokenizer(sentences, return_tensors="pt", padding=True, truncation=True)
    # 앞에서 가져온 토크나이저를 이용
    # input = {
    # 'input_ids': Tensor1,
    # 'attention_mask': Tensor2
    # }
    # Tensor1는 각 문장이 반환한 토큰 번호 시퀀스
    # Tensor2는 attention_mask 어떤 것이 패딩인지, 패딩이 아닌지 -> 모델이 패딩을 무시하도록 한다
    # 딕셔너리이다 (Key-Value)

    with torch.no_grad():
        # 이 블록 안에서는 모든 연산에서 gradient(미분 정보)를 추적하지 않겠다.
        # autograd 엔진이 꺼짐
        # 학습할떄의 역전파 사용 안함
        # 단순히 결과를 출력 (추론)만 한다
        # 앞에서 추론 모드로 설정
        outputs = model(
            input_ids=inputs["input_ids"],
            attention_mask=inputs["attention_mask"],
        )
        # outputs = SequenceClassifierOutput(
        # loss=None (또는 값),
        # logits=Tensor,
        # hidden_states=None,
        # attentions=None
        # )
        # Tensor는 각 문장이 반환한 로짓 벡터 시퀀스
        logits = outputs.logits.numpy()
        # 텐서를 넘파이 기반 배열로 변경

    # 4️ 예측 라벨 비교
    correct_basic = 0
    correct_approx = 0
    match_count = 0

    for idx, logit in enumerate(logits):  # 인덱스와 값을 동시에 꺼내주는 함수
        std_probs = basic_softmax(logit)
        approx_probs = approx2_softmax(logit)
        # 뭐 여기서부턴 그냥 두개 비교
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
            print(
                f"Standard Softmax Probs: {np.round(std_probs, 4)} → Label: {std_label}"
            )
            print(
                f"Approximate Softmax Probs: {np.round(approx_probs, 4)} → Label: {approx_label}"
            )
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
