import numpy as np
import matplotlib.pyplot as plt


def attention(Q, K, V):
    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq, d_k = Q.shape
    Nk, d_k2 = K.shape

    outputs = []

    for q in Q:
        scores = np.dot(K, q) / np.sqrt(d_k)
        f = approx2_softmax(scores)
        output = np.dot(f, V)
        outputs.append(output)
    return np.array(outputs)


def softmax(scores):
    scores_exp = np.exp(scores - np.max(scores))
    sotmax_out = scores_exp / np.sum(scores_exp)
    return sotmax_out


# Look Up Table (LUT)
def LUT(sel_mult):
    if sel_mult == 0:
        return 1  # 1
    elif sel_mult == 1:
        return 0.5  # 1/2
    elif sel_mult == 2:
        return 1.442695041  # log2(e)
    elif sel_mult == 3:
        return 2.570882563  # alpha*log2(e)


def RU(in_0, in_1, sel_mux, sel_mult):
    # Subtraction or log2-based normalization
    if sel_mux:
        # sel_mux = True: simple difference for shift (x_i - max(x))
        out_0 = in_1 - in_0
    else:
        # sel_mux = False: log2 correction (log2(exp_sum) - y_i)
        # Ensuring input is positive for log2 domain
        out_0 = in_1 - log2_approx(in_0)

    # Scaling via selected LUT constant
    out_0 = out_0 * LUT(sel_mult)

    # Exponential approximation via 2^x
    # It can approximate to add and shift operation
    out_1 = pow2_approx(out_0)

    return [out_0, out_1]


def approx2_softmax(x):
    x = np.array(x, dtype=np.float32)
    y = np.empty(x.size, dtype=np.float32)
    output = np.empty(x.size, dtype=np.float32)

    # Stage 1: Max-subtraction and exponentiation approximation
    x_max = np.max(x)
    sum_exp = 0
    for i in range(x.size):
        out = RU(x_max, x[i], True, 2)
        y[i] = out[0]
        sum_exp += out[1]

    # Stage 2: Normalization
    for i in range(y.size):
        out = RU(sum_exp, y[i], False, 0)
        output[i] = out[1]

    return output


def log2_approx(x, eps=1e-12):
    x = np.asarray(x, dtype=np.float64)
    # log2는 x>0에서만 정의 → 안전하게 클램프
    x = np.maximum(x, eps)

    w = np.floor(np.log2(x)).astype(np.int32)  # 정수 지수
    # 2**w 대신 실수 밑 or exp2 사용
    two_pow_w = np.exp2(w).astype(np.float64)  # == 2.0**w
    x_prime = x / two_pow_w  # x' = x / 2^w
    return w + (x_prime - 1.0)


def pow2_approx(x):
    x = np.asarray(x, dtype=np.float64)
    u = np.floor(x).astype(np.int32)  # 정수부
    v = x - u  # 소수부
    # 정수 밑 대신 exp2 사용
    two_pow_u = np.exp2(u).astype(np.float64)  # == 2.0**u
    return (1.0 + v) * two_pow_u
