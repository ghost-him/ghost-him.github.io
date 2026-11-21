#import "../../index.typ": template, tufted
#show: template.with(title: "背包问题")

展示常见的背包问题：01背包，完全背包，分组背包，多重背包。

= 01 背包
题目的内容：#link("https://www.acwing.com/problem/content/2/")[链接]

== 思路
开一个二维数组：`f[i][j]`，表示：前 i 个物品中，容量为 j 的总价值。而 01 背包则是一个物品有且仅有一个，即要么拿 1 个，要么就不拿。所以可以得到以下的状态转移方程：

- 不拿该物品，则容量没有变：`f[i][j] = f[i - 1][j]`；

- 如果拿了该物品，则从容量为 `j - v[i]` 的状态转移过来：`f[i][j] = f[i - 1][j - v[i]] + w[i]`；

  == 代码
  <代码>

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int v[N], w[N];
int f[N][N];

int main () {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d", &v[i], &w[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 0; j <= m; j ++) {
            // 不拿东西
            f[i][j] = f[i - 1][j];
            // 拿东西
            if (j - v[i] >= 0)
                f[i][j] = max(f[i][j], f[i - 1][j - v[i]] + w[i]);
        }
    }
    
    cout << f[n][m] << endl;
    
    return 0;
}
```

== 01 背包问题优化
对 01 背包问题的优化，就是对原代码做一个等价变形。

定义：`f[j]`：N 个物品，在背包容量为 j 时的最优解。

此时，状态转换方程为：`f[j] = max(f[j], f[j - v[i]] + w[i])`

=== 上面代码的等价变形
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int v[N], w[N];
int f[N];

int main () {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d", &v[i], &w[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = m; j >= v[i]; j --) {
            f[j] = max(f[j], f[j - v[i]] + w[i]);
        }
    }
    
    cout << f[m] << endl;
    
    return 0;
}
```

= 完全背包
题目的内容：#link("https://www.acwing.com/problem/content/3/")[链接]

与 01 背包的区别：01 背包的物品只有 1 个，而完全背包的物品则有无限个。

== 朴素法
定义 `f[i][j]`：前 i 个物品，容量为 j 的背包的最优解（价值最大）。

设拿 k 个物品 i，则 `f[i][j] = f[i - 1][j - k * v[i]] + k * w[i]`；而 k 可以取到从 0 到 `j / v[i]`。所以 `f[i][j]` 为这些集合的最大值（题目中求的是最大价值）。

所以状态转移的关系如下：

`f[i][j] = max(f[i - 1][j], f[i - 1][j - v] + w, f[i - 1][j - v * 2] + w * 2, ..., f[i - 1][j - v * k] + w * k, ...)`；

== 代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int w[N], v[N];
int f[N][N];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d", &v[i], &w[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 0; j <= m; j ++) {
            // 一个也不拿
            f[i][j] = f[i - 1][j];
            // 拿了1个及以上
            for (int k = 1; j - k * v[i] >= 0; k ++) {
                f[i][j] = max(f[i][j], f[i - 1][j - k * v[i]] + k * w[i]);
            }
        }
    }
    
    cout << f[n][m] << endl;
    
    return 0;
}
```

易知，该代码的时间复杂度为 `O(n^3)`，会超时。

== 优化思路
为代码做等价变形。

由以下状态转换知

`f[i][j] = max(f[i - 1][j], f[i - 1][j - v] + w, f[i - 1][j - v * 2] + w * 2, ..., f[i - 1][j - v * k] + w * k, ...)`；

`f[i][j - v] = max(f[i - 1][j - v], f[i - 1][j - v - v] + w, f[i - 1][j - v - v * 2] + w * 2, ..., f[i - 1][j - v - v * k] + w * k, ...)`；

所以 `f[i][j] = max(f[i - 1][j], f[i][j - v] + w)`；这里之所以可以使用 `f[i][j - v]` 来代替后面一坨，是因为他们的结尾是一样的，都是直到 `j < v * k` 结束。所以可以得出以下代码

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int w[N], v[N];
int f[N][N];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d", &v[i], &w[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 0; j <= m; j ++) {
            // 一个也不拿
            f[i][j] = f[i - 1][j];
            // 拿了1个及以上
            if (j - v[i] >= 0)
                f[i][j] = max(f[i][j], f[i][j - v[i]] + w[i]);
        }
    }
    
    cout << f[n][m] << endl;
    
    return 0;
}
```

== 一维优化
对代码做等价变形。与 01 背包问题的区别是，在遍历背包的容量时，是从前向后遍历的。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int w[N], v[N];
int f[N];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d", &v[i], &w[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = v[i]; j <= m; j ++) {
            f[j] = max(f[j], f[j - v[i]] + w[i]);
        }
    }
    
    cout << f[m] << endl;
    
    return 0;
}
```

= 多重背包
多重背包是指，给定物品的价值，物品的体积，物品的数量，然后求一个指定容量的背包最多可以装多大价值的物品。

题目链接：#link("https://www.acwing.com/problem/content/4/")[链接]

== 思路
与完全背包的思考类似，设：`f[i][j]`：前 i 个物品中，装到容量为 j 的背包中的最大价值。

== 代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;


int n, m;
int v[N], w[N], s[N];
int f[N][N];


int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d%d%d", &v[i], &w[i], &s[i]);
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 0; j <= m; j ++) {
            for (int k = 0; k <= s[i]; k ++) {
                if (j - k * v[i] >= 0)
                    f[i][j] = max(f[i][j], f[i - 1][j - k * v[i]] + k * w[i]);
            }
        }
    }
    
    cout << f[n][m] << endl;
    
    return 0;
}
```

== 时间复杂度优化
可以使用二进制优化：#link("https://blog.csdn.net/qq_33171970/article/details/50582671")[链接]

这样就可以将原问题转为一个 01 背包的问题。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010 * 10, M = 2010;

int n, m;
int v[N], w[N], idx;
int f[N][M];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        int cnt = 1;
        while(c >= cnt) {
            v[++idx] = cnt * a;
            w[idx] = cnt * b;
            c -= cnt;
            cnt = cnt * 2;
        }
        
        if (c) {
            v[++idx] = c * a;
            w[idx] = c * b;
        }
    }
    
    for (int i = 1; i <= idx; i ++) {
        for (int j = 0; j <= m; j ++) {
            f[i][j] = f[i - 1][j];
            if (j - v[i] >= 0) {
                f[i][j] = max(f[i][j], f[i - 1][j - v[i]] + w[i]);
            }
        }
    }
    
    cout << f[idx][m] << endl;
    
    return 0;
}
```

== 空间复杂度优化
由于已经转为了 01 背包的问题，所以可以使用 01 背包的空间优化方法，可以大大节省使用的空间。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010 * 10, M = 2010;

int n, m;
int v[N], w[N], idx;
int f[M];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        int cnt = 1;
        while(c >= cnt) {
            v[++idx] = cnt * a;
            w[idx] = cnt * b;
            c -= cnt;
            cnt = cnt * 2;
        }
        
        if (c) {
            v[++idx] = c * a;
            w[idx] = c * b;
        }
    }
    
    for (int i = 1; i <= idx; i ++) {
        for (int j = m; j >= v[i]; j --) {
            f[j] = max(f[j], f[j - v[i]] + w[i]);
            
        }
    }
    
    cout << f[m] << endl;
    
    return 0;
}
```

= 分组背包
== 思路
定义 `f[i][j]`：在前 i 组中的物品中选，容量为 j 时的最大价值。

状态转移：第 i 组不选择物品：`f[i][j] = f[i - 1][j]`；第 i 组中，选择第 k 个物品：`f[i][j] = f[i - 1][j - v[i][k]] + w[i][k]`。由于是从 `f[i - 1][x]` 转换过来的，所以可以保证 `f[i][x]` 只选择了 i 组中的一个物品，而没有选择其他的物品。

== 代码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;

int n, m;
int v[N][N], w[N][N], s[N];
int f[N][N];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        cin >> s[i];
        for (int j = 1; j <= s[i]; j ++) {
            scanf("%d%d", &v[i][j], &w[i][j]);
        }
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 0; j <= m; j ++) {
            // 当前的组中，一个也不选
            f[i][j] = f[i - 1][j];
            for (int k = 1; k <= s[i]; k ++) {
                // 选择第k个物品
                if (j - v[i][k] >= 0)
                    f[i][j] = max(f[i][j], f[i - 1][j - v[i][k]] + w[i][k]);
            }
        }
    }
    cout << f[n][m] << endl;
    
    return 0;
}
```
