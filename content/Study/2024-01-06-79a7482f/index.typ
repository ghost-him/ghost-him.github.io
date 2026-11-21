#import "../../index.typ": template, tufted
#show: template.with(title: "QT学习笔记-事件处理")

GUI 应用程序是由事件 （event）驱动的。点击鼠标，按下按键，窗口大小改变等等。

= QT 的事件系统
按事件的来源，可以将事件划分为 3 类：

- 自生事件（spontaneous event）：由窗口系统产生，如 `QKeyEvent`，`QMouseEvent`。自生事件会进入系统队列，等待事件循环的处理。
- 发布事件（posted event）：是由 qt 应用程序产生，如：`QTimerEvent`。使用 `QCoreApplication::postEvent()` 产生发布事件，等等事件循环的处理。
- 发送事件（sent event）：有 QT 或其他程序定向发送的事件。使用 `QCoreApplication::sendEvent()` 产生发送事件，有对象的 `event()` 函数直接处理。

qt 的主事件循环 `QCoreApplication::exec()` 从事件队列中获取原生的系统事件，将它们转为 `QEvent`，并将转换后的事件发送给 `QObject`。任何 `QObject` 派生的类都可以算是是事件。

`QWidget` 类重新实现了函数 `event()`，并针对一些典型类型的事件定义了专门的事件处理函数。要对一些典型事件进行处理，只需重新实现这些事件处理函数即可。

= 事件与信号
- 界面组件类的很多俣可以看作是对某些事件的封装，例如 `QPushButton` 的 `clicked()` 信号，可以看做是对 `QEvent::MouseButtonRelease` 类型事件的封装。
- 但是 `Qt` 的界面组件只是将少数事件封装成了信号。例如，`QLabel` 就没有与鼠标双击事件对应的信号。可以从 `QLabel` 派生一个类，把鼠标双击事件转换为发射一个自定义信号 `doubleClicked()`。即，将 `mouseDoubleClicked` 事件封装为 `doubleClicked()` 信号/

= 事件过滤器
- 事件过滤器是 `QObject` 提供的一种处理事件的方法
  - 它将一个对象的事件委托给另一个对象来监视并处理

= 拖放事件与拖放操作
拖放时，相当于操作 MIME 数据

- `QMimeData` 用于可存储在剪贴板中的信息，并支持通过拖放机制传输。
- `QMimeData` 对象将它们所持有的数据与相应的 `MIME` 类型相关联，以确保信息可以在应用程序内，应用程序之间安全传输。

= 具有拖放功能的组件
- `QAbstractItemView` 类定义了拖放操作相关的各种函数，通过这些函数的设置，`QListView`，`QTableView`，`QTreeView` 及其对应的便利类都具有非常方便的节点拖放操作功能。
