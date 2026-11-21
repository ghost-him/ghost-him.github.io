#import "../../index.typ": template, tufted
#show: template.with(title: "C++ 并发编程---线程池")

future, promise, async被称为C++中的并发三剑客，同时也是并改技术实现的关键。

= 并发基础\#\# async用法
`std::async`是一个用于异步执行函数的模板函数，返回一个`std::future`对象，该对象用来获取函数的返回值。

`std::async`会启动一个线程来执行 例子：

```cpp
#include <iostream>
#include <future>
#include <chrono>

// 异步执行的任务
std::string fetchData(std::string query) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    return "data: " + query;
}

int main() {
    // 使用异步执行fetchData
    std::future<std::string> result = std::async(std::launch::async, fetchData, "find new data");
    // 获取当前的返回值，是一个阻塞操作
    std::string data = result.get();
    // 输出当前的返回值
    std::cout << data << std::endl;
}
```

== async的启动策略
`std::async`可以接受几个不同的启动策略，这些策略在`std::launch`枚举中定义，共有以下几个类型：

+ `std::launch::deferred`：任务会在调用`get()`与`wait()`方法时才执行。
+ `std::launch::async`：任务会直接异步执行。
+ `std::launch::async | std::launch::deferred`：可能同步也可能异步，取决于编译器。默认的策略是这个。

== future中的wait()与get()
两个都是用于处理异步任务的方法。

- `std::future::get()`：是一个阻塞调用，用来获取`future`的值或异常。`get()`只可以调用一次，`future`一旦被`get()`调用，则不能再次被用来获取结果。
- `std::future::wait()`：是一个阻塞调用，不会获取`future`的值。如果任务没有完成，则调用了以后会一直等，直到任务已经完成。不会消耗`future`，因此可以多次调用。

可以使用`wait_for()`或`wait_until()`来检查异步操作是否完成。应用场景：可以用于超时操作

```cpp
if (fut.wait_for(std::chrono::seconds(0) == std::future_status::ready) {
// 操作完成
} else {
// 操作未完成
}
```

== `std::packaged_task`
是一个可调用目标，包装了一个任务，这个任务可以在另一个线程上运行。它可以捕获任务的返回值或异常，并将其存储在\`std::future对象中。

通过使用`std::packaged_task`则可以与`std::thread`进行配合。

```cpp
#include <iostream>
#include <future>
#include <chrono>

int my_task() {
    std::this_thread::sleep_for(std::chrono::seconds(2));
    std::cout << "my task" << std::endl;
    return 1;
}

int main() {
    // 创建一个包装了任务的task对象
    std::packaged_task<int()> task(my_task);
    // 获取这个task关联的future对象
    std::future<int> result = task.get_future();
    // 启动一个线程来使用这个task
    std::thread t(std::move(task));
    // 让线程与主线程分离，这样主线程可以等待任务完成
    t.detach();
    
    int value = result.get();
    std::cout << "end" << std::endl;
}
```

== `std::promise`
与`std::packaged_task`的区别：主线程在执行`std::promise`时，当子线程执行完`set_value()`方法后，主线程就可以从`std::future`中获得值，而不需要像`std::packaged_task`一样，等整个函数都执行完后才获得。

如果子线程要执行一系列的值，而主线程只需要在子线程执行完前两个操作后即可继续进行时，则可以使用`std::promise`。

在传递`std::promise`时，只可以使用`std::move`来传递或使用智能指针来传递。`std::move`不支持拷贝构造，只支持移动构造。

```cpp
#include <iostream>
#include <future>
#include <chrono>

void set_value(std::promise<int> prom) {
    std::this_thread::sleep_for(std::chrono::seconds(2));
    prom.set_value(10);
    std::cout << "promise set value success" << std::endl;
}

int main() {
    // 创建一个promise对象
    std::promise<int> prom;
    // 获取与promise相关联的future对象
    std::future<int> fut = prom.get_future();
    // 在新线程中设置promise的值
    std::thread t(set_value, std::move(prom));
    // 在主线程中获取future的值
    std::cout << "value set by thread:" << fut.get() << "\n";
    // 主线程等待子线程执行完成：子线程后面的内容也要花时间完成
    t.join();
}
```

可以使用`std::promise`与`std::future`来获取异常。在子线程中出现了异常（调用了`set_exception()`），则在主线程中也一定要有`try`与`catch`，否则，主线程会崩溃。如果在获取结果时出现了异常，那么再次调用`get()`函数时会再次抛出异常。

```cpp
#include <iostream>
#include <future>
#include <chrono>

void set_exception(std::promise<void> prom) {
    try {
        throw std::runtime_error("An error occurred!");
    }
    catch (...) {
        // 设置promise的异常
        prom.set_exception(std::current_exception());
    }
}

int main() {
    // 创建一个promise对象
    std::promise<void> prom;
    // 获取与promise相关联的future对象
    std::future<void> fut = prom.get_future();
    // 在新线程中设置promise的值
    std::thread t(set_exception, std::move(prom));
    // 在主线程中获取future的值
    try {
        std::cout << "waiting for exception:" << "\n";
        fut.get();
    }
    catch (const std::exception& e) {

        std::cout << "exception set by the thread: " << e.what() << std::endl;
    }
    t.join();
}
```

在执行`std::future`的`get`方法时，与`std::future`相关联的`std::promise`必须是存活的，不能被释放内存。如果不想被释放，则可以使用智能指针。

```cpp
void use_promise_destruct() {
    std::thread t;
    std::future<int> fut;
    {
        std::promise<int> prom;
        fut = prom.get_future();
    }
    // 错误，此时的prom已经被释放
    fut.get();
}
```

== `std::shared_future`
如果出现多个线程同时等待一个异步结果的情况，则可以使用`std::shared_future`。线程安全，无需加锁。

支持拷贝，不是智能指针。

```cpp
#include <iostream>
#include <future>
#include <chrono>

void myFunction(std::promise<int>&& promise) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    promise.set_value(10);
}

void threadFunction(std::shared_future<int> future) {
    try {
        int result = future.get();
        std::cout << "Result: " << result << std::endl;
    }
    catch (const std::future_error& e) {
        std::cout << "Future error: " << e.what() << std::endl;
    }
}

int main() {
    std::promise<int> promise;
    // 默认的移动构造。没有拷贝构造。
    std::shared_future<int> future = promise.get_future();
    // 线程1去设置值
    std::thread myThread1(myFunction, std::move(promise));
    // 线程2，3去打印
    std::thread myThread2(threadFunction, future);
    std::thread myThread3(threadFunction, future);

    /*
    * 错误，第一个move了以后，第二个的状态不对，无法移动
    * std::thread myThread2(threadFunction, std::move(future));
    * std::thread myThread3(threadFunction, std::move(future));
    */

    myThread1.join();
    myThread2.join();
    myThread3.join();
}
```

= 线程池
线程池是一种多线程处理形式，线程池在运行时则会自动执行队列中的任务。线程池是的线程都是后台线程，有一个监听线程用来管理线程池。线程池中有最大线程数，线程池中的线程数不会超过最大线程数。

线程池的使用可以避免在处理短时间任务时的创建与销毁的开销，从而提高了整体的性能。

线程池的难点：

- 一个`task`任务队列

- 封裝回调函数

- 线程池的状态转换

  == 代码实现
  <代码实现>

```cpp
#include <iostream>
#include <future>
#include <queue>
#include <algorithm>

class ThreadPool {
public:
    ThreadPool(const ThreadPool&) = delete;
    ThreadPool& operator=(const ThreadPool&) = delete;

    // 单例模式
    static ThreadPool& instance() {
        static ThreadPool ins;
        return ins;
    }

    using Task = std::packaged_task<void()>;

    // 设置初始的线程的数量
    ThreadPool(unsigned int num = 5) {
        thread_num_ = std::max((unsigned int)1, num);
        start();
    }

    ~ThreadPool() {
        stop();
    }

    template<class F, class... Args>    // 尾置类型推导：尖括号后面的是返回值类型
    auto commit(F&& f, Args&&... args) -> std::future<decltype(f(args...))> {
        using RetType = decltype(f(args...));
        if (stop_.load()) {
            return std::future<RetType>{};
        }
        auto task = std::make_shared<std::packaged_task<RetType()>>(
            std::bind(std::forward<F>(f), std::forward<Args>(args)...));

        std::future<RetType> ret = task->get_future();
        {
            std::lock_guard<std::mutex> cv_mt(cv_mt_);
            // 由于task是一个智能指针，所以这里可以保证，task在没有执行之前一直都是安全的。
            tasks_.emplace([task] {(*task)(); });
        }
        cv_lock_.notify_one();
        return ret;
    }


private:
    void start() {
        for (int i = 0; i < thread_num_; i++) {
            pool_.emplace_back([this]() {
                while (!this->stop_.load()) {
                    Task task;
                    {
                        std::unique_lock<std::mutex> cv_mt(cv_mt_);
                        this->cv_lock_.wait(cv_mt, [this] {
                            return this->stop_.load() || !this->tasks_.empty();
                            });
                        if (this->tasks_.empty())
                            return;
                        task = std::move(this->tasks_.front());
                        this->tasks_.pop();
                    }
                    this->thread_num_--;
                    task();
                    this->thread_num_++;
                }
                });
        }
    }

    void stop() {
        stop_.store(true);
        cv_lock_.notify_all();
        for (auto& td : pool_) {
            if (td.joinable()) {
                td.join();
            }
        }
    }

private:
    std::mutex cv_mt_;
    std::condition_variable cv_lock_;
    std::atomic_bool stop_;
    std::atomic_int thread_num_;
    std::queue<Task> tasks_;
    std::vector<std::thread> pool_;
};
```

这里在调用的时候，如果要通过线程池来修改外面变量的值，则要使用`std::ref()`来传递值，如：

```cpp
int main() {
    int m = 0;
    ThreadPool::instance().commit([](int& c) {
        c = 10;
        }, std::ref(m)); // 传入std::ref(m);
    // 等待线程执行完毕
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    // 输出
    std::cout << m << std::endl;
}
```

必须要使用`std::ref()`的原因是，当程序传入的是一个`int &`类型时，线程池在执行`std::bind()`函数时，会将传入类型变成复本，此时线程改的就仅仅是传入参数的复本，因此要使用`std::ref()`来解决

== 线程池的缺点
+ 只可以无序处理。两个线程之间是异步执行的。
+ 无法执行逻辑上强关联或互斥的两个函数。
