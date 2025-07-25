import numpy as np


def q412_to_float(hex_list):
    result = []
    for hex_val in hex_list:
        val = int(hex_val, 16)
        if val >= 0x8000:
            val -= 0x10000
        real_val = val / 1024.0
        result.append((real_val))
    return result


softmax_out = [
    "00e0",
    "0e62",
    "0030",
    "fd00",
    "fa00",
    "fd00",
    "f890",
    "fe00",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

softmax_out = [
    "0e62",
    "0e62",
    "0e62",
    "0e62",
    "0e62",
    "0e62",
    "0e62",
    "0e62",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

softmax_out = [
    "fce0",
    "1262",
    "0030",
    "fd00",
    "fa00",
    "fd00",
    "f890",
    "fe00",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

softmax_out = [
    "0020",
    "03c4",
    "001c",
    "000c",
    "0006",
    "000c",
    "0004",
    "000f",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

softmax_out = [
    "0080",
    "0080",
    "0080",
    "0080",
    "0080",
    "0080",
    "0080",
    "0080",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()

softmax_out = [
    "0004",
    "03ef",
    "000b",
    "0005",
    "0002",
    "0005",
    "0001",
    "0006",
]

converted = q412_to_float(softmax_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
