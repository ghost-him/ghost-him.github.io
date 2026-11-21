#import "../../index.typ": template, tufted
#show: template.with(title: "kmp算法的原理与实现")

本文介绍了 kmp 算法和实现过程和原理讲解，并提供了完整的实现代码。同时，还详细介绍了 PM 数组到 next 数组到 nextval 数组的转变过程，以及它们之前的转换方法，并提供了可运行代码以供同学们进行自我练习与测试。

= 字符串的前缀，后缀和部分匹配值
前缀：除了最后一个字符外，字符串的所有头部子串。 后缀：除了第一个字符外，字符串的所有尾部子串。 部分匹配：字符串的前缀和后缀的最长相等前后缀的长度。

例：`aba`，前缀：`{a, ab}`；后缀：`{b, ba}`。最长相等前后綴长度：${ a \, a b } sect { b a \, a } = { a }$。所以长度是 1。

此时，我们可以写出一个字符串的所有子串的部分匹配值（Partial Match, PM）：

例：

#figure(
  table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5],),
    table.hline(),
    [S], [a], [b], [c], [a], [c],
    [PM], [0], [0], [0], [1], [0],
  )
  , kind: table
  )

那么，这有什么作用呢？

例如，如果我们要匹配两个字符串：主串：`ababcac` 和模式串： `abcac`

#figure(
  table(
    columns: 8,
    align: (auto,auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6], [7],),
    table.hline(),
    [主串], [a], [b], [a], [b], [c], [a], [c],
    [模式串], [a], [b], [c], [a], [c], [], [],
  )
  , kind: table
  )

我们会发现，在编号是 3 的位置，主串和模式串是不一样的，如果我们是朴素算法，那么应该将模式串移动 1 个字符的位置，来进行下一轮匹配。

但是我们可以通过移动 $M O V E = 已 匹 配 的 字 符 数 - 对 应 的 部 分 的 匹 配 值$ 这么多来进行下一轮匹配。在当前的这个例子中，就是移动 $M O V E = 2 - 0 = 2$ 个字符。即

#figure(
  table(
    columns: 8,
    align: (auto,auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6], [7],),
    table.hline(),
    [主串], [a], [b], [a], [b], [c], [a], [c],
    [模式串], [], [], [a], [b], [c], [a], [c],
  )
  , kind: table
  )

这样来匹配。

我们可以发现，对于主串来说，由于不需要重新再比较已经比较过的字符了，所以可以将算法的时间复杂度从 $O \( n * m \)$ 降到 $O \( n + m \)$

问：这个使用部分匹配值来进行匹配的原理是什么？

我们知道一个字符串的部分匹配值的意思是：这个字符串#strong[最长的]前缀与后缀#strong[相等的]长度。这里有两个限制：一个是最长的，一个是相等的。

例如：对于字符串：`aaaa`，这里前缀可以是 `{a, aa, aaa}`，后缀可以是 `{a, aa ,aaa}`，因此根据这个定义可得，部分匹配值的长度应该是 `aaa` 的长度，即 3。

对于字符串 `ababc` 我们可以知道，当主串的第 i 个字符与子串的第 j 个字符不一致的时候，我们可以从前 j-1 个字符组成的子串中，取出长度是部分匹配值长度的前缀，来代替后缀的位置，即：向右移动模式串，直到前缀和移动前的后缀的位置重合，此时，移动的长度为 $M O V E = j - 1 - p m \[ j - 1 \]$。

例：当前第 #strong[4] 个元素不一致，所以从前 #strong[3] 个字符组成的字符串 `aba` 中取出#strong[长度是部分匹配值]（1）的前缀：`a` 来代替后缀的位置。可以看下面第二个表格：前 3 个字符的后缀是 `a`，因此，将前缀的 a 移动到与后缀重合的位置上，然后再继续比较。

#figure(
  table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4],),
    table.hline(),
    [S], [a], [b], [a], [c],
    [PM], [0], [0], [1], [0],
  )
  , kind: table
  )

#figure(
  table(
    columns: 8,
    align: (auto,auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6], [7],),
    table.hline(),
    [主串], [a], [b], [a], [b], [a], [c], [],
    [模式串], [a], [b], [a], [c], [], [], [],
    [移动后的模式串], [], [], [a], [b], [a], [c], [],
  )
  , kind: table
  )

移动的长度： $M O V E = 3 - 1 = 2$。

= next 数组的由来
我们通过前面的学习，可以知道，每一次匹配失败的时候，都需要去找前一个元素的部分匹配值。为了让这个操作方便一些，我们可以将所有的部分匹配值向右移动一格，使得每一次匹配失败的时候，都只需要找自己的部分匹配值。同时，空出来的地方填为-1，多出来的地方截去。

#figure(
  table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6],),
    table.hline(),
    [S], [a], [b], [c], [a], [c], [],
    [PM], [0], [0], [0], [1], [0], [],
    [PM'], [-1], [0], [0], [0], [1], [0（舍去）],
  )
  , kind: table
  )

所以，移动的距离可以改为 $M O V E = j - 1 - p m \[ j \]$ （当子串的第 j 个字符不匹配的时候） 相当于将整个子串的比较指针移到 $j = j - M O V E = p m \[ j \] + 1$ 个位置上，为了将这个公式更加简洁，我们将 pm 的每个值都加 1，此时，next 数组就求出来了。

#figure(
  table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6],),
    table.hline(),
    [S], [a], [b], [c], [a], [c], [],
    [PM], [0], [0], [0], [1], [0], [],
    [PM'], [-1], [0], [0], [0], [1], [0（舍去）],
    [next], [0], [1], [1], [1], [2], [],
  )
  , kind: table
  )

#strong[`next[j]` 在这里的意思是：在子串的第 j 个字符与主串发生失配的时候，将子串的指针跳到 `next[j]` 所指的位置重新与主串进行比较。（子串的位序从 1 开始）]

= 求 nextval 数组
nextval 数组是对 next 数组的优化。可以再次减小比对的次数，优化代码运行的效率。

我们先来看一个例子：

对于一个主串和模式串：`aaacaaaac` 和 `aaaac`

我们可以知道：

#figure(
  table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5],),
    table.hline(),
    [S], [a], [a], [a], [a], [c],
    [next], [0], [1], [2], [3], [4],
  )
  , kind: table
  )

我们先用 next 数组的解法来求一下这个问题的匹配过程

#figure(
  table(
    columns: 10,
    align: (auto,auto,auto,auto,auto,auto,auto,auto,auto,auto,),
    table.header([编号], [1], [2], [3], [4], [5], [6], [7], [8], [9],),
    table.hline(),
    [主串], [a], [a], [a], [c], [a], [a], [a], [a], [c],
    [模式串], [a], [a], [a], [a], [c], [], [], [], [],
    [模式串移动 1], [], [a], [a], [a], [a], [c], [], [], [],
    [模式串移动 2], [], [], [a], [a], [a], [a], [c], [], [],
    [模式串移动 3], [], [], [], [a], [a], [a], [a], [c], [],
  )
  , kind: table
  )

我们可以看到，由于编号 4 的不同，我们经过了 3 次移动以后，才会去判断主串的下一个字符。这里就是 next 数组的不足之处。

我们可以知道，如果在第 4 个字符两个串不匹配的时候，说明当前模式串的字符的主串的字符不一样。如果 `next[4]` 处的字符和当前的字符一样的时候，那么就可以得出：`next[4]` 处的字符也和当前的主串的字符不一样。所以当前这个字符如果和 `next[4]` 字符一样，那么 `next[4] = next[next[4]]` 。即当前的字符应该跳到 `next[4]` 字符跳到的位置。如果不一样，那么 next 数值保持不变。

= 考试时求 next 和 nextval 数组的方法
以字符串 `ababaa` 为例

#figure(
  table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header([S], [a], [b], [a], [b], [a], [a],),
    table.hline(),
    [k], [1], [2], [3], [4], [5], [6],
    [next], [0], [1], [1], [2], [3], [4],
    [nextval], [0], [1], [0], [1], [0], [4],
  )
  , kind: table
  )

当遍历到第 i (i \> 2)个字符的时候，当前第 i 个元素的 next 值等于#strong[前 i-1 个字符的最大的前缀与后缀相等的时候的值 + 1]。$i = 1$ 时 $i = 2$ 时 next 值分别为 0 和 1。

例如：当 i=1 时，那么 `next[1] = 0`，当 `i = 5` 时，看前 i-1 个元素组成的字符串：`abab`，可以发现最大的公共前缀后缀串为 `ab`。那么当前的 next 值为 `length(ab) + 1 = 2 + 1 = 3`。

对于 nextval 数组，第 1 位无脑写 0。对于其他的字符 i (i \> 1 )，如果当前 next 数组指向的字符 `s[next[i]]` 不等于当前的字符，即：`s[next[i]] != s[i]`，那么当前 nextval 的值等于 next 的值。如果当前 next 数组指向的字符和当前的字符一样，那么当前的 nextval 的值就正好等于 next 指向的那个字符的 nextval 的值，即: `nextval[i] = nextval[next[i]]`。

例：当 i 等于 2 时，`next[2] = 1`，此时，当前的字符是 b，next 指向的字符是 a。a 和 b 不相等，所以当前 nextval 的值就是 next 和值 `nextval[2] = next[2] = 1`。当 i 等于 3 的时候，此时当前的字符是 a，next 指向的字符也是 a，所以当前的 nextval 的值等于指向的字符的 nextval 的值，即 `nextval[3] = nextval[next[3]] = nextval[1] = 0`。

= 使用代码来实现 kmp 算法
== 求 pm 数组，next 数组，nextval 数组\`\`\`cpp
\#include
\#include
\#include

using namespace std;

const int N = 1e5 + 10;

int n; /\/ 要求的数组 char p\[N\]; /\/ pm数组 int pm\[N\]; /\/ next数组 int next\[N\]; /\/ nextval数组 int nextval\[N\];

int main () { /\/ 读取数组的长度和数组，数组从1号开始存放 cin \>\> n \>\> p + 1; /\/ 求pm数组 for (int i = 2, j = 0; i \<= n; i ++) { while (j && p\[i\] != p\[j + 1\]) j = pm\[j\]; if (p\[i\] == p\[j + 1\]) j ++; pm\[i\] = j; } /\/ 输出pm数组 cout \<\< "pm" \<\< endl; for (int i = 1; i \<= n; i ++) { cout \<\< pm\[i\] \<\< ” "\; } cout \<\< endl; /\/ 求next数组 for (int i = 1; i \<= n; i ++) { next\[i\] = pm\[i - 1\] + 1; } /\/ next数组1号为0 next\[1\] = 0; /\/ 输出next数组 cout \<\<"next” \<\< endl; for (int i = 1; i \<= n; i ++) { cout \<\< next\[i\] \<\< ” "\; } cout \<\< endl; /\/ 求nextval数组 for (int i = 1; i \<= n; i ++) { /\/ 如果当前的字符和next跳过以后的字符一样，那么当前字符的nextval和next的nextval一样 if (p\[i\] == p\[next\[i\]\]) { nextval\[i\] = nextval\[next\[i\]\]; } else { /\/ 否则，保持不变 nextval\[i\] = next\[i\]; } } cout \<\<"nextval” \<\< endl; for (int i = 1; i \<= n; i ++) { cout \<\< nextval\[i\] \<\< ” “; }

```
return 0;
```

}

````
## 使用 next 数组进行模式匹配
求 next 数组的部分在上面的代码中已经打过注释了，所以这个代码中就不写相关部分的注释了。

如果要使用 nextval 数组来求，那么只需要添加一段求 nextval 的代码，然后在匹配部分将 `ne` 改成 `nextval` 即可。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1e5 + 10, M = 1e6 + 10;

// n为子串的长度，m为主串的长度
int n, m;
// p为子串，s为主串
char p[N], s[M];
int ne[N];

int main () {
    // 读取子串的长度，子串的内容，主串的长度，主串的内容
    cin >> n >> p + 1 >> m >> s + 1;
    
    for (int i = 2, j = 0; i <= n; i ++) {
        while (j && p[i] != p[j + 1]) j = ne[j];
        if (p[i] == p[j + 1]) j ++;
        ne[i] = j;
    }
    
    for (int i = n; i >= 1; i --) {
        ne[i] = ne[i - 1] + 1;
    }
    ne[1] = 0;
    
    // i遍历主串，j遍历模式串
    int i = 1, j = 1;
    
    while(i <= m && j <= n) {
        if (j == 0 || s[i] == p[j]) {
            i ++;
            j ++;
        }
        else {
            j = ne[j];
        }
    }
    if (j > n) {
        cout << "位序是：" << i - n << endl;
    } else {
        cout << "不匹配" << endl;
    }
    
    return 0;
}
````

= 总结
<总结>
求 next 数组有两种方法：一种是先求 pm 数组，然后将 pm 数组整体向右移一格，再整体加 1 即可得到；另一种是根据定义（前 i-1个字符串中，最长匹配前缀的下一格的位序），直接用手模拟出 `next[i]` 所代表的值。
