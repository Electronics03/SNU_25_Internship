import numpy as np
import serial
import UART_base


def attention(Q, K, V, ser: serial.Serial):
    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq, d_kq = Q.shape
    Nk, d_kk = K.shape
    Nv, d_kv = V.shape

    assert Nq == Nk and d_kq == d_kk, "Dim Error"

    N = Nq
    d_k = d_kq

    outputs = np.zeros((Nq, d_kv), dtype=np.float64)

    for i, q in enumerate(Q):
        scores = np.dot(K, q) / np.sqrt(d_k)
        f = softmax_FPGA_UART(ser, scores)
        output = np.dot(f, V)
        outputs[i] = output

    return outputs


def softmax_FPGA_UART(ser: serial.Serial, scores, *, pad_value=-32.0, deadline_s=2.0):
    x = np.asarray(scores, dtype=np.float64)
    L = int(x.shape[0])
    if not (1 <= L <= 64):
        raise ValueError("Length must be between 1 and 64.")

    payload = np.full(64, pad_value, dtype=np.float64)
    payload[:L] = x

    frame = UART_base.build_softmax_frame(payload, length=L, endian="little")
    UART_base.send_exact(ser, frame)

    resp = UART_base.read_exact(ser, 128, deadline_s=deadline_s)
    probs64 = UART_base.q610_bytes_to_floats(resp, endian="little")

    p = np.asarray(probs64[:L], dtype=np.float64)
    return p
