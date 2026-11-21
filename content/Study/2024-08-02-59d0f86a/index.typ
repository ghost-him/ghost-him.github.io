#import "../../index.typ": template, tufted
#show: template.with(title: "C++20三向比较运算符详解")

三向比较运算符可以用于确定两个值的大小顺序，也被称为太空飞船操作符。使用单个表达式，它可以告诉一个值是否等于，小于或大于另一个值。

它返回的是类枚举（enumeration-like）类型，定义在 `<compare>` 与 `std` 名称空间中。其运算的结果如下：

#figure(
  table(
    columns: (44.83%, 34.48%, 20.69%),
    align: (auto,auto,auto,),
    table.header([数据类型], [值], [含义],),
    table.hline(),
    [如果操作数为整数类型，其结果称为 `强排序(strong_ordering)`], [`strong_ordering::less`], [左边的操作数#strong[小于]右边的操作数],
    [], [`strong_ordering::greater`], [左边的操作数#strong[大于]右边的操作数],
    [], [`strong_ordering::equal`], [左边的操作数#strong[等于]右边的操作数],
    [如果操作数为浮点类型，其结果称为 `偏序(partial_ordering)`], [`partial_ordering::less`], [左边的操作数#strong[小于]右边的操作数],
    [], [`partial_ordering::greater`], [左边的操作数#strong[大于]右边的操作数],
    [], [`partial_ordering::equivalent`], [左边的操作数#strong[等于]右边的操作数],
    [], [`partial_ordering::unordered`], [无法比较时（有一个非数字）],
    [如果操作数为自己实现的类型，称为 `弱排序(weak_ordering)`], [`weak_ordering::less`], [左边的操作数#strong[小于]右边的操作数],
    [], [`weak_ordering::greater`], [左边的操作数#strong[大于]右边的操作数],
    [], [`weak_ordering::equivalent`], [左边的操作数#strong[等于]右边的操作数],
  )
  , kind: table
  )

= 三向比较运算符的用法
三向比较运算符的使用方式如下：

```cpp
#include <iostream>

using namespace std;

int main() {
    int i{ 11 };
    strong_ordering result{ i <=> 0 };
    cout << typeid(result).name() << endl;

    if (result == strong_ordering::less) { cout << "less" << endl; };
    if (result == strong_ordering::greater) { cout << "greater" << endl; };
    if (result == strong_ordering::equal) { cout << "equal" << endl; };

    return 0;
}
```

可以得到以下的输出结果

```
struct std::strong_ordering
greater
```

同时，`<compare>` 还提供了一些函数来解释排序结果，有以下几种：`std::is_eq()`，`is_neq()`，`is_lt()`，`is_lteq()`，`is_gt()`，`is_gteq()`。

使用的方式如下：

```cpp
#include <iostream>
#include <compare>
using namespace std;

int main() {
    int i{ 11 };
    strong_ordering result{ i <=> 0 };
    cout << typeid(result).name() << endl;

    if (is_lt(result)) { cout << "less" << endl; };
    if (is_gt(result)) { cout << "greater" << endl; };
    if (is_eq(result)) { cout << "equal" << endl; };

    return 0;
}
```

= 三向比较运算符的作用
在编写自己的类时，如果需要实现比较运算符，在 C++20 之前，通常要重载 6 个比较运算符：（`>`，`<`，`<=`，`>=`，`==`, `!=`）。在 C++20 引入了三向比较运算符以后，就可以只重载 `<=>` 与 `==` 后，其他的运算符会由编译器为我们生成。（在 C++20 中，重载了 `==` 后，`!=` 也会自动重载）

以下是使用示例：

```cpp
#include <iostream>
#include <compare>
using namespace std;

class MyClass {
public:
    MyClass(int ini) : _data{ ini } {}

    auto operator<=>(const MyClass& other) const {
        return this->_data <=> other._data;
    }
    auto operator==(const MyClass& other) const {
        return this->_data == other._data;
    }
private:
    int _data;
};

int main() {
    MyClass a{ 10 }, b{ 20 };

    if (a < b) {
        cout << "a < b" << endl;
    }
    if (a != b) {
        cout << "a != b" << endl;
    }

    return 0;
}
```

可以得到以下的运算结果：

```
a < b
a != b
```
