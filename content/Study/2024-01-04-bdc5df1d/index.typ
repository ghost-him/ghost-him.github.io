#import "../../index.typ": template, tufted
#show: template.with(title: "AcWing 4908. 饥饿的牛")

= 题目描述
贝茜是一头饥饿的牛。

每天晚上，如果牛棚中还有干草的话，贝茜都会吃掉其中的一捆。

初始时，牛棚中没有干草。

为了让贝茜不被饿死，农夫约翰制定了 N 个给贝茜送干草的计划。

其中第i个计划是在第di天的白天给贝茜送去bi捆干草。

这些计划互不冲突，保证1≤d1＜d2＜．．．＜dN≤T。请你计算，贝茜在第1～T 天中有多少天有干草吃。

题目链接：#link("https://www.acwing.com/problem/content/description/4911/")[4908. 饥饿的牛]

= 题解
代码

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

typedef long long LL;

using namespace std;

vector<pair<LL, LL>> store;

LL n, t;

int main () {
    cin >> n >> t;
    // 读取输入
    for (int i = 0; i < n; i ++) {
        LL d, b;
        scanf("%lld%lld", &d, &b);
        store.push_back({d, b});
    }
    // 排序
    sort(store.begin(), store.end());
    LL res = 0; // 答案
    LL day = 0; // 上一次送食物的时间
    LL food = 0;// 剩下的食物
    // 遍历每个数对
    for (auto & i : store) {
        // 获得天与食物的数量
        LL d = i.first, b = i.second;
        // 获取这一次送过来与上一次送过来的天数之差
        LL c = d - day;
        // 如果天数之差大于食物的数量，则有food天有食物吃
        if (food <= c) {
            res += food;
            food = 0;
        }
        else {
            // 如果天数之差小于食物的数量，则在这期间都有食物可以吃
            res += c;
            food -= c;
        }
        food += b;
        day = d;
    }
    // 如果天数与食物之和大于了t，则增加天数直到t为止
    if (day + food > t) {
        res += t - day + 1;
    } else {
        // 如果剩下的食物不足以支撑到第t天，则加food天
        res += food;
    }
    cout << res << endl;
    return 0;
}
```

模拟题，直接看代码即可，代码中有详细注释。
