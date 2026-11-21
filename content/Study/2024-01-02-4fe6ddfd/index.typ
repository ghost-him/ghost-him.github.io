#import "../../index.typ": template, tufted
#show: template.with(title: "QT学习笔记-GUI程序结构与运行机制")

= 项目结构以 QWidget 作为窗口基类则创建出来的文件有
```
test2.pro：qmake构建系统的项目配置文件，存储了各种项目的设置
main.cpp：主程序的入口，实现了main函数
widget.ui：使用XML格式描述元件及而已的界面文件
widget.h：窗口类定义头文件，用到了.ui文件
widget.cpp：是实现文件
```

== `test2.pro` 文件`QT       += core gui # 引用 core 和 gui 库 greaterThan(QT_MAJOR_VERSION, 4): QT += widgets # 如果qt的版本大于4，则引入widgets库 CONFIG += c++17 SOURCES += \     main.cpp \     widget.cpp HEADERS += \     widget.h FORMS += \     widget.ui qnx: target.path = /tmp/$${TARGET}/bin else: unix:!android: target.path = /opt/$${TARGET}/bin !isEmpty(target.path): INSTALLS += target`
变量的含义，详细见 `qmake manual`

- QT：qt 模块的列表，在用到模块时要手动添加
- CONFIG：通用配置选项
- DEFINES：预处理定义列表
- TEMPLATE：模板，是 app 还是 lib，默认是 app
- SOURCES：源文件
- HEADERS：头文件
- FORMS：ui 文件
- TARGET：生成的可执行文件名称，默认与项目同名

`$${xxx}`：用 `xxx` 的值替换当前的位置。

== `Widget.h` 文件\`\`\`cpp
\#ifndef WIDGET\_H
\#define WIDGET\_H

\#include

QT\_BEGIN\_NAMESPACE namespace Ui { class Widget; } QT\_END\_NAMESPACE

class Widget : public QWidget { Q\_OBJECT/\/ 宏，如果要使用QT信号与槽机机制，必须添加

public: Widget(QWidget \*parent = nullptr); \~Widget();

private: Ui::Widget \*ui; /\/ Ui::Widget类型的一个指针，指向可视化的界面 };
\#endif /\/ WIDGET\_H

````
## `Widget.cpp`
```cpp
#include "widget.h"
#include "ui_widget.h"

Widget::Widget(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::Widget)
{
    ui->setupUi(this); // 实现了组件的各种设置，信号与槽的关联
}

Widget::~Widget()
{
    delete ui;
}
````

= 信号与槽
<信号与槽>
信号与槽是 qt 编程的基本，也是 qt 的一大创新。多种实现方式中最常用的是

```cpp
QObject::connect(sender, SIGNAL(signal()), receiver, SLOT(slot()));
```

`connect()` 是 QObject 类中的静态成员函数，在使用时，QObject 通常可以省略。`SIGNAL` 与 `SLOT` 是 QT 的宏，用于将参数转换为相应的字符串。

以下是一些注意事项：

- 一个信号可以连接多个槽函数
- 多个信号可以连接同一个参函数

```cpp
ui->setupUi(this);
connect(ui->radioBlack, SIGNAL(clicked()), this, SLOT(do_setFontColor()));
connect(ui->radioBlue, SIGNAL(clicked()), this, SLOT(do_setFontColor()));
connect(ui->radioRed, SIGNAL(clicked()), this, SLOT(do_setFontColor()));
```

- 一个信号可以接连另一个信号

QT 还支持通过函数名称将信号与槽关联，需要先开启这个功能

```cpp
QMetaObject::connectSlotsByName(Dialog);
```

使用的格式为

```cpp
void on_<object name>_<signal name>(<signal parameters>);
```

示例：

```cpp
void on_chkBoxUnder_clicked(bool checked);
void on_chkBoxBold_clicked(bool checked);
```

= QT 项目构建过程基本原理
<qt-项目构建过程基本原理>
一个 qt 项目会包括以下的内容：

- QT c++头文件
- 窗口 ui 文件
- 资源文件

qt 会使用元对象系统中的元对象编译器（MOC）对项目中的头文件进行预处理。生成一个标准的 c++程序。

同时，ui 文件会使用 UIC，资源文件会使用 RCC 分别将其编译成标准 c++程序，然后再使用标准 c++编译器（比如 Mingw 64）来生成可执行文件。
