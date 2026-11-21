#import "../../index.typ": template, tufted
#show: template.with(title: "CRTP技术")

CRTP (Curiously Recurring Template Pattern)，奇异递归模板模式，是 C++ 中一种高级模板技术。

= 核心思想
CRTP 的核心思想是一个类 `Derived` 从一个以 `Derived` 自身作为模板参数的模板类 `Base` 派生。

以下是一个其写法：

```cpp
template <typename T>
class Base {
    // ...
};

class Derived : public Base<Derived> {
    // ...
};
```

在这里，`Derived` 类继承自 `Base<Derived>`，也就是 `Base` 模板类的一个特化版本，而这个特化版本恰好是以 `Derived` 自身作为模板参数的。这就是“奇异递归”的由来。

= CRTP的作用与优势
== #strong[静态多态（Compile-Time Polymorphism）]
CRTP 允许在编译时实现多态行为，而不是运行时。这意味着可以避免虚函数（`virtual` 关键字）带来的运行时开销（如虚函数表查找）。基类 `Base<T>` 可以调用 `T` 类型（即派生类）的成员函数，而编译器在编译时就知道 `T` 是什么类型，从而直接生成对派生类函数的调用。

```cpp
#include <iostream>

template <typename T>
class CounterBase {
public:
    void increment() {
        static_cast<T*>(this)->doIncrement(); // 调用派生类的doIncrement
    }
    void decrement() {
        static_cast<T*>(this)->doDecrement(); // 调用派生类的doDecrement
    }
protected:
    // 确保派生类实现了这些方法
    void doIncrement() { /* 默认实现或纯虚函数概念 */ }
    void doDecrement() { /* 默认实现或纯虚函数概念 */ }
};

class MyCounter : public CounterBase<MyCounter> {
public:
    MyCounter() : count(0) {}
    int getCount() const { return count; }

private:
    int count;
    friend class CounterBase<MyCounter>; // 允许基类访问私有成员

    void doIncrement() {
        count++;
        std::cout << "MyCounter incremented to: " << count << std::endl;
    }
    void doDecrement() {
        count--;
        std::cout << "MyCounter decremented to: " << count << std::endl;
    }
};

int main() {
    MyCounter mc;
    mc.increment(); // 调用 CounterBase<MyCounter>::increment()，进而调用 MyCounter::doIncrement()
    mc.increment();
    mc.decrement();
    return 0;
}
```

== #strong[用于创建Mixin类]
Mixin 是一种软件设计模式，它允许一个类“混合”或“注入”额外的功能到另一个类中，而无需使用多重继承（特别是在多重继承可能导致菱形继承问题或复杂性时）。通过 Mixin，可以将一组特定的行为或接口封装在一个独立的类中，然后让其他类继承这个 Mixin 类，从而获得这些行为。

CRTP 是实现 Mixin 的一种非常优雅和高效的方式。当一个类 `Derived` 继承自 `Mixin<Derived>` 时，`Mixin` 类可以利用 `Derived` 的类型信息，在编译时为 `Derived` 类提供通用的功能实现，同时要求 `Derived` 类实现一些特定的“钩子”方法。这样，`Mixin` 类提供了通用的骨架，而 `Derived` 类提供了具体的细节。

现在用这样的一个例子：实现一个`Comparable` Mixin。这样如果一个子类需要实现比较操作时，只需要实现一个`operator<` 即可完成所有的5类比较运算符。

```cpp
#include <iostream>
#include <string>

// Comparable Mixin: 这是一个CRTP基类，它为派生类提供所有比较操作符的实现。
// 它假设派生类（T）会实现 operator<(const T& other)。
template <typename T>
class Comparable {
public:
    // 提供 operator> 的实现，基于 operator<
    bool operator>(const T& other) const {
        // static_cast<const T&>(*this) 将当前对象（Base类型）转换为派生类类型（T），
        // 从而能够调用派生类T中实现的 operator<。
        return other < static_cast<const T&>(*this);
    }

    // 提供 operator== 的实现，基于 operator<
    bool operator==(const T& other) const {
        // 如果 a 不小于 b 且 b 不小于 a，则 a 等于 b
        return !(static_cast<const T&>(*this) < other) && !(other < static_cast<const T&>(*this));
    }

    // 提供 operator!= 的实现，基于 operator==
    bool operator!=(const T& other) const {
        return !(static_cast<const T&>(*this) == other);
    }

    // 提供 operator<= 的实现，基于 operator>
    bool operator<=(const T& other) const {
        return !(static_cast<const T&>(*this) > other);
    }

    // 提供 operator>= 的实现，基于 operator<
    bool operator>=(const T& other) const {
        return !(static_cast<const T&>(*this) < other);
    }

    // 注意：operator< 必须由派生类自己实现。
    // 如果派生类没有实现 operator<，编译时会报错。
};

// 派生类 MyInt 继承自 Comparable<MyInt>，并实现 operator<
class MyInt : public Comparable<MyInt> {
private:
    int value;
public:
    MyInt(int v) : value(v) {}

    // 派生类必须实现 operator<
    bool operator<(const MyInt& other) const {
        return this->value < other.value;
    }

    int getValue() const { return value; }
};

// 派生类 MyString 继承自 Comparable<MyString>，并实现 operator<
class MyString : public Comparable<MyString> {
private:
    std::string text;
public:
    MyString(const std::string& s) : text(s) {}

    // 派生类必须实现 operator<
    bool operator<(const MyString& other) const {
        return this->text < other.text;
    }

    const std::string& getText() const { return text; }
};

int main() {
    MyInt i1(10), i2(20), i3(10);
    std::cout << "MyInt comparisons:" << std::boolalpha << std::endl;
    std::cout << "i1 < i2: " << (i1 < i2) << std::endl;   // true (MyInt::operator<)
    std::cout << "i1 > i2: " << (i1 > i2) << std::endl;   // false (Comparable::operator>)
    std::cout << "i1 == i3: " << (i1 == i3) << std::endl; // true (Comparable::operator==)
    std::cout << "i2 != i3: " << (i2 != i3) << std::endl; // true (Comparable::operator!=)
    std::cout << "i1 <= i3: " << (i1 <= i3) << std::endl; // true (Comparable::operator<=)
    std::cout << "i2 >= i1: " << (i2 >= i1) << std::endl; // true (Comparable::operator>=)

    std::cout << "\nMyString comparisons:" << std::boolalpha << std::endl;
    MyString s1("apple"), s2("banana"), s3("apple");
    std::cout << "s1 < s2: " << (s1 < s2) << std::endl;   // true (MyString::operator<)
    std::cout << "s1 > s2: " << (s1 > s2) << std::endl;   // false (Comparable::operator>)
    std::cout << "s1 == s3: " << (s1 == s3) << std::endl; // true (Comparable::operator==)

    return 0;
}
```

在这个例子中，`Comparable` 类是一个 Mixin。它通过 CRTP 接收派生类 `T` 作为模板参数，并利用 `static_cast<const T&>(*this)` 在编译时调用 `T` 中实现的 `operator<`。这样，`MyInt` 和 `MyString` 只需实现一个 `operator<`，就能自动获得所有其他比较操作符的功能，大大减少了代码重复。

== 策略模式
策略模式是一种行为设计模式，它允许在运行时选择算法的行为。然而，在 C++ 中，通过模板和 CRTP，我们可以在#strong[编译时]选择不同的策略，从而避免了运行时虚函数调用的开销，实现了高性能和灵活性。这通常被称为“策略式设计”或“基于策略的设计”。

CRTP 在策略模式中的应用通常是：一个通用类（或称为“主机”类）接受一个或多个“策略”类作为模板参数。这些策略类定义了特定的算法或行为，而通用类则通过继承或成员组合的方式使用这些策略。当策略需要访问或操作通用类自身的数据或方法时，CRTP 模式就显得尤为有用，因为策略类可以通过模板参数获取通用类的具体类型。

#strong[示例：实现一个基于策略的日志系统]

假设你有一个通用组件，需要记录其生命周期事件和操作。你希望能够灵活地切换不同的日志策略（例如，打印到控制台、写入文件、不记录任何内容）。

```cpp
#include <iostream>
#include <string>
#include <typeinfo> // 用于获取类型名称

// 日志策略1: ConsoleLoggerPolicy
// 这是一个CRTP策略，它知道它所服务的具体类型 T
template <typename T>
class ConsoleLoggerPolicy {
public:
    void log_creation() {
        std::cout << "[ConsoleLog] " << typeid(T).name() << " object created." << std::endl;
    }
    void log_destruction() {
        std::cout << "[ConsoleLog] " << typeid(T).name() << " object destroyed." << std::endl;
    }
    void log_action(const std::string& action) {
        std::cout << "[ConsoleLog] " << typeid(T).name() << ": " << action << std::endl;
    }
};

// 日志策略2: NoLoggerPolicy (不执行任何日志操作)
template <typename T>
class NoLoggerPolicy {
public:
    void log_creation() {} // 空实现
    void log_destruction() {} // 空实现
    void log_action(const std::string& action) {} // 空实现
};

// 通用组件类：MyComponent
// 它接受一个日志策略作为模板参数，并继承该策略。
// 注意：这里的 MyComponent 也是一个 CRTP 模式的基类，因为它将自己的类型 T 传递给 LoggingPolicy。
template <typename T, typename LoggingPolicy>
class MyComponent : public LoggingPolicy {
public:
    MyComponent() {
        // 调用策略类的方法来记录创建事件
        LoggingPolicy::log_creation();
    }

    ~MyComponent() {
        // 调用策略类的方法来记录销毁事件
        LoggingPolicy::log_destruction();
    }

    void performOperation() {
        // 调用策略类的方法来记录操作
        LoggingPolicy::log_action("Performing a generic operation.");
        // 实际操作...
    }
};

// 具体的组件实现1：使用 ConsoleLoggerPolicy
class SpecificWidget : public MyComponent<SpecificWidget, ConsoleLoggerPolicy<SpecificWidget>> {
public:
    SpecificWidget() {
        // SpecificWidget 自己的初始化逻辑
        LoggingPolicy::log_action("SpecificWidget initialized."); // 调用策略方法
    }

    void doSomethingSpecific() {
        LoggingPolicy::log_action("Doing something specific in SpecificWidget.");
    }
};

// 具体的组件实现2：使用 NoLoggerPolicy
class SilentGadget : public MyComponent<SilentGadget, NoLoggerPolicy<SilentGadget>> {
public:
    SilentGadget() {
        // SilentGadget 自己的初始化逻辑
        // 注意：这里调用 log_action 不会有任何输出，因为策略是 NoLoggerPolicy
        LoggingPolicy::log_action("SilentGadget initialized.");
    }
};

int main() {
    std::cout << "--- SpecificWidget (with ConsoleLoggerPolicy) ---" << std::endl;
    {
        SpecificWidget widget;
        widget.performOperation();
        widget.doSomethingSpecific();
    } // widget 在这里超出作用域，析构函数被调用

    std::cout << "\n--- SilentGadget (with NoLoggerPolicy) ---" << std::endl;
    {
        SilentGadget gadget;
        gadget.performOperation();
    } // gadget 在这里超出作用域，析构函数被调用

    return 0;
}
```

在这个例子中：

- `ConsoleLoggerPolicy`~和~`NoLoggerPolicy`~是两种不同的日志策略。它们都以 CRTP 方式接受它们所服务的具体类~`T`~作为模板参数，以便在日志消息中包含类型信息。
- `MyComponent`~是一个通用组件，它通过模板参数~`LoggingPolicy`~注入日志功能。`MyComponent`~继承自~`LoggingPolicy`，从而可以直接调用策略中定义的方法（如~`log_creation()`）。
- `SpecificWidget`~和~`SilentGadget`~是~`MyComponent`~的具体实例化，它们在编译时选择了不同的日志策略。

这种模式允许你在编译时灵活地切换组件的行为（这里是日志行为），而无需任何运行时开销（没有虚函数表查找）。当策略需要访问或了解其所注入的宿主类（例如 `typeid(T).name()`）时，CRTP 的特性就显得尤为重要。

== 编译期接口检查
基类可以强制派生类实现某些方法。如果派生类没有实现基类期望的方法，编译就会失败，从而在编译期捕获错误。

== #strong[避免代码重复]
将通用逻辑放在基类中，派生类只需实现其特有的部分，减少代码重复。

= 缺点
== 不是运行时多态
CRTP 提供的多态是编译时多态。你不能像使用虚函数那样，通过一个 `Base*` 指针在运行时指向不同的派生类对象并调用其方法。例如，`Base<SomeDerived>* ptr = new SomeDerived();` 这样的用法是有效的，但 `Base<AnotherDerived>* ptr2 = new AnotherDerived();`，这两个 `Base` 类型是完全不同的，它们没有共同的非模板基类。

== 其他
其他的还有比如理解复杂，模板编译时间会比较多，但是个人认为这个问题不是最主要的问题，相对于它带来的便捷性，是可以做一些牺牲的
