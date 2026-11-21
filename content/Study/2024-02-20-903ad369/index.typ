#import "../../index.typ": template, tufted
#show: template.with(title: "欧拉回路和欧拉路径")

= 定义
欧拉路径：一条能够不重不漏地经过图上的每一条边的路径

欧拉回路：起点和终点是同一个点的欧拉路径

= 思路
在一个图中，对于起点与终点来说，一定会从它出发或在其终结，因此，它们的度数一定是奇数。对于中间点来说，进入了该点以后一定会出去，所以它们的度一定是偶数。

= 结论
+ 对于无向图，所有边是连通的：
  + 存在欧拉路径的充分必要条件：度数是奇数的点只能有 0 个或 2 个。
  + 存在欧拉回路的充分必要条件：度数为奇数的点只能有 0 个。
+ 对于有向图，所有边是连通的：
  + 存在欧拉路径的充分必要条件：要么所有点的出席等于入度，要么除了两个点之外，其余所有点的出度等于入度，剩余的两个点，起点满足出度比入度多 1，终点满足入度比出度多 1。
  + 存在欧拉回路的充分必要条件：所有的出度均等于入度。

判断一个图是不是欧拉图

+ 无向图
  + 所有点的度数必需都是偶数
  + 所有的边连通
+ 有向图
  + 所有点的入度等于出度
  + 所有的边连通

= 例题
#link("https://www.acwing.com/problem/content/description/1125/")[铲雪车]

代码

```cpp
#include <cstring>
#include <iostream>
#include <algorithm>
#include <cmath>

using namespace std;

int main() {
    double x1, y1, x2, y2;
    cin >> x1 >> y1;
    
    double sum = 0;
    while(cin >> x1 >> y1 >> x2 >> y2) {
        double dx = x1 - x2;
        double dy = y1 - y2;
        sum += sqrt(dx * dx + dy * dy) * 2;
    }
    
    int minutes = round(sum / 1000 / 20 * 60);
    int hours = minutes / 60;
    minutes %= 60;
    printf("%d:%02d", hours, minutes);
    
}
```
