import numpy as np


def fp16_to_float(hex_str):
    val = int(hex_str, 16)
    fp16 = np.uint16(val).view(np.float16)
    return float(fp16)


def float_to_fp16_hex(val):
    fp16 = np.float16(val)
    bits = fp16.view(np.uint16)
    return f"{bits:04x}"


hex_list = ["4380", "4400", "3C00"]

for h in hex_list:
    print(f"{h} -> {fp16_to_float(h)}")

dec_list = [0.2]

for d in dec_list:
    print(f"{d} -> {float_to_fp16_hex(d)}")
