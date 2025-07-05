# How to Approximation?

## 0. Pre-Processing

$$
\vec{x}=\{x_0, x_1, ... , x_{N-1} \}
$$

- Input vector $\vec{x}$ : N-elements
- Fixed-Point 16 bit

$$
x_j^\prime = x_j - \max(\vec{x})
$$

- This preprocessing step is used to prevent overflow.
- If the input values are very large, the output can be extremely large($e^x$), causing overflow. 
- By subtracting $\max(x)$, the largest input becomes 0, making the maximum output equal to 1.

## I. Exponential Function
$$
\begin{aligned}
e^x& = (2^{\log_2 e})^x\\
&= 2^{x\log_2e}\\
&= 2^{u + v}\\
&= 2^v \cdot 2^u\\
\therefore &\approx (1+v) \ll u
\end{aligned}
$$

- $u$ : integer part of $x\log_2e$
- $v$ : fractional part of $x\log_2e$
- In fixed-point, shift operations are more efficient than multiplication.

## II. Softmax
$$
\begin{aligned}
S_j(x)&= \frac{e^{x_j^\prime}}{\sum_{i=0}^{N-1}e^{x_i^\prime}}\\
&= \frac{2^{x_j^\prime\cdot\log_2e}}{\sum_{i=0}^{N-1}e^{x_i^\prime}}\\
&= \frac{2^{x_j^\prime\cdot\log_2e}}{2^{\log_2(\sum_{i=0}^{N-1}e^{x_i^\prime})}}\\
\therefore &= 2^{x_j^\prime\cdot\log_2e-\log_2(\sum_{i=0}^{N-1}e^{x_i^\prime})}\\
\end{aligned}
$$

- Approximate the exp function by converting it to a base-2 representation
- Use $\log_2$ to transform to the exponential domain and convert division into subtraction.

## III. Log Base-2 of x


