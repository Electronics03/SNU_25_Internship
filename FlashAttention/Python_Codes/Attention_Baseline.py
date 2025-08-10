import numpy as np


def attention(Q, K, V):

    outputs = []

    for q in Q:
        scores = np.dot(K, q)
        f = softmax(scores)
        output = np.dot(f, V)
        outputs.append(output)

    return np.array(outputs)


def softmax(scores):
    scores_exp = np.exp(scores - np.max(scores))
    sotmax_out = scores_exp / np.sum(scores_exp)
    return sotmax_out
