import numpy as np
import torch


def Q610_to_float(hex_list):
    result = []
    for hex_val in hex_list:
        val = int(hex_val, 16)
        if val >= 0x8000:
            val -= 0x10000
        real_val = val / 1024.0
        result.append((real_val))
    return result


def baseline_softmax_FP32(x):
    logits_tensor = np.array(x)
    max_elem = logits_tensor.max()
    logits_tensor = logits_tensor - max_elem
    prob_softmax = np.exp(logits_tensor) / sum(np.exp(logits_tensor))
    return prob_softmax


softmax_in = ""


def split_by_n(s, n=4):
    return [s[i : i + n] for i in range(0, len(s), n)]


for _ in range(63):
    in_FX16 = input()
    softmax_in = softmax_in + in_FX16

softmax_out = ""


def split_by_n(s, n=4):
    return [s[i : i + n] for i in range(0, len(s), n)]


for _ in range(63):
    in_FX16 = input()
    softmax_out = softmax_out + in_FX16

softmax_in_arr = split_by_n(softmax_in)
softmax_out_arr = split_by_n(softmax_out)

in_converted = Q610_to_float(softmax_in_arr)
in_converted = np.array(in_converted).reshape(63, 64)
out_converted = Q610_to_float(softmax_out_arr)
out_converted = np.array(out_converted).reshape(63, 64)


for i in range(63):
    out_ideal = baseline_softmax_FP32(in_converted[i])
    for j in range(64):
        print(f"{in_converted[i][j]:.5f} {out_converted[i][j]:.5f} {out_ideal[j]:.5f}")
    print()

with open("softmax_compare.txt", "w") as txtfile:
    for i in range(63):
        out_ideal = baseline_softmax_FP32(in_converted[i])
        for j in range(64):
            txtfile.write(
                f"{in_converted[i][j]:.5f}  {out_converted[i][j]:.5f}  {out_ideal[j]:.5f}\n"
            )
        txtfile.write("\n")
