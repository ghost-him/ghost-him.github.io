#import "../../index.typ": template, tufted
#show: template.with(title: "快速求组合数")

组合是数学的重要概念之一。从 $n$ 个不同元素中每次取出 $m$ 个不同元素 $\( 0 lt.eq m lt.eq n \)$~，不管其顺序合成一组，称为从 $n$ 个元素中不重复地选取 $m$ 个元素的一个组合。所有这样的组合的种数称为组合数。

本文将通过动态规划的思维和数学方法来求解组合数。

= 方法一：动态规划
适用数据范围：`c[i][j]`，`i < 2000 且 j < 2000`

通过公式 $ C_n^m = C_(n - 1)^(m - 1) + C_(n - 1)^m $ 可知，求一个组合数时，只需要知道之前的两个组合数，再通过相加即可得出。

我们要理解这个公式，可以既可以通过数学公式推导，可以通过算法中动态规划的思维来理解。在高中的时候，老师已经讲过这个公式的数学推导了，所以这里就不赘述了。

这里讲一下动态规划的思维。

这个动态规划的思维是#strong[01 背包]模型。我们设变量 `C[i][j]` 表示的是第下标是 i，上标是 j 的组合数，即 $C_i^j$ 。即，这个变量表示的是在 i 个物品中选 j 个物品的方案数。我们在选第 j 个物品时，有两种方案：

+ 第一种是#strong[选]第 j 个物品。
+ 第二种是#strong[不选]第 j 个物品。

我们先看第一种情况：如果选了第 j 个物品，那么当前的状态就是在 i 个物品中选了 j 个物品。同时，由于这个状态是从上一个状态转移过来的。只有当上一个状态是选了 j - 1 个物品时，加上当前的物品，才可以是当前的这个状态。因此，上一个状态就是#strong[在 i - 1 个物品中选了 j - 1 个物品]的方案，即 `c[i - 1][j - 1]`。

我们再来看第二种情况：如果我们不选这个物品。那就说明当前的状态选的物品的个数和上一个状态选的物品的个数一致。因此，上一个状态就是#strong[在 i - 1 个物品中选 j 个物品]的方案，即 `c[i - 1][j]`。

由于求的是方案的#strong[个数]（组合数的定义），所以#strong[当前的状态等于转移的状态之和]。即 `c[i][j] = c[i - 1][j - 1] + c[i - 1][j]` 。

题目链接：#link("https://www.acwing.com/problem/content/887/")[AcWing 885. 求组合数 I]

我们来看一下代码的写法

```cpp
#include <iostream>
#include <cstring>

using namespace std;

const int N = 2010, mod = 1e9 + 7;

// 询问的个数
int n;
// c[i][j] 表示的值
int c[N][N];

int main () {
    // 根据题目中询问的数据的范围，预处理一下c[i][j]的值
    for (int i = 0; i <= 2000; i ++) {
        for (int j = 0; j <= i; j ++) {
            // c[i][0] = 1
            if (j == 0) c[i][j] = 1;
            else {
                // 根据公式写
                c[i][j] = (c[i - 1][j] + c[i - 1][j - 1]) % mod;
            }
        }
    }
    // 读取询问的次数
    cin >> n;
    for (int i = 0; i < n; i ++) {
        // 读取每次查询的 下标a 和 上标j
        int a, b;
        scanf("%d%d", &a, &b);
        // 输出c[a][b]的值
        printf("%d\n", c[a][b]);
    }
    
    return 0;
}
```

= 方法二：数学公式
适用数据范围：`c[i][j]`，`i < 10000 且 j < 10000`

通过公式 $ C_n^m = P_n^m / P_n = frac(n !, m ! \( n - m \) !) $ 可知如果想要求一个组合数，只需要通过阶乘运算就可以得出。

当我们要算的数字很小的时候，我们可以通过直接除法的方式来直接求出一个组合数。但是，在取余的环境下，我们不可以直接用除法。此时，如果我们需要乘以一个数，我们可以乘以这个数的#strong[逆元]。

假设 $A$ 的逆元是 $a$，那么 $ C / A #h(0em) mod med p equiv C * a #h(0em) mod med p $ #strong[通过逆元，我们可以将除法变成乘法]。

设一个 `fact[i]` 表示 $i !$ ；`infact[i]` 表示 $i !$ 的逆元；`c[i][j]` 表示 $C_i^j$。那么 `c[i][j] = fact[i] * infact[j] * fact[n - m]`。

在这里，如何计算一个逆元的值呢？

通过费马小定理，我们可以知道，如果 p 是一个质数，而整数 a 不是 p 的倍数，那么 $ a^(p - 1) equiv 1 #h(0em) mod med p $

因此， $ C / A #h(0em) mod med p equiv C * a #h(0em) mod med p $ $ 1 equiv a * A #h(0em) mod med p $ $ A^(p - 1) equiv a * A #h(0em) mod med p $ $ A^(p - 2) equiv a #h(0em) mod med p $ 所以，当 p 和 A 互质的时候，A 的逆元就是 $A^(p - 2)$。

我们来看代码的写法。

题目：#link("https://www.acwing.com/problem/content/888/")[AcWing 886. 求组合数 II]

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010, mod = 1e9 + 7;

// 要用long long 类型，所以为了少写字母，将long long 定义成LL
typedef long long LL;
// i! 的值和 i! 的逆元
int fact[N], infact[N];

// 快速幂模板，计算A的逆元
LL qmi(LL a, LL b, LL q) {
    LL res = 1;
    while (b) {
        if (b & 1) {
            res = res * a % q;
        }
        a = a * a % mod;
        b >>= 1;
    }
    return res;
}

int main () {
    // 初始化, 0! = 1, 0!的逆元也是1
    fact[0] = infact[0] = 1;
    // 求i!的值和其逆元。
    for (int i = 1; i < N; i ++) {
        // 根据 (i - 1)! 计算 i! 的值
        fact[i] = (LL) fact[i - 1] * i % mod;
        // 根据 (i - 1)! 逆元的值计算 i! 逆元的值
        infact[i] = (LL)infact[i - 1] * qmi(i, mod - 2, mod) % mod;
    }
    
    int n;
    scanf("%d", &n);
    while (n --) {
        int a, b;
        scanf("%d%d", &a, &b);
        // 输出公式
        printf("%d\n", (LL)fact[a] * infact[b] % mod * infact[a - b] % mod);
    }
    return 0;
}
```
