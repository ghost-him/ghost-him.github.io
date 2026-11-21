#import "../../index.typ": template, tufted
#show: template.with(title: "C++协程")

协程是可以暂停和恢复的函数。协程用于实现异步逻辑，实现单线程中的并发任务。

仅当作笔记，内容还不完善!!

协程的优势：

+ 性能强
+ 语法优雅
+ 未来的大方向

协议在被暂停以后，可以返回到

+ 调度器（函数）
+ `caller`（调用当前协程的协程）
+ 直接恢复另一个协程（用另一个协程取代当前的协程）

= 协程的实现
== `co_await`表达式
用于暂停协程，直到恢复。当协程运行，执行到了`co_wait`时，协程则直接返回。

不是所有的对象都可以等待。将可以被等待的对象称为可等待体。

如果要自己实现一个可等待体，则要求类型实现了`await_ready`，`await_suspend`，`await_resume`三个成员函数。

- `await_ready`函数：用于判定可等待体是否已经准备好。
- `await_suspend`函数：挂起点挂起时，调度协程的函数。
- `await_resume`函数：用于接收异步执行的结果。

== `co_return`表达式
设置返回类型的值，并通知挂起点，当前的协程已经完成。

需要实现一个`promise_type`。

== `co_yield`表达式
通常用于生成器上，会立刻返回一个值。

实现时，要必须要有`promise_type`类。可以用于自定义协程自身的行为，比如在挂起前与挂起后反做的事。可以将`promise_type`作为嵌套类型。对于那些无法修改的类型，那么可以通过特化`coroutine_traits`类型来实现。

`promise_type`有以下几个函数：

+ `get_return_object（）`：用于返回值
+ `initial_suspend()`：提供在挂起前执行代码的机会，返回值有`suspend_always`与`suspend_never`。`suspend_always`在`await_ready`函数中返回`false`，同时协程会在挂起点挂起并等等使用`coroutine_handle`激活恢复。`suspend_never`则相反。
+ `final_suspend()`：提供在挂起后执行代码的机会
+ `yield_value()`：用于获取`co_yield`从挂起点挂起后恢复的值。
+ `return_void()`：当`co_return`返回空时，则执行`return_void()`函数
+ `return_value()`：当`co_return`返回值时，则执行`return_value`函数
