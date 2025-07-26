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


def split_by_n(s, n=4):
    return [s[i : i + n] for i in range(0, len(s), n)]


softmax_in = "061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5be061d061dfde20b13fbcf0b26042bf5befa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55dfa60042dffbff46a0a79f8b9fbccf55d00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a00f70ac00a9909d6ff4df72dff900b2a"


softmax_in_arr = split_by_n(softmax_in)

softmax_out = "000e000e000100310001003200080000000e000e000100310001003200080000000e000e000100310001003200080000000e000e000100310001003200080000000e000e000100310001003200080000000e000e000100310001003200080000000e000e000100310001003200080000000e000e00010031000100320008000000010016000700000069000100020000000100160007000000690001000200000001001600070000006900010002000000010016000700000069000100020000000100160007000000690001000200000001001600070000006900010002000000010016000700000069000100020000000100160007000000690001000200000002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a00010000000100230002001f001e001a0001000000010023"


softmax_out_arr = split_by_n(softmax_out)

in_converted = Q610_to_float(softmax_in_arr)
in_converted = np.array(in_converted).reshape(3, 64)
out_converted = Q610_to_float(softmax_out_arr)
out_converted = np.array(out_converted).reshape(3, 64)


for i in range(3):
    out_ideal = baseline_softmax_FP32(in_converted[i])
    for j in range(64):
        print(f"{in_converted[i][j]:.5f} {out_converted[i][j]:.5f} {out_ideal[j]:.5f}")
    print()
