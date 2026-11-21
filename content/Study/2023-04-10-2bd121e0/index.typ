#import "../../index.typ": template, tufted
#show: template.with(title: "并查集原理和实现")

= 介绍
并查集是一种树型数据结构，它用于处理#strong[不相交]集合的合并以及查询的问题。它可以指出两个点是否在一个连通块内，以及指出一个点所在的连通块。

= 并查集的操作
并查集有两个操作：

- 合并：将两个不在同一个连通块内的点合并到同一个连通块内。
- 查找：查询当前的这个点所在的连通块的位置。

= 并查集的应用
+ 在最小生成树---kruskal 算法中，判断两个点是否在同一个连通块的时候，就可以使用并查集来判断。
+ 在 tarjan 算法中，使用了并查集来存储当前的子树在哪个根结点中。
+ 可以应用在判断两个人是否是亲戚。

= 并查集的代码的实现
在代码的实现中，我们要开辟一个长度与节点数一致的数组，每个数组存放的是#strong[每个结点所在连通块的根结点]。每个根结点都是一个集合。

```cpp
// 假设一共有1e5个结点, 我们使用下标在[1, 1e5]的元素，不使用下标是0的元素。
const int N = 1e5 + 1;
// p表示每个结点所在连通块的根结点
int p[N];
```

由于在初始时候，每个结点相互独立。因此，在初始化的时候，我们要将每个元素都指向自己。

```cpp
int main () {
    // 初始化每个结点各自的根结点。
    for (int i = 1; i < N; i ++)
        p[i] = i; // 指向自己，表示自己就是一个单独的集合，不属于其他的集合。
}
```

如果我们要查找当前这个点所在的集合，我们要写出一个 `find` 函数。

```cpp
int find(int x) {
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}
```

参数：

- `x` : 表示当前要查找的结点的编号。

返回值：当前查找的结点所在集合（连通块）的根结点。

== 使用的性质
如果结点 a 和结点 b 在同一个连通块，那么，它们的根结点是一样的，即：

```cpp
find(a) == find(b)
```

如果不一样，那么：

```cpp
find(a) != find(b)
```

如果我们要将结点 a 添加到结点 b 的集合中：

```cpp
p[find(a)] = find(b)
```

将 a 结点所在集合的根结点指向 b 结点所在集合的根结点即可。

= 例题
== #link("https://www.acwing.com/problem/content/838/")[AcWing 836. 合并集合]
参考代码:

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e5 + 10;

// 一共有n个结点，m个操作
int n, m;
// 并查集数组
int p[N];

// 查找根结点
int find(int x) {
    if (x != p[x]) p[x] = find(p[x]);
    return p[x];
}

int main () {
    // 读取结点数和操作数
    cin >> n >> m;
    // 初始化并查集
    for (int i = 1; i <= n; i ++) p[i] = i;
    // 读取操作
    while(m --) {
        // 存储每个操作
        char c;
        int a, b;
        // 读取操作
        cin >> c >> a >> b;
        // 查找各自的根结点
        int pa = find(a);
        int pb = find(b);
        // 合并操作
        if (c == 'M') {
            // 如果当前的两个点不在同一个集合中
            if (pa != pb) {
                // 添加到同一个集合
                p[pa] = pb;
            }
        } else {
            // 查询操作
            if (pa == pb) {
                // 如果两个结点的根结点一致，说明是在同一个集合内
                cout << "Yes" << endl;
            } else {
                // 否则说明不在同一个集合内
                cout << "No" << endl;
            }
        }
    }
    
    return 0;
}
```
