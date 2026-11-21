#import "../../index.typ": template, tufted
#show: template.with(title: "高性能服务器设计思路")

该文章为以下视频的笔记：

https:/\/www.bilibili.com/video/BV1WF411R7aK

文中代码采用 c 风格，linux 下的系统调用的名称。只采用伪代码的形式编写，无法运行。

= 阻塞 IO 形式
最简单的服务器形式

伪代码形式：

```cpp
server_fd = socket(); // 创建一个socket
bind(server_fd, "0.0.0.0", 8080); // 将当前的socket绑定到一个指定的地址和端口
listen(server_fd) // 监听连接请求

while (1) {
    client_fd = accept(server_fd); // 接受连接请求
    if (read(client_fd, buff)) { // 从client_fd中读取数据，并将数据存放到buff中
        handler(buff) // 处理当前buff中的数据
    } else {
        close(client_fd) // 如果已经读完了，则关闭连接
    }
}
```

特点：一次只可以处理一个连接，处理完以后才可以接受下一个连接的请求。 原因：这里的 `accept` 函数和 `read` 函数都是阻塞的。

如果要支持多个客户端的连接请求，那么可以对代码做一些改进：

```cpp
server_fd = socket(); // 创建一个socket
bind(server_fd, "0.0.0.0", 8080); // 将当前的socket绑定到一个指定的地址和端口
listen(server_fd) // 监听连接请求

while (1) {
    client_fd = accept(server_fd); // 接受连接请求
    fds.add(client_fd); // 将当前的新连接的fd添加到fds的连接数组中
    for (fd : fds) { // 遍历当前fds中的所有的fd
        if (read(fd, buff)) { // 从client_fd中读取数据，并将数据存放到buff中
            handler(buff) // 处理当前buff中的数据
        } else {
            close(fd) // 如果已经读完了，则关闭连接
        }
    }
}
```

代码存在的问题：

+ 如果在等待新的连接时，无法处理已经连接上的请求。
+ 同理，如果在等待已经连接上的 fd 传输数据时，无法连接新的请求。
+ 如果在遍历 fds 时，如果其中的一个 fd 一直没有传输数据过来，那么整个程序会卡死（一直阻塞在 read 函数）。

产生问题的原因：`read` 函数和 `accept` 函数相互影响导致的。

解决办法：引入多线程。

= 阻塞 IO+多线程
```cpp
server_fd = socket(); // 创建一个socket
bind(server_fd, "0.0.0.0", 8080); // 将当前的socket绑定到一个指定的地址和端口
listen(server_fd) // 监听连接请求

while (1) {
    client_fd = accept(server_fd); // 接受连接请求
    
    pthread_create(client_fd){ // 创建一个新的线程
        while(1) {
            if (read(client_fd, buff)) { // 从client_fd中读取数据，并将数据存放到buff中
                handler(buff) // 处理当前buff中的数据
            } else {
                close(client_fd) // 如果已经读完了，则关闭连接
            }
        }
    }
}
```

特点：

+ 可以实现一个可用的多线程 tcp 服务器，同时支持处理多个客户端的连接请求。
+ 一个线程处理一个连接

缺点：

+ 无法处理大量连接

原因：每个线程都会占用一定的资源（时，空），所以不但可以创建的线程数是有限的，而且上下文切换的也会占用大量的时间，会影响处理的效率。

解决方法：使用线程池来代替大量的线程

```cpp
server_fd = socket(); // 创建一个socket
bind(server_fd, "0.0.0.0", 8080); // 将当前的socket绑定到一个指定的地址和端口
listen(server_fd) // 监听连接请求
thread_pool_create(num) // 创建指定数量的线程

while (1) {
    client_fd = accept(server_fd); // 接受连接请求
    thread_pool_get(client_fd) {  // 从线程池中获取一个线程
        while(1) {
            if (read(client_fd, buff)) { // 从client_fd中读取数据，并将数据存放到buff中
                handler(buff) // 处理当前buff中的数据
            } else {
                close(client_fd) // 如果已经读完了，则关闭连接
                break;  // 跳出循环，将线程放回线程池 
            }
        }
    }
}
```

缺点：

+ 获取线程 `thread_pool_get` 是一个阻塞的函数，所以会影响服务器的处理能力。
+ 在高并发的环境下，主线程会由于线程池中的线程的数量受到限制，从而无法处理新的请求（直到有旧的连接关闭，线程释放）

原因：每个连接都要一个线程处理，而线程池中的线程是有限的，所以线程池的大小就决定了同时在线连接数的数量。

解决办法：

+ 部署更多的服务器

= 非阻塞 IO
对于一个网络 IO，共有两个系统对象，一个是应用进程，一个是系统内核。当一个 read 函数发生时，会有两个阶段：

+ 等待数据准备
+ 将数据从内核拷贝到用户空间 在阻塞 IO 模型中，只有当这两个阶段都完成了以后都会返回。

所以这里就是一个可以优化的地方。

在非阻塞 IO 模型中，当应用线程发出 read 系统调用的时候，如果内核中的数据还没有准备好，他并不会去阻塞应用的线程，而是返回一个错误。对于应用线程来说，发出一个 read 系统调用以后不需要等待，就可以得到一个结果。如果这个结果是一个错误，那么就说明当前还没有准备好，于是，可以再次发送一个 read 操作。当数据已经准备好了，并且应用线程发送了一个 read 系统调用的时候，内核会将数据拷贝到应用进程，拷贝完以后再返回成功。

因此，对于阻塞模型与非阻塞模型来说，不同的地方在于第一阶段，第二阶段下，两个模型都是一样的。

```cpp
server_fd = socket(); // 创建一个socket
bind(server_fd, "0.0.0.0", 8080); // 将当前的socket绑定到一个指定的地址和端口
listen(server_fd) // 监听连接请求
set_non_block(server_fd) // 设置成非阻塞

while (1) {
    client_fd = accept(server_fd); // 接受连接请求
    if (client_fd > 0) {
        set_non_block(client_fd); // 设置非阻塞模式
        fds.add(client_fd); // 新的fd加入到fds中
    }
        
    for (fd : fds) { // 遍历当前fds中的所有的fd
        n = read(fd, buff); // 非阻塞的读取数据
        if (n == -1) {
            continue; // 无数据可读
        } else if (n == 0) { // 连接关闭
            close(fd); // 断开连接
        } else {
            handler(buff) // 读到数据逻辑处理
        }
    }
}
```

缺点：`while` 循环中会不断的向系统询问，系统的开销很大，同时会占用大量的 cpu 资源。

= IO 多路复用
目的：避免应用线程循环检查发起系统调用的开销

原理：将需要监听的文件描述符，通过一个系统 (select, poll, epoll 等)一直传递到内核中，由内核来监视这些文件描述符。当其中的任意一个文件描述符发生了 I/O 事件（读，写，连接，关闭等），内核就会通知应用程序进行处理。

多路是指需要处理的多个连接的 I/O 事件，复用是指复用一个或少量的线程资源。I/O 多路复用就是用一个或者少量的线程资源去处理多个连接的 I/O 事件。

使用 select 函数来举例：

```cpp
server_fd = socket();
bind(server_fd, "0,0,0,0", 8080);
listen(server_Fd);
readfds; // 待监听的集合
client_fds; // 连接描述符数组

while (1) {
    // 清空集合
    FD_ZERO(&readfds);
    // 添加server_Fd 到集合中
    FD_SET(server_Fd. &readfds);
    // 遍历连接fd集合
    for (fd : client_fds) {
        //将有效的fd添加到集合中
        if (fd) {
            FD_SET(fd, &readfds);
        }
    }

    // 阻塞等待fd上的IO事件
    select(fd_num, &readfds, NULL, NULL, NULL);
    // 如果server_fd有事件，则有新的连接
    if (FD_ISSET(server_fd, &readfds)) {
        client_fd = accept(server_fd);
        // 新的fd加入到数组中
        client_fds.add(client_fd);
    }

    for (fd : client_fds) {
        // 如果有IO事件
        if (FD_ISSET(fd, &readfds)) {
            if (read(fd, buff)) {
                handler(buff);
            } else {
                // 连接关闭 
                close(fd);
                // 从集合中移除
                client_fds.remove(fd);
            }
        }   
    }
}
```

优点：避免了主动的轮询，减少了 cpu 的占用。

缺点：

+ 每次在调用 select 函数都需要重新初始化待监听描述符集合
+ 每次都要将描述符集合拷贝到内核中
+ Select 返回后需要遍历所有文件描述符，依次检查是否就绪。（即使就一个准备好，也要遍历全部）
+ 最多只可以监听 1024 个文件描述符

`poll` 对第 1 点和第 4 点做了优化。`epoll` 对所有的缺点都进行了优化。`epoll` 使用内核空间和用户空间共享的内存区来传递文件描述符，避免了从用户态向内核态拷贝的开销。同时，不需要遍历全部文件描述符，因为它只将发生变动的文件描述符返回。

#strong[注：看评论区说 epoll 会将数据从内核拷贝到用户空间，并不是共享内存实现的]
