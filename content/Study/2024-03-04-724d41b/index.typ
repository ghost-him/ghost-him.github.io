#import "../../index.typ": template, tufted
#show: template.with(title: "数论模板")

模板算法

求 m^k mod p，时间复杂度 O(logk)。

```cpp
int qmi(int m, int k, int p)
{
    int res = 1 % p, t = m;
    while (k)
    {
        if (k & 1) res = res * t % p;
        t = t * t % p;
        k >>= 1;
    }
    return res;
}
```

计算 $⌈m \/ n⌉$ ：

```cpp
    int ans = (m + n - 1) / n;
```
