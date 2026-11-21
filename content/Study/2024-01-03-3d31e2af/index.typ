#import "../../index.typ": template, tufted
#show: template.with(title: "QT学习笔记-qt框架功能概述")

= qt 模块
qt 框架中的模块分为两大类：

- qt 基本模块：提供了 qt 在所有平台上的基本功能。
- qt 附加模块：实现了一些特定功能的模块。

常见的基本模块：

- Qt core：是 qt 框架的核心，定义了元对象系统
- Qt GUI：设计 GUI 界面的基础类，包括事件处理，文字处理等。
- Qt Widgets：提供用于创建 GUI 的各种界面组件类。

= qt 全局定义
在 `<QGlobal>` 头文件中包含了一些 Qt 类库的一些全局定义的

- 基本数据类型
- 函数
- 宏

以下是不常见的数据类型：

#figure(
  table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([qt 数据类型], [等效定义], [字节],),
    table.hline(),
    [`qreal`], [`double`], [8],
    [`qsizetype`], [`ssize_t`], [8],
  )
  , kind: table
  )

== 小代码
== 输出当前的 qt 版本号
```cpp
#include <QCoreApplication>

int main(int argc, char *argv[])
{
    qDebug() << QT_VERSION_STR;

    QString str;
    // 可以使用这种方法来对比qt版本号
    qDebug() << str.asprintf("0X%0X", QT_VERSION);
}
```

== 判断当前的机器是大端还是小端
```cpp
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
    qDebug() << "小端方式";
#elif Q_BYTE_ORDER == Q_BIG_ENDIAN
    qDebug() << "大端方式";
#endif
```

= Qt 的元对象系统
qt 中引入元对象系统对标准 c++语言进行了扩展 描述

- QObject 类是所有使用元对象系统的类的基类
- 必须在一个类的形状部分插入 Q\_OBJECT，才可以使用元对象系统的特性。当 MOC 发现类中定义的 Q\_OBJECT 宏时，会为其生成相应的 c++源文件
- 元对象编译器（MOC）是一个预处理器，先将 qt 的特性程序转换为标准 c++程序，再由标准 c++编译器进行编译。

Object 类

- 元对象：每个 QObject 及其子类的实例都有一个元对象（静态变量）。函数 metaObject ()可以返回它的指针。
- 类型信息：QObject 的 inherits ()函数可以判断继承关系
- 动态翻译：函数 str ()返回一个字符串的翻译版本
- 对象树：表示对象间从属关系的树状结构。QObject 提供了 parent ()，children ()，findChildren ()等函数。对象树中的某个对象被删除对，它的子对象也将被删除。

QMetaObject 类

- 元对象是对类的描述，包含类信息，方法，属性等元数据
- QObject 和 QMetaObject 提供了以下函数接口，可以获取运行时的类型信息，类似标准 C++中的 RTTI。

使用程序获取一个对象的类型以及父类型，并判断是不是对应的类型。

```cpp
#include "mainwindow.h"

#include <QApplication>

#include <QPushButton>
#include <QTimer>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QObject* btn = new QPushButton();

    qDebug() << btn->metaObject()->className();
    QPushButton* pushbtn = qobject_cast<QPushButton*>(btn);

    qDebug() << pushbtn->metaObject()->className();

    QTimer* timer = new QTimer();
    qDebug() << timer->inherits("QTimer");
    qDebug() << timer->inherits("QObject");
    qDebug() <<  timer->inherits("QAbstractButton");
    qDebug() << btn->inherits("QAbstractButton");

    qDebug() << btn->metaObject()->superClass()->className();
}
```

= qt 系统属性
在 QObject 的子类中可以通过 Q\_PROPERTY 宏定义属性：

```
Q_PROPERTY(type name)
```

系统属性中主要是用来与其他语言打交到的。

代码使用方法

```cpp
#include "mainwindow.h"

#include <QApplication>

#include <QPushButton>
#include <QTimer>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QObject* btn = new QPushButton();
    QObject* object = btn;
    // 当前的对象中没有flateee属性，所以返回 false
    bool isFlat = object->property("flateee").toBool();
    qDebug() << isFlat;
    // 将这个对象设置了flateee属性，所以返回 true
    object->setProperty("flateee", true);
    isFlat =  object->property("flateee").toBool();
    qDebug() << isFlat;
}
```

= 信号与槽
信号与槽是元对象系统支持的，是对象间通信所采取的机制。

使用宏的版本

```cpp
QMetaObject::Connection QObject::connect(const QObject *sender, const char * signal, const QObject * receiver, const char * member, Qt::ConnectionType = Qt::AutoConnection)
```

使用函数指针的版本

```cpp
QMetaObject::Connection QObject::connect(const QObject *sender, const QMetaMethod & signal, const QObject * receiver, const QMetaMethod & method, Qt::ConnectionType = Qt::AutoConnection)
```

如果信号与槽函数都存在重载的情况，则需要使用 `qOverload<参数类型>` 进行指定。例如：

`do_click()` 函数有两个版本，因此如果只写 `Widget::do_click`，则编译器会不知道选择哪个版本，如果加了 `qOverload<>`，则编译器会选择不带参数的版本，如果加的是 `qOverload<bool>`，则编译器会选择带参数的版本。

```cpp
void do_click(bool checked);
void do_click();


connect(ui->checkBox, &QCheckBox::clicked, this, qOverload<bool>(&Widget::do_click));
connect(ui->checkBox, &QCheckBox::clicked, this, qOverload<>(&Widget::do_click));
```

`Qt::ConnectionType` 指定了信号与槽之间的关联方式

- `Qt::AutoConnection`：自动确定关联方式
- `Qt::DirectConnection`：信号被发射时，槽立即执行，槽函数与信号在同一线程
- `Qt::QueuedCoonnction`：事件循环回到接收者线程后执行槽，槽与信号在不同线程
- `Qt::BloackingQueueConnection`：与 `Qt::QueuedCoonnction` 类似，信号线程会被阻塞直到槽执行完毕，当槽函数与信号在同一线程，会造成死锁。

`disconnect()` 函数

+ 解除与一个 `sender` 所有的 `signal` 的连接：
  + `disconnect(myObject, nullptr, nullptr, nullptr);`
  + `myObject->disconnect();`
+ 解除一个特定信号的所有连接：
  + `disconnect(myObject, SIGNAL(mySignal()), nullptr, nullptr);`
  + `myObject->disconnect(SIGNAL(mySignal()));`
+ 解除一个特定 `receiver` 的所有连接
  + `disconnect(myObject, nullptr, myReceiver, nullptr);`
  + `myObject->disconnect(myReceiver);`
+ 解除一对特定的信号和槽的连接
  + `disconnect(lineEdit, &QLineEdit::textChanged, label, &QLabel::setText);`

`sender()` 函数

在槽函数里，使用 `QObject::sender()` 可以获取信号发射者的指针。信号函数必须无返回值，但可以有输入参数信号函数无需实现，只需在某些条件下发射信号。信号函数会由 MOC 实现，我们不需要关心其具体的实现。

自定义信号及其使用

```cpp
class QPerson::public QObject {
    Q_OBJECT
private:
    int m_age = 10;
public:
    void incAge();
signals:
    void ageChanged(int value);
}

void QPerson::incAge() {
    m_age++;
    emit ageChanged(m_age); // 发射信号
}
```

= 对象树
QObject 以对象树的形式组织自己，其构造函数里有一个 `parent` 参数。当用另一个对象作为父对象创建一个 `QObject` 时，它会被添加到父对象的 `children()` 列表中，而当父对象被删除时，它会被删除，这种方法非常适合 GUI 对象的需求。例如，`QShortcut(键盘快捷键)` 是相关窗口的子对象，因此当用户关闭该窗口时，快捷键也会被删除。

`children()` 函数

```cpp
// 返回对象的子对象列表
const QObjectList & QObject::children();

// 函数的返回类型是QObject类型指针列表
typedef QList<QObject *> QObjectList;

// 示例：修改所有按钮的名称
// 获取分组框的子对象列表
QObjectList objList = ui->groupBox_Btns->children();
for (int i = 0; i < objList.size(); i ++) {
    // 获取元对象 
    const QMetaObject *meta = objList.at(i)->metaObject();
    QString className = QString(meta->className());
    if (className == "QPushButton") {
        QPushButton *btn = qobject_cast<QPushButton*>(objList.at(i));
        QString str->btn->text();
        btn->setText(str + "*");
    }
}

```

`findChild()` 函数

返回此对象的#strong[一个]具有给定名称的子对象，该子对象可以转换为类型 T，如果没有该对象，则返回 `nullptr`

```cpp
template<typename T> 
T QObecjt::findChild(const QString & name = QString(), Qt::FindOptions options  Qt::FindChildrenRecursively) const
```

如果省略 `name` 将匹配掺对象。搜索是递归执行的，除非 options 指定为 `FindDirectChildrenOnly`。

```cpp
// 返回parentWidget的一个子按钮QPushButton, 名为"button1"
// 即使这个按钮不是父元素的直接子元素
QPushButton* button = parentWidget->findChild<QPushButton *>("button1");
```

`findChildren()` 函数：

返回此对象的#strong[所有]具有给定名称的子对象，这些子对象可以转换为类型 T，如果没有此类对象，则返回一个空列表。省略 `name` 参数将匹配所有对象的名称。搜索是递归执行的，除非 `options` 指定了 `FindDirectChildrenOnly` 选项

```cpp
QList<QWidget *> widgets = parentWidget.findChildren<QWidget *>("widgetname");
```

= 容器类
Qt 库提供了一组通用的基于模块的容器类。可用于存储指定类型的项。例如，如果需要一个大小可变的 `QString` 数组，可以使用 `QList<QString>` 或 `QStringList`。

#quote(block: true)[
Qt 容器类比 STL 更轻巧（速度与存储优化），更安全（线程安全），更易使用。如果不熟悉 STL，或更喜欢用 `QT的方式` 写代码，可以选用 QT 容器类。
]

Qt 容器提供了用于遍历的迭代器。STL 风格的迭代器是最高效的迭代器，可以与 QT 和 STL 的泛型算法一起使用。提供 java 风格的迭代器是为了向后兼容。

== 顺序方式\* QList，QStack，QQueue
- 对于大多数应用程序来说，QList 是最好的选择，它提供了非常快的追加。如果确实需要使用链表，可以使用 std::list
- QStack 与 QQueue 是便利类，提供了 LIFO 与 FIFO 语义。

== 关联方式\* QMap, QMultiMap, QHash, QMultiHash, QSet
- "multi"容器支持与一个键关联的多个值
- "hash"容器通过使用散列函数而不是在有序集合上进行二分查找，从而提供了更快的查找速度。
- 如果在 map 中没有指定键的项，这些函数返回一个默认的构造的值
- 还有一个 `value()` 重载方法，如果指定的键不存在，则使用第二个参数作为默认值

```cpp
QMap<QString, int> map;

int num1 = map["thirteen"];
int num2 = map.value("thirteen");
int num3 = map.value("thirteen", 13);
```

== `stl` 风格的迭代器示例
```cpp
QList<QString> list;
list << "A" <<"B" << "C" << "D";
QList<QString>::reverse_iterator i;
for (i = list.rbegin(); i != list.rend(); i ++) {
    *i = i->toLower();
}
```

由于隐式共享，函数返回一个容器的开销非常小，Qt API 包含许多函数，可以为每个值返回一个 QList 或 QStringList。如果想要使用 STL 迭代器迭代它们，应该始终获取容器的副本并迭代该副本。

= 其他常用的基础类
== `QVariant` 类类似于 Qt 常见数据类型的 union（类型不确定，某时刻只能为一种类型）
`QObject:: property()` 的原形：`QVariant QObject::property(const char *name) const` 各种属性的数据类型不同，需要使用 `QVariant` 类表示可以存储任何类型的数据。

名为 `toT()` 的方法（例如 `ToInt()`，`ToString()`）是 const 。用于转换为具体的类型。`toT()` 会进行复制和转换，而不会改变对象本身。

```cpp
Qvariant var(173);
QStrign str = var.toString();
int val = var.value<int>();

QStringList strList;
strlist<< "one" << "two" << "three";
var.setValue(strList);
QStringList value = var.toStringList();
```

由于 QVariant 是 QT 核心模块的一部分，不能提供到 QT GUI 中定义的数据类型的转换函数，因此对于 QT GUI 模块中的一些类，QVariant 没有相应的 toT 函数，需要通过 `QVariant:: value()` 函数来得到指定类型的值。

```cpp
QFont font = this->font();
Qvariant var = font;
QFont font2 = var.value<QFont>();
```

== QFlags 类`QFlags<Enum>` 类是模块类，Enum 是枚举类型。QFlags 是 Qt 中用于存储枚举值的或运算组合。
Qt 使用 QFlags 提供类型安全（与 C++用 int 或 uint 相比）。例如，Qt:: Alignment 类型只是 `QFlags<Qt::AlignmentFlag>` 的 typedef 类型。`QLabel:: setAlignment()` 接受一个 `Qt::Aligment` 参数，说明 `Qt::AlignmentFlag` 值或 `{}` 的任何组合都是合法的。

```cpp
label->setAignment(Qt::AlignLeft | Qt::AlignTop);
label->setAlignment({});
```

自定义类型的枚举类型 要使用 `Q_DECLARE_FLAGS()` 与 `Q_DECLARE_OPERATOR_FOR_FLAGS()`

```cpp
class MyClass {
public:
    enum Option {
        NoOptions = 0x0,
        ShowTabs = 0x1,
        ShowAll = 0x2,
        SqueezeBlank = 0x4
    };
    Q_DECLARE_FLAGS(Options, Option);
};
Q_DECLARE_OPERATOR_FOR_FLAGS(MyClass::Options);

```

== QRandomGenerator 类是高质量的随机数生成器。可以填充用户提供的种子值，如果种子值确定，那么这个类生成的数字序列是确定的。
```cpp
QRandomGenerator * rand1 = new QRandomGenerator(QDataTime::currentMSecsSinceEpoch());

qDebug() << rand1->generate();
```

`QRandomGenerator::securelyseed()` 可以用过创建一个 `QRandomGenerator`，这个是通过 `QRandomGenerator::system()` 安全地产生种子值，意味着它生成的数字序列不能轻易的预测。

`QRandomGenerator::global()` 返回一个 `QRandomGenerator` 的全局实例（使用 `securelyseed`）

其他相关的函数

```cpp
quint64 QRandomGenerator::generate64();
quint32 QRandomGenerator::generate();
double QRandomGenerator::generateDouble() // 生成[0.1)之间的浮点数
```

支持括号运算符

```cpp
QRandomGenerator rand(QDateTime::currentSecsSinceEpoch());
qDebug << rand(); // 等同于 rand.generate();
```

使用 `fillRange` 生成一组随机数

```cpp
QList<quint32> list;
list.resize(16);
// 1
QRandomGenerator::global()->fillRange(list.date(), list.size());
// 2
QRandomGenerator::global()->fillRange(list);
```

使用 `bounded` 函数生成指定范围内的随机数

```cpp
template<typename T>
T QRandomGenerator::bound(T highest);

// [lowest, highest)
template<typename T>
T QRandomGenerator::bound(T lowest, T highest);
```
