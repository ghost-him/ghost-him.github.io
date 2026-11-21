#import "../../index.typ": template, tufted
#show: template.with(title: "第 十一到十五 次CCF计算机软件能力认证")

11\~15次认证的题目

= 第十一次
写了 1，2，4 题

== 打酱油
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int main() {
    int n;
    cin >> n;
    n /= 10;
    int res = 0;
    while(n / 5) {
        n -= 5;
        res += 5;
        res += 2;
    }
    
    while(n / 3) {
        n -= 3;
        res += 3;
        res += 1;
    }
    res += n;

    cout << res << endl;
    
    return 0;
}
```

== ~公共钥匙盒
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>
#include <set>
using namespace std;

const int N = 1010;

struct op{
    int tm, type, id;
    bool operator<(const  op & t) const {
        if (tm != t.tm) {
            return tm < t.tm;
        } 
        if (type != t.type) {
            return type > t.type;
        }
        return id < t.id;
    }
} ops[N * 2];
int q[N];

int n, m;


int main() {
    cin >> n >> m;
   
    int k = 0;
    while(m --) {
        int id, start, len;
        cin >> id >> start >> len;
        ops[k ++] = {start, 0, id};
        ops[k ++] = {start + len, 1, id};
    }
   sort(ops, ops + k);
   
   for (int i = 1; i <= n; i ++) q[i] = i;
   
   for (int i = 0; i < k; i ++) {
       int id = ops[i].id;
       if (!ops[i].type) {
           for (int j = 1; j <= n; j ++) {
               if (q[j] == id) {
                   q[j] = 0;
                   break;
               }
           }
       } else {
           for (int j = 1; j <= n; j ++) {
               if (!q[j]) {
                   q[j] = id;
                   break;
               }
           }
       }
   }
   
   for (int i = 1; i <= n; i ++) {
       cout << q[i] << " ";
   }
   
   
    return 0;
}
```

== 通信网络
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 10010, M = 20010;

int n, m;
int h1[N], h2[N], e[M], ne[M], idx;
bool st1[N], st2[N];

void add(int h[], int a, int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
}

void dfs(int u, int h[], bool st[]) {
    st[u] = true;
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        if (!st[j]) dfs(j, h, st);
    }
}

int main() {
    cin >> n >> m;
    memset(h1, -1, sizeof h1);
    memset(h2, -1, sizeof h2);
    
    while(m --) {
        int a, b;
        cin >> a >> b;
        add(h1, a, b), add(h2, b, a);
    }
    
    int res = 0;
    for (int i = 1; i <= n; i ++) {
        memset(st1, 0, sizeof st1);
        memset(st2, 0, sizeof st2);
        
        dfs(i, h1, st1);
        dfs(i, h2, st2);
        
        int s = 0;
        for (int j = 1; j <= n; j ++) {
            if(st1[j] || st2[j]) {
                s ++;
            }
        }
        if (s == n) res ++;
    }
    cout << res << endl;
    
    return 0;
}
```

= 第十二次
== 最小差值
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n;
int a[N];

int main() {
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    
    sort(a + 1, a + 1 + n);
    
    int res = 1e9;
    for (int i = 2; i <= n; i ++) {
        res = min(res, a[i] - a[i - 1]);
    }
    
    cout << res << endl;
    
    return 0;
}
```

== 游戏
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>
using namespace std;

int main() {
    int n, k;
    cin >> n >> k;
    queue<int> q;
    int j = 1;
    for (int i = 1; i <= n; i ++) q.push(i);
    while(q.size() > 1) {
        int t = q.front();
        q.pop();
        if (j % k && j % 10 != k) q.push(t);
        j ++;
    }
    cout << q.front() << endl;
    return 0;
}
```

对于约瑟夫问题，可以使用队列来模拟。

== 行车路线
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

const int N = 510, M = 100010 * 2, INF = 1e6;

int n, m;
int h[N], e[M], f[M], w[M], ne[M], idx;
int dist[N][1010];
bool st[N][1010];

struct Node{
    int x, y, v;
    // x:编号，y:最后一个小路的长度,v:距离
    bool operator<(const Node& t) const {
        // 直接将大堆改成小堆
        return v > t.v;
    }
};

void add(int t, int a, int b, int c) {
    e[idx] = b, f[idx] = t, w[idx] = c, ne[idx] = h[a], h[a] = idx ++;
}

void dijkstra() {
    priority_queue<Node> heap;
    memset(dist, 0x3f, sizeof dist);
    
    heap.push({1, 0, 0});
    dist[1][0] = 0;
    
    while(heap.size()) {
        auto t = heap.top();
        heap.pop();
        if (st[t.x][t.y]) continue;
        st[t.x][t.y] = true;
        
        for (int i = h[t.x]; ~i; i = ne[i]) {
            int x = e[i], y = t.y;
            if (f[i]) {
                // 小路
                y += w[i];
                if (y <= 1000) {
                    if (dist[x][y] > t.v - t.y * t.y + y * y) {
                        dist[x][y] = t.v - t.y * t.y + y * y;
                        if (dist[x][y] <= INF) {
                            heap.push({x, y, dist[x][y]});
                        }
                    }
                }
            } else {
                // 大路
                if (dist[x][0] > t.v + w[i]) {
                    dist[x][0] = t.v + w[i];
                    if (dist[x][0] <= INF) {
                        heap.push({x, 0, dist[x][0]});
                    }
                }
            }
        }
    }
}

int main() {
    scanf("%d%d", &n, &m);
    memset(h, -1, sizeof h);
    while(m --) {
        int t, a,b, c;
        scanf("%d%d%d%d", &t, &a, &b, &c);
        add(t,a, b, c),add(t, b, a, c);
    }
    
    dijkstra();
    
    int res = INF;
    for (int i = 0; i <= 1000; i ++) res = min(res, dist[n][i]);
    printf("%d\n", res);
    
    return 0;
}
```

由于答案保证不超过 `1e6`，所以连续的小路长度不走过 1000。

`dist[i][j]`：从 1 走到 i，最后小路长度是 j 的前提下，值是多少。

状态转移：从 i 点走到 k 点。

- 走大路：`dist[i][j] -> dist[k][0] = dist[i][j] + w`；w 为大路的长度
- 走小路：`dist[i][j] -> dist[k][j + w] = dist[i][j] - j^2 + (j + w)^2`，`w` 为小路的长度。

= 第十三次
== 跳一跳
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int res;

int main() {
    int t;
    int last = 0;
    while(cin >> t, t) {
        if (t == 1) {
            res += 1;
            last = 0;
        } else {
            last += 2;
            res += last;
        }
    }
    cout << res << endl;
    
    return 0;
}
```

== 碰撞的小球
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;

int n, L, t;
struct Ball {
    int p, v;
}b[N];


int main() {
    cin >> n >> L >> t;
    for (int i = 0; i < n; i ++) {
        cin >> b[i].p;
        b[i].v = 1;
    }
    
    while(t --) {
        for (int i = 0; i < n; i ++) {
            b[i].p += b[i].v;
            if (b[i].p == L || !b[i].p)
                b[i].v *= -1;
        }
        for (int i = 0; i < n; i ++) {
            for (int j = i + 1; j < n; j ++) {
                if (b[i].p == b[j].p) {
                    b[i].v *= -1;
                    b[j].v *= -1;
                }
            }
        }
    }
    
    for (int i = 0; i < n; i ++) {
        cout << b[i].p << " ";
    }
    return 0;
}
```

== URL 映射
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

const int N = 110;

struct Url {
    string path, name;
}url[N];

int n, m;

string get_number(string& str) {
    string res;
    for (auto c : str) {
        if (c >= '0' && c <= '9') {
            res += c;
        } else {
            res.clear();
            return res;
        }
    }
    // 去掉前导0
    int k = 0;
    while(k + 1 < res.size() && res[k] == '0') k ++;
    return res.substr(k);
}

vector<string> get(string& path, string& str) {
    vector<string> res(1);
    int i, j;
    for (i = 1, j = 1; i < path.size() && j < str.size();) {
        int u = i + 1, v = j + 1;
        while(u < path.size() && path[u] != '/') u ++;
        while(v < str.size() && str[v] != '/') v ++;
        string a = path.substr(i, u - i), b = str.substr(j, v - j);
        if (a == "<str>") {
            res.push_back(b);
            i = u + 1, j = v + 1;
            
        } else if (a == "<int>") {
            auto t = get_number(b);
            if (t.empty()) {
                res.clear();
                return res;
            }
            res.push_back(t);
            i = u + 1, j = v + 1;
        } else if (a == "<path>") {
            res.push_back(str.substr(j));
            return res;
        } else if (a != b) {
            res.clear();
            return res;
        } else {
            i = u + 1, j = v + 1;
        }
    }
    
    if (i - path.size() != j - str.size()) {
        res.clear();
    }
    return res;
}

void work(string& str) {
    for (int i = 0; i < n; i ++) {
        auto res = get(url[i].path, str);
        if (res.size()) {
            cout << url[i].name;
            for (int j = 1; j < res.size(); j ++) {
                cout << ' ' << res[j];
            }
            cout << endl;
            return ;
        }
    }
    cout << "404" << endl;
}

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i ++) {
        cin >> url[i].path >> url[i].name;
    }
    
    while(m --) {
        string str;
        cin >> str;
        work(str);
    }
}
```

== 棋局评估
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 3, INF = 1e8;

int g[N][N];

bool check(int x) {
    for (int i = 0; i < 3; i ++) {
        int s = 0;
        for (int j = 0; j < 3; j++) {
            if (g[i][j] == x) {
                s ++;
            }
        }
        if (s == 3) return true;
        s = 0;
        for (int j = 0; j < 3; j ++) {
            if (g[j][i] == x) {
                s ++;
            }
        }
        if (s == 3) return true;
    }
    if (g[0][0] == x && g[1][1] == x && g[2][2] == x) return true;
    if (g[2][0] == x && g[1][1] == x && g[0][2] == x) return true;
    return false;
}

int evaluate() {
    int s = 0;
    for (int i = 0; i < 3; i ++) {
        for (int j = 0;j < 3; j ++) {
            if (!g[i][j])
                s ++;
        }
    }

    if (check(1)) {
        return s + 1;
    } 
    if (check(2)) {
        return -(s + 1);
    }
        if (!s) return 0;
    return INF;
}

int dfs(int u) {
    int t = evaluate();
    if (t != INF) return t;
    
    if (!u) {
        // alice
        int res = -INF;
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                if (!g[i][j]) {
                    g[i][j] = 1;
                    res = max(res, dfs(1));
                    g[i][j] = 0;
                }
            }
        }
        return res;
    } else { // Bob
        int res = INF;
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                if (!g[i][j]) {
                    g[i][j] = 2;
                    res = min(res, dfs(0));
                    g[i][j] = 0;
                }
            }
        }
        return res;
    }
    
}

int main() {
    int t;
    cin >> t;
    while(t --) {
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                cin >> g[i][j];
            }
        }
        cout << dfs(0) << endl;
    }
    
    return 0;
}
```

最大最小搜索：在博弈论中比较常见。在 A 走时，A 要选择最大得分的走法，而 B 走时，则要走最小得分的走法。

= 第十四次
== 卖菜
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <deque>
using namespace std;

const int N = 1010;

int a[N];
int sum;
int n;

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        scanf("%d", &a[i]);
    }
    
    cout << (a[0] + a[1]) / 2 << " ";
    for (int i = 1; i < n - 1; i ++) {
        cout << (a[i - 1] + a[i] + a[i + 1]) / 3 << " ";
    }
    cout << (a[n - 1] + a[n - 2]) / 2 << " ";
    
    return 0;
}
```

== 买菜
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e6 + 10;

int n;
bool st[N];

int main() {
    cin >> n;
    for (int k = 0; k < n; k ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        for (int i = a; i < b; i ++) {
            st[i] = true;
        }
    }

    int res = 0;
    for (int k = 0; k < n; k ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        for (int i = a; i < b; i ++) {
            if (st[i])
                res ++;
        }
    }
    cout << res << endl;
    
    return 0;
}
```

== 再卖菜
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

const int N = 310, M = N * 3;

int n;
int h[N], e[M], ne[M], w[M], idx;
int dist[N], q[N];
int b[N];
bool st[N];

void add(int a, int b, int c) {
    e[idx] = b, ne[idx] = h[a], w[idx] = c, h[a] = idx ++;
}

void spfa() {
    queue<int> q;
    memset(dist, -0x3f, sizeof dist);
    dist[0] = 0;
    q.push(0);
    while(q.size()) {
        int t = q.front();
        q.pop();
        
        st[t] = false;
        for (int i = h[t]; ~i; i = ne[i]) {
            int j = e[i];
            if (dist[j] < dist[t] + w[i]) {
                dist[j] = dist[t] + w[i];
                if (!st[j]) {
                    q.push(j);
                    st[j] = true;
                }
            }
        }
    }
}

int main() {
    cin >> n;
    memset(h, -1, sizeof h);
    for (int i = 1; i <= n; i ++) cin >> b[i];
    for (int i = 2; i < n; i ++) {
        add(i - 2, i + 1, b[i] * 3);
        add(i + 1, i - 2, -(b[i] * 3 + 2));
    }
    add(0, 2, b[1] * 2), add(2, 0, -(b[1] * 2 + 1));
    add(n - 2, n, b[n] * 2), add(n, n - 2, -(b[n] * 2 + 1));
    for (int i = 1; i <= n; i ++) add(i - 1, i , 1);
    spfa();
    
    for (int i = 1; i <= n; i ++) {
        cout << dist[i] - dist[i - 1] << " ";
    }

}
```

由 $b_i = ⌊\( a_(i - 1) + a_i + a_(i + 1) \) \/ 3⌋ = ⌊\( s_(i + 1) - s_(i - 2) \) \/ 3⌋$ 知 $3 * b_i < = s_(i + 1) - s_(i - 2) < = 3 * b_(i + 2)$ 且 $s_i - s_(i - 1) = a_i > = 1$

所以

+ 第 2 天到第 n-1天 `3*b[i]<=a[i-1]+a[i]+a[i+1]<=3*b[i]+2`
+ 第 1 天 `2*b[1]<=a[1]+a[2]<=2*b[1]+1`
+ 第 n 天 `2*b[n]<=a[n-1]+a[n]<=2*b[n]+1`

然后将其转为差数约分的标准形式即可。

差数约分相关：#link("/Study/2024-03-06-565b5ea/")[链接]

= 第十五次
== 小明上学
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int r, y, g;
int n;
int res;

int get_time(int k, int t) {
    if (k == 1) {
        return t;
    } else if (k == 2) {
        return t + r;
    } else {
        return 0;
    }
}

int main() {
    cin >> r >> y >> g;
    cin >> n;
    while(n --) {
        int k ,t;
        scanf("%d%d", &k, &t);
        if (k == 0) {
            res += t;
        } else {
            res += get_time(k, t);
        }
    }
    
    cout << res << endl;
    return 0;
}
```

== 小明放学
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

typedef long long LL;

LL r, g, y;
int n;

int main() {
    cin >> r >> y >> g;
    
    cin >> n;
    LL time = 0;
    for (int i = 0; i < n; i ++) {
        LL k, t;
        scanf("%lld%lld", &k, &t);
        if (k == 0) {
            time += t;
        } else {
            LL res = 0;
            if (k == 1) {
                res += r - t;
            } else if (k == 2) {
                res += r + y + g - t;
            } else {
                res += r + g - t;
            }
            res += time;
            res %= r + g + y;
            
            if (res < r) {
                time += r - res;
            } else if (res >= r + g) {
                time += r + g + y - res + r;
            }
        }
    }
    cout << time << endl;
    return 0;
}
```

== 数据中心
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 5e4 + 10, M = 1e5 + 10;

struct edge{
    int u, v, t;
    bool operator<(const edge& o) const {
        return t < o.t;
    }
}edges[M];

int n, m, u;
int p[N];

int find(int x) {
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}

int main() {
    cin >> n >> m >> u;
    for (int i = 1; i <= n; i ++) p[i] = i;
    for (int i = 0; i < m; i ++) {
        int u, v, t;
        scanf("%d%d%d", &u, &v, &t);
        edges[i] = {u, v, t};
    }
    
    sort(edges, edges + m);
    
    int res = 0;
    for (int i = 0; i < m; i ++) {
        int u = edges[i].u, v = edges[i].v;
        int t = edges[i].t;
        int pu = find(u), pv = find(v);
        if (pu == pv) continue;
        
        p[pu] = pv;
        
        res = max(res, t);
    }
    
    cout << res << endl;
    
    return 0;
}
```
