import numpy as np


def q412_to_float(hex_list):
    result = []
    for hex_val in hex_list:
        val = int(hex_val, 16)
        if val >= 0x8000:
            val -= 0x10000
        real_val = val / 256.0
        result.append((real_val))
    return result


softmax_out = [
    "0036",
    "0005",
    "0005",
    "0001",
    "00b8",
    "0008",
    "0016",
    "0002",
    "0019",
    "0002",
    "0002",
    "0002",
    "00e4",
    "0008",
    "000a",
    "0002",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
