# 필요한 라이브러리 설치
# pip install datasets transformers matplotlib

from datasets import load_dataset
from transformers import BertTokenizerFast
import matplotlib.pyplot as plt
import numpy as np

# 1. SST-2 validation 데이터셋 불러오기
ds = load_dataset("glue", "sst2", split="validation")

# 2. 토크나이저 로드 (BERT-base-uncased)
tok = BertTokenizerFast.from_pretrained("bert-base-uncased")

lengths = []
eff_lengths = []

for ex in ds:
    ids = tok(ex["sentence"], add_special_tokens=True)["input_ids"]
    # [CLS], [SEP] 제거
    if ids and ids[0] == tok.cls_token_id:
        ids = ids[1:]
    if ids and ids[-1] == tok.sep_token_id:
        ids = ids[:-1]
    L = len(ids)
    lengths.append(L)
    eff_lengths.append(min(L, 64))  # 하드웨어 최대 입력을 64로 제한

# 3. 히스토그램 그리기
plt.figure(figsize=(6, 4))
plt.hist(eff_lengths, bins=range(0, 65, 2), edgecolor="black", color="gray")
plt.xlabel("Effective token length (<=64)")
plt.ylabel("Number of sentences")
plt.grid(axis="y", alpha=0.6)
plt.tight_layout()
plt.show()

# 4. 구간별 비율 계산
buckets = {"1-16": 0, "17-32": 0, "33-64": 0, ">64": 0}


avg_len = np.mean(lengths)
print("평균 토큰 길이:", avg_len)

for L in lengths:
    if L <= 16:
        buckets["1-16"] += 1
    elif L <= 32:
        buckets["17-32"] += 1
    elif L <= 64:
        buckets["33-64"] += 1
    else:
        buckets[">64"] += 1

N = len(lengths)
bucket_pct = {k: v * 100 / N for k, v in buckets.items()}
print("버킷별 비율:", bucket_pct)
