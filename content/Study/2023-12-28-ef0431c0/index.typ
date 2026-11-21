#import "../../index.typ": template, tufted
#show: template.with(title: "C++ 多态内存资源（pmr）")

= 内存池的产生背景
如果程序中出现大量的`new` `delete`操作，那么由于每一次操作都会调用系统调用，所以程序的运行速度会蛮的很慢。因此，为了避免大量的出现内存分配的情况，可以采用预分配内存的方式来解决。

= 应用场景
在嵌入式与音视频等对内存效率很敏感的领域中用。

= 内存分配的性能排行
`windows malloc(new, delete) < sync < glib malloc(new, delete) < unsync < mono`

= C++标准库中的内存池
C++中提供了`allocator`类与`memory_resource`类来为用户实现更高效的内存管理机制。`allocator`类中存的是对`memory_resource`类的一个指针，用来和容器打交道；而拥有内存资源，同时对内存进行操作的类是`memory_resource`，与内存打交道。

== allocator类
`std::pmr::polymorphic_allocator` 多态分配器

`allocator`的比较：设有两个分配器`a`与`b`。若`a`分配的内存可以由`b`来释放，则`a`与`b`相等。 为什么要有比较的功能？

+ 在`std::move()`函数中，如果相等，则可以直接替换
+ 在`list`等容器中，有`merge()`成员函数，如果分配器相等，则可以不分配内存，如果不相等，则会自动进行拷贝复制。

== memory\_resource类
`std::pmr::memory_resource`是所有的类的父类，是一个抽象类。

=== `monotonic_buffer_resource`
- 只有在资源被销毁时才会释放已分配的内存。它适用于快速分配内存的情况，即使用内存建立几个对象，然后一次性全部释放。因此，不适合当做全局的内存池。
- 可以使用初始缓冲区构建。如果没有初始缓冲区，或者缓冲区已用完，则会从构建时提供的上游内存资源中获取额外的缓冲区。获取的缓冲区大小按几何级数递增。 \
- 不是线程安全的。

在创建对象的时候，可以直接指定内存池的大小，也可以指定一个数组并传入这个数组的大小。这样就完成了内存池的初始化。

```cpp
// 全局内存池
std::pmr::synchronized_pool_resource pool;
// 全局数组
char g_buf[65536 * 10];
int main() {
    {
        // std::pmr::monotonic_buffer_resource mem{65536 * 10, &pool }; //如果mem中已经写满了，则会写到pool中
        std::pmr::monotonic_buffer_resource mem{ g_buf, sizeof(g_buf), &pool};
        // 设置 a 容器使用mem内存池
        std::vector<char, std::pmr::polymorphic_allocator<char>> a{ &mem };
        for (int i = 0; i < 65536; i++) {
            a.push_back(42);
        }
    }
}
```

同时，定义一个容器的时候，也有一个简写的版本：

```cpp
std::vector<char, std::pmr::polymorphic_allocator<char>> a{ &mem };
等价于
std::pmr::vector<char> a{ &mem };
```

如果`std::pmr::容器<char> a`没有指定一个内存池（包括当一个内存池的上游内存池没有指定的时候），那么，它会指向默认的`std::pmr::get_default_resource`。如果你没有使用`set_default_resource`，则`get_default_resource`等价于`new_delete_resource`。而`new_delete_resource`等价于没有使用内存池，与直接使用`new`，`delete`无差异。即，直接使用`new`与`delete`来分配内存。

`set_default_resource`使用方法。要注意内存池的生命周期。

```cpp
// 直接在代码中写即可

// ...
// 已经存在的一个内存池
std::pmr::monotonic_buffer_resource mem{65536 * 10};
// 将默认的内存池设置成mem
std::pmr::set_default_resource(&mem);
// ...
```

=== `std::pmr::synchronized_pool_resource`
可以动态的添加与释放空间。提供了原子保护，支持多线程的访问。

- 它拥有已分配的内存，并在销毁时释放内存，即使某些已分配的块尚未调用 deallocate 也是如此。 \
- 它由一组池组成，这些池可满足不同块大小的请求。每个池管理一个块集合，然后将这些块分成大小一致的块。 \
- 对 `do_allocate` 的调用会被分派到可容纳所请求大小的最小区块的池中。 \
- 当池中的内存耗尽时，该池的下一个分配请求就会从上游分配器中分配额外的内存块来补充池中的内存。获得的块大小会呈几何级数增长。 \
- 超过最大块大小的分配请求将由上游分配器直接提供。 \
- 最大块大小和最大块大小可通过向其构造函数传递 `std::pmr::pool_options` 结构来调整。 \
- 可由多个线程访问，无需外部同步，也可使用特定于线程的池来降低同步成本。

如果只会有单线程访问的情况，则可以使用`std::pmr::unsynchronized_pool_resource`来代替，性能更好。

=== `std::pmr::unsynchronized_pool_resource`
- 它拥有已分配的内存，并在销毁时释放内存，即使某些已分配的块尚未调用 deallocate 也是如此。 \
- 它由一组池组成，这些池可满足不同块大小的请求。每个池管理一个块集合，然后将这些块分成大小一致的块。要求的是固定的长度或链表的方式。
- 对 `do_allocate` 的调用会被分派到可容纳所请求大小的最小区块的池中。 \
- 当池中的内存耗尽时，该池的下一个分配请求就会从上游分配器中分配额外的内存块来补充池中的内存。获得的块大小会呈几何级数增长。 \
- 超过最大块大小的分配请求将由上游分配器直接提供。 \
- 最大块大小和最大块大小可以通过向其构造函数传递 `std::pmr::pool_options` 结构来调整。
- 不是线程安全的，不能同时从多个线程访问；

=== `std::pmr::null_memory_resource`
无论分配多少的内存，都会抛出异常。不分配内存，可以防止内存池申请了过多的内存。比如： `std::pmr::monotonic_buffer_resource mem{ g_buf, sizeof(g_buf), &std::pmr::null_memory_resource};`。这样就可以将`mem`的内存分配限制在`g_buf`上。

=== `std::pmr::new_delete_resource`
使用`new`与`delete`来分配内存，是默认的内存分配方式。

= 内存池的实战
在智能指针中，默认的是使用`new`与`delete`来分配内存，那么我们可以使用`std::allocate_ptr`来指定分配内存的地方。

例如： `auto a = std::allocate_shared<int>(std::pmr::polymorphic_allocator<int>(&pool), 42)`
