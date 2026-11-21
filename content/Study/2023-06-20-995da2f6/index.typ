#import "../../index.typ": template, tufted
#show: template.with(title: "开源代码学习：yazi-json解析器设计")

== 代码地址
#link("https://www.bilibili.com/video/BV1TP411p7cC/")[视频地址]

== 项目特点
独立，跨平台，高性能

== 涉及的知识点
- 面向对象设计
- 构造函数的重载
- 函数递归
- 运算符的重载：bool，int，double，string
- 标准模板库的运用：vector，map，ifstream，stringstream
- 内存管理：决定性能
- enum，union 的巧用

= 设计分析
- API 接口的设计
- 解析器的设计和实现

== API 设计
json 文件夹：存放 api 的设计部分和 parser 解析器的部分

Json 的数据分为 `null, bool, int, double, string, asrray, object`，因此，这里使用枚举类型来进行区分。

```cpp
enum Type {
    json_null = 0,
    json_bool,
    json_int,
    json_double,
    Json_string,
    Json_array,
    Json_object
};
```

由于 json 的数据类型有以下的特点：每次一定是属于一个其中的某一个类型。因此，我们可以使用联合体 (union)来存放数据，这个占用的空间更小一些。在联合体中，所有字段的内存是共用的，占用的空间大小由内存中占用最大的字段决定。

```cpp
union Value {
    bool m_bool;
    int m_int;
    double m_double;
    std::string* m_string;
    std::vector<Json>* m_array;
    // 对象的类型是一个kv的键值对
    std::map<string, Json>* m_object;
};
```

在这里，由于 double 类型占用的空间最大（8 个字节），所以这个联合体的大小为 8。

如果两个文件要相互引用，即有以下两个文件: `a.h` 和 `b.h`。如果 a 要用到 b，同时，b 也要用到 a。代码体现如下：

```cpp
// a.h
#pragma once
#include "b.h"

class a {
public :
    void action();
};
// =======================================
// a.cpp

#include "a.h"
void a::action() {
    b newb;
    newb.action();
}
// ===========================================
// b.h

#pragma once
#include "a.h"

class b {
public:
    a action() {
        return a();
    }
};
```

可以看到：b 返回的是一个 a 类型的对象，同时，a 也需要使用 b 来进行处理，那么我们可以在 a.cpp 中包含 b.h 而不是 a.h 中。代码如下：

```cpp
#include "a.h"
#include "b.h"

void a::action() {
    b newb;
    newb.action();
}
```

这样就可以解决因为相互引用，从而导致编译不通过的问题。

在写自己的库的时候，为了防止自己的代码和别人写的代码产生命名冲突，可以使用命名空间来相互隔离。

```cpp
namespace [命名空间的名字] {
    // ...
}
```

由于 json 的不同类型的开头首字母一定是不一样的，所以可以使用开头的首字母来判断当前值的数据类型，然后再执行相应的解析函数。

```cpp
char ch = get_next_token();
switch (ch) {
case 'n':
    m_idx--;
    return parse_null();
case 't':
case 'f':
    m_idx--;
    return parse_bool();
case '-':
case '0':
case '1':
case '2':
case '3':
case '4':
case '5':
case '6':
case '7':
case '8':
case '9':
    m_idx--;
    return parse_number();
case '"':
    return Json(parse_string());
case '[':
    return parse_array();
case '{':
    return parse_object();
default:
    break;
}
throw new logic_error("unexpected char");
```

= 项目的分析
在跟着视频敲代码的时候，我看这个 json 类的设计过程真的是一言难尽。作者有很多非常不好的操作：浅拷贝；判断两个 json 是否一样时，只看两个指针是不是指向同一个等。

这里可以很简单的写出一个会导致内存泄露的代码：

```cpp
    Json arr;
    arr[0] = true;
    arr[1] = 123;
    arr[2] = "hello world";

    Json one = arr;
    arr.clear();

    cout << one.str() << endl;
```

这里会内存泄露的原因就是浅拷贝。

```cpp
    Json a;
    a[0] = true;
    a[1] = 123;
    a[2] = "hello world";

    Json b;
    b[0] = true;
    b[1] = 123;
    b[2] = "hello world";

    if (a == b) {
        cout << "yes" << endl;
    }
    else {
        cout << "no" << endl;
    }
```

通过这个代码也可以看到，程序的运算结果是 `no`。

因此这个代码还是有很大的安全隐患的。
