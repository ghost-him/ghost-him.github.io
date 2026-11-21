#import "../../index.typ": template, tufted
#show: template.with(title: "求次小生成树算法")

= 定义
给一个带权的图，把图的所有生成树按权值从小到大排序，第二小的称为次小生成树。

有两种定义方式：第一种是排名在第二位的生成树：次小生成树的权值可以等于最小生成树。第二种是在数值上严格大于最小生成树的权值（严格次小生成树）。

= 求的方法
== 法一先求最小生成树，再枚举删去最小生成树中的边求解（删去以后在剩余的边中再求一次最小生成树）
如果使用 kruskal 算法，则时间复杂度是 $O \( m l o g_2 \( m \) + n m \)$。m 为边数，n 为点数。

=== 正确性
可以从集合的角度考虑，如果有 n 条边，那么可以将集合分成 n-1 类，第 1 类是不包含最小生成树的第 1 条边 … 第 k 类是不包含最小生成树的第 j 条边。不同的集合之间可能有交集，但是并集一定是会覆盖所有的边。所以只要求一下每个集合的最小值，再取一个 min，就可以得出总的最小值。

=== 局限
只可以求出非严格次小生成树，无法求出严格次小生成树。

== 法二
先求最小生成树，然后依次枚举非树边，然后将该边加入树中，同时从树中去掉一条边，使得最终的图仍是一棵树。则一定可以求出次小生成树。

如果最小生成树的权值是 sum，则加上新边的权重是 $w_新$ ，去掉一个树边 $w_树$，则操作一次以后的权重为 $s u m + w_新 - w_树$。如果要让这个值最小，则应该去的值尽可能的大。如果新加的边的两端是 a 和 b，则应该去的值是 a 和 b 这个环上的最大值。

这个操作可以抽象为#strong[求树上任意两点之间的极值]。可以使用 lca，动态树等方法来做。

暴力的方法：记录一下从根节点到当前结点的最大的边权即可。可以使用 $O \( n \)$ 的做法求出每个点到任意一个点的最大的距离。然后任意两个点，求出它们之间的最大的值，这个值就是 $w_树$ 的值。时间复杂度为 $O \( n^2 \)$ 。所以使用这个方法的总的时候复杂度为 $O \( m + n^2 + m l o g_2 \( m \) \)$ （枚举非树边 + 预处理+ 求最小生成树（kruskal 算法））

非严格次小生成树的解法：由于每个最小生成树都一定会存在次小生成树。所以要枚举每个非树边（在次小生成树中存在，在最小生成树中不存在的边），然后并这个边加入到树中以后，一定会形成一个环，所以要在环上去一个边。所以要去环上最大的边，这样可以使得次小生成树的权值最小。

严格次小生成树解法：和非严格次小生成树的区别：如果当前的值无法替换环上的最大的边权（当前的值与最大边权相等），则可以替换次大边权。所以在预处理的时候要处理最大边权和次大边权。

=== 正确性
定义一个操作：设 T 为图 G 的一个生成树，对于非树边 a 和非树边 b，插入边 a，并删除边 b 的操作为（+a，-b）。 如果 T+a-b 之后，仍然是一棵生成树，则称（+a，-b）是 T 的一个可行交换。 称由 T 进行一次可行变换所得到的新生成树集合称为 T 的#strong[邻集]。

定理：次小生成树一定在最小生成树的邻集中。即：一定存在一个次小生成树，使得它与最小生成树只有一个边不同。

不论是严格次小还是非严格次小都成立。

证明：反证法。假设存在一个次小生成树，使得它与最小生成树有两条边不同。

- 非严格次小生成树：将次小生成树的所有边从小到大的排序，然后遍历，找到第一个不在最小生成树中的边。此时这个边的两个端点所在的集合一定是存在某些边使之相连。同时，由于是从小到大的遍历，所以那些边的权值一定是大于当前遍历到的边。因此，将当前遍历的边加上，将那个权值大的边去掉以后，我们依然可以得到一个生成树，并且这个生成树的权值要小于之前的那个生成树。由于有两个边不同，所以把这个边改了以后，依然最小生成树不同，但权值更小了。所以把这个边换了以后，这个生成树依然与最小生成树不同，且最小生成树的值没有变大。所以只要生成树与最小生成树的边的差别大于 1 条，就一直可以做这个操作，直到只与最小生成树的差别只有一条。
- 严格次小生成树：将次小生成树的所有边从小到大的排序，然后遍历，找到第一个不在最小生成树中的边。此时这个边的两个端点所在的集合一定是存在某些边使之相连。同时，由于是从小到大的遍历，所以那些边的权值一定是#strong[大于或等于]当前遍历到的边。如果两个边相等，则，替换了以后，权值不变，次小生成树和最小生成树中不同的边少了一条；如果边大于当前的边，则将其替换以后，边权会严格降低。因此，可以通过非严格最小生成树的方法来构造一个和最小生成树只有 1 边之差的次小生成树。

=== 算法流程 ：
+ 读边
+ 使用 kruskal 算法求出最小生成树
+ 对最小生成树建图
+ 对最小生成树预处理
+ 从小到大遍历每一个非树边，然后使用 lca 求出 a 和 b 之间的最大边权和次大边权。
+ 输出结果

= 题目
链接：#link("https://www.acwing.com/problem/content/1150/")[AcWing 1148. 秘密的牛奶运输]

这里使用倍增法优化求 a 和 b 之间的最大值与次大值。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

typedef long long LL;
const int N = 100010, M = 300010, INF = 0x3f3f3f3f;

struct Edge {
    int a, b, w;
    // 表示当前的边是不是树上的点 
    bool used;
    bool operator<(const Edge& t) const {
        return w < t.w;
    }
}edge[M];

int n, m;
int p[N];
int h[N], e[M], ne[M], w[M], idx;
// 当前点的深度，向上跳2^j步的结点，向上跳2^j步中最大值和次大值 
int depth[N], fa[N][17], d1[N][17], d2[N][17];

void add(int a, int b, int c) {
    e[idx] = b, ne[idx] = h[a], w[idx] = c, h[a] = idx ++;
}

int find(int x) {
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}
// 使用kruskal算法求最小生成树 
LL kruskal() {
    for (int i = 1; i <= n; i ++) {
        p[i] = i;
    }
    
    sort(edge, edge + m );
    LL res = 0;
    for (int i = 0; i < m; i ++) {
        int a = find(edge[i].a);
        int b = find(edge[i].b);
        int w = edge[i].w;
        
        if (a != b) {
            p[a] = b;
            res += w;
            edge[i].used = true;
        }
    }
    return res;
}

// 建最小生成树的图 
void build() {
    memset(h, -1, sizeof h);
    for (int i = 0; i < m; i ++) {
        if (edge[i].used) {
            int a = edge[i].a, b = edge[i].b, w = edge[i].w;
            // 无向图 
            add(a, b, w), add(b, a, w);
        }
    }
}

// 对最小生成树预处理 
void bfs() {
    memset(depth, 0x3f, sizeof depth);
    depth[0] = 0, depth[1] = 1;
    
    queue<int> q;
    // 设1为根 
    q.push(1);
    while (q.size()) {
        int t = q.front();
        q.pop();
        
        for (int i = h[t]; ~i; i = ne[i]) {
            int j = e[i];
            // 如果当前的点没有遍历过 
            if (depth[j] > depth[t] + 1) {
                depth[j] = depth[t] + 1;
                q.push(j);
                // j的父结点是t 
                fa[j][0] = t;
                // 只有一个边，所以最大的边是当前的边，不存在次大边 
                d1[j][0] = w[i], d2[j][0] = -INF;
                for (int k = 1; k <= 16; k ++) {
                    int anc = fa[j][k - 1];
                    fa[j][k] = fa[fa[j][k - 1]][k - 1];
                    int distance[4] = {d1[j][k - 1], d2[j][k - 1], d1[anc][k - 1], d2[anc][k - 1]};
                    d1[j][k] = d2[j][k] = -INF;
                    for (int u = 0; u < 4; u ++) {
                        int d = distance[u];
                        // 更新一下跳2^k步的最大值和次大值 
                        if (d > d1[j][k]) d2[j][k] = d1[j][k], d1[j][k] = d;
                        else if (d != d1[j][k] && d > d2[j][k]) d2[j][k] = d;
                    }
                }
            }
        }
    }
}

// 返回加上一个边，减去一个边的值 
int lca(int a, int b, int w) {
    // 存放a和b之间所有的最大值和次大值的边权 
    static int distance[N * 2];
    int cnt = 0;
    if (depth[a] < depth[b]) {
        swap(a, b);
    } 
    
    for (int k = 16; k >= 0; k --) {
        // 如果a跳2^k步以后的深度比b大，则a就跳，直到a和b的深度一样 
        if (depth[fa[a][k]] >= depth[b]) {
            // 将跳之前的最大值和次大值存起来
            distance[cnt ++] = d1[a][k];
            distance[cnt ++] = d2[a][k]; 
            a = fa[a][k];
        }
    }
    // 如果a和b在同一个深度，但是不是同一个点的时候 
    if (a != b) {
        // a和b一起跳 
        for (int k = 16; k >= 0; k --) {
            if (fa[a][k] != fa[b][k]) {
                distance[cnt ++] = d1[a][k];
                distance[cnt ++] = d2[a][k];
                distance[cnt ++] = d1[b][k];
                distance[cnt ++] = d2[b][k];
                a = fa[a][k];
                b = fa[b][k];
            }
        }
        // 此时a和b到lca下同一层，所以还要各跳1步 
        distance[cnt ++] = d1[a][0];
        distance[cnt ++] = d1[b][0];
    }
    // 求a和b之间的最大值和次大值 
    int dist1 = -INF, dist2 = -INF;
    for (int i = 0; i < cnt; i ++) {
        int d = distance[i];
        if (d > dist1) dist2 = dist1, dist1 = d;
        else if (d != dist1 && d > dist2) {
            dist2 = d;
        }
    }
    // 当w大于最大值，则替换最大值 
    if (w > dist1) return w - dist1;
    // 当w等于最大值，则替换次大值 
    if (w > dist2) return w - dist2;
    // 否则不可以替换 
    return INF;
}

int main () {
    cin >> n >> m;
    memset(h, -1, sizeof h);
    for (int i = 0; i < m; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        edge[i] = {a, b, c};
    }
    
    LL sum = kruskal();
    build();
    bfs();
    
    LL res = 1e18;
    for (int i = 0; i < m; i ++) {
        if (!edge[i].used) {
            int a = edge[i].a, b = edge[i].b, w = edge[i].w;
            res = min(res, sum + lca(a, b, w));
        }
    }
    cout << res << endl;
    
    return 0;
}
```
