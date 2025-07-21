import numpy as np
from time import sleep


def float_to_q88(arr):
    scaled = np.round(arr * 256)
    clipped = np.clip(scaled, -32768, 32767)
    return clipped.astype(np.int16)


for _ in range(3):
    vec_float = np.random.uniform(low=-3.0, high=3.0, size=64)
    vec_q88 = float_to_q88(vec_float)

    for i, val in enumerate(vec_float):
        print(f"{val:.3f}", end=", ")
        if i % 8 == 7:
            print()

    for i, val in enumerate(vec_q88):
        print(f"16'h{int(val) & 0xFFFF:04X}", end=", ")
        if i % 8 == 7:
            print()
    sleep(1)
