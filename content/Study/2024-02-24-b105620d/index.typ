#import "../../index.typ": template, tufted
#show: template.with(title: "第 六到十 次CCF计算机软件能力认证")

= 第六次
写了4题

== 数位之和
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int res = 0;
int t;

int main() {
    cin >> t;
    while(t) {
        res += t % 10;
        t /= 10;
    }
    cout << res << endl;
    return 0;
}
```

== 消除类游戏
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 35;

int n, m;
int g[N][N];
bool st[N][N];

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= m; j ++) {
            scanf("%d", &g[i][j]);
        }
    }
    int last = 0, v = 0;
    for (int i = 1; i <= n; i ++) {
        last = 0, v = 0;
        for (int j = 1; j <= m; j ++) {
            if (g[i][j] == last) {
                v ++;
                if (v >= 3) {
                    st[i][j] = true;
                    st[i][j - 1] = true;
                    st[i][j - 2] = true;
                } 
            } else {
                last = g[i][j];
                v = 1;
            }
        }
    }
    for (int j = 1; j <= m; j ++) {
        last = 0, v = 0;
        for (int i = 1; i <= n; i ++) {
            if (g[i][j] == last) {
                v ++;
                if (v >= 3) {
                    st[i - 2][j] = true;
                    st[i - 1][j] = true;
                    st[i][j] = true;
                } 
            } else {
                last = g[i][j];
                v = 1;
            }
        }
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= m; j ++) {
            if (st[i][j]) {
                cout << 0;
            } else {
                cout << g[i][j];
            }
            cout << " ";
        }
        cout << "\n";
    }
    
    
    
    return 0;
}
```

一行一行，一列一列的检测

== ~画图
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

typedef pair<int, int> PII;

const int N = 110;

int n, m, p;
char g[N][N];
int dx[4] = {0, 1, 0, -1};
int dy[4] = {1, 0, -1, 0};
bool st[N][N];

void dfs(int x, int y, char c) {
    st[x][y] = true;
    g[x][y] = c;
    for (int i = 0; i < 4; i ++) {
        int a = x + dx[i], b = y + dy[i];
        if (a >= 0 && a < m && b >= 0 && b < n && !st[a][b]) {
            if (g[a][b] == '-' || g[a][b] == '|' || g[a][b] == '+') continue;
            dfs(a, b, c);
        }
    }
}


int main() {
    cin >> m >> n >> p;
   
    for (int i = 0; i < m; i ++) {
        for (int j = 0; j < n; j ++) {
            g[i][j] = '.';
        }
    }
    for (int i = 1; i <= p; i ++) {
        int command;
        cin >> command;
        if (command == 1) {
            int x, y;
            char c;
            cin >> x >> y >> c;
            memset(st, 0, sizeof st);
            dfs(x, y, c);
        } else {
            int x1, y1, x2, y2;
            cin >> x1 >> y1 >> x2 >> y2;
            if (x1 > x2) swap(x1, x2);
            if (y1 > y2) swap(y1, y2);
            char c = '-', d = '|';
            if (x1 == x2) {
                // 竖线
                swap(c, d);
            }
            
            for (int i = x1; i <= x2; i ++) {
                for (int j = y1; j <= y2; j ++) {
                    auto & t = g[i][j];
                    if (t == d || t == '+') {
                        t = '+';
                    } else {
                        t = c;
                    }
                }
            }
        }
    }
    
    for (int i = n - 1; i >= 0; i --) {
        for (int j = 0; j < m; j ++) {
            cout << g[j][i];
        }
        cout << "\n";
    }
    
    return 0;
}
```

== 送货
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <set>

using namespace std;

const int N = 10010, M = 100010;

int n, m;
set<int> g[N];
int p[N];
int ans[M];
int top;

int find(int x) {
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}

void dfs(int u) {
    while(g[u].size()) {
        int t = *g[u].begin();
        
        // 无向边
        g[u].erase(t);
        g[t].erase(u);
        dfs(t);
    }
    ans[++ top] = u;
}


int main() {
    scanf("%d%d", &n, &m);
    for (int i = 1; i <= n; i ++) p[i] = i;
    while(m --) {
        int a, b;
        scanf("%d%d", &a, &b);
        g[a].insert(b), g[b].insert(a);
        p[find(a)] = find(b);
    }
    
    int s = 0;
    for (int i = 1; i <= n; i ++) {
        if (find(i) != find(1)) {
            cout << -1 << endl;
            return 0;
        } else if(g[i].size() % 2) s++;
    }
    
    // 如果图不是欧拉图或者1号点（起点）的度不是奇数
    if (s != 0 && s != 2 || s == 2 && g[1].size() % 2 == 0) {
        cout << -1 << endl;
        return 0;
    }
    dfs(1);
    
    for (int i = top; i; i --) {
        printf("%d ", ans[i]);
    }
    
    return 0;
}
```

欧拉图与欧拉回路问题：#link("/Study/2024-02-20-903ad369/")[链接]

= 第七次
写了4题

== 折点计数
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
    for (int i =1 ; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    
    int res = 0;
    for (int i = 2; i < n; i ++) {
        if (a[i] > a[i - 1] && a[i] > a[i + 1] || a[i] < a[i - 1] && a[i] < a[i + 1]) {
            res ++;
        }
    }
    cout << res << endl;
    
    return 0;
}
```

== ~俄罗斯方块
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 30;

int g[N][N];
int s[N][N];
int p[4][4];

int n;

bool draw(int x, int y) {
    memcpy(s, g, sizeof s);
    for (int i = 0; i < 4; i ++) {
        for (int j = 0; j < 4; j ++) {
            if (p[i][j]) {
                int a = x + i, b  = y + j;
                s[a][b] ++;
                if (s[a][b] == 2)
                    return true;
            }
        }
    }
    return false;
}

int main() {
    for (int i = 0; i < 15; i ++) {
        for (int j = 0; j < 10; j ++) {
            cin >> g[i][j];
        }
    }
    
    for (int i = 0; i < 10; i ++) g[15][i] = 1;
    for (int i = 0; i < 4; i ++) {
        for (int j = 0; j < 4; j ++) {
            cin >> p[i][j];
        }
    }
    
    int c;
    cin >> c;
     c --;
    
    for (int i = 0; ; i ++) {
        if (draw(i, c)) {
            draw(i - 1, c);
            break;
        }
    }
    
    for (int i = 0; i < 15; i ++) {
        for (int j = 0; j < 10; j ++) {
            cout << s[i][j] <<  " ";
        }
        cout << endl;
    }
    
    return 0;
}
```

== 路径解析
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

vector<string> get(string& str) {
    vector<string> res;
    for (int i = 0; i < str.size(); i ++) {
        if (str[i] == '/') continue;
        int j = i + 1;
        while(j < str.size() && str[j] != '/') j ++;
        res.push_back(str.substr(i, j - i));
        i = j;
    }
    return res;
}

void work(vector<string> cur, vector<string> path) {
    for (auto p: path) {
        if (p == ".") continue;
        if (p == "..") {
            if (cur.size()) cur.pop_back();
        }
        else {
            cur.push_back(p);
        }
    }
    
    if (cur.empty()) {
        puts("/");
    
        return;
    }
    for (auto p : cur) {
        cout << "/" << p;
    }
    cout << endl;
}


int main() {
    int n;
    string str;
    cin >> n >> str;
    
    vector<string> cur = get(str), ap;
    
    getchar();
    while(n --) {
        getline(cin, str);
        auto path = get(str);
        if (str.size() && str[0] == '/') {
            // 如果是绝对路径
            work(ap, path);
        } else {
            work(cur, path);
        }
    }
    
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

const int N = 110, M = 310;

int ts[N][N];
int te[N][N];
typedef pair<pair<int, int>, int> PII;

bool is_safe(int x, int y, int time) {
    if (ts[x][y] == -1) return true;
    if (time >= ts[x][y] && time <= te[x][y]) {
        return false;
    }
    return true;
}

int n, m, t;
int dist[N][N][M];

int dx[4] = {0, 1, 0, -1};
int dy[4] = {1, 0, -1, 0};

void bfs() {
    queue<PII> q;
    q.push({{1, 1}, 0});
    dist[1][1][0] = 0;
    
    while(q.size()) {
        auto t = q.front();
        q.pop();
        
        int x = t.first.first, y = t.first.second;
        int time = t.second;
        
        if (x == n && y == m) return;
        
        for (int i = 0; i < 4; i ++) {
            int nx = x + dx[i], ny = y + dy[i];
            int ntime = time + 1;
            if (nx < 1 || nx > n || ny < 1 || ny > m) continue;
            if (is_safe(nx, ny, ntime)) {
                if (dist[nx][ny][ntime] > dist[x][y][time] + 1) {
                    dist[nx][ny][ntime] = dist[x][y][time] + 1;
                    q.push({{nx,ny} , ntime});
                }
            }
        }
    }
}


int main() {
    memset(dist, 0x3f, sizeof dist);
    memset(ts, -1, sizeof ts);
    cin >> n >> m >> t;
    while(t --) {
        int r, c, a, b;
        scanf("%d%d%d%d", &r, &c, &a, &b);
        ts[r][c] = a, te[r][c] = b;
    }
    
    bfs();
    
    int res = 2e9;
    for (int i = 0; i < M; i ++) {
        res = min(res, dist[n][m][i]);
    }
    
    cout << res << endl;
    return 0;
}
```

在本题中，我们不好判断向上下左右走是否方便，无法把信息统一起来。为了把信息统一起来，所以我们可以使用拆点的方法：只根据格子的横纵无法判断，那么再加一维：表示走到这个格子的时间。

M：表示当前可能的时间。由题目的数据范围可知：最大为 300。从左上走到右下，为 100+100=200 时间。而一个格式的最大不能走的时间为 100。所以 200+100=300。

= 第八次
== 最大波动
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;


int main() {
    int n;
    cin >> n;
    int res = 0;
    int last = 0;
    for (int i = 0; i < n; i ++) {
        int t = 0;
        cin >> t;
        if (i) {
            res = max(res, abs(t - last));
        }
        last = t;
    }
    cout << res << endl;
    
    return 0;
}
```

== ~火车购票
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110, M = 20;

bool st[N];


int main() {
    int n;
    cin >> n;
    while(n --) {
        int p;
        cin >> p;
        
        bool success = false;
        for (int i = 1; i <= 100; i += 5) {
            for (int j = 0; j < 5; j ++) {
                int s = 0;
                for (int k = j; k < 5; k ++) {
                    if (!st[i + k]) {
                        s ++;
                    } else {
                        // 无连续的座位
                        break;
                    }
                }
                if (s >= p) {
                    for (int k = 0; k < p; k ++) {
                        int t = i + j + k;
                        st[t] = true;
                        cout << t << " ";
                    }
                    success = true;
                    break;
                }
            }
            if (success) break;
        }
        
        if (!success) {
            for (int i = 1; i <= 100 && p; i ++) {
                if (!st[i]) {
                    p --;
                    st[i] = true;
                    cout << i << ' ';
                }
            }
        }
        cout << "\n";
        
    }
    
    return 0;
    
}
```

== 炉石传说
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

struct Role {
    int a, h;
}p[2][10];

void remove(int k, int pos) {
    for (int i = pos; i <= 7; i ++) {
        p[k][i] = p[k][i + 1];
    }
}


int main() {
    p[0][0].h = p[1][0].h = 30;
    
    
    int n;
    cin >> n;
    int k = 0;
    while(n --) {
        string op;
        cin >> op;
        if (op == "end") k ^= 1;
        else if (op == "summon") {
            int pos, a, h;
            cin >> pos >> a >> h;
            for (int i = 7; i > pos; i --) {
                p[k][i] = p[k][i - 1];

            }
            p[k][pos] = {a, h};
        } else {
            int a, d;
            cin >> a >> d;
            p[k][a].h -= p[!k][d].a;
            p[!k][d].h -= p[k][a].a;
            if (a && p[k][a].h <= 0) remove(k, a);
            if (d && p[!k][d].h <= 0) remove(!k, d);
        }
    }
    
    if (p[0][0].h <= 0) cout << "-1" << endl;
    else if (p[1][0].h <= 0) cout << "1" << endl;
    else cout << "0" << endl;
    
    for (int k = 0; k < 2; k ++) {
        cout << p[k][0].h << endl;
        int s = 0;
        for (int i = 1; i <= 7; i ++) {
            if (p[k][i].h > 0) {
                s ++;
            }
        }
        
        cout << s << " ";
        for (int i = 1; i <= s; i ++) {
            cout << p[k][i].h << " ";
        }
        cout << endl;
    }
    
    return 0;
}
```

== 交通规划
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

typedef pair<int, int> PII;

const int N = 10010, M = 100010, INF = 0x3f3f3f3f;

int n, m;
int h[N], e[M * 2], ne[M * 2], w[M * 2], idx;
int dist[N];
bool st[N];
int ans = 0;

void add(int a, int b, int c) {
    e[idx] = b, ne[idx] = h[a], w[idx] = c, h[a] = idx ++;
}

void dijkstra(int start) {
    priority_queue<PII, vector<PII>, greater<PII>> q;
    dist[start] = 0;
    q.push({0, start});
    
    while(q.size()) {
        auto t = q.top();
        q.pop();
        
        int v = t.second;
        
        if (st[v]) continue;
        st[v] = true;
        
        for (int i = h[v]; ~i; i = ne[i]) {
            int j = e[i];
            if (dist[j] > dist[v] + w[i]) {
                dist[j] = dist[v] + w[i];
                q.push({dist[j], j});
            }
        }
    }
}

int main() {
    memset(h, -1, sizeof h);
    memset(dist, 0x3f, sizeof dist);
    
    cin >> n >> m;
    while(m --) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        add(a, b, c);
        add(b, a, c);
    }
    
    dijkstra(1);
    
    int res = 0;
    for (int a = 2; a <= n;  a ++) {
        int minw = INF;
        for (int j = h[a]; ~j; j = ne[j]) {
            int b = e[j];
            if (dist[a] == dist[b] + w[j]) {
                // 如果a可以从b走到1号点，则a到b的这个路径为备选边
                minw = min(minw, w[j]);
            }
        }
        // 选择备选边中长度最小的边。长度不为INF时，表明：这个点一定可以到1号点，如果不可以到1号点，则为INF
        res += minw;
    }
    
    cout << res << endl;
    
    return 0;
}
```

最短路树

+ 先求一个最短路（dijkstra 或 spfa）
+ 枚举一下每个点的所有邻边，判断一下这个邻边是否满足从这条边往起始点走，最短距离不变，满足要求的即为备选边。
+ 在备选边中选择最短边。

`dist[i]:从i号点向1号点走时，要花费的最短路径`

= 第九次
== 中间数
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
    
    sort(a + 1 , a + 1 + n);
    int res = -1;
    int v, less, bigger;
    for (int i = 1; i <= n; i ++) {
        v = a[i];
        less = bigger = 0;
        for (int j = 1; j <= n; j ++) {
            if (a[j] < v) {
                less ++;
            } else if (a[j] > v) {
                bigger ++;
            }
        }
        
        if (less == bigger) {
            res = v;
            break;
        }
    }
    cout << res << endl;
    
    
}
```

== ~工资计算
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int get_tex(int money) {
    money -= 3500;
    double res = 0;
    if (money <= 0) return res;
    int tex = min(money, 1500);
    res += tex * 0.03;
    money -= tex;
    if (money <= 0) return res;
    
    tex = min(money, 3000);
    res += tex * 0.1;
    money -= tex;
    if (money <= 0) return res;
    
    tex = min(money, 4500);
    res += tex * 0.2;
    money -= tex;
    if (money <= 0) return res;
    
    tex = min(money, 26000);
    res += tex * 0.25;
    money -= tex;
    if (money <= 0) return res;
    
    tex = min(money, 20000);
    res += tex * 0.3;
    money -= tex;
    if (money <= 0) return res;
    
    tex = min(money, 25000);
    res += tex * 0.35;
    money -= tex;
    if (money <= 0) return res;
    
    res += money * 0.45;
    return res;
}

int main() {
    int n;
    cin >> n;
    
    int l = 1, r = n * 2 / 100;
    
    while(l < r) {
        int mid = l + r >> 1;
        int money = mid * 100;
        int tex = get_tex(money);
        if (money - tex == n) {
            l = r = mid;
        } else if (money - tex > n) {
            r = mid;
        } else {
            l = mid;
        }
    }
    
    cout << l * 100 << endl;
    
    return 0;
}
```

这个题目可以发现：钱越多，交的税越多，此时是一个单调增的关系。所以可以使用二分法来完成这个题。

题目中说，`所有评测数据保证小明的税前工资为一个整百的数`。所以可以二分百位以上的数。

== 权限查询
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

#include <unordered_map>
#include <set>

using namespace std;

struct P{
    string name;
    mutable int level;
    P(string str) {
        int k = str.find(":");
        if (k == -1) name = str, level = -1;
        else {
            name = str.substr(0, k);
            level = stoi(str.substr(k + 1));
        }
    }
    

    bool operator<(const P&t) const {
        return name < t.name;
    }
};

unordered_map<string, set<P>> role, person;

int main() {
    int n;
    string str;
    cin >> n;
    while(n --) cin >> str;
    cin >> n;
    while(n --) {
        string name;
        cin >> name;
        int cnt;
        cin >>cnt;
        while(cnt --) {
            cin >> str;
            P t(str);
            auto& r = role[name];
            if (t.level == -1) r.insert(t);
            else {
                if(!r.count(t)) r.insert(t);
                else {
                    auto it = r.find(t);
                    it->level = max(it->level, t.level);
                }
            }
        }
    }
    cin >> n;
    while(n --) {
        string name;
        cin >> name;
        int cnt;
        cin >> cnt;
        auto& p = person[name];
        while(cnt -- ) {
            string str;
            cin >> str;
            for (auto& t : role[str]) {
                if (t.level == -1) p.insert(t);
                else {
                    if(!p.count(t)) p.insert(t);
                    else {
                        auto it = p.find(t);
                        it->level = max(it->level, t.level);
                    }
                }
            }
        }
    }
    
    cin >> n;
    while(n --) {
        string user, pr;
        cin >> user >> pr;
        P t(pr);
        auto& p = person[user];
        if (!p.count(t)) {
            cout << "false" << endl;
        } else {
            auto it = p.find(t);
            if (t.level != -1) {
                if (it->level >= t.level) cout << "true" << endl;
                else cout << "false" <<endl;
            } else {
                if (it->level == -1) cout << "true" << endl;
                else cout << it->level << endl;
            }
        }
    }
    
}
```

== 压缩编码
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>


using namespace std;

const int N = 1010;
int n;
int s[N], f[N][N];

int main() {
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        cin >> s[i];
        s[i] += s[i - 1];
    }
    
    for (int len = 2; len <= n; len ++) {
        for (int i = 1; i  + len -1 <= n; i ++) {
            int j = i + len - 1;
            f[i][j] = 1e9;
            for (int k = i; k < j; k ++) {
                f[i][j] = min(f[i][j], f[i][k] + f[k + 1][j] + s[j] - s[i - 1]);
            }
        }
    }
    
    cout << f[1][n];
}
```

= 第十次
写了 1，2，4，题。模拟题太复杂了。

== 分蛋糕
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, k;
int a[N];

int main() {
    cin >> n >> k;
    
    for (int i = 1;  i<= n; i ++) {
        scanf("%d", &a[i]);
    }
    
    int res = 0;
    int now = 0;
    
    for (int i = 1; i <= n; i ++) {
        now += a[i];
        if (now >= k) {
            res ++;
            now = 0;
        }
    }
    // 最后一个人，只要有蛋糕，就可以加1
    if (now > 0) {
        res ++;
        now = 0;
    }
        
    cout << res << endl;
    
    return 0;
}
```

== ~学生排队
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

const int N = 1010;

int n;
vector<int> a;

int main() {
    cin >> n;
    
    a.resize(n + 1, 0);
    
    for (int i = 1; i <= n; i ++) {
        a[i] = i;
    }
    
    int m;
    cin >> m;
    while(m --) {
        int val, k;
        cin >> val >> k;
        auto it = find(a.begin(), a.end(), val);
        
        int span = it - a.begin();
        a.erase(it);
        span += k;
        a.insert(a.begin() + span, val);

    }
    
    for (int i = 1; i <= n; i ++) {
        cout << a[i] << " ";
    }
    
    return 0;
}
```

== 地铁修建
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

const int N = 100010, M = N * 2;

struct edge {
    int a, b, c;
    bool operator<(const edge& t) const {
        return c < t.c;
    }
}edges[M];
int idx;

int p[N];
int dist[N];
int h[N], ne[M], e[M], w[M], t;
int n, m;

int find(int x) {
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}

void add(int a, int b, int c) {
    e[t] = b, ne[t] = h[a], w[t] = c, h[a] = t ++;
}

void bfs() {
    queue<int> a;
    a.push(1);
    
    while(a.size()) {
        int b = a.front();
        a.pop();
        
        for (int i = h[b]; ~i; i = ne[i]) {
            int j = e[i];
            
            if (dist[j] == 0) {
                dist[j] = max(dist[b], w[i]);
                a.push(j);
            }
        }
    }
}

int main() {
    memset(h, -1, sizeof h);
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) p[i] = i;
    
    for (int i  =0; i < m; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        edges[idx ++] = {a, b, c};
    }
    
    sort(edges, edges + idx);
    
    for (int i = 0; i < idx; i ++) {
        int a = edges[i].a, b = edges[i].b, c = edges[i].c;
        int pa = find(a), pb = find(b);
        if (pa == pb) {
            continue;
        }
        
        p[pa] = pb;
        add(a, b, c);
        add(b, a, c);
    }
    
    bfs();
    
    cout << dist[n];
    return 0;
    
}
```

这题可以发现，要求的是：从 1 号点到第 n 号点的最长路径段的长度。

比如，路径由长度分别为：1， 2， 4 的小路径组成，则答案为：4。

所以可以先用 kruskal 算法，求出的路径一定是图中最小的路径。然后再用 bfs 求一下从 1 号点到 n 号点的最长路径。
