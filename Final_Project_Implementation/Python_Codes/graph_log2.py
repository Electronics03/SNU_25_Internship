import numpy as np
import matplotlib.pyplot as plt

x_log_data = np.array(
    [
        0.000977,
        0.001953,
        0.003906,
        0.007812,
        0.015625,
        0.031250,
        0.062500,
        0.125000,
        0.250000,
        0.500000,
        1.000000,
        2.000000,
        4.000000,
        8.000000,
        16.000000,
        31.999023,
    ]
)

y_log_approx = np.array(
    [
        -10,
        -9,
        -8,
        -7,
        -6,
        -5,
        -4,
        -3,
        -2,
        -1,
        0,
        1,
        2,
        3,
        4,
        4.999023,
    ]
)

x_log_true = np.linspace(0, 32, 1000)
y_log_true = np.log2(x_log_true)

plt.figure(figsize=(8, 5))
plt.plot(x_log_true, y_log_true, label="True log2(x)", color="blue")
plt.plot(x_log_data, y_log_approx, "o-", label="Verilog log2_approx", color="red")
plt.title("log2 Approximation Comparison")
plt.xlabel("Input x")
plt.ylabel("log2(x)")
plt.legend()
plt.grid()
plt.show()
