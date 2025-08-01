import numpy as np
from time import sleep


def float_to_q612(arr):
    scaled = np.round(arr * 1024)
    clipped = np.clip(scaled, -32768, 32767)
    return clipped.astype(np.int16)


for _ in range(64):
    vec_float = np.random.uniform(low=-3, high=3, size=64)
    vec_q610 = float_to_q612(vec_float)

    for i, val in enumerate(vec_q610):
        print(f"{int(val) & 0xFFFF:04X}", end="")
    sleep(0.1)
    print()
