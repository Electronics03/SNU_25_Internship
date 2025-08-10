# FLASH-D: FlashAttention with Hidden Softmax Division

## 1. AttenttionBaseline

### A. Full Operation Process (Matrix)

$$
\begin{aligned}
\bold{Q}&=
\left[
\begin{matrix}
\vec{q}_1 \\ \vec{q}_2 \\ \vdots \\ \vec{q}_n
\end{matrix}
\right]
&
\bold{K}&=
\left[
\begin{matrix}
\vec{k}_1 \\ \vec{k}_2 \\ \vdots \\ \vec{k}_n
\end{matrix}
\right]
&
\bold{V}&=
\left[
\begin{matrix}
\vec{v}_1 \\ \vec{v}_2 \\ \vdots \\ \vec{v}_n
\end{matrix}
\right]
\end{aligned}
$$

$$
\begin{aligned}
\bold{K}^T&=
\left[
\begin{matrix}
\vec{k}_1^T & \vec{k}_2^T & \cdots & \vec{k}_n^T
\end{matrix}
\right]
\end{aligned}
$$

$$
\begin{aligned}
\bold{Q}\bold{K}^T &=
\left[
\begin{matrix}
\vec{q}_1 \\ \vec{q}_2 \\ \vdots \\ \vec{q}_n
\end{matrix}
\right]
\left[
\begin{matrix}
\vec{k}_1^T & \vec{k}_2^T & \cdots & \vec{k}_n^T
\end{matrix}
\right]
\\
&=\left[
\begin{matrix}
\vec{q}_1\cdot\vec{k}_1 &
\vec{q}_1\cdot\vec{k}_2 &
\cdots &
\vec{q}_1\cdot\vec{k}_n \\
\vec{q}_2\cdot\vec{k}_1 &
\vec{q}_2\cdot\vec{k}_2 &
\cdots &
\vec{q}_2\cdot\vec{k}_n \\
\vdots & \vdots & \ddots & \vdots & 
\\
\vec{q}_n\cdot\vec{k}_1 &
\vec{q}_n\cdot\vec{k}_2 &
\cdots &
\vec{q}_n\cdot\vec{k}_n \\
\end{matrix}
\right]\\
\therefore &=
\left[
\begin{matrix}
s_{11} &
s_{12} &
\cdots &
s_{1n} \\
s_{21} &
s_{22} &
\cdots &
s_{2n} \\
\vdots & \vdots & \ddots & \vdots & 
\\
s_{n1} &
s_{n2} &
\cdots &
s_{nn} \\
\end{matrix}
\right]
\end{aligned}
$$

$$
\begin{aligned}
\bold{F}&=
\left[
\begin{matrix}
\mathrm{softmax}(
s_{11} &
s_{12} &
\cdots &
s_{1n}) \\
\mathrm{softmax}(
s_{21} &
s_{22} &
\cdots &
s_{2n}) \\
\vdots & \vdots & \ddots & \vdots & 
\\
\mathrm{softmax}(
s_{n1} &
s_{n2} &
\cdots &
s_{nn}) \\
\end{matrix}
\right]\\
\therefore &=
\left[
\begin{matrix}
f_{11} &
f_{12} &
\cdots &
f_{1n} \\
f_{21} &
f_{22} &
\cdots &
f_{2n} \\
\vdots & \vdots & \ddots & \vdots & 
\\
f_{n1} &
f_{n2} &
\cdots &
f_{nn} \\
\end{matrix}
\right]
\end{aligned}
$$

$$
\begin{aligned}
\bold{F}\bold{V}&=
\left[
\begin{matrix}
f_{11} &
f_{12} &
\cdots &
f_{1n} \\
f_{21} &
f_{22} &
\cdots &
f_{2n} \\
\vdots & \vdots & \ddots & \vdots & 
\\
f_{n1} &
f_{n2} &
\cdots &
f_{nn} \\
\end{matrix}
\right]
\left[
\begin{matrix}
\vec{v}_1 \\ \vec{v}_2 \\ \vdots \\ \vec{v}_n
\end{matrix}
\right]\\
&=
\left[
\begin{matrix}
f_{11}\vec{v}_1 +
f_{12}\vec{v}_2 +
\cdots +
f_{1n}\vec{v}_n \\

f_{21}\vec{v}_1 +
f_{22}\vec{v}_2 +
\cdots +
f_{2n}\vec{v}_n \\
\vdots 
\\
f_{n1}\vec{v}_1 +
f_{n2}\vec{v}_2 +
\cdots +
f_{nn}\vec{v}_n \\
\end{matrix}
\right]\\
\therefore &=
\left[
\begin{matrix}
\vec{o}_1 \\ \vec{o}_2 \\ \vdots \\ \vec{o}_n
\end{matrix}
\right]
\end{aligned}
$$

$$
\therefore \mathrm{Attention}(\bold{Q},\bold{K},\bold{V})
=\mathrm{Softmax}(\bold{Q}\bold{K}^T)\bold{V}
$$

### B. Detailed Operation Process (Row)

$$
s_i = \vec{q}\cdot\vec{k}_i
$$

$$
f_i=\mathrm{Softmax}(s_i)=\frac{e^{s_i-\mathrm{max}(s)}}{\sum_je^{s_j-\mathrm{max}(s)}}
$$

$$
\therefore \mathrm{Attention}(\vec{q},\bold{K},\bold{V})
=\sum_if_i\vec{v}_i
$$

### C. Python Code

```python
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
```

## 2. FlashAttenttion: Online Softmax

### A. Maximum Value Update

$$
\begin{aligned}
l_{i-1}&=\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}\\
l_i&=l_{i-1}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}
\\
&=(\sum_{i-1} e^{s_j-\mathrm{max_{prev}}})\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}
\\
&=
(\sum_{i-1} e^{(s_j-\mathrm{max_{prev}})+(\mathrm{max_{prev}}-\mathrm{max_{new}})})
+e^{s_{i}-\mathrm{max_{new}}}
\\
&=
(\sum_{i-1} e^{s_j-\mathrm{max_{new}}})
+e^{s_{i}-\mathrm{max_{new}}}
\\
\therefore &=
\sum_{i} e^{s_j-\mathrm{max_{new}}}
\\
\end{aligned}
$$

$$
\begin{aligned}
\vec{o}_{i-1} &= \sum_{i-1}
\left[\frac{e^{s_k-\mathrm{max_{prev}}}}{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}\cdot \vec{v}_k\right]\\
\vec{o}_{i} 
&= \vec{o}_{i-1}\cdot\frac{l_{i-1}}{l_i}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_{i}}
\\
&=
\sum_{i-1}
\left[
\frac{e^{s_k-\mathrm{max_{prev}}}}{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}\cdot \vec{v}_k
\right]
\left[
\frac{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\cdot e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
\right]+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\\
&=
\sum_{i-1}
\left[
\frac{e^{s_k-\mathrm{max_{prev}}}}{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}\cdot \vec{v}_k
\cdot
\frac{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\cdot e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
\right]+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\\
&=
\sum_{i-1}
\left[
\frac{e^{s_k-\mathrm{max_{prev}}}\cdot e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}}{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}
\cdot
\frac{\sum_{i-1} e^{s_j-\mathrm{max_{prev}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}
\cdot \vec{v}_k
\right]+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\\
&=
\sum_{i-1}
\left[
\frac{e^{s_k-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}
\cdot \vec{v}_k
\right]+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\\
&= \sum_{i}
\left[\frac{e^{s_k-\mathrm{max_{new}}}}{\sum_{i} e^{s_j-\mathrm{max_{new}}}}\cdot \vec{v}_k\right]
\end{aligned}
$$

### B. Flash Attention

$$
\begin{aligned}
s_i &= \vec{q}\cdot\vec{k}_i\\
\mathrm{max_{new}}&=
\mathrm{max}(\mathrm{max_{prev}}, s_i)
\\
l_\mathrm{new}&=l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}\\
\vec{o}_{i} 
&= \vec{o}_{i-1}\cdot\frac{l_\mathrm{prev}}{l_\mathrm{new}}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}
\end{aligned}
$$

$$
\therefore \mathrm{Attention}(\vec{q},\bold{K},\bold{V})
=\vec{o}_{N}
$$

### C. Python Code

```python
import numpy as np

def flash_attention(Q, K, V):

    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq = len(Q)
    Nk = len(K)

    d_v = V.shape[1]

    outputs = np.zeros((Nq, d_v), dtype=np.float64)

    for qi, q in enumerate(Q):
        m = -np.inf
        l = 0.0
        o = np.zeros(d_v)

        for i in range(Nk):
            s = np.dot(K[i], q)
            m_new = max(m, s)

            l_new = l * np.exp(m - m_new) + np.exp(s - m_new)
            o = o * np.exp(m - m_new) * (l / l_new) + V[i] * (np.exp(s - m_new) / l_new)

            m = m_new
            l = l_new

        outputs[qi] = o

    return outputs
```

## 3. FlashAttenttion2: Lazy Softmax

### A. Flash Attention

$$
\begin{aligned}
s_i &= \vec{q}\cdot\vec{k}_i\\
\mathrm{max_{new}}&=
\mathrm{max}(\mathrm{max_{prev}}, s_i)
\\
l_\mathrm{new}&=l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}\\
\vec{o}_{i} 
&= \vec{o}_{i-1}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+\vec{v}_i
\cdot
e^{s_j-\mathrm{max_{new}}}
\end{aligned}
$$

$$
\therefore \mathrm{Attention}(\vec{q},\bold{K},\bold{V})
=\frac{\vec{o}_{N}}{l_\mathrm{new}}
$$

### B. Python Code

```python
import numpy as np

def flash_attention_2(Q, K, V):

    Q = np.asarray(Q, dtype=np.float64)
    K = np.asarray(K, dtype=np.float64)
    V = np.asarray(V, dtype=np.float64)

    Nq = len(Q)
    Nk = len(K)

    d_v = V.shape[1]

    outputs = np.zeros((Nq, d_v), dtype=np.float64)

    for qi, q in enumerate(Q):
        m = -np.inf
        l = 0.0
        o = np.zeros(d_v)

        for i in range(Nk):
            s = np.dot(K[i], q)
            m_new = max(m, s)

            l = l * np.exp(m - m_new) + np.exp(s - m_new)
            o = o * np.exp(m - m_new) + V[i] * np.exp(s - m_new)

            m = m_new

        outputs[qi] = o / l

    return outputs
```

## 4. Flash-D: Hidden Softmax Division

### A. Sigmoid

$$
\begin{aligned}
\sigma(x)&=\frac{1}{1+e^{-x}}
\end{aligned}
$$

### B. Flash Attention

$$
\begin{aligned}
s_i &= \vec{q}\cdot\vec{k}_i\\
\mathrm{max_{new}}&=
\mathrm{max}(\mathrm{max_{prev}}, s_i)
\\
l_\mathrm{new}&=l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}\\
\vec{o}_{i} 
&= \vec{o}_{i-1}\cdot\frac{l_\mathrm{prev}}{l_\mathrm{new}}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}
\end{aligned}
$$

### C. Flash-D: Hidden Softmax Division

$$
\begin{aligned}
l_\mathrm{new}&=l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}
\\
l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
&=
l_\mathrm{new}-e^{s_{i}-\mathrm{max_{new}}}
\end{aligned}
$$

- **Recursive Weight Computation**

$$
\begin{aligned}
\vec{o}_{i} 
&= \vec{o}_{i-1}\cdot\frac{l_\mathrm{prev}}{l_\mathrm{new}}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}\\
&=\vec{o}_{i-1}\cdot\frac{l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}}{l_\mathrm{new}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}\\
&=\vec{o}_{i-1}\cdot\frac{l_\mathrm{new}-e^{s_{i}-\mathrm{max_{new}}}}{l_\mathrm{new}}
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}\\
&=\vec{o}_{i-1}\cdot
\left[
1-\frac{e^{s_{i}-\mathrm{max_{new}}}}{l_\mathrm{new}}
\right]
+\vec{v}_i
\cdot
\frac{e^{s_j-\mathrm{max_{new}}}}{l_\mathrm{new}}\\
\end{aligned}
$$

$$
\begin{aligned}
w_i&=\frac{e^{s_{i}-\mathrm{max_{new}}}}{l_\mathrm{new}}
\end{aligned}
$$

$$
\begin{aligned}
\vec{o}_{i} 
&=\vec{o}_{i-1}\cdot
\left[
1-w_i
\right]
+\vec{v}_i
\cdot
w_i\\
\end{aligned}
$$

- **Weight Computation with Sigmoid Function**

$$
\begin{aligned}
l_\mathrm{new}&=\frac{e^{s_{i}-\mathrm{max_{new}}}}{w_i}\\
l_\mathrm{prev}&=\frac{e^{s_{i-1}-\mathrm{max_{prev}}}}{w_{i-1}}
\end{aligned}
$$

$$
\begin{aligned}
l_\mathrm{new}&=l_\mathrm{prev}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}
\\
\frac{e^{s_{i}-\mathrm{max_{new}}}}{w_i}
&=
\frac{e^{s_{i-1}-\mathrm{max_{prev}}}}{w_{i-1}}\cdot
e^{\mathrm{max_{prev}}-\mathrm{max_{new}}}
+e^{s_{i}-\mathrm{max_{new}}}\\
\frac{e^{s_{i}-\mathrm{max_{new}}}}{w_i}
&=
\frac{e^{s_{i-1}-\mathrm{max_{new}}}}{w_{i-1}}+e^{s_{i}-\mathrm{max_{new}}}\\
\frac{e^{s_{i}}}{w_i}
&=
\frac{e^{s_{i-1}}}{w_{i-1}}+e^{s_{i}}\\
\frac{1}{w_i}
&=
\frac{e^{s_{i-1}-s_{i}}}{w_{i-1}}+1
\end{aligned}
$$

$$
\begin{aligned}
w_i&=\frac{w_{i-1}}{e^{s_{i-1}-s_{i}}+w_{i-1}}\\
&=\frac{e^{\ln(w_{i-1})}}{e^{s_{i-1}-s_{i}}+e^{\ln(w_{i-1})}}\\
&=\frac{1}{e^{s_{i-1}-s_{i}-\ln(w_{i-1})}+1}\\
&=\frac{1}{1+e^{-(s_{i}-s_{i-1}+\ln(w_{i-1}))}}\\
&=\sigma(s_{i}-s_{i-1}+\ln(w_{i-1}))
\end{aligned}
$$

- **Flash-D**

$$
\begin{aligned}
s_i &= \vec{q}\cdot\vec{k}_i\\
w_i&=\sigma(s_{i}-s_{i-1}+\ln(w_{i-1}))\\
\vec{o}_{i} 
&=\vec{o}_{i-1}\cdot
\left[
1-w_i
\right]
+\vec{v}_i
\cdot
w_i\\
\end{aligned}
$$

$$
\therefore \mathrm{Attention}(\vec{q},\bold{K},\bold{V})
=\vec{o}_{N}
$$

### D. Python Code

```python
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
```