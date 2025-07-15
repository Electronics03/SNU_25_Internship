import numpy as np


def q412_to_float(hex_list):
    result = []
    for hex_val in hex_list:
        val = int(hex_val, 16)
        if val >= 0x8000:
            val -= 0x10000
        real_val = val / 4096.0
        result.append((real_val))
    return result


softmax0_in = [
    "21c3",
    "fdf8",
    "fc4e",
    "ec6e",
    "3521",
    "0501",
    "13be",
    "ee08",
]
softmax0_out = [
    "035c",
    "005d",
    "0053",
    "001d",
    "0b68",
    "008b",
    "016a",
    "0020",
]

softmax1_in = [
    "0501",
    "0501",
    "0501",
    "0501",
    "0501",
    "0501",
    "0501",
    "0501",
]
softmax1_out = [
    "0200",
    "0200",
    "0200",
    "0200",
    "0200",
    "0200",
    "0200",
    "0200",
]
softmax2_in = [
    "21c3",
    "fdf8",
    "fc4e",
    "fc6e",
    "4521",
    "0501",
    "13be",
    "fe08",
]

softmax2_out = [
    "0195",
    "002b",
    "0026",
    "0027",
    "0e2e",
    "003f",
    "00a9",
    "002b",
]


def compute_softmax(logits):
    exps = np.exp(logits - np.max(logits))  # Numerical stability
    return exps / np.sum(exps)


converted = q412_to_float(softmax0_in)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
converted = q412_to_float(softmax0_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
# 예제 0
logits0 = [2.11011, -0.12695, -0.23096, -1.22314, 3.32056, 0.31274, 1.23389, -1.12305]

softmax0_true = compute_softmax(logits0)
print("Softmax 0 참값:")
for v in softmax0_true:
    print(f"{v:.5f}")
print()
print()
converted = q412_to_float(softmax1_in)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
converted = q412_to_float(softmax1_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

# 예제 1
logits1 = [0.31274, 0.31274, 0.31274, 0.31274, 0.31274, 0.31274, 0.31274, 0.31274]

softmax1_true = compute_softmax(logits1)
print("\nSoftmax 1 참값:")
for v in softmax1_true:
    print(f"{v:.5f}")
print()
print()
converted = q412_to_float(softmax2_in)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
converted = q412_to_float(softmax2_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()


# 예제 2
logits2 = [2.11011, -0.12695, -0.23096, -0.22314, 4.32056, 0.31274, 1.23389, -0.12305]

softmax2_true = compute_softmax(logits2)
print("\nSoftmax 2 참값:")
for v in softmax2_true:
    print(f"{v:.5f}")
print()
