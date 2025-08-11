import numpy as np


def flash_attention_2(Q, K, V):

    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq, d_k = Q.shape
    Nk, d_k2 = K.shape

    d_v = V.shape[1]

    outputs = np.zeros((Nq, d_v), dtype=np.float64)

    for qi, q in enumerate(Q):
        m = -np.inf
        l = 0.0
        o = np.zeros(d_v)

        for i in range(Nk):
            s = np.dot(K[i], q) / np.sqrt(d_k)
            m_new = max(m, s)

            l = l * np.exp(m - m_new) + np.exp(s - m_new)
            o = o * np.exp(m - m_new) + V[i] * np.exp(s - m_new)

            m = m_new

        outputs[qi] = o / l

    return outputs
