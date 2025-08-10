import numpy as np
import Attention_Baseline
import FlashAttention
import FlashAttention2
import FlashD


def main():
    np.random.seed(0)
    Q = np.random.rand(5, 4)
    K = np.random.rand(5, 4)
    V = np.random.rand(5, 6)

    print("in:")
    print(Q)
    print(K)
    print(V)

    out1 = Attention_Baseline.attention(Q, K, V)
    out2 = FlashAttention.flash_attention(Q, K, V)
    out3 = FlashAttention2.flash_attention_2(Q, K, V)
    out4 = FlashD.flash_D(Q, K, V)
    print("Attention_Baseline Output:\n", out1)
    print("FlashAttention Output:\n", out2)
    print("FlashAttention2 Output:\n", out3)
    print("FlashD Output:\n", out4)


if __name__ == "__main__":
    main()
