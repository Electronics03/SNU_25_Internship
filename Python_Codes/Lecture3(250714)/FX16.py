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


softmax2_out = [
    "01b3",
    "03cc",
    "1d30",
    "0004",
    "0f48",
    "ba00",
    "0016",
    "0fa8",
    "0001",
    "aa80",
    "0e00",
    "c100",
    "0410",
    "21a0",
    "0302",
    "9280",
    "18b0",
    "3200",
    "17d0",
    "7240",
    "1250",
    "0001",
    "1950",
    "7080",
    "0968",
    "0124",
    "0900",
    "7f80",
    "0d00",
    "23a0",
    "0490",
    "0218",
    "8280",
    "03da",
    "7d40",
    "68c0",
    "3c20",
    "0b28",
    "3680",
    "ec80",
    "0d78",
    "0c78",
    "020a",
    "1530",
    "7cc0",
    "2200",
    "0ec0",
    "07ac",
    "1f00",
    "00fe",
    "ec80",
    "1d30",
    "05c4",
    "8f80",
    "0540",
    "7f40",
    "02c0",
    "3d20",
    "1280",
    "5380",
    "07b0",
    "0182",
    "6480",
    "25c0",
]

converted = q412_to_float(softmax2_out)
for real_val in converted:
    print(f"{real_val:.5f}")
print()
