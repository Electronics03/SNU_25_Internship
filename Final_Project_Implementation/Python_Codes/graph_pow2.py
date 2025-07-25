import numpy as np
import matplotlib.pyplot as plt

x_pow_data = np.array(
    [
        -31.999023,
        -11.000000,
        -10.000000,
        -9.000000,
        -8.000000,
        -7.000000,
        -6.000000,
        -5.000000,
        -4.000000,
        -3.000000,
        -2.000000,
        -1.000000,
        0.000000,
        1.000000,
        2.000000,
        3.000000,
        4.000000,
        4.999023,
    ]
)

y_pow_approx = np.array(
    [
        0.000000,
        0.000000,
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
        16.00000,
        31.98437,
    ]
)
x_pow_true = np.linspace(-32, 5, 1000)
y_pow_true = 2**x_pow_true

plt.figure(figsize=(8, 5))
plt.plot(x_pow_true, y_pow_true, label="True 2^x", color="blue")
plt.plot(x_pow_data, y_pow_approx, "o-", label="Verilog pow2_approx", color="red")
plt.title("2^x Approximation Comparison")
plt.xlabel("Input x")
plt.ylabel("2^x")
plt.legend()
plt.grid()
plt.show()
