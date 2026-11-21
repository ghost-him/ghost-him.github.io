#import "../../index.typ": template, tufted
#show: template.with(title: "第21到25次CCF计算机软件能力认证")

优先写前2题

= 第21次
== 期末预测之安全指数
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;


int main() {
    int n;
    cin >> n;
    long long res = 0;
    
    while(n --) {
        int w, score;
        scanf("%d%d", &w, &score);
        
        res += w * score;
    }
    
    cout << max((long long)0, res) << endl;
    
    return 0;
}
```

== 期末预测之最佳阈值
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

#include <map>

using namespace std;

const int N = 1e5 +10;

int m;

typedef pair<int, int> PII;

PII c[N];

int y[N], result[N];

int s0[N], s1[N];

int main() {
    cin >> m;
    for (int i = 1; i <= m; i ++) {
        scanf("%d%d", &c[i].first, &c[i].second);
    }
    
    sort(c + 1, c + 1 + m);
    
    for (int i = 1; i <= m ; i ++) {
        s0[i] += s0[i - 1] + (c[i].second == 0);
        s1[i] += s1[i - 1] + (c[i].second == 1);
    }
    
    int res = 0;
    int maxv = -1;
    for (int i = 1; i <= m; i ++) {
        
        int t = s1[m] - s1[i - 1];
        t += s0[i - 1];
        if (t >= maxv) {
            maxv = t;
            res = c[i].first;
        }
        while(i + 1 <= m && c[i + 1].first == c[i].first) i ++;
    }
    
    cout << res << endl;
    
    return 0;
}
```

= 第22次
== 灰度直方图
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 300;

int n, m, L;

int g[N];

int main() {
    cin >> n >> m >> L;
    for (int i = 0; i < n; i ++) {
        for (int j = 0; j < m; j ++) {
            int t;
            scanf("%d", &t);
            g[t] ++;
        }
    }
    for (int i = 0; i < L; i ++) {
        printf("%d ", g[i]);
    }
    
    return 0;
}
```

== ~邻域均值
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 610;

int n, L, r, t;
int g[N][N];

int main() {
    cin >> n >> L >> r >> t;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            scanf("%d", &g[i][j]);
        }
    }
    
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            g[i][j] += g[i][j - 1] + g[i - 1][j] - g[i - 1][j - 1];
        }
    }
    int res = 0;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            int x1 = min(i + r, n);
            int y1 = min(j + r, n);
            
            int x2 = max(i - r, 1);
            int y2 = max(j - r, 1);
            int sum = g[x1][y1] - g[x1][y2 - 1] - g[x2 - 1][y1] + g[x2 - 1][y2 - 1];
            int num = (x1 - x2 + 1) * (y1 - y2 + 1);
                       // cout << i << " " << j  << " " << num<< endl;
            
            if (sum <= t * num) {
                res ++;
            }
        }
    }
    
    cout << res << endl;
    return 0;
}
```

== DHCP 服务器
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <unordered_map>

const int M = 1e5 + 10;

using namespace std;

struct IP {
    int status;
    string owner;
    int expired;
}ips[M];

int N, Tdef, Tmax, Tmin;
string H;
int n;

int getIP(string send) {
    for (int i = 1; i <= n; i ++) {
        if (ips[i].owner == send)
            return i;
    }
    
    for (int i = 1; i <= N; i ++) 
        if (ips[i].status == 0)
            return i;
    
    for (int i = 1; i <= N; i ++)
        if (ips[i].status == 3)
            return i;
    return -1;
}

void expire(int t) {
    for (int i = 1; i <= N; i ++) {
        if (ips[i].expired && ips[i].expired <= t) {
            if (ips[i].status == 1) {
                ips[i].status = 0;
                ips[i].owner.clear();
                ips[i].expired = 0;
            } else {
                ips[i].status = 3;
                ips[i].expired = 0;
            }
        }
    }
    
    
}

void discover(int t, string send, string receive, int expired) {
    int idx = getIP(send);
    if (idx == -1) {
        return;
    }
    IP& ip = ips[idx];
    
    ip.status = 1;
    ip.owner = send;
    
    if (expired == 0) {
        ip.expired = t + Tdef;
    } else {
        int td = expired - t;
        if (td >= Tmax) {
            ip.expired = t + Tmax;
        } else if (td <= Tmin) {
            ip.expired = t + Tmin;
        } else {
            ip.expired = expired;
        }
    }
    
    cout << H << " " << send << " OFR " << idx << " " << ip.expired << endl;
}

void Request(int t, string send, string receive, int ip, int expired) {
    if (receive != H) {
        for (int i = 1; i <= N; i ++) {
            IP&j = ips[i];
            if (j.owner == send) {
                if (j.status == 1) {
                    j.status = 0;
                    j.owner.clear();
                    j.expired = 0;
                }
            }
        }
        return;
    }    
    
    if (ip <= N && ip >= 1 && ips[ip].owner == send) {
        
    } else {
         cout << H << " " << send << " NAK " << ip << " " << 0 << endl;
         return ;
    }
    
    IP&j = ips[ip];
    j.status = 2;
    j.owner = send;
    
    if (expired == 0) {
        j.expired = t + Tdef;
    } else {
        int td = expired - t;
        if (td >= Tmax) {
            j.expired = t + Tmax;
        } else if (td <= Tmin) {
            j.expired = t + Tmin;
        } else {
            j.expired = expired;
        }
    }
    
    cout << H << " " << send << " ACK " << ip << " " << j.expired << endl;
    
}


int main() {
    cin >> N >> Tdef >> Tmax >> Tmin >> H;
    cin >> n;
    
    for (int i = 1; i <= n; i ++) {
        int t;
        string send, receive, type;
        int ip, expired;
        cin >> t >> send >> receive >> type >> ip >> expired;
        if (receive != H && receive != "*" && type != "REQ") continue;
        // 如果不是discover, request之一，则不处理
        if (type != "REQ" && type != "DIS") continue;
        // 如果接收主机为* 但类型不是discover或接收主机是本机，但类型是discover，则不处理
        if ((receive == "*" && type != "DIS" )||(receive == H && type == "DIS")) continue;
        
        expire(t);
        
        if (type == "DIS") {
            discover(t, send, receive, expired);
        } else if (type == "REQ") {
            Request(t, send, receive, ip, expired);
        }
        
    
        
    }
    
    return 0;
}
```

== 校门外的树
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

typedef long long LL;

const int N = 1010, M = 1e5 + 10, MOD = 1e9 + 7;

int n;
int a[N];
int f[N];
vector<int> q[M];
bool st[M];


int main() {
    for (int i = 1; i < M; i ++) {
        for (int j = i * 2; j < M; j += i) {
            q[j].push_back(i);
        }
    }    
    
    scanf("%d", &n);
    for (int i = 0; i < n; i ++) {
        scanf("%d", &a[i]);
    }
    
    f[0] = 1;
    for (int i = 1; i < n; i ++) {
        memset(st, 0, sizeof st);
        for (int j = i - 1; j >= 0; j --) {
            int d = a[i] - a[j], cnt = 0;
            for (int k : q[d]) {
                if (!st[k]) {
                    cnt ++;
                    st[k] = true;
                }
            }
            st[d] = true;
            f[i] = (f[i] + (LL)f[j] * cnt) % MOD;
        }
    }
    
    cout << f[n - 1] << endl;
    
    return 0;
}
```

= 第23次
== ~数组推导
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

const int N = 100;

int n;
vector<int> a;

int main() {
    cin >> n;
    for (int i = 0; i < n; i ++) {
        int t;
        scanf("%d", &t);
        a.push_back(t);
    }
    
    int maxv = 0;
    for (auto i : a) {
        maxv += i;
    }
    
    sort(a.begin(), a.end());
    a.erase(unique(a.begin(), a.end()), a.end());
    int minv = 0;
    for (auto i : a) {
        minv += i;
    }
    
    cout << maxv << "\n" << minv << endl;
    
    return 0;
}
```

== 非零段划分
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 500010, M = 10010;

int n;
int a[N], cnt[M];

int main() {
    scanf("%d", &n);
    for (int i = 1; i <= n; i ++) scanf("%d", &a[i]);
    
    n = unique(a + 1, a + 1 + n) - a - 1;
    a[0] = a[n + 1] = 0;
    for (int i = 1; i <= n; i ++) {
        int x = a[i - 1], y = a[i], z = a[i + 1];
        if (x < y && z < y) cnt[y] ++;
        else if (x > y && z > y) cnt[y] --;
    }
    
    int res = 0, sum = 0;
    for (int i = M - 1; i; i --) {
        sum += cnt[i];
        res = max(res, sum);
    }
    cout << res << endl;
    
}
```

== ~脉冲神经网络
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 2010, INF = 1e8;

int n, s, p, T;
double dt;
int h[N], e[N], D[N], ne[N], idx;
double W[N], v[N], u[N], a[N], b[N], c[N], d[N];

int r[N], cnt[N];
double I[1024][N / 2];

void add(int a, int b, double c, int d) {
    e[idx] = b, W[idx] = c, D[idx] = d, ne[idx] = h[a], h[a] = idx ++;
}

static unsigned long _next = 1;

/* RAND_MAX assumed to be 32767 */
int myrand(void) {
    _next = _next * 1103515245 + 12345;
    return((unsigned)(_next/65536) % 32768);
}

int main() {
    memset(h, -1, sizeof h);
    scanf("%d%d%d%d", &n, &s, &p, &T);
    scanf("%lf", &dt);
    for (int i = 0; i < n; ) {
        int rn;
        scanf("%d", &rn);
        double vv, uu, aa, bb, cc, dd;
        scanf("%lf%lf%lf%lf%lf%lf", &vv, &uu, &aa, &bb, &cc, &dd);
        for (int j = 0; j < rn; j ++, i ++) {
            v[i] = vv, u[i] = uu, a[i] = aa, b[i] = bb, c[i] = cc, d[i] = dd;
        }
    }
    
    for (int i = n; i < n + p; i ++) scanf("%d", &r[i]);
    
    int mod = 0;
    while(s --) {
        int a, b, d;
        double c;
        scanf("%d%d%lf%d", &a, &b, &c, &d);
        add(a, b, c, d);
        mod = max(mod, d + 1);
    }
    
    for (int i = 0; i < T; i ++) {
        int t = i % mod;
        for (int j = n; j < n + p; j ++) {
            if (r[j] > myrand()) {
                for (int k = h[j]; ~k; k = ne[k]) {
                    int x = e[k];
                    I[(t + D[k]) % mod][x] += W[k];
                }
            }
        }
    
        for (int j = 0; j < n; j ++) {
            double vv = v[j], uu = u[j];
            v[j] = vv + dt * (0.04 * vv * vv + 5 * vv + 140 - uu) + I[t][j];
            u[j] = uu + dt * a[j] * (b[j] * vv - uu);
            
            if (v[j] >= 30) {
                for (int k = h[j]; ~k; k = ne[k]) {
                    int x= e[k];
                    I[(t + D[k]) % mod][x] += W[k];
                }
                cnt[j] ++;
                v[j] = c[j], u[j] += d[j];
            }
        }
           memset(I[t], 0, sizeof I[t]);
    }
    
    double minv = INF, maxv = -INF;
    int minc = INF, maxc = -INF;

    for (int i = 0; i < n; i ++ )
    {
        minv = min(minv, v[i]);
        maxv = max(maxv, v[i]);
        minc = min(minc, cnt[i]);
        maxc = max(maxc, cnt[i]);
    }

    printf("%.3lf %.3lf\n", minv, maxv);
    printf("%d %d\n", minc, maxc);

    
}
```

= 第24次
== 序列查询
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 210;


int n, m;
int a[N];

int find(int x) {
    int l = 0, r = n;
    while(l < r) {
        int mid = l + r + 1 >> 1;
        if (a[mid] < x) l = mid;
        else r = mid - 1;
    }
    return l;
}

int main() {
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    a[n + 1] = m;
    
    long long res = 0;
    for (int i = 1; i <= n + 1; i ++) {
        int x = find(a[i]);
        res += (a[i] - a[i - 1]) * x;
    }
 
    cout << res << endl;
}
```

== 序列查询新解
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

typedef long long LL;

const int N = 100010;

int n, m;
int a[N];
int R;

LL get(int l, int r) {
    if (l / R == r / R) {
        return (LL)(r - l + 1) * (l / R);
    }
    int a = l / R + 1, b = r / R - 1;
    LL res = (a + b) * (LL)(b - a + 1) / 2 * R;
    res += (a - 1) * (LL)(a * R - l);
    res += (b + 1) * (LL)(r - (b * R + R) + 1);
    return res;
}

int main() {
    scanf("%d%d", &n, &m);
    for (int i = 1; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    a[n + 1] = m;
    R = m / (n + 1);
    
    LL res = 0;
    for (int i = 0; i <= n; i ++) {
        int l = a[i], r = a[i + 1] - 1;
        int x = l / R, y = r / R;
        if (y <= i || x >= i) {
            res += abs((LL)i * (r - l + 1) - get(l, r));
        } else {
            int mid = i * R;
            res += abs((LL)i * (mid - l + 1) - get(l, mid));
            res += abs((LL)i * (r - mid) - get(mid + 1, r));
        }
    }
    
    cout << res << endl;
    return 0;
}
```

= 第25次
== 未初始化警告
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e5 + 10;

int n, k;
bool st[N];


int main() {
    cin >> n >> k;
    int res = 0;
    st[0] = true;
    for (int i = 0; i < k; i ++) {
        int a, b;
        scanf("%d%d", &a, &b);
        if (!st[b])
            res ++;
        st[a] = true;
    }
    
    cout << res << endl;
    return 0;
}
```

== 出行计划
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 2e5 + 10;

int n, m, k;
int s[N];

void add(int l, int r) {
    s[l] ++;
    s[r + 1] --;
}

int main() {
    cin >> n >> m >> k;
    for (int i = 1; i <= n; i ++) {
        int t, c;
        scanf("%d%d", &t, &c);
        add(max(t - c + 1, 0), t);
    }
    
    for (int i = 1; i <= 2e5 + 1; i ++) {
        s[i] += s[i - 1];
    }
    
    for (int i = 0; i < m; i ++) {
        int t;
        scanf("%d", &t);
        t += k;
        if (t > N) cout << 0 << endl;
        else cout << s[t] << endl;
    }
    
    return 0;
}
```
