#import "../../index.typ": template, tufted
#show: template.with(title: "13年12月CCF计算机软件能力认证")

写了前四题

= 1.出现次数最多的数
```cpp
#include <iostream>
#include <string>
#include <algorithm>
#include <map>

using namespace std;

const int N = 10010;

int n;
int nums[N];

int main()
{
    cin >> n;
    for (int i = 0; i < n; i++)
    {
        int t;
        scanf("%d", &t);
        nums[t]++;
    }

    int maxv = 0;
    int ans = 0;
    for (int i = 0; i < N; i++)
    {
        if (nums[i] > maxv)
        {
            maxv = nums[i];
            ans = i;
        }
    }

    cout << ans << endl;

    return 0;
}
```

= 2.ISBN号码\`\`\`cpp
\#include
\#include
\#include

using namespace std;

int a, b, c; char d;

int main() { scanf("%d-%d-%d-%c", &a, &b, &c, &d);

```
int res = 0;
string t;
t += to_string(a);
t += to_string(b);
t += to_string(c);

for (int i = 0; i < t.size(); i++)
{
    res += (t[i] - '0') * (i + 1);
}

int ans = res % 11;

if (ans == (d - '0') || (ans == 10 && d == 'X'))
{
    cout << "Right";
} else {
    cout << a << "-" << b << "-" << c << "-";
    if (ans == 10) {
        cout << "X";
    } else {
        cout << ans;
    }
}

return 0;
```

}

````

# 3.最大的矩形
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <stack>

using namespace std;

const int N = 1010;

int n;
int nums[N];
int r[N];
int l[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i++)
    {
        cin >> nums[i];
    }

    stack<int> q;
    for (int i = 1; i <= n; i++)
    {
        while (q.size() && nums[q.top()] >= nums[i])
            q.pop();
                
        l[i] = q.empty() ? 0 : q.top();

q.push(i);
    }

    while(q.size()) q.pop();

    for (int i = n; i >= 1; i--)
    {
        while (q.size() && nums[q.top()] >= nums[i])
            q.pop();
       
        r[i] =q.empty() ? n + 1 : q.top();
         q.push(i);
    }

    int res = 0;
    for (int i = 1; i <= n; i ++) {
        res = max(res, nums[i] * (r[i] - l[i] - 1));
    }
    cout << res << endl;
    return 0;
}
````

= 4.有趣的数
<有趣的数>
题解：

组合计数问题。

有四个条件：

+ 0， 1， 2， 3 每个都要至少出现一次
+ 所有的 0 都出现在 1 之前
+ 所有的 2 都出现在 3 之前
+ 最高位不为 0

解题方法：

+ 将数字划分为 2 类：0 与 1 为一类，一共的位数大于等于 2；2 与 3 为一类，一共的位数大于等于 2
+ 设第一类为 k 位，则第二类为 n-k 位。则 2\<= k \<= n - 2

因为首位不可以是 0，所以第一类只可以在 n-1 位中选择，设有 k 位第一类数，则可以放的位置为 $C_(n - 1)^k$ 个。如果 0 有 a 个，则有 k-a 个 1，此时，可以发现，整个序列已经确定下来了。易知：1\<=a\<=k-1。所以整个可能的情况就是 $c_(n - 1)^k * \( k - 1 \) * \( n - k - 1 \)$ 个情况。然后结果就是 k 从 2 到 n-2 取一个求和。

代码：

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;
typedef long long LL;

const int N = 1010, MOD = 1e9 + 7;
  
int n;
int C[N][N];
  
int main()
{
    cin >> n;
    for (int i = 0; i <= n; i++)
    {
        for (int j = 0; j <= i; j++)
        {
            if (!j)
                C[i][j] = 1;
            else
                C[i][j] = (C[i - 1][j] + C[i - 1][j - 1]) % MOD;
        }
    }
  
    int res = 0;
    for (int k = 2; k <= n - 2; k++)
    {
        res = (res + (LL)C[n - 1][k] * (k - 1) % MOD * (n - k - 1) % MOD) % MOD;
    }
    cout << res << endl;
    return 0;
}
```
