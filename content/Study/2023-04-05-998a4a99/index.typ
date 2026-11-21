#import "../../index.typ": template, tufted
#show: template.with(title: "最近公共祖先")

本文介绍了求最近公共祖先（lca）的三个算法。

- 向上标记法
- 倍增法
- tarjan 算法

同时，给出了倍增法和 tarjan 算法的代码表示。

#html.hr()

最近公共祖先是指在有根树中，找出某两个结点 u 和 v 最近的公共祖先，即满足 x 是 u 和 v 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）的一个结点 x。

= 向上标记法
从其中一个点，向根节点遍历，并把途经的点全部遍历。然后另一个点也开始遍历，如果走到了一个已经被遍历过的点了，那么这个点就是最近的公共祖先。

LCA 算法：

+ 如果 b 的位于 a 的下方。那么交换 a 和 b，使得在运行的过程中，a 始终位于 b 的下方。
+ 如果 a 和 b 不在同一层，那么，将 a 一直回溯，使得 a 和 b 位于同一层。
+ 如果 a 和 b 不一样，则将 a 和 b 一起回溯，直到 a 和 b 相等。这个时候，a （b） 就是 a 和 b 的公共祖先节点。

= 倍增法
倍增法可以看成是对向上标记法的一个优化，优化了查询父节点的时间。

原理：任何一个数字都可以使用二进制来表示，这里使用二进制来表示当前节点的深度。通过二进制可以将节点查找父节点的时间复杂度从 `O(n)` 降为 `O(logn)`

时间复杂度：预处理：`O(nlogn)`，查询：`O(nlogn)`

例题：#link("https://www.acwing.com/problem/content/1174/")[AcWing 1172. 祖孙询问]

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

const int N = 4e4 + 10;

int n, m;
int h[N], e[N * 2], ne[N * 2], idx;
// 当前的点到根节点的深度
int depth[N];
// 当前节点i向上跳2^j次方的以后的点
int fa[N][16];

void add(int a ,int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
}

void bfs(int u) {
    // 初始化所有节点的深度是正无穷
    memset(depth, 0x3f, sizeof depth);
    // bfs求深度
    queue<int> q;
    // 输入根节点
    q.push(u);
    // 根节点的深度是1
    depth[u] = 1;
    // 哨兵节点是深度是0.
    depth[0] = 0;
    
    while (q.size()) {
        int t = q.front();
        q.pop();
        
        // 遍历和当前节点t相邻的节点。
        for (int i = h[t]; ~i; i = ne[i]) {
            int j = e[i];
            // 如果这个节点j还没有被遍历过
            if (depth[j] > depth[t] + 1) {
                // 更新当前的节点j的深度
                depth[j] = depth[t] + 1;
                // 将这个节点j输入到队列中
                q.push(j);
                
                // 这个节点j的父节点(向上跳一次)是节点t
                fa[j][0] = t;
                // 更新节点j的所有的祖宗节点
                for (int k = 1; k <= 15; k ++) {
                    fa[j][k] = fa[fa[j][k - 1]][k - 1];
                }
            }
        }
    }
}

int lca(int a ,int b)  {
    // 如果b比a深，则相互交换
    if (depth[b] > depth[a]) return lca(b, a);
    // 如果当前a节点在b节点下方，则将a的深度和b保持一致
    for (int i = 15; i >= 0; i --) {
        // 如果a向上跳了以后还是在b的下方，则a可以跳
        if (depth[fa[a][i]] >= depth[b]) {
            a = fa[a][i];
        }
    }
    // 如果当前a和b一样了,则返回
    if (a == b) return a;
    // 如果不一样，则说明当前是同层不同树
    //     c
    //    / \
    //   a   b
    for (int i = 15; i >= 0; i --) {
        // 一起向上跳，直到一样
        if (fa[a][i] != fa[b][i]) {
            a = fa[a][i];
            b = fa[b][i];
        }
    }
    // 返回
    return fa[a][0];
}

int main () {
    memset(h, -1, sizeof h);
    int root = 0;
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        if (b == -1) root = a;
        else {
            // 无向边
            add(a, b);
            add(b, a);
        }
    }
    // 从根节点初始化这个树
    bfs(root);
    cin >> m;
    for (int i = 1; i <= m; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        // 获取a和b的公共祖宗节点
        int c = lca(a, b);
        if (c == a) cout << 1 << endl;
        else if (c == b) cout << 2 << endl;
        else cout << 0 << endl;
    }
    
    return 0;
}
```

= tarjan 算法
Tarjan 算法是一个离线求 lca 算法。离线的意思是它会先读取所有的查询，然后再运行算法，当算法运行结束的时候，答案也出来了。反之，如果是一个在线算法，那么就是会先读取一个查询然后输出一个查询。离线算法和在线算法之间的区别是#strong[是否要实时的输出结果]。

时间复杂度是 `O(n + m)`，其中，n 是点的个数，m 是询问的数量

本质是对向上标记法的一个优化。基于深度优化遍历，在遍历的过程中，把点分成三大类：

+ 已经遍历过的点，已经搜索过，且已经回溯过的点。（点及其子树已经搜完）
+ 正在搜索的点（分支）。
+ 还未搜到的点。

算法步骤如下：

+ 首先，将所有的询问都读入，然后从某个根节点开始进行深度优先搜索。
+ 在搜索过程中，给每个节点分配一个时间戳和一个追溯值，表示该节点被访问的顺序和能够到达的最小时间戳的节点。
+ 同时，使用并查集维护每个节点所属的集合，初始时每个节点为一个单独的集合。
+ 当搜索到一个节点 x 时，检查是否有与 x 有询问关系的节点 y 已经被访问过，如果是，则 y 所在的集合的根节点就是 x 和 y 的最近公共祖先。
+ 当搜索完 x 的所有子树后，将 x 和其子树中的所有节点合并到 x 的父节点所在的集合中。
+ 最后，输出所有询问的答案。

例题：

题目链接：#link("https://www.acwing.com/problem/content/description/1173/")[AcWing 1171. 距离]

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

typedef pair<int, int> PII;

const int N = 20010, M = N * 2;

int n, m;
int h[N], e[M], ne[M], w[M], idx;   // 存储图
vector<PII> query[N];               // 存储询问
int dist[N];    // 当前的点到根节点的距离
int st[N];      // 当前遍历的点的编号
int res[N];     // 第i号查询的结果
int p[N];       // 并查集

// 并查集
int find(int x) {
    if (p[x] != x) {
        p[x] = find(p[x]);
    }
    return p[x];
}

// 建图
void add(int a, int b, int c) {
    e[idx] = b, ne[idx] = h[a], w[idx] = c, h[a] = idx ++;
}

// 建立每个点到根节点的距离
void dfs(int u, int fa) {
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        if (j == fa) continue;
        dist[j] = dist[u] + w[i];
        dfs(j, u);
    }
}

// tarjan算法
void tarjan(int u) {
    // 当前的点标记为1，表明正在被遍历
    st[u] = 1;
    // 遍历相邻的点
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        // 如果当前的点还没有被遍历过
        if (!st[j]) {
            // 遍历当前的点
            tarjan(j);
            // 遍历好以及回溯了以后，将这个点添加到并查集中
            p[j] = u;
        }
    }

    // 遍历与当前的点有关的询问
    for (auto item : query[u]) {
        // 获取另一个点和询问的编号
        int y = item.first, id = item.second;
        // 如果这个点已经被遍历过了
        if (st[y] == 2) {
            // 获取两个点的公共祖宗结点
            int anc = find(y);
            // 获取距离
            res[id] = dist[u] + dist[y] - dist[anc] * 2;
        }
    }
    // 标记为2，表示已经遍历完了
    st[u] = 2;
}

int main () {
    cin >> n >> m;
    memset(h, -1, sizeof h);
    for (int i = 0; i < n - 1; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        add(a, b, c);
        add(b, a, c);
    }
    // 记读取所有的询问 
    for (int i = 1; i <= m; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        if (a != b) {
            query[a].push_back({b, i});
            query[b].push_back({a, i});
        }
    }
    // 初始化并查集
    for (int i = 1; i <= n; i ++) p[i] = i;
    // 获取当前的点到根节点的距离
    dfs(1, -1);
    // tarjan算法
    tarjan(1);
    // 输出答案
    for (int i = 1; i <= m; i ++) {
        printf("%d\n", res[i]);
    }
}
```
