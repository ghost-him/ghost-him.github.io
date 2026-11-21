#import "../../index.typ": template, tufted
#show: template.with(title: "有向图的强连通分量")

= 定义
对于一个有向图，连通分量：对于分量中的任意两点 U, V，必然可以从 u 走到 v，同时也可以从 v 走到 u。

强连通分量：极大的连通分量。极大：若在一个连通分量中，加上了任意一个点以后，都不构成连通分量，此时这个连通分量为极大连通分量。

= 代码中的作用
可以使用缩点的方式，将一个有向图转换为一个有向无环图（拓扑图）。缩点：将一个连通分量缩成一个点。此时，如果要求最短路或最长路时，可以使用递推的方式来求，时间复杂度为 $O \( n + m \)$。

= 算法思路
使用 DFS 的思路。将一个点分成 4 大类。

+ 树枝边 `(x, y)`，x 为 y 的一个父结点。
+ 前向边 `(x, y)`，x 为 y 的一个祖先结点。
+ 后向边 `(x, y)`，在 dfs 回溯时，x 是 y 的一个祖先结点。（在正向搜索时，y 是 x 的一个祖先结点）
+ 横叉边 `(x, y)`，从当前的点 x 向其它已经搜索过的分支上的点 y 搜索时的边。

判断一个点是不是在强连通分量中：

+ 存在后向边指向祖先结点
+ 先走到横叉边，再通过横叉边走到祖先结点。

== Tarjan 算法求强连通分量
对每个点定义两个时间戳：`dfn[u]` 表示遍历到 u 的时间戳。`low[u]` 表示从 u 开始走，所能遍历到的最小时间戳是什么。u 是其所在的强联通分量的最高点，等价于 `dfn[u] == low[u]`。

Tarjan 算法的通用模板，求强连通分量。

```cpp

// 栈中存的点是当前还没有搜完的强连通分量的点
stack<int> stk;
// st[i]表示i这个点是否在栈中
bool st[N];
int dfn[N], low[N], timestamp;
int id[N];  // 表示i这个点所在的强连通分量的编号

void tarjan(int u) {
    // 获取当前点的时间戳 
    dfn[u] = low[u] = ++ timestamp;
    // 将当前的点入栈
    stk.push(u);
    st[u] = true;
    // 遍历所有的邻边
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        // 如果当前的点没有被遍历过
        if (!dfn[j]) {
            // 遍历当前的点 
            tarjan(j);
            // 更新一下low[u] 
            low[u] = min(low[u], low[j]);
        }
        else if(st[j]) {
            // 如果当前的点还在栈中
            low[u] = min(low[u], dfn[j]);
        }
    }
    // 如果当前的点是最高点
    if (dfn[u] == low[u]) {
        int y;
        // 强连通分量的数量加一
        ++ scc_cnt;
        do {
            y = stk.top();
            stk.pop();
            st[y] = false;
            // 设置当前点所在的强连通分量
            id[y] = scc_cnt;
        } while(y != u);
        // 退出循环时，表明已经遍历完了所有的点
    }
}
```

一般来说，求出强连通分量以后，还要进行：

+ 缩点：遍历所有的点，如果 i 与 j 不在同一个 scc 中，则添加从 `id(i)` 指向 `id(j)` 的一条边。此时就可以把缩点以后的图建出来。强连通分量编号递减的顺序一定是拓扑序。

= 例题
#link("https://www.acwing.com/problem/content/1176/")[受欢迎的牛]

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 10010, M = 50010;

int n ,m;
int h[N], e[M], ne[M], idx;
int dfn[N], low[N], timestamp;
int stk[N], top;
bool in_stk[N];
// 每个点所在的强连通分量的编号，连通分量的编号，连通分量的编号 
int id[N], scc_cnt, siz[N];
// 出度 
int dout[N];

void add(int a, int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
}

void tarjan(int u) {
    // 获取当前点的时间戳 
    dfn[u] = low[u] = ++ timestamp;
    // 将当前的点入栈 
    stk[++ top] = u, in_stk[u] = true;
    // 遍历所有的邻边 
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        // 如果当前的点没有被遍历过 
        if (!dfn[j]) {
            // 遍历当前的点 
            tarjan(j);
            // 更新一下low[u] 
            low[u] = min(low[u], low[j]);
        } else if (in_stk[j]) {
            // 如果当前的点在栈中,那么就更新一下low值
            low[u] = min(low[u], dfn[j]); 
        }
    }
    // 如果当前的点可以遍历到的最上面的点就是自己，那么当前的虚就是所在的连通分量的最上面的那个点 
    if (dfn[u] == low[u]) {
        // 更新一下连通分量的编号
        ++ scc_cnt; 
        // 找到当前连通分量里所有的点
        int y;
        do {
            y = stk[top --];
            in_stk[y] = false;
            
            id[y] = scc_cnt;
            siz[scc_cnt] ++;
        } while (y != u);
    }
    
    
}


int main () {
    scanf("%d%d", &n, &m);
    memset(h, -1, sizeof h);
    while (m --) {
        int a, b;
        scanf("%d%d", &a, &b);
        add(a, b);
    }
    
    for (int i = 1; i <= n; i ++) {
        if (!dfn[i]) {
            tarjan(i);
        }
    
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = h[i]; ~j; j = ne[j]) {
            int k = e[j];
            int a = id[i], b = id[k];
            if (a != b) {
                // 如果a和b不在同一个连通分量时
                // 出度++ 
                dout[a] ++; 
            }
        }
    }
    
    int zeros = 0, sum = 0;
    for (int i = 1; i <= scc_cnt; i ++) {
        if (!dout[i]) {
            zeros ++;
            sum += siz[i];
            if (zeros > 1) {
                sum = 0;
                break;
            }
        }
    }
    
    cout << sum << endl;
    
    
    return 0;
}
```
