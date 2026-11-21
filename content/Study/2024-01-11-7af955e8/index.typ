#import "../../index.typ": template, tufted
#show: template.with(title: "C++实现单例模式")

记录一下自己在写代码时遇到的坑。。。

#strong[单例模式]:

- 单例模式确保一个类只有一个实例，并提供一个全局访问点。
- 它可以保持一个类的状态，并在应用程序的不同部分之间共享这个状态。
- 单例通常在需要严格控制如何和何时访问资源的情况下使用，例如配置管理器或日志记录器。
- 单例模式可能会导致代码之间的高耦合度，并且在多线程环境中可能需要额外的同步机制。

实现单例的模版：

```cpp
Class MyClass {
public:
    // 删除拷贝构造函数和拷贝赋值操作符
    MyClass(MyClass const&) = delete;
    MyClass& operator=(MyClass const&) = delete;
    // 提供一个全局唯一的接口
    static MyClass& getInstance() {
        static MyClass instance;
        return instance;
    }

private:
    // 将构造函数声明为私有
    MyClass() = default;
}
```

如果没有

```cpp
MyClass(MyClass const&) = delete;
MyClass& operator=(MyClass const&) = delete;
```

这两行代码，则这个类依然可以通过

```cpp
MyClass anotherInstance = MyClass::getInstance()
```

的方式得到一个新的实例，无法保证全局唯一的实例。
