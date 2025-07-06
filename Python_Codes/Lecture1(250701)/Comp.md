# Softmax Function Approximation Comparison

This section demonstrates how the approximate softmax implementation (approx2_softmax) compares to the standard softmax function.

The standard softmax formula is:

$$
S_j(x) = \frac{e^{x_j - \max(x)}}{\sum_{i = 0}^{N - 1} e^{x_i - \max(x)}}
$$

### Purpose:
- Normalize a vector of logits into probabilities that sum to 1
- Prevent numerical overflow by subtracting max(x)

### Test Setup:
- Input: Random array of 50 values sampled uniformly from [-3, 3]
- Both implementations (approximate and standard) are applied to the same input

### Visualization:
- **Bar Chart Comparison**:
  - Side-by-side bars show the output probabilities of both implementations.
  - Helps visually verify how closely the approximated version matches the true softmax.

- **Error Percentage Plot**:
  - Displays the relative error for each element.
  - Highlights which indices have higher approximation error.

### Interpretation:
- Ideally, the approximate version closely matches the standard softmax.
- Minor differences (a few %) are expected due to the log2/exp2-based approximation.
- Error plot helps quantify the quality of approximation.

### Result
![Softmax_test](./Pictures/Softmax_test.png)


### Code

```py
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
    import matplotlib.pyplot as plt

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
```

## References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.