import numpy as np

import numpy as np


def fp16_to_float(hex_str):
    val = int(hex_str, 16)
    fp16 = np.uint16(val).view(np.float16)
    return float(fp16)


def float_to_fp16_hex(val):
    fp16 = np.float16(val)
    bits = fp16.view(np.uint16)
    return f"{bits:04x}"


hex_list = ["281a", "2d93", "3394", "3926"]

for h in hex_list:
    print(f"{h} -> {fp16_to_float(h)}")
