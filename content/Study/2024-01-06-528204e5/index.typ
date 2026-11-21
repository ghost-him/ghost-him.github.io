#import "../../index.typ": template, tufted
#show: template.with(title: "Trie 树实现")

Trim 树是一个树状的数据结构，它可以实现很快的查找与添加。一共有两个函数：`insert()` 与 `query()`。一个实现添加，一个实现查找。

Trim 树存储树据的方式是：一个结点是一个字符，从树结点到其一个子结点中所经过的所有结点连起来时为结点。例如：

```
          o
         / \
        n   v
       /   /
      e   e
         /
        r
```

以上字典树可以表示以下单词: `on`，`one`，`over`。

例题：#link("https://www.acwing.com/problem/content/description/837/")[Trie字符串统计]

代码：

```cpp
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

const int N = 1e5 * 26 + 10;

// tr[i][j]表示根结点是i，子结点为j + 'a'。如果tr[i][j] != 0，则说明当前有这个子结点，如果==0，则说明没有这个结点
int tr[N][26], idx; // idx为一个结点的全局唯一序号，
int cnt[N];

void add(string & x) {
    int p = 0; // 从树结点出发
    for (auto& i : x) { 
        int u = i - 'a'; // 将ascii字母映射成0-26的数值
        if (!tr[p][u]) tr[p][u] = ++ idx; // 如果当前结点没有叶子结点，则添加一个叶子结点
        p = tr[p][u]; // 将当前结点的指针移动到叶子结点上
    }
    cnt[p] ++;
}

int query(string & x) {
    int p = 0;
    for (auto& i : x) {
        int u = i - 'a';
        if (!tr[p][u]) return 0;  // 如果tr[p][u] == 0，则说明当前没有
        p = tr[p][u];
    }
    return cnt[p];
}

int main () {
    int n;
    cin >> n;
    for (int i = 0; i < n; i ++) {
        char I;
        string x;
        cin >> I >> x;
        
        if (I == 'I') {
            add(x);
        } else {
            cout << query(x) << endl;
        }
    }
    return 0;
}
```
