import numpy as np


def float_to_Q610_hex(float_num: np.float64) -> str:
    int_num = int(round(float_num * 1024))
    if int_num > 32767:
        int_num = 32767
    elif int_num < -32768:
        int_num = -32768
    int_num = np.int16(int_num)
    return f"{np.uint16(int_num):04X}"


def float_to_hex_concat(float_list: list[np.float64]) -> str:
    out = ""
    for float_num in float_list:
        out = float_to_Q610_hex(float_num) + out
    return out


def Q610_hex_to_float(hex_num: str) -> np.float64:

    s = hex_num.strip()

    assert len(s) == 4, "Value Error"
    w = int(s, 16)
    if w & 0x8000:
        w -= 0x10000
    return np.float64(w / 1024)


def hex_concat_to_float_list(hex_concat: str) -> list[np.float64]:

    s = hex_concat.strip().replace(" ", "").replace("\n", "")
    assert len(s) % 4 == 0, "Value Error"
    out: list[np.float64] = []
    for i in range(0, len(s), 4):
        out.append(Q610_hex_to_float(s[i : i + 4]))
    out.reverse()
    return out
