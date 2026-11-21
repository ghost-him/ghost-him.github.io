#import "../../index.typ": template, tufted
#show: template.with(title: "第 十六到二十 次CCF计算机软件能力认证")

优先写前2题

= 第十六次
== 小中大
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e5 + 10;

int n;
int a[N];

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        scanf("%d", &a[i]);
    }
    
    cout << max(a[0], a[n - 1]) << " ";
    if (n % 2) {
        cout << a[n / 2] << " ";
    } else {
        if ((a[n / 2] + a[(n / 2) - 1]) % 2) {
            // 分数
            printf("%.1lf ",((double)a[n / 2] + a[(n / 2) - 1]) / 2);
        } else {
            cout << (a[n / 2] + a[(n / 2) - 1]) / 2 << " ";
        }
        
    }
    
    cout << min(a[0], a[n - 1]);
    
    return 0;
}
```

== 二十四点
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <stack>
#include <vector>
#include <map>
using namespace std;
vector<char> out;
stack<char> ops;
stack<int> ans;

map<char, int> level;

void clear() {
    out.clear();
    while(ops.size()) ops.pop();
    while(ans.size()) ans.pop();
}

void add(char i) {
    if (ops.size()) {
        if (level[i] > level[ops.top()]) {
            ops.push(i);
        } else if (level[i] <= level[ops.top()]) {
            while(ops.size() && level[i] <= level[ops.top()]) {
                out.push_back(ops.top());
                ops.pop();
            }
            ops.push(i);
        }
    } else {
        ops.push(i);
    }
}

int compute(string a) {
    clear();
    for (int i = 0; i < a.size(); i ++) {
        if (i % 2) {
            // op
            add(a[i]);
        } else {
            out.push_back(a[i]);
        }
    }
    
     while(ops.size()) {
        out.push_back(ops.top());
        ops.pop();
    }

    
    for (int i = 0; i < out.size(); i ++) {
        if (out[i] >= '0' && out[i] <= '9') {
            ans.push(out[i] - '0');
        } else {
            int r = ans.top(); ans.pop();
            int l = ans.top(); ans.pop();
            if (out[i] == '+') {
                ans.push(l + r);
            } else if (out[i] == '-') {
                ans.push(l - r);
            } else if (out[i] == 'x') {
                ans.push(l * r);
            } else {
                ans.push(l / r);
            }
        }
    }

    return ans.top();
        
}

int main() {
    level['+'] = 1;
    level['-'] = 1;
    level['x'] = 2;
    level['/'] = 2;
    int n;
    cin >> n;
    while(n --) {
        string a;
        cin >> a;
        if (compute(a) == 24) {
            printf("Yes\n");
        } else {
            printf("No\n");
        }
        
    }
    
    return 0;
}
```

== 消息传递接口
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <deque>
#include <sstream>

using namespace std;

const int N = 1e4 + 10;

int T, n;
deque<string> ops[N];

bool check() {
    for (int i = 0; i < n; i ++) {
        if (!ops[i].empty())
            return true;
    }
    return false;
}

int main() {
    cin >> T >> n;
    getchar();
    while(T --) {
        
        for (int i = 0; i < n; i ++) {
            ops[i].clear();
            string line;
            getline(cin, line);
            stringstream ss(line);
            
            while(!ss.eof()) {
                string t;
                ss >> t;
                ops[i].push_back(t);
            }
        }
        bool flag = false;
        while(check()) {
            bool con = false;
            for (int i = 0; i < n; i ++) {
                if (ops[i].empty()) continue;
                string a = ops[i].front();
                if (a[0] == 'R') continue;
                else {
                    int tar = stoi(a.substr(1));
                    if (ops[tar].empty()) {
                        flag = true;
                        break;
                    }
                    string tarOPS = ops[tar].front();
                    if (tarOPS[0] == 'R' && (stoi(tarOPS.substr(1))) == i) {
                        ops[tar].pop_front();
                        ops[i].pop_front();
                        con = true;
                    } 
                }
            }
            
            if (!con)  {
                flag = true;
                break;
            }
        }
        cout << (int)flag << endl;
    }
    
    
    return 0;
}
```

= 第十七次
== 小明种苹果
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int sum[N];
int num[N];

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i ++) {
        scanf("%d", &sum[i]);
        for (int j = 0; j < m; j ++) {
            int t;
            scanf("%d", &t);
            sum[i] += t;
            num[i] += abs(t);
        }
    }
    
    int res = 0;
    for (int i = 0; i < n; i ++) {
        res += sum[i];
    }
    cout << res << " ";
    
    int maxv = num[0], id = 0;
    for (int i = 0; i < n; i ++) {
        if (num[i] > maxv) {
            maxv = num[i];
            id = i;
        }
    }
    
    cout << id + 1 << " " << maxv;
    
    return 0;
}
```

== 小明种苹果（续）
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n, m;
int sum[N * 2];
bool st[N * 2];
int res;

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        int t;
        cin >> t;
        for (int j = 0; j < t; j ++) {
            int c;
            cin >> c;
            if (j) {
                if (c <= 0) {
                    sum[i] += c;
                } else {
                    if (sum[i] != c) {
                        sum[i] = c;
                        st[i] = true;
                    }
                }
            } else {
                sum[i] = c;
            }
        }
    }
    
    int sm = 0;
    for (int i = 0; i < n; i ++) {
        sm += sum[i];
    }
    cout << sm << " ";
    
    for (int i = 0; i < n; i ++) {
        if (st[i])
            res ++;
    }
    cout << res <<  " ";
    
    
    for (int i = n; i < 2 * n; i ++) {
        sum[i] = sum[i - n];
        st[i] = st[i - n];
    }
    
    res = 0;
    for (int i = 1; i <= n; i ++) {
        if (st[i - 1] && st[i] && st[i + 1]) {
            res ++;
        }
    }
    
    cout << res << " ";
    return 0;
}
```

== 推荐系统
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <set>
#include <unordered_map>

#define x first
#define y second

using namespace std;

typedef pair<int, int> PII;

int n, m;

const int N = 55;
// 存储id与score
set<PII> g[N];
// 映射id与score
unordered_map<int, int> f[N];
int sum[N], cnt[N];
set<PII>::reverse_iterator it[N];
vector<int> ans[N];

int main() {
    cin >> m >> n;
    for (int i = 1; i <= n; i ++) {
        int id, score;
        scanf("%d%d", &id, &score);
        for (int j = 0; j < m; j ++) {
            f[j][id] = score;
            g[j].insert({score, -id});
            
        }
    }
    
    int Q;
    scanf("%d", &Q);
    while(Q --) {
        int t;
        scanf("%d", &t);
        if (t == 1) {
            int type, id, score;
            scanf("%d%d%d", &type, &id, &score);
            f[type][id] = score;
            g[type].insert({score, -id});
        } else if (t == 2) {
            int type, id;
            scanf("%d%d", &type, &id);
            
            g[type].erase({f[type][id], -id});
            f[type].erase(id);
        } else {
            int tot;
            scanf("%d", &tot);
            for (int i = 0; i < m; i ++ ){
                scanf("%d", &sum[i]);
                it[i] = g[i].rbegin();
                cnt[i] = 0;
                ans[i].clear();
            }
            // 求k路归并的最大值，求tot个最大值
            while(tot --) {
                // 查询k路中的最大值
                int k = -1;
                for (int i = 0; i < m; i ++) {
                    // 当队列中还有元素，且该类选择的元素的数量小于给定的上限时
                    if (it[i] != g[i].rend() && cnt[i] < sum[i]) {
                        if (k == -1 || it[i]-> x > it[k] -> x) {
                            k = i;
                        }
                    }
                }
                // k为选择的最大值，不为-1，则说明已经选择了其中的一个
                if (k == -1) break;
                ans[k].push_back(-it[k]->y);
                cnt[k] ++;
                it[k] ++;
            }
            for (int i = 0; i < m; i ++) {
                if (ans[i].empty()) cout << -1 << endl;
                else {
                    for (auto x : ans[i]) {
                        printf("%d ", x);
                    }
                    printf("\n");
                }
            }
        }
    }
    
}
```

= 第十八次
== 报数
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;

const int N = 4;

int n;
queue<int> q;
int st[N];

bool check(int i) {
    if (i % 7 == 0) return true;
    while(i) {
        if (i % 10 == 7) {
            return true;
        }
        i /= 10;
    }
    return false;
}

int main() {
    cin >> n;
    for (int i = 0; i < 4; i ++) {
        q.push(i);
    }
    int cnt = 0, i = 1;
    while(cnt < n) {
        int t = q.front();
        q.pop();
        if (check(i)) {
            st[t] ++;
        } else {
            cnt ++;
        }
        q.push(t);
        i ++;
    }
    
    for (int i = 0; i < 4; i ++) {
        cout << st[i] << endl;
    }
    
    
    return 0;
}
```

== ~回收站选址
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <set>

using namespace std;

#define  x first
#define  y second

typedef pair<int, int> PII;
set<PII> store;

int n;
int cnt[5];

int score(PII& loc) {
    int res = 0;
    int ms = 0;    
    for (auto i : store) {
        if (i != loc) {
            if (abs(i.x - loc.x) == 1 && i.y - loc.y == 0) {
                ms ++;
            } else if (abs(i.y - loc.y) == 1 && i.x - loc.x == 0) {
                ms ++;
            }
            
            if (abs(i.x - loc.x) == 1 && abs(i.y - loc.y) == 1) {
                res ++;
            }
            
        }
    }
    if (ms == 4) {
        return res;
    }
    return -1;
}

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        store.insert({a, b});
    }
    
    for (auto i : store) {
        int t = score(i);
        if (t != -1) {
            cnt[t] ++;
        }
    }
    
    for (int i = 0; i < 5; i ++) {
        cout << cnt[i] << "\n";
    }
    
    return 0;
}
```

== 化学方程式
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <unordered_map>

using namespace std;

unordered_map<string, int> parse(string& str, int& i) {
    unordered_map<string, int> res;
    int k = 0;
    while(isdigit(str[i])) {
        k = k * 10 + str[i] - '0';
        i ++;
    }
    k = max(k, 1);

    for (;i < str.size();) {
        if (str[i] == '(') {
            i ++;
            auto ans = parse(str, i);
            int val = 0;
            while(i < str.size() && isdigit(str[i])) {
                val = val * 10 + str[i ++] - '0';
            }
            val = max(val, 1);
            for (auto& i : ans) {
                res[i.first] += i.second * val;
            }
        } else if (str[i] == ')') {
            i ++;
            break;
        } else {
            string temp;
            int val = 0;
            temp.push_back(str[i ++]);
            while(i < str.size() && islower(str[i])) {
                temp.push_back(str[i ++]);
            }
            while(i < str.size() && isdigit(str[i])) {
                val = val * 10 + str[i ++] - '0';
            }
            val = max(val, 1);
            res[temp] += val;
        }
    }

    for (auto& i : res) {
        i.second *= k;
    }


    return res;
}

vector<string> cut(string& str) {
    str.push_back('+');
    string temp;
    vector<string> res;
    for (int i = 0; i < str.size(); i ++) {
        if (str[i] != '+') {
            temp.push_back(str[i]);
        } else {
            res.push_back(temp);
            temp.clear();
        }
    }
    return res;
}

int main() {
    int n;
    cin >> n;
    while(n --) {
        string line;
        cin >> line;
        auto it = line.find('=');
        string left = line.substr(0, it);
        string right = line.substr(it + 1);
        
        vector<string> lefts = cut(left);
        vector<string> rights = cut(right);
        
        unordered_map<string, int> left_cnt, right_cnt;
        
        
        for (auto& i : lefts) {
            int k = 0;
            auto maps = parse(i, k);
            for (auto&j : maps) {
                left_cnt[j.first] += j.second;
            }
        }
        
        for (auto& i : rights) {
            int k = 0;
            auto maps = parse(i, k);
            for (auto&j : maps) {
                right_cnt[j.first] += j.second;
            }
        }
        
     
        //cout << "---" << endl;
        for (auto& i : left_cnt) {
            //cout << i.first << " " << i.second << endl;
            right_cnt[i.first] -= i.second;
            //cout << i.first << " " << right_cnt[i.first]<<endl;
            if (right_cnt[i.first] == 0)
                right_cnt.erase(i.first);
        }
        
        if (right_cnt.size()) cout << "N" << endl;
        else cout << "Y" << endl;
        
    }
    
    
    return 0;
}
```

= 第十九次
== ~线性分类器
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;
typedef long long LL;

struct Node {
    int x, y;
    char type;
}node[N];

int n, m;

LL get(int a, int b, int c, int x, int y) {
    return (LL)a + (LL)b * x + (LL)c * y;
}

bool same(LL a, LL b) {
    if (a > 0 && b > 0) return true;
    if (a < 0 && b < 0) return true;
    return false;
}

bool check(int a, int b, int c) {
    LL t = 0;
    for (int i = 1; i <= n; i ++) {
        if (node[i].type == 'A') {
            LL num = get(a, b, c, node[i].x, node[i].y);
            if (t && !same(num, t)) {
                return false;
            }
            t = num;
        }
    }
    for (int i = 1; i <= n; i ++) {
        if (node[i].type == 'B') {
            LL num = get(a, b, c, node[i].x, node[i].y);
            if (same(num , t)) {
                return false;
            }
        }
    }
    return true;
}

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        int x, y;
        char t[2];
        scanf("%d%d%s", &x, &y, &t);
        node[i] = {x, y, t[0]};
    }
    
    for (int i = 1; i <= m; i ++) {
        int a, b, c;
        scanf("%d%d%d", &a, &b, &c);
        if (check(a,b,c)) {
            cout << "Yes" << endl;
        } else {
            cout << "No" << endl;
        }
    }
    
    return 0;
}
```

判断点在直接的哪边：将 x, y 代入方程，如果大于 0，则在直线的上方，如果小于 0，则在直线的下方。

== 稀疏向量
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <map>

using namespace std;

typedef long long LL;

int n;
map<int, int> ta, tb;
LL res ;
int main() {
    int a, b;
    cin >> n >> a >> b;
    for (int i = 0; i < a ; i ++) {
        int idx, val;
        scanf("%d%d", &idx, &val);
        ta[idx] = val;
    }
    
    for (int i = 0; i < b; i ++) {
        int idx, val;
        scanf("%d%d", &idx, &val);
        tb[idx] = val;
    }
    
    for (auto& i: ta) {
        int idx = i.first, val = i.second;
        res += (LL)val * tb[idx];
    }
    cout << res << endl;
    return 0;
}
```

= 第二十次
== ~称检测点查询
```cpp
#include <iostream>
#include <cstring>
#include <vector>
#include <cmath>
#include <algorithm>

using namespace std;

const int N = 210;
typedef pair<int, int> PII;

struct Loc{
    int x, y;
} loc[N];

int n, x, y;

struct dis {
    double dist;
    int idx;
    bool operator<(const dis& t) const {
        if(dist != t.dist) return dist < t.dist;
        return idx < t.idx;
    }
};

vector<dis> store; // {dist, idx}

double get_dist(int x1, int y1, int x2, int y2) {
    double dx = x1 - x2;
    double dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
}

int main() {
    cin >> n >> x >> y;
    for (int i = 1; i <= n; i ++) {
        int x, y;
        scanf("%d%d", &x, &y);
        loc[i] = {x, y};
    }
    
    for (int i = 1; i <= n; i ++) {
        double dist = get_dist(x, y, loc[i].x, loc[i].y);
        store.push_back({dist, i});
    }
    
    sort(store.begin(), store.end());
    
    for (int i = 0; i < 3; i ++) {
        cout << store[i].idx << endl;
    }
    return 0;
}
```

== 风险人群筛查
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

int n, k, t, x1, y1, x2, y2;

int stay, pass;

bool check(int x, int y) {
    if (x >= x1 && x <= x2) {
        if (y >= y1 && y <= y2) {
            return true;
        }
    }
    return false;
}

int main() {
    cin >> n >> k >> t >> x1 >> y1 >> x2 >> y2;
    for (int i = 0; i < n; i ++) {
        int cnt = 0;
        bool flag = false;
        bool flag_st = false;
        for (int j = 0; j < t; j ++) {
            int x, y;
            scanf("%d%d", &x, &y);
            if (check(x, y)) {
                cnt ++;
                flag = true;
                if (cnt >= k) {
                    flag_st = true;
                }
            } else {
                cnt = 0;
            }
        }
        if (flag) {
            pass ++;
        } 
        if (flag_st) {
            stay ++;
        }
    }
    
    cout << pass << "\n" << stay << endl;
    
    return 0;
}
```

== 点亮数字人生
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>
#include <queue>

using namespace std;

const int N = 3010, M = N * 5;

int m, n;
int w[N], f[N];
int h[N], e[M], ne[M], idx;
queue<int> q, d[N];
vector<int> in[M], out[M];

int get(char* str) {
    string names[] ={
        "AND", "OR", "NOT", "XOR", "NAND", "NOR"
    };
    for (int i = 0; i < 6; i ++) {
        if (names[i] == str)
            return i;
    }
    return -1;
}

void add(int a, int b) {
    e[idx] = b, ne[idx] = h[a], h[a] = idx ++;
    d[b] ++;
}

bool topsort() {
    q.clear();
    for (int i = 1; i <= m + n; i ++) {
        if (!d[i]) {
            q[++ tt] = i;
        }
    }
    int cnt = 0;
    while(q.size()) {
        int t = q.front();
        cnt ++;
        q.pop();
        
        for (int i = h[t]; ~i; i = ne[i]) {
            int j = e[i];
            if ( -- d[j] == 0) {
                q.push(j);
            }
        }
    }
    return cnt == m + n - 1;
}

int main() {
    int T;
    scanf("%d", &T);
    while(T --) {
        scanf("%d%d", &m, &n);
        memset(h, -1, sizeof h);
        idx = 0;
        memset(d, 0, sizeof d);
        char str[100];
        for (int i = 1; i <= n; i ++) {
            int cnt;
            scanf("%s%d", str, &cnt);
            f[m + i] = get(str);
            while(cnt --) {
                scanf("%s", str);
                int t = atoi(str + 1);
                if (str[0] == 'I') add(t, m + 1);
                else add(m + t, m + 1);
            }
        }
        
        int Q;
        scanf("%d", &Q);
        for (int i = 0; i < Q;i ++) {
            in[i].clear();
            for (int j  0; j < m; j ++) {
                int x;
                scanf("%d", &x);
                in[i].push_back(x);
            }
        }
        for (int i = 0; i < Q;i ++) {
            out[i].clear();
            int cnt;
            scanf("%d", &cnt);
            while(cnt --) {
                int x;
                scanf("%d", &x);
                out[i].push_back(x);
            }
        }
        if (!topsort()) {
            cout << "LOOP" << endl;
        } else {
            for (int i = 0; i < Q; i ++) {
                for (int j = 0; j < m; j ++) {
                    w[j + 1] = in[i][j];
                }
                for (int j = m + 1; j < m + n; j ++) {
                    if (f[j] == 0 || f[j] == 5) w[j] = 1;
                    else w[j] = 0;
                }
            }
        }
        
    }
    
}
```

== 星际旅行
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <cmath>

using namespace std;

const int N = 110, M = 2010;

int n, m;
double R;
double o[N], p[M][N];
double d[M], rd[M];
double ans[M];

inline double sqr(double x) {
    return x * x;
}


int main() {
    scanf("%d%d%lf", &n, &m, &R);
    for (int i = 0; i < n; i ++) scanf("%lf", &o[i]);
    for (int i = 0; i < m; i++) {
        double s = 0;
        for (int j = 0; j < n; j ++) {
            scanf("%lf", &p[i][j]);
            s += sqr(p[i][j] - o[j]);
        }
        d[i] = sqrt(s);
        rd[i] = sqrt(s - sqr(R));
    }
    
    for (int i = 0; i < m; i ++) {
        for (int j = 0; j < i; j ++) {
            double s = 0;
            for (int k = 0; k < n; k ++) {
                s += sqr(p[i][k] - p[j][k]);
            }
            double c = sqrt(s), a = d[i], b = d[j];
            double p = (a + b + c) / 2;
            double area = sqrt(p * (p - a) * (p - b) * (p - c));
            double h = area * 2 / c;
            if (h >= R || sqr(b) >= sqr(a) + s || sqr(a) >= sqr(b) + s) {
                ans[i] += c, ans[j] += c;
                continue;
            }
            double angle1 = acos((sqr(a) + sqr(b) - s) / (2 * a * b));
            double angle2 = acos(R / a);
            double angle3 = acos(R / b);
            double t = (angle1 - angle2 - angle3) * R + rd[i] + rd[j];
            ans[i] += t, ans[j] += t;
        }
    }
    for (int i = 0; i < m; i ++) {
        printf("%.12lf\n", ans[i]);
    }
    
}
```
