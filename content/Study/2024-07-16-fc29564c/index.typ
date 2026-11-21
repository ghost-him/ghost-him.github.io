#import "../../index.typ": template, tufted
#show: template.with(title: "C++20使用“复制和交换”方法实现安全处理异常的赋值运算符")

以下笔记来自：#link("https://book.douban.com/subject/35863224/")[C++20高级编程(第5版)] `p231-237`。

= 前期准备
对于 C++来说，如果没有自行编写拷贝构造函数或赋值运算符，C++会自动生成。然而，对于基本类型，编译器只会提供表层复制或赋值，也就是浅拷贝。

那么对于以下的类，如果使用了编译器提供了默认的拷贝构造函数，会导致程序运行错误：

```cpp
class Sheet {
public:
    Sheet(size_t width, size_t height) 
        : m_width{ width }, m_height{ height }
    {
        m_chart = new int* [m_width];
        for (size_t i{ 0 }; i < m_width; i++ ) {
            m_chart[i] = new int[m_height];
        }
    }
    
    ~Sheet() {
        for (size_t i{ 0 }; i < m_width; i++) {
            delete[] m_chart[i];
        }
        delete[] m_chart;
        m_chart = nullptr;
    }

private:
    size_t m_width{ 0 };
    size_t m_height{ 0 };
    
    int** m_chart;
};
```

可以使用以下的代码验证，可以发现程序会报错：

```cpp
int main() {
    // 构造一个变量
    Sheet a1{ 5, 7 };
    // 使用默认的拷贝构造函数完成拷贝构造
    Sheet a2{ a1 };
    return 0;
}
```

因此，我们需要自己写一个拷贝构造函数来完成对于类的拷贝构造（深拷贝）。

```cpp
#include <iostream>

using namespace std;

class Sheet {
public:
    Sheet(size_t width, size_t height) 
        : m_width{ width }, m_height{ height }
    {
        m_chart = new int* [m_width];
        for (size_t i{ 0 }; i < m_width; i++ ) {
            m_chart[i] = new int[m_height];
        }
    }
    
    ~Sheet() {
        for (size_t i{ 0 }; i < m_width; i++) {
            delete[] m_chart[i];
        }
        delete[] m_chart;
        m_chart = nullptr;
    }
    //////////////////////    ADD   ///////////////////////////
    Sheet(const Sheet& src) 
        : Sheet{src.m_width, src.m_height}
    {
        for (size_t i{ 0 }; i < m_width; i++) {
            for (size_t j{ 0 }; j < m_height; j++) {
                m_chart[i][j] = src.m_chart[i][j];
            }
        }
    }
    ///////////////////////////////////////////////////////////

private:
    size_t m_width{ 0 };
    size_t m_height{ 0 };
    
    int** m_chart;
    };
```

再次执行上面的代码，可以发现程序不会报错了，因为通过深拷贝，可以正确的分配内存了。

= 赋值运算符
那么，如果要实现赋值运算符，应该怎么实现？

首先，来看以下的实现方式：

```cpp
Sheet& operator=(const Sheet& rhs) {
    // 检查是不是自赋值
    if (this == &rhs) {
        return *this;
    }
    // 释放旧内存
    for (size_t i{ 0 }; i < m_width; i++) {
        delete[] m_chart[i];
    }
    delete[] m_chart;
    m_chart = nullptr;
    // 分配新内存
    m_width = rhs.m_width;
    m_height = rhs.m_height;
    
    m_chart = new int* [m_width];
    for (size_t i{ 0 }; i < m_width; i++) {
        m_chart[i] = new int[m_height];
    }
    // 复制数据
    for (size_t i{ 0 }; i < m_width; i++) {
        for (size_t j{ 0 }; j < m_height; j++) {
            m_chart[i][j] = rhs.m_chart[i][j];
        }
    }
    return *this;
}
```

该函数做了以下的事情：

+ 检查自赋值
+ 释放当前使用的内存
+ 分配新的内存
+ 复制各个内存

我在第一眼看的时候并没有发现什么错，不过经过书中的指点，我才明白：该代码存在以下的漏洞：

如果该代码成功的释放了内存，合理的设置了 m\_width 与 m\_height，但是分配内存的循环抛出了异常。如果出现了这种情况，则将不再执行该方法的剩余部分，而是直接从该方法中退出。此时 `Sheet` 实例受损，它的 m\_width 与 m\_height 数据成员声明了指定的大小，但 m\_chart 数据成员不指向正确数量的内存。所以，#strong[该代码不能安全的处理异常！]

所以，我们需要一种全有或全无的机制：要么全部成功，要么该对象保持不变。如果要实现一个能安全处理异常的赋值运算符，则要使用 #strong[复制和交换] 的方法：

== 什么是复制和交换方法
该方法共有以下几步：

+ 给目标类添加一个 `swap()` 方法（推荐提供一个非成员函数的版本，这样各种标准库算法都可以使用它了）
+ 使用复制和变换的惯用方法
  + 创建一个右边的副本
  + 用当前对象与这个副本交换

== 代码演示
以下是代码演示：

首先，先写一个 swap 函数，成员函数版与非成员函数版。

```cpp
class Sheet {
public:

    // 之前的代码省略
    
    // 成员函数版
    void swap(Sheet& other) noexcept {
        std::swap(m_width, other.m_width);
        std::swap(m_height, other.m_height);
        std::swap(m_chart, other.m_chart);
    }

private:
    // 数据成员省略
};

// 再提供一个非成员函数版
void swap(Sheet& first, Sheet& second) noexcept {
    first.swap(second);
}
```

然后使用复制与交换的惯用方法，完成赋值运算符。

```cpp
Sheet& operator=(const Sheet& rhs) {
    Sheet temp{ rhs };
    swap(temp);
    return *this;
}
```

复制与交换方法通过 3 个阶段来实现：

+ 第一阶段创建一个临时副本。这不修改当前 Sheet 对象的状态，因此，如果在这个阶段上发生异常，不会出现问题。
+ 第二阶段使用 `swap()` 函数，将创建的临时副本与当前对象交换。`swap()` 永远不会抛出异常。
+ 第三阶段销毁临时对象（由于发生了交换，temp 为原始对象）以清理内存。

== 复制和交换方法的好处
- 使用了复制和交换惯用方法的情况下，不再需要自我赋值的检查了。
- 可以避免代码重复，又可以保证强大的异常安全性
- 复制和交换惯用方法不仅仅适用于赋值运算符。它可以用于任何需要多个步骤的操作，并且你希望将其转换为全有或全无的操作。

= 完整的代码
```cpp
#include <iostream>

using namespace std;

class Sheet {
public:
    Sheet(size_t width, size_t height) 
        : m_width{ width }, m_height{ height }
    {
        m_chart = new int* [m_width];
        for (size_t i{ 0 }; i < m_width; i++ ) {
            m_chart[i] = new int[m_height];
        }
    }
    
    ~Sheet() {
        for (size_t i{ 0 }; i < m_width; i++) {
            delete[] m_chart[i];
        }
        delete[] m_chart;
        m_chart = nullptr;
    }
    
    Sheet(const Sheet& src) 
        : Sheet{src.m_width, src.m_height}
    {
        for (size_t i{ 0 }; i < m_width; i++) {
            for (size_t j{ 0 }; j < m_height; j++) {
                m_chart[i][j] = src.m_chart[i][j];
            }
        }
    }
    
    void swap(Sheet& other) noexcept {
        std::swap(m_width, other.m_width);
        std::swap(m_height, other.m_height);
        std::swap(m_chart, other.m_chart);
    }
    
    Sheet& operator=(const Sheet& rhs) {
        Sheet temp{ rhs };
        swap(temp);
        return *this;
    }

private:
    size_t m_width{ 0 };
    size_t m_height{ 0 };
    
    int** m_chart;
};

void swap(Sheet& first, Sheet& second) noexcept {
    first.swap(second);
}

int main() {
    Sheet a1{ 5, 7 };
    Sheet a2{ 2, 4 };
    
    a2 = a1;
    
    return 0;
}
```
