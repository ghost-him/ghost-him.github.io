#import "../../index.typ": template, tufted
#show: template.with(title: "滑动窗口原理")

滑动窗口是给定一个固定长度的窗口，用这个窗口在一个给定的数组上滑动，然后求出这个窗口中的最大/最小值。这个数组可以是一个离线数组，也可以是一个在线数组。

= 例子
以 `acwing` 题目： #link("https://www.acwing.com/problem/content/156/")[154. 滑动窗口] 为例。

给定一个数组：`[1 3 -1 -3 5 3 6 7]`，窗口的大小为 `3`，求出在这个窗口中的#strong[最大值与最小值]。则滑动的过程如下：

#figure(
  table(
    columns: 3,
    align: (center,center,center,),
    table.header([窗口位置], [最小值], [最大值],),
    table.hline(),
    [\[1 3 -1\] -3 5 3 6 7], [-1], [3],
    [1 \[3 -1 -3\] 5 3 6 7], [-3], [3],
    [1 3 \[-1 -3 5\] 3 6 7], [-3], [5],
    [1 3 -1 \[-3 5 3\] 6 7], [-3], [5],
    [1 3 -1 -3 \[5 3 6\] 7], [3], [6],
    [1 3 -1 -3 5 \[3 6 7\]], [3], [7],
  )
  , kind: table
  )

= 朴素算法
每次移动一下，都遍历一下这个窗口中的值，然后选出最大值与最小值。

代码如下：

```cpp
#include <iostream>
#include <algorithm>
using namespace std;

const int N = 1e6 + 10;

// 输入的数据，a[]为数组，n为数组长度，k为窗口的大小
int a[N], n, k;

int maxs[N];    // 最大值的数组
int mins[N];    // 最小值的数组

int main() {
    // 输入数据
    cin >> n >> k;
    for (int i = 1; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    
    // 遍历数组
    for (int r = k; r <= n; r ++) {
        int l = r - k + 1;
        // 设置这一轮的最大值与最小值
        int minv = 1e9, maxv = -1e9;
        for (int i = l; i <= r; i ++) {
            // 求出最大值与最小值
            minv = min(minv, a[i]);
            maxv = max(maxv, a[i]);
        }
        // 将这一轮的最大值与最小值存入结果数组中
        maxs[r] = maxv;
        mins[r] = minv;
    }
    // 输出最小值数组中的值
    for (int i = k; i <= n; i ++) {
        printf("%d ", mins[i]);
    }
    printf("\n");
    // 输入最大值数组中的值
    for (int i = k; i <= n; i ++) {
        printf("%d ", maxs[i]);
    }
    return 0;
}
```

可以看到，最坏时间复杂度为 `O(n^2)`，是很慢的。

= 单调队列优化
使用单调队列优化后的时间复杂度可以降到 `O(n)`，时间是大大减少。

在滑动的过程中，我们可以发现，在多个窗口里，最值可以是同一个，因此，如果我们可以找到一个办法可以快速的求出这个最值的下标，则可以大大的减少时间的花销。

比如：

```
 滑动窗口的位置                最大值   单调队列中的值
---------------               -----   --------
[14 2 27] -5 28 13 39          27      [27]
14 [2 27 -5] 28 13 39          27      [27 -5]
14 2 [27 -5 28] 13 39          28      [28]
14 2 27 [-5 28 13] 39          28      [28 13]
14 2 27 -5 [28 13 39]          39      [39]
```

前 2 个窗口的最值一直为 27。因此我们就可以想到单调队列。这里的单调队列维护的是 #strong[窗口内，最值的下标]。如果求的是最大值，则队列以单调递减排列，如果求的是最小值，则队列以单调递增排列。在每次的遍历时，都要进行以下的处理步骤：

+ 判断队首的元素是否已经离开了窗口
+ 判断队尾的元素是否没有当前的元素好
+ 将当前的元素加入队列中
+ 输出队首的元素

代码如下：

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <deque>

using namespace std;

const int N = 1e6 + 10;

int n, k;
int a[N];
// 用于存放答案
int qi[N];

deque<int> q;

int main () {
    cin >> n >> k;
    for (int i = 1; i <= n; i ++) {
        scanf("%d", &a[i]);
    }
    // 从前往后遍历每一个元素
    for (int i = 1; i <= n; i ++) {
        // 如果当前的队列中还有值，且队首的元素已经离开了窗口，则弹出
        if (q.size() && i - q.front() + 1 > k) q.pop_front();
        // 如果队尾的元素没有当前遍历的元素优秀，则弹出
        while (q.size() && a[q.back()] >= a[i]) q.pop_back();
        // 加入到队尾中
        q.push_back(i);
        // 输出队首的元素
        qi[i] = a[q.front()];
    }
    // 输出最小值
    for (int i = k; i <= n; i ++ ) {
        cout << qi[i] << " ";
    }
    cout << "\n";
    // 队列清空
    q.clear();
    
    for (int i = 1; i <= n; i ++) {
        if (q.size() && i - q.front() + 1 > k) q.pop_front();
        while (q.size() && a[q.back()] <= a[i]) q.pop_back();
        q.push_back(i);
        qi[i] = a[q.front()];
    }
    
    for (int i = k; i <= n; i ++ ) {
        cout << qi[i] << " ";
    }
        
    return 0;
}
```
