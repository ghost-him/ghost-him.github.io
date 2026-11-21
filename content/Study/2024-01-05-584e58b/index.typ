#import "../../index.typ": template, tufted
#show: template.with(title: "QT学习笔记-常用界面组件的使用")

`QWidget` 是所有界面组件类的直接或间接父类。`QWidget` 的父类是 `QObject` 与 `QPaintDevice`。

`Widget` 组件：所有界面组件的统称，它从操作系统接收鼠标，键盘和其他事件，并在屏幕上显示自己，每个组件都是矩形的，并且按 z 轴顺序排列。

`window`：没有嵌入到父组件中的组件。通常，有一个 frame 和一个标题栏，可以使用 `window flags` 创建没有这两个装饰的窗口。在 Qt 中，`QMainWindow` 和 `QDialog` 的各种子类是最常用的 window 类型。

= `QWidget` 类的主要属性和接口函数
`sizePolicy:QSizePolicy`

`QSizePolicy` 类用于描述布局中的水平和垂直大小调整策略。包含两个枚举值（垂直，水平），其值是枚举类型 `QSizePolicy::Policy`，还包含 `stretch` 值：

#figure(
  table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([constant], [value], [description],),
    table.hline(),
    [QSizePolicy:: Fixed], [0], [是否固定大小],
    [QSizePolicy:: Minimum], [GrowFlag], [最小值],
    [Maximum], [ShrinkFlag], [最大值],
    […], […], […],
  )
  , kind: table
  )

QWidget 作为窗口时的一些函数和属性

#figure(
  table(
    columns: (50%, 50%),
    align: (auto,auto,),
    table.header([context], [function],),
    table.hline(),
    [Window function], [`show(), hide(), raise(), lower(), close()`],
    [Top-level function], [`windowModified(), showMaximized(), fullScreen, showNormal(), activateWindow()` 等],
    [Window contents], [`update(), repaint(), scroll()` 等],
    […], […],
  )
  , kind: table
  )

== 布局管理
通过一些类实现，经过预编译后，被转换为 c++代码。

`QStackedLayout`：在 designer 里没有体现，提供了一个组件堆叠，其中一次只有一个可见。

`Grid layout` 与 `Form layout` 区别：`Grid layout` 是先划分空间，然后再放元素。而 `Form layout` 则是直接放元素，可以不放满空间。

容器组件：可以将一组需要布局管理的组件放在一个容器组件中，这样，当容器大小变化时，里面的组件也会自动变化。

`layoutStretch`：用于设置划分空间的比例，对于 `Grid layout`，应该使用全局设置，设置单个组件的 `stretch` 的使用不大。

#figure(
  table(
    columns: (12.73%, 87.27%),
    align: (auto,auto,),
    table.header([数值], [意思],),
    table.hline(),
    [0,0,0], [3 个组件平均分],
    [0,0,1], [前两个达到合适宽度后不再加宽度，其余的都给第三个],
    [1,1,2], [三个组件以 1：1：2 的比例分1],
  )
  , kind: table
  )

`QGridLayout` 类添加组件的函数是 `addWidget()`

```cpp
void QGridLayout::addWidget(QWidget *widget, int fromRow, int fromColumn, int rowSpan, int columnSpan, Qt::Alignment alignment = Qt::Alignment());
```

`rowSpan` 与 `columnSpan` 为因子。

== 分割条
分割条允许用户通过拖动子 widget 之间的边界来控制子 widget 的大小，任意数量的部件都可以由单个分割条控制。

使用 `addWidget` 来添加子部件

= QString 字符串操作
QString 没有父类，QString 存储一个由 16 位 Qchar 组成字符串，每个 QChar 对应一个 UTF-16 编码单元。(编译值大于 65535 的 unicode 字符使用两个连续的 QChar 存储)

QString 的创建和初始化

将 `const char *` 传递给它的构造函数。例：下面的代码创建了一个包含 `"hello"` 的长度为 5 的 QString。

```cpp
QString str = "hello";
```

QString 字符串的索引：

QString 使用从 0 开始的索引，像 c++的数组一样。要访问特定索引位置的字符，可以使用 `[]` 运算符。对于非常量字符串，运算符 `[]` 返回一个指向字符的引用，可以在赋值语句的左侧使用。

= `QSpinBox 和 QDoubleSpinBox`
`QSpinBox 和 QDoubleSpinBox` 都是 `QAbstractSpinBox` 的子类。

设置前缀与后缀 前缀：`prefix()`；后缀：`suffix()`；

读取数值

- 包括前缀与后缀：`text()`；
- 不包括前缀与后缀：`cleanText()`

设置最大值与最小值 最大值：`maximum()`；最小值：`minimum()`；

设置步长： `singlestep()`；

设置当前显示的值： `value()`

设置显示时使用的进制： `displayIntergerBase()`

设置显示数值的小数位数： `decimals()`

= 常用的按钮按键
常用的按钮组件有普通按钮 `QPushButton`，工具按钮 `QToolButton`，单选按钮 `QRadioButton`，复选框 `QCheckBox`，父类都是 `QAbstractBUtton`，所以有很多共同的特性。例如，`QAbsctractButton` 具有 `checkable` 和 `checked` 属性，所以，这些按钮都是可复选的。通过属性设置，`QPushBUtton` 也可以实现 `QCheckBox` 或 `QRadioButton` 的功能。

`QAbstractButton` 的 `autoExclusive` 属性：如果启用了自动独占性，属于同一个父部件的可检查按钮将互斥。

`QGroupBox` 的 `flat` 属性：可以最小化区域框的空间消耗。在大多数样式中，启用这个属性会移除框架的左边缘，右边缘和底边。

= `QSlider` 与 `QProgressBar`
滑动条 `QSlider`，卷滚条 `QScrollBar` 和表盘 `QDial` 是 3 个滑动行输入组件，可用于输入数值，他们的基类都是 `QAbstractSlider`。

进度条 `QProgressBar` 是常见的用于数值显示的组件，特别适用于显示百分比进度。

= 日期时间数据
- QTime：时间数据类型
- QDate：日期数据类型
- QDateTime：日期时间数据类型
- QCalenderWidget：一个用日历形式选择日期的组件

字符格式

#figure(
  table(
    columns: 2,
    align: (auto,auto,),
    table.header([格式字符], [意义],),
    table.hline(),
    [d], [天，不补 0 显示],
    [dd], [天，补 0 显示],
    […], […],
  )
  , kind: table
  )

= QComboBox（下拉列表）
`QComboBox` 是下拉列表框组件，它提供一个下拉列表供用户选择输入，也可以提供一个编辑框用于输入文字。`ComboBox` 下拉的每个项还可以存储一个或多个 `QVariant` 类型的用户数据，用户数据并不显示在界面上。

`placeholderText`：`QStringcurrentIndex` 为 `-1` 时显示的内容。在下来列表中并不会显示。

= `QMainWindow` 和 `QAction`
`QMainWindow` 是主窗口类，具有菜单栏，工具栏，状态栏等主窗口常见的界面元素。在 ui 可视化设计时，可以设计很多 `Action`，然后用 `Action` 创建菜单项和工具栏按钮。

= `QToolButton` 和 `QListWidget`
`QListWidget` 是显示的列表组件，列表的每个项是一个 `QListWidgetItem` 对象，一个项存储了文字，图标，用户数据等内容。

= QTreeWidget
`QTreeWidget` 是一种 Item Widget 组件，即树形组件，它的项被称为节点。树形组件适合于显示具有层级结构的数据。

`QTreeWidget` 组件的表头和目录树节点都是 `QTreeWidgetItem` 类对象

= `QTableWidget`
是一种 `Item Widget` 组件，它以表格形式显示和管理数据。表格的每个单元格关联一个 `QTableWidgetItem` 对象，可以设置每个单元格的文字内容，字体，文字颜色，背景色，图标等，还可以有复选框。每个单元格还可以存储用户数据。
