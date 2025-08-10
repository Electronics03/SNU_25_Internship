import numpy as np


def flash_D(Q, K, V):

    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq = len(Q)
    Nk = len(K)

    d_v = V.shape[1]

    outputs = np.zeros((Nq, d_v), dtype=np.float64)

    for qi, q in enumerate(Q):
        o = np.zeros(d_v)
        weight = 1
        s = 0.0
        for i in range(Nk):
            s_new = np.dot(K[i], q)
            if i != 0:
                weight = sigmoid(s_new - s + np.log(weight))

            o = o * (1 - weight) + V[i] * weight
            s = s_new

        outputs[qi] = o

    return outputs


def sigmoid(x):
    sigmoid_out = 1 / (1 + np.exp(-x))
    return sigmoid_out
