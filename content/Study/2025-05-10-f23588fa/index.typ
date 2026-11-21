#import "../../index.typ": template, tufted
#show: template.with(title: "C++中线程安全的对两个锁同时加锁")

= C++中线程安全的对两个锁同时加锁
在C++中，线程安全地同时加锁多个锁是一个常见的需求，尤其是在操作多个需要互斥访问的资源时。本文通过一个big\_object类的例子，展示了如何在多线程环境中安全地交换两个对象。首先，danger\_swap函数展示了非线程安全的加锁方式，可能导致死锁。随后，safe\_swap函数通过使用std::lock和std::lock\_guard结合std::adopt\_lock，实现了对两个锁的同时加锁，避免了死锁问题。进一步，C++17引入的std::scoped\_lock简化了这一过程，能够自动管理多个锁的加锁

参考文档：https:/\/llfc.club/articlepage?id=2UVOC0CihIdfguQFmv220vs5hAG

如果我们现在有一个需要互斥访问的变量 `big_object`，它的定义如下：

```cpp
// 假如这个object是一个非常大的数据结构
class big_object {
public:
    big_object(int data) :_data(data) {}
    //拷贝构造
    big_object(const big_object& b2) :_data(b2._data) {
        _data = b2._data;
    }
    //移动构造
    big_object(big_object&& b2) :_data(std::move(b2._data)) {
    }
    //重载输出运算符
    friend std::ostream& operator << (std::ostream& os, const big_object& big_obj) {
        os << big_obj._data;
        return os;
    }
    //重载赋值运算符
    big_object& operator = (const big_object& b2) {
        if (this == &b2) {
            return *this;
        }
        _data = b2._data;
        return *this;
    }
    //交换数据
    friend void swap(big_object& b1, big_object& b2) {
        big_object temp = std::move(b1);
        b1 = std::move(b2);
        b2 = std::move(temp);
    }
private:
    // 这里使用随便一个变量用于表示其成员
    int _data;
};
```

由于这个是需要互斥访问的，所以每一个对象都需要有一个锁来确保线程安全的访问。所以定义一个`big_object_mgr`来管理这个类。

```cpp
// 现在使用一个线程安全的类对这个超大类做管理
class big_object_mgr {
public:
    big_object_mgr(int data = 0): _obj(data) {}

    void printinfo() {
        std::cout << "current obj data is " << _obj << std::endl;
    }

    friend void danger_swap(big_object_mgr& obj_1, big_object_mgr& obj_2);
    friend void safe_swap(big_object_mgr& obj_1, big_object_mgr& obj_2);
    friend void safe_swap_scope(big_object_mgr& obj_1, big_object_mgr& obj_2);

private:
    std::mutex _mutex;
    big_object _obj;
};
```

我们以交换这两个`big_object_mgr`对象为例，来说明一下如果线程安全的实现交换。

首先来看一下实现的，线程不安全的交换逻辑：

```cpp
void danger_swap(big_object_mgr &obj_1, big_object_mgr &obj_2) {
    std::cout << "danger swap start" << std::endl;
    // 如果这两个对象是同一个对象，则直接返回
    if (&obj_1 == &obj_2) {
        return;
    }

    std::lock_guard<std::mutex> lock_guard1(obj_1._mutex);
    // 这个延时1s表示：用于演示两个锁加锁之间发生了线程运行交换
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::lock_guard<std::mutex> lock_guard2(obj_2._mutex);

    std::swap(obj_1._obj, obj_2._obj);
    std::cout << "danger swap end" << std::endl;
}
```

这个代码第一眼看上去是没有问题的，但是如果仔细分析一下，就可以知道有以下的问题：#strong[由于lock\_guard1与2是非同时加锁的，所以可能会出现当lock\_guard1加锁后，发生了线程的调度，此时会有另一个线程对lock\_guard2进行了加锁，这样就会有可能发生了死锁。]

实验代码如下：

```cpp
void test_danger_swap() {
    big_object_mgr objm1(5);
    big_object_mgr objm2(100);
    std::thread t1(danger_swap, std::ref(objm1), std::ref(objm2));
    std::thread t2(danger_swap, std::ref(objm2), std::ref(objm1));
    t1.join();
    t2.join();
    objm1.printinfo();
    objm2.printinfo();
}
```

这里为了可以 100% 的产生死锁，我们通过在给`lock_guard1`加锁成功后，延迟1秒再来加锁`lock_guard2`。

#html.hr()

以上就可以确定出问题：#strong[由于需要使用两个锁，但是当这两个锁没有同时加锁时，就会导致线程不安全]。为了解决这个问题，我们可以使用`std::lock()`实现对两个锁的同时加锁。现在来看`safe_swap`代码的实现：

```cpp
void safe_swap(big_object_mgr& obj_1, big_object_mgr& obj_2) {
    std::cout << "safe_swap start" << std::endl;
    if (&obj_1 == &obj_2) {
        return;
    }

    // 从上述的代码中可以看到，死锁的过程是在给两个锁分别加锁的过程中发生的
    // 所以只需要给这两个锁同时加锁就可以解决这个问题
    std::lock(obj_1._mutex, obj_2._mutex);

    // 如果想使用lock_guard来管理这个锁的释放，则可以使用领养锁来管理
    std::lock_guard<std::mutex> lock_guard1(obj_1._mutex, std::adopt_lock);
    // 这个延时1s表示：用于演示两个锁加锁之间发生了线程运行交换
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::lock_guard<std::mutex> lock_guard2(obj_2._mutex, std::adopt_lock);
    std::swap(obj_1._obj, obj_2._obj);
    std::cout << "safe_swap end" << std::endl;
}
```

由于`std::lock_guard`会默认给传入的锁上锁，而我们使用`std::lock`以后，就已经给锁上好锁了，所以就无法直接通过`std::lock_guard`来对这个锁做管理。此时就可以通过领养锁`std::adopt_lock`来实现对已经上过锁的锁的管理。此时，`std::lock_guard`就只负责`std::mutex`的释放，而不负责上锁。

这个的测试代码如下，可以看到，代码是可以正确的运行的：

```cpp
void test_safe_swap() {
    big_object_mgr objm1(5);
    big_object_mgr objm2(100);
    std::thread t1(safe_swap, std::ref(objm1), std::ref(objm2));
    std::thread t2(safe_swap, std::ref(objm2), std::ref(objm1));
    t1.join();
    t2.join();
    objm1.printinfo();
    objm2.printinfo();
}
```

#html.hr()

现在已经解决了同时上锁的问题，但是这样写代码又过于麻烦了，有没有更简单的办法呢？有的兄弟，有的。c++17中引入了一个`std::scoped_lock`，可以使用这个锁来实现对两个锁的同时上锁，使用方式如下：

```cpp
void safe_swap_scope(big_object_mgr& obj_1, big_object_mgr& obj_2) {
    std::cout << "safe_swap_scope start" << std::endl;
    if (&obj_1 == &obj_2) {
        return;
    }
    // 上述的方式还是太麻烦了，在c++17中引入了std::scoped_lock，可以同时对两个锁上锁，以及解锁
    std::scoped_lock guard(obj_1._mutex, obj_2._mutex);
    std::swap(obj_1._obj, obj_2._obj);
    std::cout << "safe_swap_scope end" << std::endl;
}
```

测试代码如下：

```cpp
void test_safe_swap_scope() {
    big_object_mgr objm1(5);
    big_object_mgr objm2(100);
    std::thread t1(safe_swap_scope, std::ref(objm1), std::ref(objm2));
    std::thread t2(safe_swap_scope, std::ref(objm2), std::ref(objm1));
    t1.join();
    t2.join();
    objm1.printinfo();
    objm2.printinfo();
}
```

#html.hr()

由于在开发中很难避免一个函数内同时加多个锁的情况，所以需要避免循环加锁。而我们可以使用层级锁来解决这个问题。

层级锁的实现如下：

```cpp
// 层级锁
// 为了避免循环加锁，可以使用层级锁来完成加锁
// 如果不按顺序加锁，则会抛出异常
class hierarchical_mutex {
public:
    explicit hierarchical_mutex(unsigned long value):_hierarchy_value(value), _previous_hierarchy_value(0){};

    hierarchical_mutex(const hierarchical_mutex&) = delete;
    hierarchical_mutex& operator = (const hierarchical_mutex&) = delete;

    void lock() {
        check_for_hierarchy_violation();
        _internal_mutex.lock();
        update_hierarchy_violation();
    }

    void unlock() {
        // 如果解锁的顺序不对，则抛出异常
        if (_this_thread_hierarchy_value != _hierarchy_value) {
            throw std::logic_error("hierarchical_mutex unlock unexpectedly");
        }
        _this_thread_hierarchy_value = _previous_hierarchy_value;
        _internal_mutex.unlock();
    }

    bool try_lock() {
        check_for_hierarchy_violation();
        if (!_internal_mutex.try_lock()) {
            return false;
        }
        update_hierarchy_violation();
        return true;
    }

private:
    std::mutex _internal_mutex;
    // 当前的层级值
    unsigned long const _hierarchy_value;
    // 上一级层级的值
    unsigned long _previous_hierarchy_value;
    // 本线程记录的层级值
    static thread_local unsigned long _this_thread_hierarchy_value;

    // 检测加锁是不是合理的
    void check_for_hierarchy_violation() {
        if (_this_thread_hierarchy_value <= _hierarchy_value) {
            throw std::logic_error("hierarchy violation");
        }
    }

    void update_hierarchy_violation() {
        _previous_hierarchy_value = _this_thread_hierarchy_value;
        _this_thread_hierarchy_value = _hierarchy_value;
    }

};

thread_local unsigned long hierarchical_mutex::_this_thread_hierarchy_value(ULONG_MAX);
```

层级锁的核心思路是通过 #strong[给每个锁分配一个层级（hierarchy level），并强制线程按照层级从高到低（数值从大到小）的顺序来获取锁，从而避免死锁。] 如果加锁的顺序不正确，则会抛出异常，这会强迫程序员检查代码逻辑。

测试代码如下：

```cpp
void test_hierarchy_lock() {
    hierarchical_mutex hmtx1(1000);
    hierarchical_mutex hmtx2(100);

    std::thread t1([&hmtx1, &hmtx2]() {
        hmtx1.lock();
        hmtx2.lock();
        hmtx2.unlock();
        hmtx1.unlock();
    });

    std::thread t2([&hmtx1, &hmtx2]() {
        hmtx2.lock();
        hmtx1.lock();
        hmtx1.unlock();
        hmtx2.unlock();
    });
    t1.join();
    t2.join();
}
```
