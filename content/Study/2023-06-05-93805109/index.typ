#import "../../index.typ": template, tufted
#show: template.with(title: "中位数模型")

= 模型介绍
给定一个数轴，数轴上有 $n$ 个点。求一个点 $x$ 使得所有的点到这个点的距离之和最小。

= 公式
$ d i s t a n c e = \| a_1 - x \| + \| a_2 - x \| + . . . + \| a_n - x \| $

= 公式证明
已知绝对值不等式 $\| x - a \| + \| x - b \| gt.eq \| a - b \|$ 可知，如果点 x 在 a 和 b 之外，那么 x 和 a 与 b 的距离之和一定大于 a 到 b 的距离。因此，将 x 放在 a 和 b 之间时，x 到 a 和 b 的距离之和正好等于 a 与 b 的长度。

将这个结论推广到 n 个数：将这些数两两分组，第 $i$ 个数与第 $n - i + 1$ \$个数为一组。可得公式: $ d i s t a n c e = \( \| a_1 - x \| + \| a_n - x \| \) + \( \| a_2 - x \| + \| a_(n - 1) - x \| \) + . . . gt.eq \| a_n - a_1 \| + \| a_(n - 1) - a_2 \| + . . . $ 可得，如果要让第一个等号成立，那么要让 x 取在 $a_1$ 和 $a_n$ 之间，如果要让第二个等号成立，那么要让 x 取在 $a_2$ 和 $a_(n - 1)$ 之间；以此类推，如果 n 是奇数，那么 x 取到 a 的中位数的位置即可；如果 n 是偶数，那么只需要让 x 取到中间一组的两个数之间。此时这个不等式可以最小。

= 例题
== 模版题
#link("https://www.acwing.com/activity/content/problem/content/1764/")[AcWing 104. 货仓选址]

=== 思路
参考上述公式及证明即可。

=== 代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e5 + 10;

int n;
int a[N];

int main() {
    // 读n个数
    cin >> n;
    for (int i = 0;i < n; i ++) {
        scanf("%d", &a[i]);
    }   
    // 对n个数进行排序
    sort(a, a + n);
    
    // 总长度
    int res = 0;
    for (int i = 0; i < n; i ++) {
        // 不论奇还是偶，a[n / 2]都是中位数的位置
        res += abs(a[i] - a[n / 2]);
    }
    // 输出长度
    cout << res << endl;
    return 0;
}
```

== 扩展题
#link("https://www.acwing.com/problem/content/124/")[AcWing 122. 糖果传递]

=== 思路
已经当前第 i 个孩子的糖果的数量为 $a \[ i \]$ ，那么可以设第 i 个孩子会给第 i-1 个孩子的糖果的数量为 $x \[ i \]$，同时，第 i+1 个孩子会给第 i 个孩子的糖果的数量为 $x \[ i + 1 \]$。由此可得，在最终状态下，第 i 个孩子拥有的糖果的数量为 $a \[ i \] - x \[ i \] + x \[ i + 1 \]$。

将每个孩子的最终的等式写下来可知： $ {a_1 - x_1 + x_2 = a v g\
a_2 - x_2 + x_3 = a v g\
. . .\
a_(n - 1) - x_(n - 1) + x_n = a v g\
a_n - x_n + x_1 = a v g $ 可知一共有 n 个等式，n 个变量。易知，这个等式存在多个解，可以用一个变量来表示其他的 n-1 个变量。

将等式变形如下： $ {x_1 - x_2 = x_1 - a v g\
x_2 - x_3 = a_2 - a v g\
. . .\
x_(n - 1) - x_n = a_(n - 1) - a v g\
x_n - x_1 = a_n - a v g $ 我们可以用 $x_1$ 来表示其他的 n-1 个变量，将等式化简如下： $ {x_1 & = a_1 - 0\
x_2 & = x_1 - \( \( n - 1 \) * a v g - sum_(i = 2)^n a_i \)\
 & . . .\
x_(n - 1) & = x_n + a_(n - 1) - a v g = x_1 - \( 2 * a v g - a_n - a_(n - 1) \)\
x_n & = x_1 - \( a v g - a_n \) $

可以看到每一项都是 $x_1$ 减去一个常数 c。将第 i 个 x 减去的常数设为 $c_i$。这样，题目中要求的等式 $ d i s t a n c e = sum_1^n \| x_i \| $ 可以化简为模版题的 $ d i s t a n c e = \| x_1 - c_1 \| + \| x_1 - c_2 \| + . . . + \| x_1 - c_n \| $ 即给 n 个常数 c，求一个点 x，使得这个点到其他各点的距离之和最小。

我们可以根据公式得到 $c_i$ 和 $c_(i - 1)$ 之间的关系是 $c_(i - 1) = c_i + a v g - a \[ i - 1 \]$。

=== 代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

typedef long long LL;

const int N = 1000010;

int n;
int a[N];
LL c[N];

int main() {
    cin >> n;
    for (int i =1 ; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    
    // 求平均数
    LL sum = 0;
    for (int i = 1; i <= n; i ++) {
        sum += a[i];
    }
    
    LL avg = sum / n;
    // 求c[i]
    for (int i = n; i > 1; i --) {
        c[i] = c[i + 1] + avg - a[i];
    }

    // 模版
    sort(c + 1, c + 1 + n);
    
    // 模版
    LL res = 0;
    for (int i = 1; i <= n; i ++) {
        // 这里的c[i]的下标是从1开始的，所以这里要减c[(n + 1) / 2]
        res += abs(c[i] - c[(n + 1) / 2]);
    }
    
    cout << res << endl;
    
        
    return 0;
}
```
