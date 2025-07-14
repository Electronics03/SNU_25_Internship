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


hex_list = ["3c00", "4000", "4200", "4400", "4500", "4600", "4700", "4800"]
dec_list = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]

for h in hex_list:
    print(f"{h} -> {fp16_to_float(h)}")

for d in dec_list:
    print(f"{d} -> h{float_to_fp16_hex(d)}")

print(fp16_to_float("231c"))
