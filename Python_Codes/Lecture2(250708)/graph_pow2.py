import numpy as np
import matplotlib.pyplot as plt

x_pow_data = np.array(
    [
        -4.000000,
        -3.500000,
        -3.000000,
        -2.500000,
        -2.000000,
        -1.750000,
        -1.500000,
        -1.250000,
        -1.000000,
        -0.750000,
        -0.500000,
        -0.250000,
        0.000000,
        0.250000,
        0.500000,
        0.750000,
        1.000000,
        1.250000,
        1.500000,
        1.750000,
        2.000000,
        2.125000,
        2.250000,
        2.375000,
        2.500000,
        2.625000,
        2.750000,
        2.875000,
    ]
)

y_pow_approx = np.array(
    [
        0.062500,
        0.093750,
        0.125000,
        0.187500,
        0.250000,
        0.312500,
        0.375000,
        0.437500,
        0.500000,
        0.625000,
        0.750000,
        0.875000,
        1.000000,
        1.250000,
        1.500000,
        1.750000,
        2.000000,
        2.500000,
        3.000000,
        3.500000,
        4.000000,
        4.500000,
        5.000000,
        5.500000,
        6.000000,
        6.500000,
        7.000000,
        7.500000,
    ]
)

y_pow_true = 2**x_pow_data

plt.figure(figsize=(8, 5))
plt.plot(x_pow_data, y_pow_true, label="True 2^x", color="blue")
plt.plot(x_pow_data, y_pow_approx, "o-", label="Verilog pow2_approx", color="red")
plt.title("2^x Approximation Comparison")
plt.xlabel("Input x")
plt.ylabel("2^x")
plt.legend()
plt.grid()
plt.show()
