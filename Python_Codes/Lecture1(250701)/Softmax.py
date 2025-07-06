import numpy as np
import matplotlib.pyplot as plt

# Look Up Table (LUT)
def LUT(sel_mult):
    if sel_mult == 0:
        return 1            # 1
    elif sel_mult == 1:
        return 0.5          # 1/2
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
        out_0 = in_1 - np.log2(in_0)

    # Scaling via selected LUT constant
    out_0 = out_0 * LUT(sel_mult)

    # Exponential approximation via 2^x
    # It can approximate to add and shift operation
    out_1 = 2 ** (out_0)

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


def basic_softmax(x):
    x = np.array(x, dtype=np.float32)
    exp_x = np.exp(x, dtype=np.float32)
    return exp_x / np.sum(exp_x)


def main():
    N = 50
    dtype = np.float32

    # Generate input: 50 random values from uniform(-3, 3)
    x = np.random.uniform(-3, 3, size=N).astype(dtype)
    print("Input vector x:", x)

    # Compute approximate and standard softmax
    approx_output = approx2_softmax(x)
    basic_output = basic_softmax(x)

    # Compute relative error in percentage
    error_percentage = (approx_output - basic_output) / basic_output * 100

    # Print results
    print("Softmax output (approx):", approx_output)
    print("Sum of outputs (approx):", np.sum(approx_output))

    print("Softmax output (basic):", basic_output)
    print("Sum of outputs (basic):", np.sum(basic_output))

    print("Error (%):", error_percentage)

    # --- Visualization Section ---
    plt.figure(figsize=(12, 5))

    # 1. Bar chart comparing outputs
    plt.subplot(1, 2, 1)
    indices = np.arange(len(x))
    plt.bar(indices - 0.2, basic_output, width=0.4, label="Basic Softmax")
    plt.bar(indices + 0.2, approx_output, width=0.4, label="Approx2 Softmax")
    plt.title("Softmax Output Comparison")
    plt.xlabel("Index")
    plt.ylabel("Probability")
    plt.legend()

    # 2. Error percentage plot
    plt.subplot(1, 2, 2)
    plt.bar(indices, error_percentage)
    plt.title("Error Percentage per Element")
    plt.xlabel("Index")
    plt.ylabel("Error (%)")

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()
