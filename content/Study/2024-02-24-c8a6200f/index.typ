#import "../../index.typ": template, tufted
#show: template.with(title: "第 一到五 次CCF计算机软件能力认证")

= 第一次
写了前4题

== 相反数
```cpp
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

const int N = 1010;

int n;
bool st[N];

int main()
{
    int res = 0;
    cin >> n;
    for (int i = 0; i < n; i++)
    {
        int t;
        cin >> t;
        t = abs(t);
        if (st[t]) {
            res++;
        }

        st[t] = true;
    }
    cout << res << endl;

    return 0;
}
```

== 窗口
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

const int N = 15;

struct window
{
    int x1, y1, x2, y2;
    int id;
};

int n, m;

vector<window> windows;

bool check(int x, int y, int index)
{
    int x1 = windows[index].x1;
    int y1 = windows[index].y1;
    int x2 = windows[index].x2;
    int y2 = windows[index].y2;
    if (x1 <= x && x2 >= x && y1 <= y && y2 >= y)
    {
        return true;
    }
    return false;
}

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; i++)
    {
        int x1, y1, x2, y2;
        scanf("%d%d%d%d", &x1, &y1, &x2, &y2);
        windows.push_back({x1, y1, x2, y2, i});
    }

    while (m--)
    {
        int x, y;
        scanf("%d%d", &x, &y);
        bool flag = false;
        for (int i = n - 1; i >= 0; i--)
        {
            if (check(x, y, i))
            {
                printf("%d\n", windows[i].id);
                flag = true;
                int x1, y1, x2, y2;
                int id;
                x1 = windows[i].x1;
                y1 = windows[i].y1;
                x2 = windows[i].x2;
                y2 = windows[i].y2;
                id = windows[i].id;
                windows.erase(windows.begin() + i);
                windows.push_back({x1, y1, x2, y2, id});
                break;
            }
        }
        if (!flag)
        {
            printf("IGNORED\n");
        }
    }

    return 0;
}
```

本题思路：

`vector` 维护的是当前窗口的优先级，下标越小的窗口，越在下面，顶层窗口在数组最后。获取到点以后从优先级最高的窗口开始遍历，查看目标窗口是否满足，如果满足，则会输出当前窗口的序号，同时将其优先级设置为最高（将该窗口移动到数组最后）

== 命令行选项
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <set>
#include <map>
#include <sstream>

using namespace std;

const int N = 25;

struct arg
{
    string key, value;
    bool hasArgs;
    const bool operator<(const arg &other) const
    {
        return this->key < other.key;
    }
};

set<string> noArgs;
set<string> args;

map<string, arg> store;

int main()
{
    string temp;
    cin >> temp;
    for (int i = 1; i < temp.size(); i++)
    {
        if (temp[i] != ':' && temp[i - 1] != ':')
        {
            noArgs.insert((string) "-" + temp[i - 1]);
        }
        else if (temp[i] == ':')
        {
            args.insert((string) "-" + temp[i - 1]);
        }
    }
    
    if (temp[temp.size() - 1] != ':') {
        noArgs.insert((string) "-" + temp[temp.size() - 1]);
    }
    int n;
    cin >> n;
    string t1;
            getline(cin, t1);
    for (int i = 1; i <= n; i++)
    {
        string command;
        getline(cin, command);

        stringstream ss(command);
        string com;
        ss >> com;
        vector<string> commands;
        while(!ss.eof()) {
            string temp;
            ss >> temp;
            commands.push_back(temp);
        }
        
        for (int i = 0; i < commands.size(); i ++) {
            if (args.count(commands[i])) {
                if (i + 1 < commands.size())
                    store[commands[i]] = {commands[i], commands[i + 1], true};
                else
                    break;
                i ++;
            } else if (noArgs.count(commands[i])) {
                 store[commands[i]] = {commands[i], "", false};
            } 
            else {
                break;
            }
        }
        
        printf("Case %d:", i);
        for (auto &i : store)
        {
            arg &value = i.second;
            if (value.hasArgs)
            {
                cout << " " + value.key + " " + value.value;
            } else {
                cout << " " + value.key;
            }
        }
        store.clear();
        printf("\n");
    }

    return 0;
}
```

暴力模拟就可以了。

== 无线网络
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

#define x first
#define y second

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;
const int N = 210, M = N * N;

int n, m, k, r;
int h[N], e[M], ne[M], idx;
PII p[N];
int dist[N][N]; // 所有点的距离

bool check(PII a, PII b)
{
    LL dx = a.x - b.x;
    LL dy = a.y - b.y;
    return dx * dx + dy * dy <= (LL)r * r;
}

void add(int a, int b)
{
    e[idx] = b, ne[idx] = h[a], h[a] = idx++;
}

int bfs()
{
    queue<PII> q;
    q.push({1, 0});
    memset(dist, 0x3f, sizeof dist);

    dist[1][0] = 0;
    while (q.size())
    {
        auto t = q.front();
        q.pop();

        for (int i = h[t.x]; ~i; i = ne[i])
        {
            int x = e[i], y = t.y;
            if (x > n)
                y++;
            if (y <= k)
            {
                if (dist[x][y] > dist[t.x][t.y] + 1)
                {
                    dist[x][y] = dist[t.x][t.y] + 1;
                    q.push({x, y});
                }
            }
        }
    }
    int res = 1e8;
    for (int i = 0; i <= k; i ++) {
        res = min(res, dist[2][i]);
    }
    return res - 1;
}

int main()
{
    memset(h, -1, sizeof h);
    cin >> n >> m >> k >> r;
    for (int i = 1; i <= n; i++)
    {
        cin >> p[i].x >> p[i].y;
    }
    for (int i = n + 1; i <= n + m; i++)
    {
        cin >> p[i].x >> p[i].y;
    }

    for (int i = 1; i <= n + m; i++)
    {
        for (int j = i + 1; j <= n + m; j++)
        {
            if (check(p[i], p[j]))
            {
                add(i, j);
                add(j, i);
            }
        }
    }
    cout << bfs() << endl;
    return 0;
}
```

原题等价为：从 1 走到 2，且不同特殊点数\<=k 的最短路

`f(i, j)`：从 1 走到 i，且恰好经过 j 个特殊点的最短路

```
a -> b ，   b为特殊点：f(a, j) -> f(b, j + 1)
            b不是特殊点：f(a, j) -> f(b, j)
```

= 第二次
写了 4 题

== 相邻数对
```cpp
#include <iostream>
#include <algorithm>
#include <cstring>

using namespace std;

const int N = 10010;

int n;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i++)
    {
        cin >> a[i];
    }

    int res = 0;
    for (int i = 1; i <= n; i++)
    {
        for (int j = i + 1; j <= n; j++)
        {
            if (a[i] - a[j] == 1 || a[j] - a[i] == 1)
            {
                res++;
            }
        }
    }
    cout << res << endl;
    return 0;
}
```

范围最大是 1000，所以可以直接用 `O(n^2)` 的算法

== 画图
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

const int N = 110;

using namespace std;

bool st[N][N];

int n;

int main()
{
    cin >> n;
    for (int m = 1; m <= n; m++)
    {
        int x1, y1, x2, y2;
        cin >> x1 >> y1 >> x2 >> y2;
        for (int i = x1; i < x2; i++)
        {
            for (int j = y1; j < y2; j++)
            {
                st[i][j] = true;
            }
        }
    }

    int res = 0;
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j ++) {
            if (st[i][j])
                res++;
        }
    }
    cout << res << endl;
    return 0;
}
```

这个题目的数据范围表明可以使用 `O(n^3)` 的算法

== 字符串匹配
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>
using namespace std;

const int N = 110;

vector<string> strs(N, "");
vector<string> after(N, "");
bool st[N];

int n, k;
string mod;

string ToLower(string str)
{
    string res;
    for (auto i : str)
    {
        res.push_back(tolower(i));
    }
    return res;
}

int main()
{
    cin >> mod >> k >> n;
    for (int i = 1; i <= n; i++)
    {
        cin >> strs[i];
    }

    if (k == 0)
    {
        mod = ToLower(mod);
        for (int i = 1; i <= n; i++)
        {
            after[i] = ToLower(strs[i]);
        }
    } else {
        for (int i = 1; i <= n; i++)
        {
            after[i] = strs[i];
        }
    }

    for (int i = 1; i <= n; i++)
    {
        if (after[i].find(mod) != string::npos)
        {
            st[i] = true;
        }
    }

    for (int i = 1; i <= n; i ++) {
        if (st[i])
            cout << strs[i] << endl;
    }

    return 0;
}
```

== 最优配餐
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

typedef pair<int, int> PII;

const int N = 1010;

bool st[N][N];
int dist[N][N];
bool g[N][N];
PII start[N * N];

struct {
    int x, y, num;
} order[N * N];

int n, m, k, d;

int dx[4] = {-1, 0, 1, 0};
int dy[4] = {0, 1, 0, -1};

long long bfs()
{
    queue<PII> q;
    memset(dist, 0x3f, sizeof dist);
    for (int i = 1; i <= m; i++)
    {
        int x = start[i].first, y = start[i].second;
        dist[x][y] = 0;
        q.push({x, y});
    }

    while (q.size())
    {
        auto t = q.front();
        q.pop();
        int x = t.first, y = t.second;
        for (int i = 0; i < 4; i++)
        {
            int nx = x + dx[i], ny = y + dy[i];
            if (nx < 1 || nx > n || ny < 1 || ny > n)
                continue;
            if (g[nx][ny] || st[nx][ny])
                continue;
            if (dist[nx][ny] > dist[x][y] + 1) {
                dist[nx][ny] = dist[x][y] + 1;
                q.push({nx, ny});
            }
        }
    }
    long long res = 0;
    for (int i = 1; i <= k; i ++) {
        int x = order[i].x, y = order[i].y;
        res += (long long)dist[x][y] * order[i].num;
    }
    return res;
}

int main()
{
    cin >> n >> m >> k >> d;
    for (int i = 1; i <= m; i++)
    {
        scanf("%d%d", &start[i].first, &start[i].second);
    }

    for (int i = 1; i <= k; i++)
    {
        int x, y, c;
        scanf("%d%d%d", &x, &y, &c);
        order[i] = {x, y, c};
    }

    for (int i = 1; i <= d; i++)
    {
        int x, y;
        scanf("%d%d", &x, &y);
        g[x][y] = true;
    }

    cout << bfs() << endl;

    return 0;
}
```

= 第三次
写了前4题

== 门禁系统
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n;
int s[N];

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        int t;
        cin >> t;
        s[t]++;
        cout << s[t] << " ";
    }

    return 0;
}
```

== Z 字形扫描
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 510;

int n;
int g[N][N];

int main() {
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            scanf("%d", &g[i][j]);
        }
    }

    for (int k = 1; k <= 2 * n - 1; k ++) {
        if (k % 2) {
            // 奇
            for (int i = k, j = 1; i >= 1; i --, j ++ ) {
                if (i <= n && j <= n)
                cout << g[i][j] << " ";
            }
        } else {
            // 偶
            for (int i = 1, j = k; j >= 1; j --, i ++) {
                if (j <= n && i <= n)
                cout << g[i][j] << " ";
            }
        }
    }
    return 0;
}
```

== 集合竞价
```cpp
#include<iostream>
#include<cstdio>
using namespace std;
int n;
struct record
{
    int type;
    double p;
    int s;
    bool is_del;
}d[5010];
int main()
{
    string type;
    while(cin>>type)
    {
        if(type=="buy")
        {
            double p;
            int s;
            cin>>p>>s;
            d[++n]={1,p,s};
        }
        else if(type=="sell")
        {
            double p;
            int s;
            cin>>p>>s;
            d[++n]={2,p,s};
        }
        else
        {
            int id;
            cin>>id;
            d[id].is_del=1;
            d[++n].is_del=1;
        }
    }
    double resp=0;
    long long  ress=0;
    for(int i=1;i<=n;i++)
    {
        if(d[i].is_del==0)
        {
            double p=d[i].p;
            long long  s1=0,s2=0;
            for(int j=1;j<=n;j++)
            {
                if(d[j].is_del==0)
                {
                    if(d[j].type==1&&d[j].p>=p) s1+=d[j].s;
                    else if(d[j].type==2&&d[j].p<=p) s2+=d[j].s;
                }
            }
            long long  t=min(s1,s2);
            if(t>ress||t==ress&&p>resp)
                resp=p,ress=t;
        }
    }
    printf("%.2lf %lld\n", resp, ress);
    return 0;
}
```

这个题目没看懂，题解来源： #link("https://www.acwing.com/solution/content/37447/")[链接]

== 最优灌溉
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010, M = 100010;

int n, m;
struct edge{
    int a, b, c;
    bool operator<(const edge& other) {
        return c < other.c;
    }
} edges[M];

int p[N];

int find(int x) {
    if (p[x] != x)
        p[x] = find(p[x]);
    return p[x];
}

int main()
{
    cin >> n >> m;
    for (int i = 0; i < m; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        edges[i] = {a, b, c};
    }

    sort(edges, edges + m);
    for (int i = 0; i <= n; i ++) {
        p[i] = i;
    }

    int res = 0;
    for (int i = 0; i < m; i ++) {
        int a = edges[i].a, b = edges[i].b, c = edges[i].c;
        int pa = find(a), pb = find(b);
        if (pa == pb)
            continue;
        p[pa] = pb;
        res += c;
    }
    cout << res << endl;
    return 0;
}
```

最小生成树的模版题

= 第四次
写了前四题

== 图像旋转
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;
int n, m;
int g[N][N];

int main() {
    cin >> n >> m;
    
    for (int i = 0; i < n; i ++) {
        for (int j = 0; j < m; j ++) {
            scanf("%d", &g[i][j]);
        }
    }
    
    for (int j = m - 1; j >= 0; j --) {
        for (int i = 0; i < n; i ++) {
            printf("%d ", g[i][j]);
        }
        printf("\n");
    }
    
    
    return 0;
}
```

== 数字排序
```cpp
#include <iostream>
#include <cstring>
#include <queue>
#include <algorithm>
#include <map>

using namespace std;

typedef pair<int, int> PII;

struct temp {
    int key, value;
    bool operator<(const temp & t) {
        if (key != t.key) {
            return key < t.key;
        } else {
            return value > t.value;
        }
    }
};

map<int, int> store;
vector<temp> res;

int main() {
    int n;
    cin >> n;
    for (int i = 0; i < n; i ++) {
        int t;
        cin >> t;
        store[t] ++;
    }
    
    for (auto& i : store) {
        int key = i.first, value = i.second;
        res.push_back({value, key});
    }
    
    sort(res.begin(), res.end());
    reverse(res.begin(), res.end());
    
    for (auto& i : res) {
        printf("%d %d\n", i.value, i.key);
    }
    
}
```

== 节日
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int a, b, c, y1, y2;

int months[13] = {
    0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

int is_leap(int y) {
    if (y % 4 == 0 && y % 100 || y % 400 == 0) {
        return 1;
    }
    return 0;
}

int get_days(int year, int month) {
    if (month == 2) return months[month] + is_leap(year);
    return months[month];
}

int main() {
    cin >> a >> b >> c >> y1 >> y2;
    
    int days = 0;
    for (int year = 1850; year <= y2; year ++) {
        for (int month = 1; month <= 12; month ++) {
            if (year >= y1 && month == a) {
                int w = (1 + days) % 7, cnt = 0;
                for (int d = 1; d <= get_days(year, month); d ++) {
                    if (w == c - 1) {
                        cnt ++;
                        if (cnt == b) {
                            printf("%04d/%02d/%02d\n", year, month, d);
                            break;
                        }
                    }
                    w = (w + 1) % 7;
                }
                if (cnt < b) {
                    printf("none\n");
                }
            }
            days += get_days(year, month);
        }
    }
    
    return 0;
}
```

日期相关的问题

== 网络延时
```cpp
#include <iostream>
#include <algorithm>
#include <cstring>
using namespace std;

const int N = 20010;

int n, m;
int h[N], e[N * 2], ne[N * 2], idx;
int d1[N], d2[N], p[N];


void add(int a, int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
}

void dfs_d(int u, int fa) {
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        if (j == fa) continue;
        
        dfs_d(j, u);
        
        int tar = d1[j] + 1;
        if (tar > d1[u]) {
            d2[u] = d1[u], d1[u] = tar, p[u]= j;
        } else if (tar > d2[u]){
            d2[u] = tar;
        }
    }
}

int main() {
    memset(h, -1, sizeof h);
    cin >> n >> m;
    for (int i = 2; i <= n; i ++) {
        int t;
        scanf("%d", &t);
        add(t, i);
        add(i, t);
    }
    for (int i = 1; i <= m; i ++) {
        int tar = i + n;
        int t;
        scanf("%d", &t);
        add(tar, t);
        add(t, tar);
    }
    
    dfs_d(1, -1);

    int res = 0;
    for (int i = 1; i < n + m ;i ++) {
        res = max(res, d1[i] + d2[i]);
    }
    cout << res << endl;
    
    return 0;
}
```

= 第五次
写了前四题

== 数列分段
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n;
int last = -1;
int ans;

int main() {
    cin >> n;
    for(int i = 1; i <= n; i ++) {
        int t;
        cin >> t;
        if (t != last) {
            last = t;
            ans ++;
        }
    }
    cout << ans << endl;
    
    return 0;
}
```

== 日期计算
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 13;

int months[N] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

int y,d;

bool is_leap(int year) {
    if (year % 4 == 0 && y % 100) {
        return true;
    }
    if (year % 400 == 0) {
        return true;
    }
    return false;
}

int main() {
    cin >> y >> d;
    
    months[2] += is_leap(y);
    
    for (int i = 1; i <= 12; i ++) {
        if (d > months[i]) {
            d -= months[i];
        }
        else {
            cout << i << "\n" << d << endl;
            break;
        }
    }
    
    return 0;
}
```

== 模板生成系统
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <unordered_map>
#include <vector>

using namespace std;

int n, m;
vector<string> strs;
unordered_map<string, string> vars;

int main() {
    cin >> n >> m;
    getchar();
    while(n --) {
        string str;
        getline(cin, str);
        strs.push_back(str);
    }
    
    while(m --) {
        string key, value;
        cin >> key;
        char c;
        while(c = getchar(), c != '\"');
        while(c = getchar(), c != '\"') value += c;
        vars[key] = value;
    }
    
    for (auto& str : strs) {
        for (int i = 0; i < str.size();) 
            if(i + 1 < str.size() && str[i] == '{' && str[i + 1] == '{')  {
                int j = i + 3;
                string key;
                while(str[j] != ' ' || str[j + 1] != '}' || str[j + 2] != '}') {
                    key += str[j ++];
                }
                cout << vars[key];
                i = j + 3;
            } else {
                cout << str[i ++];
            }
        cout << "\n";
    }
    
    return 0;
}
```

模拟题，学习代码结构

== 高速公路
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <stack>

using namespace std;

const int N = 10010, M = 100010;

int n, m;
int h[N], e[M], ne[M], idx;
int dfn[N], low[N], timestamp;
int scc_cnt, id[N], scc_num[N]; // scc_num表示一个强连通分量中的点的个数
stack<int> stk;
bool st[N];

void add(int a, int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
}

void tarjan(int u) {
    dfn[u] = low[u] = ++ timestamp;
    stk.push(u);
    st[u] = true;
    
    for (int i = h[u]; ~i; i = ne[i]) {
        int j = e[i];
        if (!dfn[j]) {
            tarjan(j);
            low[u] = min(low[u], low[j]);
        } else if (st[j]) {
            low[u] = min(low[u], dfn[j]);
        }
    }
    
    if (dfn[u] == low[u]) {
        ++ scc_cnt;
        int y;
        do {
            y = stk.top();
            stk.pop();
            
            st[y] = false;
            id[y] = scc_cnt;
            scc_num[scc_cnt] ++;
        } while(y != u);
    }
}

int main() {
    memset(h, -1, sizeof h);
    cin >> n >> m;
    for (int i = 0; i < m; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        add(a, b);
    }
    
    for (int i = 1; i <= n; i ++) {
        if (!dfn[i]) {
            tarjan(i);
        }
    }
    
    int ans = 0;
    // 遍历所有的强连通分量的个数
    for (int i = 1; i <= scc_cnt; i ++) {
        ans += (scc_num[i] * (scc_num[i] - 1)) / 2;
    }
    cout << ans << endl;
    return 0;
}
```

可以由题意得，如果 A 可以到 B，同时 B 也可以到 A，则 A 与 B 在同一个强连通分量中。那么只要求出图中有多少个强连通分量，每个强连通分量有多少个点就可以了。

求强连通分量的办法：#link("/Study/2024-02-17-31194034/")[链接]
