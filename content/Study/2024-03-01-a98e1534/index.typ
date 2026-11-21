#import "../../index.typ": template, tufted
#show: template.with(title: "c++多态与底层实现")

笔记来源：#link("https://www.bilibili.com/video/BV1et411b73Z?p=135")[链接]

= 多态
C++的多态性是指在程序运行时，根据对象的实际类型来调用相应函数的功能。即，会在运行时表现出不同的性质。

多态分为两类：

- 静态多态：函数重载与运算符重载属于静态多态，复用函数名。
- 动态多态：派生类与虚函数实现运行时多态。

静态多态与动态多态的区别：

- 静态多态的函数地址早绑定-编译阶段确定函数地址
- 动态多态的函数地址晚绑定-运行时确定函数地址

动态多态的满足条件：

- 有继承关系
- 子类要重写父类的虚函数
  - 重写：函数返回值，函数名，参数列表完全

动态多态的使用

- 使用父类的指针或者引用来执行子类的对象

= 底层实现
父类

```cpp
class Animal {
public:
    // 虚函数
    virtual void speak() {
        cout << "动物在说话" << endl;
    }
}
```

`Animal` 类的内部结构中有一个 `vfptr`，指向一个虚函数表 `vftable`，表内记录的是虚函数的地址：`&Animal::speak()`

虚函数的作用是允许在派生类中重新定义与基类同名的函数，并且可以通过基类指针或引用来访问基类和派生类中的同名函数。

```
vfptr: 虚函数（表）指针
v: virtual
f: function

vftable: 虚函数表
v: virtual
f: function
```

子类

```cpp
class Cat : public Animal {
public:
    virtual void speak() {
        cout << "猫在说话" << endl;
    }
}
```

由于 `cat` 继承自 `Animal`，所以 `cat` 中也维护着一个 `vfptr`,指向一个 `vftable`，此时，该表中记录着父类的指针：`&Animal::speak()`。如果子类重写了父类的虚函数，则子类中的虚函数表内容会替换成子类的虚函数地址：`&Animal::speak() -> &Cat::speak()`
