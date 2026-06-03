# 수식 렌더링 데모

인라인 수식: 질량-에너지 등가식 $E = mc^2$ 그리고 오일러 항등식 $e^{i\pi} + 1 = 0$.

## 디스플레이 수식

가우스 적분:

$$\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}$$

이차방정식의 근:

$$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

## 행렬과 합

$$
A = \begin{pmatrix} a & b \\ c & d \end{pmatrix}
\qquad
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$

## 코드와 섞기

```python
import math
def gaussian(x):
    return math.exp(-x**2)
```

수식 $\sigma^2 = \frac{1}{n}\sum_{i=1}^{n}(x_i - \mu)^2$ 은 분산입니다.
