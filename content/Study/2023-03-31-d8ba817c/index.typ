#import "../../index.typ": template, tufted
#show: template.with(title: "基础博弈论")

本文介绍了 #strong[公平组合游戏] 和 #strong[有向图游戏] 两种博弈论算法。当做我的一个笔记，防止以后遗忘，方便复习时回想。附带一个完整的数学证明过程。

= 公平组合游戏 ICG
如果一个游戏满足：

+ 两个玩家交替行动
+ 在游戏的任意时刻，可以执行的合法行动与轮到哪名玩家无关
+ 不可以行动的玩家判负

== NIM 游戏
题目：#link("https://www.acwing.com/problem/content/893/")[AcWing 891. Nim 游戏]

#quote(block: true)[
给定~n~堆石子，两位玩家轮流操作，每次操作可以从任意一堆石子中拿走任意数量的石子（可以拿完，但不能不拿），最后无法进行操作的人视为失败。

问如果两人都采用最优策略，先手是否必胜。
]

=== 思路有 n 堆石子：$a_1 \, a_2 \, dots.h.c \, a_n$ 。如果异或为 0，那么就是先手必败。如果不为 0，那么先手必胜。
最终状态：0 ^ 0 ^ 0 ^ … ^ 0 = 0，所以先手必败。 证：如果当前的状态的异或和不为 0 ，那么一定可以通过某个方式，使得异或和为 0。

设 $a_1 and a_2 and dots.h.c and a_n = x eq.not 0$ ，x 的二进行表示中最高的一位 1 在第 k 位。所以在 $a_1$ \~ $a_n$ 中一定存在一个数 $a_i$，$a_i$ 的第 k 位是 1 。$a_i and x < a_i$，所以可以在 $a_i$ 这堆石子中拿走 $a_i - \( a i and x \)$ 这么多个石子。此时，$a_i$ 还剩下 $a_i - \( a_i - \( a i and x \) \) = a_i and x$ 。所以原式等于 $a_1 and a_2 and dots.h.c and a_i and x and a_(i + 1) and dots.h.c and a_n = x and x = 0$

若 $a_1 and a_2 and dots.h.c and a_n = 0$ 。反证，设从 $a'_i$ 中拿，使得原式为 0。则 $a_1 and a_2 and dots.h.c and a'_i and dots.h.c and a_n = 0$ 。此时 $a_i = a'_i$。所以不存在一个方法，使得拿完以后，原式的异或值是 0。

因此，如果异或不为 0 的时候，先手拿完以后一定可以使其变成 0，此时，后手拿的时候就是 0，后手拿完以后，先手又不是 0。所有不是 0 的局面都是先手拿的，是 0 的局面都是后手拿的。所以全 0 的状态一定会被后手拿到，先手必胜。反之亦然。

=== 例子
设有两堆石子，2 和 3。那么先手只需要在第 2 堆里先拿一个，使之变成 2，2。那么后手无论拿多少，先手只需要从另一堆拿出一样数量的石子即可。因此，无论怎样，后手一定会先遇到 0，0 这个状态，因此后手必输。

=== 先手必胜与必败状态
如果当前的状态可以转换到先手必败状态，那么当前的就是先手必胜状态。 如果当前的状态无论怎么转换，都是先手必胜状态，那么当前的状态就是先手必败状态。

本题中，最终必败状态为：0，0。

=== 代码 ：
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

// 总共会有n个数字
int n;

int main () {
    int res = 0;
    cin >> n;
    // 读取n个数字
    for (int i = 0; i < n; i ++) {
        int x;
        scanf("%d", &x);
        // 异或
        res = res ^ x;
    }
    // 如果结果不为0，那么就是先手必胜，否则就是选手必败
    if (res) cout << "Yes" << endl;
    else cout << "No" << endl;
    
    return 0;
}
```

= 有向图游戏
给定一个有向无环图，图中有一个唯一的起点，在起点上有一个棋子，玩家要交替的将这个棋子沿着边移动，每次可以移动一步。如果不可以移动了，则判负。

任何一个公平组合游戏都可以转换为一个有向图游戏。转换的方法是：把当前的局面看成一个点，把当前局面的合法行动看成连接下一个点的有向边。

== Mex 运算
设 S 表示一个非负整数集合。定义 mex(S) 为求出不属于集合 S 的最小非负整数的运算。即，mex (S) = min(x)，且 x 不属于 S。

例：集合：{$1 \, 2 \, 3$} ，则 mex (S) = 0 。

== SG 函数
在有向图游戏中，对于每个节点 x，设从 x 出发共有 k 条有向边，分别到达 y1, y2 … Yn。定义 SG(x)为 x 的后继节点 y1, y2 … Yn 的 SG 函数值构成的集合再执行 mex (S)运算的结果。即，SG(x) = mex ({SG(y1), SG(y2) , … , SG(yn)})。

== 结论
任何一个非 0 状态 (SG(x) != 0) 都可以到 0，任何一个 0 状态都到不了 0。终点是 0。

对于单个图，如果 SG (x) 等于 0，那么就必败，如果不是 0 ，那么就必胜。 如果有多个图，那么将所有图的 SG 值异或起来，如果为 0，则为必败，如果不为 0，则为必胜。

该结论证明方法与 NIM 游戏的证明方法类似。

== NIM 游戏-集合
题目：#link("https://www.acwing.com/problem/content/895/")[AcWing 893. 集合-Nim 游戏]

#quote(block: true)[
给定~n~堆石子以及一个由~k~个不同正整数构成的数字集合~S。

现在有两位玩家轮流操作，每次操作可以从任意一堆石子中拿取石子，每次拿取的石子数量必须包含于集合~S，最后无法进行操作的人视为失败。

问如果两人都采用最优策略，先手是否必胜。
]

=== 代码 ：
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <set>

using namespace std;

const int N = 110, M = 10010;

int n, m;
// s表示可供选择的集合，f存储的是所有可能出现过的情况的sg值 
int s[N], f[M];

int sg(int x) {
    // 如果当前的sg的值已经求过了，则直接返回 
    if (f[x] != -1) return f[x];
    // set来去重 
    set<int> S;
    for (int i = 0; i < m; i ++) {
        // 如果当前可以通过s[i]到达下一个状态，则获取下一个状态的值
        if (x >= s[i]) S.insert(sg(x - s[i]));
    }
    // 查看sg的值
    for (int i = 0; ;i ++) {
        if (!S.count(i)) {
            return f[x] = i;
        }
    }
    
}

int main () {
    cin >> m;
    for (int i = 0; i < m; i ++) scanf("%d", &s[i]);
    
    cin >> n;
    // 初始化sg的值
    memset(f, -1, sizeof f);
    int res = 0;
    for (int i = 0; i < n; i ++) {
        int x;
        cin >> x;
        // 如果有多个图，那么就是多个图的sg的异或
        res ^= sg(x);
    }
    // 如果结果是0，那么先手必败，否则先手必胜
    if (res) cout << "Yes" << endl;
    else cout << "No" << endl;
    
    
    return 0;
}
```
