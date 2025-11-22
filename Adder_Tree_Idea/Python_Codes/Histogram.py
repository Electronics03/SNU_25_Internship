# 필요한 라이브러리 설치
# pip install datasets transformers

from datasets import load_dataset
from transformers import BertTokenizerFast
import numpy as np

# 1. SST-2 validation 데이터셋 불러오기
ds = load_dataset("glue", "sst2", split="validation")

# 2. 토크나이저 로드 (BERT-base-uncased)
tok = BertTokenizerFast.from_pretrained("bert-base-uncased")

lengths = []

for ex in ds:
    ids = tok(ex["sentence"], add_special_tokens=True)["input_ids"]
    L = len(ids)
    lengths.append(L)

print(np.mean(lengths))

# 3. 텍스트 파일로 저장 (1줄당 하나의 길이값)
with open("sst2_token_lengths.txt", "w") as f:
    for L in lengths:
        f.write(f"{L}\n")

print("저장 완료: sst2_token_lengths.txt")
