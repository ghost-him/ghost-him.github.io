#import "../../index.typ": template, tufted
#show: template.with(title: "第十四届蓝桥杯大赛软件赛省赛-试题 B---01 串的熵 解题思路+完整代码")

= 问题描述
对于一个长度为 n 的 01 串 $S = x_1 x_2 x_3 . . . x_n$，香农信息熵的定义为 $H \( S \) = - sum_1^n p \( x_i \) l o g_2 \( p \( x_i \) \)$，其中 $p \( 0 \)$, p $\( 1 \)$ 表示在这个 $01$ 串中 $0$ 和 $1$ 出现的占比。比如，对于 $S = 100$ 来说，信息熵 $H \( S \) = - 1 / 3 l o g_2 \( 1 / 3 \) - 2 / 3 l o g_2 \( 2 / 3 \) - 2 / 3 l o g_2 \( 2 / 3 \) = 1.3083$。对于一个长度为 $23333333$ 的 $01$ 串，如果其信息熵为 $11625907.5798$，且 $0$ 出现次数比 $1$ 少，那么这个 $01$ 串中 $0$ 出现了多少次？

= 思路
我们先来看这个 $h \( s \)$ 的定义，然后先把 $h \( s \)$ 这个函数写出来。

我们看这个 $100$ 的例子：一共有 1 个 1，2 个 0，$h \( s \)$ 也是由 1 个 $- 1 / 3 l o g_2 \( 1 / 3 \)$ 和 2 个 $- 2 / 3 l o g_2 \( 2 / 3 \)$ 构成，再根据公式，我们可以推测：如果有 n 个 0，m 个 1，那么 $h \( s \)$ 应该是由 n 个 $p \( 0 \) l o g_2 \( p \( 0 \) \)$ 构成，同时，由 m 个 $p \( 1 \) l o g_2 \( p \( 1 \) \)$ 构成。$p \( 0 \)$ 表示 0 出现的占比，$p \( 0 \) = frac(n, n + m)$ ，$p \( 1 \) = frac(m, n + m)$。所以我们可以设一个函数，用来求解 $h \( s \)$。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int gcd(int a, int b) {
    return b ? gcd(b, a % b) : a;
}

// p0 表示 '0' 出现的次数；p1表示 '1' 出现的次数
double h(int p0, int p1) {
    // 需要将 3/6 化简成 1/2 这样的形式，简化运算的时间
    // 将分子和分母共同除以它们的最大公因数即可。
    int t0 = p0, t1 = p1;
    // 获取最大公因数
    int t = gcd(t0, t1);
    // 化简
    t0 /= t, t1 /= t;
    // 获取总数
    double t2 = t0 + t1;
    // 返回的答案
    double res = 0;
    // 套入公式
    res -= p0 * (t0 / t2) * (log2(t0) - log2(t2));
    res -= p1 * (t1 / t2) * (log2(t1) - log2(t2));
    return res;
}

int main () {
    // 100 由 2个0 和 1个1 组成，代入函数以验证函数的正确性
    cout << h(2, 1) << endl;
    
    return 0;
}
```

可得运行结果：

```
1.30827
```

与题目中的结果一致，说明我们写的代码是正确的。

接下来我们就应该来求这个题目的答案了。

我们先来看看这个函数的性质：我们多求几组数字。我们以长度为 10 的所有 01 串来看：

```cpp
int main () {
    cout << h(9, 1) << endl;
    cout << h(8, 2) << endl;
    cout << h(7, 3) << endl;
    cout << h(6, 4) << endl;
    cout << h(5, 5) << endl;
    cout << h(4, 6) << endl;
    cout << h(3, 7) << endl;
    cout << h(2, 8) << endl;
    cout << h(1, 9) << endl;
    return 0;
}
```

可得运行结果：

```
1.56342
2.98911
4.08468
4.76816
5
4.76816
4.08468
2.98911
1.56342
```

我们可以发现：

+ $h \( s \)$ 关于 5 对称
+ 在对称轴的一侧，$h \( s \)$ 的值#strong[单调]

由于题目中说明：`且 0 出现次数比 1 少` ，所以，0 的个数一定小于总数的一半，所以 #strong[0 的数量越多，熵越大]。我们知道了这个性质以后，可以采用二分的方法，将 0 的数量二分出来。

```cpp
int main () {
    // 0 的数量最小是 1， 最大是 (23333333 + 1) / 2 （总数的一半）
    int l = 1, r = (23333333 + 1) / 2;
    while (l < r) {
        // 获取当前判断的 0 的数量
        int mid = l + r >> 1;
        // 如果熵大于目标值，说明 0 的数量太多了，要减小 0 的数量
        // 如果熵小于目标值，说明 0 的数量太少了，要增加 0 的数量
        if (h(mid, 23333333 - mid) > 11625907.5798) r = mid; // 减少 0
        else l = mid + 1; // 增加 0
    }
    cout << l << endl;
    return 0;
}
```

可得：

```
11027421
```

然后我们再验证一下这个结果：

```cpp
int main () {
    printf("%.10lf", h(11027421, 23333333 - 11027421));
    return 0;
}
```

得结果：

```
11625907.5798144601
```

正确

= 答案
```
11027421
```

= 完整的代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int gcd(int a, int b) {
    return b ? gcd(b, a % b) : a;
}

double h(int p0, int p1) {
    int t0 = p0, t1 = p1;
    int t = gcd(t0, t1);
    t0 /= t, t1 /= t;
    double t2 = t0 + t1;
    double res = 0;
    
    res -= p0 * (t0 / t2) * (log2(t0) - log2(t2));
    res -= p1 * (t1 / t2) * (log2(t1) - log2(t2));
    return res;
}

int main () {
    int l = 1, r = (23333333 + 1) / 2;
    while (l < r) {
        int mid = l + r >> 1;
        if (h(mid, 23333333 - mid) > 11625907.5798) r = mid;
        else l = mid + 1;
    }
    cout << l << endl;
    return 0;
}
```
