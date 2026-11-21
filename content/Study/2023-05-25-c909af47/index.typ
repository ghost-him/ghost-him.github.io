#import "../../index.typ": template, tufted
#show: template.with(title: "linux 网络编程（3） --- 高并发服务器")

= 高并发服务器
三种实现并发服务器

- 阻塞式
- 非阻塞忙轮询式
- 响应式 --- 多路IO转接（能效最好）

== 多路IO转接
也叫做多任务IO服务器。该类服务器实现的主旨思想是，不再由应用程序自己监视客户端连接， 取而代之由内核代替程序监视文件

=== `select`函数
```
int select(int nfds, fd_set *restrict readfds, fd_set *restrict writefds, fd_set *restrict exceptfds, struct timeval *restrict timeout);
参数：
    nfds：监听的所有文件描述符中，最大的文件描述符+1
    readfds：读 文件描述符监听集合     传入，传出参数
    writefds：写 文件描述符监听集合    传入，传出参数     通常写NULL
    exceptfds：异常 文件描述符监听集合  传入，传出参数     通常写NULL
    time：
        >0:     设置监听超时时长
        NULL：   阻塞监听
        0：      非阻塞监听（需要轮询）
返回值：
    >0:     所有监听集合中， 满足对应时间的总数
    0：      没有满足监听条件的文件描述符
    -1：     失败， 设置errno
```

对`fd_set`的一些操作函数

```
void FD_CLR(int fd, fd_set *set);       将一个文件描述符从描述符中移除
int  FD_ISSET(int fd, fd_set *set);     判断一个文件描述符是否在集合中
void FD_SET(int fd, fd_set *set);       将待监听的文件描述符，添加到监听集合中
void FD_ZERO(fd_set *set);              清空一个文件描述符集合
```

==== 使用`select`搭建高并发服务器
- 无需多线程和多进程即可实现多线程和多进程的效果（单线程/进程监听多个端口）

#strong[大体思路]

```
lfd = socket();             创建套接字
bind();                     绑定地址结构
listen();                   设置监听上限
fd_set rset, allset;        创建r监听集合和总集合
FD_ZERO(&allset);           将总集合清零
FD_SET(lfd, &allset);       将lfd添加至总集合
while (1) {
    rset = allset               初始化读集合
    ret = select(lfd + 1, &rset, NULL, NULL, NULL);     监听文件描述符集合对应事件
    if (ret > 0) {                      有监听的文件描述符满足对应事件
        if (FD_ISSET(lfd, &rset)) {     当lfd在集合中时（说明有连接）
            cfd = accept();             建立连接，返回用于通信的文件描述符
            FD_SET(cfd, &allset);       添加到监听通信描述符集合中
        }
        
        for (int i = ldf + 1; i <= 最大文件描述符; i ++) {
            FD_ISSET(i, &rset)          有read,write事件
            read()
            {...}
            write()
        }
    }
}
```

#strong[具体代码逻辑]

```cpp
#include "wrap.h"

#define server_port 443

int main()
{
  int listenfd, connfd;
  int n;
  char buf[BUFSIZ];

  struct sockaddr_in clit_addr, serv_addr;
  socklen_t clit_addr_len;

  listenfd = Socket(AF_INET, SOCK_STREAM, 0);

  int opt = 1;
  setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
  bzero(&serv_addr, sizeof(serv_addr));
  serv_addr.sin_port = htons(server_port);
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  Bind(listenfd, &serv_addr, sizeof(serv_addr));
  Listen(listenfd, 128);

  fd_set rset, allset;            // 定义读集合
  int ret , maxfd = listenfd;     // 最大文件描述符
  FD_ZERO(&allset);               // 清空 监听集合
  FD_SET(listenfd, &allset);      // 将listenfd添加到监听集合中

  while (1) {
    rset = allset;                // 备份
    ret = select(maxfd + 1, &rset, NULL, NULL, NULL);
    if (ret < 0) {
      sys_err("select error");
    }

    if (FD_ISSET(listenfd, &rset)) {    // listenfd满足监听的读事件
      clit_addr_len = sizeof(clit_addr);
      connfd = Accept(listenfd, &clit_addr, &clit_addr_len);    // 不会阻塞
      FD_SET(connfd, &allset);        // 监听数据的读事件

      if (maxfd < connfd)         // 修改最大的fd
        maxfd = connfd;
      if (ret == 1) {             // 说明select只返回一个，且是listenfd
        continue;
      }
    }

    for (int i = listenfd + 1; i <= maxfd; i++) {   // 处理读事件的fd
      if (FD_ISSET(i, &rset)) {                     // 找到满足的fd
        n = read(i, buf, sizeof(buf));
        if (n == 0) {           // 若已经关闭连接了
          close(i);
          FD_CLR(i, &allset);   // 移除监听集合
        } else if (n == -1) {
          sys_err("read error");
        }

        for (int j = 0; j < n; j++) {
          buf[j] = toupper(buf[j]);
        }
        write(i, buf, n);
        fprintf(stdout, "%s\n", buf);
      }
    }
  }
  close(listenfd);
  return 0;
}
```

==== `select`优缺点
缺点：

+ 监听上限受文件描述符的限制， 最大是1024个
+ 检测满足条件的`fd`， 自己添加业务逻辑来提高效率。提高了编码的难度。（注意：由于设计的问题，才导致了这个现象， 性能不低）

优点：

+ 跨平台

=== `poll`函数
#strong[半成品， 可以不学]

```
int poll(struct pollfd fds[], nfds_t nfds, int timeout);
参数：
    fds：监听的文件描述符数组
    nfds：监听数组的，实际有效的监听个数
    timeout：超时时长（单位：毫秒）
        -1： 阻塞等待
        0：  立刻返回，不阻塞进程
        >0： 等待指定的毫秒数，若当前系统事件精度不够，则向上取整
    
struct pollfd {
    int   fd;         /* 文件描述符 */
    short events;     /* 监听的事件 */
        POLLIN，POLLOUT，POLLERR，...
    short revents;    /* 传入时，给0值，如果满足对应的事件，则会返回非0 */
    
};
```

#strong[使用方法]

```
struct pollfd pfds[1024];

pfds[0].fd = lfd;
pfds[0].events = POLLIN;
pfds[0].revents = 0;

pfds[0].fd = cfd1;
pfds[0].events = POLLIN;
pfds[0].revents = 0;

...

while(1) {
    int ret = poll(pfds, 5, -1);
    for(int i = 0; i < 5; i++) {
        if (pfds[i].revents & POLLIN) {
            Accept();
            Read();
            { ... }
            Write();
        }
    }
}
```

==== `poll`优缺点
#strong[优点：]

+ 自带数组结构，可将#strong[监听事件集合]和#strong[返回事件集合]分离
+ 可以拓展监听上限，可超出1024限制

#strong[缺点：]

+ 不能跨平台
+ 无法直接定位满足监听事件的文件描述符，编码难度较大。

=== `epoll`函数
​`epoll`是linux下提供多路复用io借口`select/poll`的增强版，可以显著的提高程序在大量并发连接中只有少量活跃的情况下系统cpu的利用率。目前`epoll`是大规模并发网络程序中的热门首选模型。

#strong[查看一个进程可以打开的socket描述符的上限]

```
cat /proc/sys/fs/file-max
```

==== `epoll_create`函数
```
作用：创建一个红黑二叉树
int epoll_create(int size)；
参数：
    size： 创建的红黑数的监听节点数（仅供内核参考）
返回值：
    成功：指向新创建的红黑树的根节点fd
    失败：-1，设置errno
```

==== `epoll_ctl`函数
```
作用：设置监听红黑树
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
参数：
    epfd：指向红黑树根节点的值
    op：对该监听红黑树所作的操作
        EPOLL_CTL_ADD：添加fd到监听红黑树中
        EPOLL_CTL_MOD：修改fd在监听红黑树上的监听事件
        EPOLL_CTL_DEL：将一个fd从监听红黑树摘下来（取消监听）
    fd：待监听的fd
    event：本质是一个struct epoll_event的 结构体 的地址
返回值：
    成功：0
    失败：-1,设置errno
    
    
struct epoll_event {
    uint32_t     events;      /* Epoll events */
        EPOLLIN，EPOLLOUT，EPOLLERR，...
    epoll_data_t data;        /* User data variable */
};

typedef union epoll_data {
    void        *ptr;       
    int          fd;        对于监听事件的fd
    uint32_t     u32;       不用
    uint64_t     u64;       不用
} epoll_data_t;
```

==== `epoll_wait`函数
```
作用：监听事件
int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout);
参数：
    epfd: 红黑树的句柄
    events：传出参数，数组，满足监听条件的fd结构体
    maxevents:数组的元素的总个数（自己定义的数组events的长度）
    timeout：超时时间
        -1：阻塞
        0：不阻塞
        >0:超时事件，单位：毫秒
返回值：
    >0 :满足监听的总个数（events中传出来的）。可以用作数组下标（循环的上限）
    0：没有满足的监听的事件
    -1：失败，设置errno
```

#strong[使用epoll实现多路IO的思路]

```
lfs = socket();                     // 监听连接事件
bind();
listen();

int epfd = epoll_create();          // epfd:监听红黑树的树根

struct epoll_event tep, ep[1024];   // tep 用来设置单个fd属性， ep是epol_wait传出的满足的监听事件的数组
tep.events = EPOLLIN;               // 初始化lfd的监听属性
tep.data.fd = lfd;
epoll_ctl(epfd, EPOLL_CTL_ADD, lfd, &tep);      // 将lfd添加到监听红黑树上

while (1) {
    ret = pol_wait(wait, ep, 1024, -1);                     // 实施监听
    check(ret);     // 检查返回值
    
    for (int i = 0; i < ret; i++) {
        if (ep[i].data.fd == lfd) {     // lfd满足读事件（有新的客户端发起连接请求）
            cfd = accept();
            tmp.events = EPOLLIN;       // 初始化cfd的监听属性
            tmp.data.fd = cfd;
            epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &tep);
        } else {        // cfd满足读事件，有客户端写数据
            n = read();
            if (n == 0) {           // 对端关闭
                close(ep[i].data.fd);   // 关闭socket
                epoll_ctl(epfd, EPOLL_CTL_DEL, ep[i].data.fd, NULL);    // 将关闭的fd,从监听树上摘下
            } else if (n > 0) {     // 读到了数据
                { ... } // 处理事件
                write() // 回发数据
            }
        }
    }
}

```

==== 使用`epoll`搭建高并发服务器
```cpp
#include <wrap.h>
#include <sys/epoll.h>

#define MAXLINE 8192
#define OPEN_MAX 5000
#define server_port 443

int main()
{
  int listenfd, connfd, sockfd;
  int n, num = 0;
  ssize_t nready, efd, res;
  char buf[MAXLINE], str[INET_ADDRSTRLEN];
  socklen_t clilen;

  struct sockaddr_in cliaddr, servaddr;
  struct epoll_event tep, ep[OPEN_MAX]; // tep:epoll_ctl的参数， ep[]: epoll_wait的参数

  listenfd = Socket(AF_INET, SOCK_STREAM, 0);
  int opt = 1;
  setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)); // 端口复用
  bzero(&servaddr, sizeof(servaddr));
  servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
  servaddr.sin_port = htons(server_port);
  servaddr.sin_family = AF_INET;
  Bind(listenfd, &servaddr, sizeof(servaddr));
  Listen(listenfd, 20);

  efd = epoll_create(OPEN_MAX); // 创建epoll模型， efd指向红黑树根节点
  if (efd == -1)
  {
    sys_err("epoll_create error");
  }

  tep.events = EPOLLIN;
  tep.data.fd = listenfd;

  res = epoll_ctl(efd, EPOLL_CTL_ADD, listenfd, &tep);
  if (res == -1)
  {
    sys_err("epoll_ctl error");
  }

  for (;;)
  {
    // epoll为server阻塞监听事件， ep为struct epoll_event类型数组， OPEN_MAX为数组容量， -1表示永久阻塞
    nready = epoll_wait(efd, ep, OPEN_MAX, -1);
    if (nready == -1)
    {
      sys_err("epoll_wait error");
    }

    for (int i = 0; i < nready; i++)
    {                                // 循环数组中的元素
      if (!(ep[i].events & EPOLLIN)) // 如果不是读事件，则继续
        continue;

      if (ep[i].data.fd == listenfd)
      { // 判断满足事件的fd不是lfd
        clilen = sizeof(cliaddr);
        connfd = Accept(listenfd, &cliaddr, &clilen);

        printf("received from %s at port %d\n",
               inet_ntop(AF_INET, &cliaddr.sin_addr.s_addr, str, sizeof(str)),
               ntohs(cliaddr.sin_port));
        printf("cfd %d ---client %d\n", connfd, ++num);

        tep.events = EPOLLIN;
        tep.data.fd = connfd;
        res = epoll_ctl(efd, EPOLL_CTL_ADD, connfd, &tep); //  加入红黑树
        if (res == -1)
        {
          sys_err("epoll_ctl error");
        }
      }
      else
      {
        sockfd = ep[i].data.fd;
        n = read(sockfd, buf, MAXLINE);
        if (n == 0)
        {                                                    // 读到0, 说明客户端关闭连接
          res = epoll_ctl(efd, EPOLL_CTL_DEL, sockfd, NULL); // 将该文件描述符从红黑树摘除
          if (res == -1)
          {
            sys_err("epoll_ctl error");
          }
          close(sockfd);
          printf("client[%d] closed connection\n", sockfd);
        }
        else if (n < 0)
        {
          perror("read n < 0 error:");
          res = epoll_ctl(efd, EPOLL_CTL_DEL, sockfd, NULL);
          close(sockfd);
        }
        else
        {
          for (int i = 0; i < n; i++)
          {
            buf[i] = toupper(buf[i]);
          }
          write(STDOUT_FILENO, buf, n);
          write(sockfd, buf, n);
        }
      }
    }
  }
  close(listenfd);
  return 0;
}
```

==== 事件触发模型
有两种触发模型

- `ET`边缘触发：有数据到来的时候才会触发，不管缓冲区中有没有数据

​缓冲区剩余未读尽的数据不会导致`epoll_wait`触发，新的事件满足才会触发。

```
struct epoll_event event;
event.events = EPOLLIN | EPOLLE;
```

- `LT`水平触发（默认）：只要有数据就会触发

​缓冲区剩余未读尽的数据会导致`epoll_wait`触发

```
struct epoll_event event;
event.events = EPOLLIN;
```

#strong[比较：]

- LT是缺省的工作方式， 并且同时支持`block`的和`no-block`的两种socket.这样的模式编码出错概率会比较小， 同时`select/poll`都是这种模型的代表。当只需要用到一个文件的一部分的时候（例如读取一个文件的属性），就可以使用此模式。
- ET是高速工作模式（推荐使用这种），只支持`no-block` socket，当文件描述符从未就绪变成就绪时，内核通过epoll告诉你。若没有io操作，使得文件变为未就绪态，内核则不会再次通知。通常与忙轮询相结合

`fcntl`实现文件的非阻塞（读数据的时候的非阻塞）

#strong[结论：]

`epoll`的ET模式是高效模式，但是只支持非阻塞模式

#strong[设计思路：]

```
flag = fcntl(cfd, F_GETFG);     //设置非阻塞
flag |= O_NONBLOCK;
fcntl(cfd, F_SETFL, flag);

struct epoll_event event;
event.events = EPOLLIN | EPOLLET;
epoll.ctl(epfd, EPOLL_CTL_ADD, cfd, &event);
```

#strong[代码实现]

```cpp
#include <fcntl.h>
#include "wrap.h"
#include <sys/epoll.h>



#define MAXLINE 8192
#define OPEN_MAX 5000
#define server_port 443

int main() {
  int listenfd, connfd, sockfd;
  int n, num = 0;
  ssize_t nready, efd, res;
  char buf[MAXLINE], str[INET_ADDRSTRLEN];
  socklen_t clilen;

  struct sockaddr_in cliaddr, servaddr;
  ////////////////////////////////////////////////////////////
  struct epoll_event tep, ep[OPEN_MAX];   // tep:epoll_ctl的参数， ep[]: epoll_wait的参数

  listenfd = Socket(AF_INET, SOCK_STREAM, 0);
  int opt = 1;
  setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)); // 端口复用
  bzero(&servaddr, sizeof(servaddr));
  servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
  servaddr.sin_port = htons(server_port);
  servaddr.sin_family = AF_INET;
  Bind(listenfd, &servaddr, sizeof(servaddr));
  Listen(listenfd, 20);

  efd = epoll_create(OPEN_MAX);       // 创建epoll模型， efd指向红黑树根节点
  if (efd == -1) {
    sys_err("epoll_create error");
  }

  tep.events = EPOLLIN;           // 设置成边缘触发模式
  tep.data.fd = listenfd;

  res = epoll_ctl(efd, EPOLL_CTL_ADD, listenfd, &tep);
  if (res == -1) {
    sys_err("epoll_ctl error");
  }

  for (;;) {
    // epoll为server阻塞监听事件， ep为struct epoll_event类型数组， OPEN_MAX为数组容量， -1表示永久阻塞
    nready = epoll_wait(efd, ep, OPEN_MAX, -1);
    if (nready == -1) {
      sys_err("epoll_wait error");
    }

    for (int i = 0; i < nready; i ++) { // 循环数组中的元素
      if (!(ep[i].events & EPOLLIN))    // 如果不是读事件，则继续
        continue;

      if (ep[i].data.fd == listenfd) {  // 判断满足事件的fd不是lfd
        clilen = sizeof(cliaddr);
        connfd = Accept(listenfd, &cliaddr, &clilen);

        printf("received from %s at port %d\n",
                inet_ntop(AF_INET, &cliaddr.sin_addr.s_addr, str, sizeof (str)),
                ntohs(cliaddr.sin_port));
        printf("cfd %d ---client %d\n", connfd, ++num);

        tep.events = EPOLLIN | EPOLLET;
        tep.data.fd = connfd;

        int flag = fcntl(connfd, F_GETFL);                  // 设置为非阻塞
        flag |= O_NONBLOCK;
        fcntl(connfd, F_SETFL, flag);

        res = epoll_ctl(efd, EPOLL_CTL_ADD, connfd, &tep);   //  加入红黑树
        if (res == -1) {
          sys_err("epoll_ctl error");
        }
      } else {
        sockfd = ep[i].data.fd;
        while((n = read(sockfd, buf, MAXLINE)) > 0) {
          if (n == 0) { // 读到0, 说明客户端关闭连接
            res = epoll_ctl(efd, EPOLL_CTL_DEL, sockfd,
                            NULL); // 将该文件描述符从红黑树摘除
            if (res == -1) {
              sys_err("epoll_ctl error");
            }
            close(sockfd);
            printf("client[%d] closed connection\n", sockfd);
          } else if (n < 0) {
            perror("read n < 0 error:");
            res = epoll_ctl(efd, EPOLL_CTL_DEL, sockfd, NULL);
            close(sockfd);
          } else {
            for (int i = 0; i < n; i++) {
              buf[i] = toupper(buf[i]);
            }
            write(STDOUT_FILENO, buf, n);
            write(sockfd, buf, n);
          }
        }
      }
    }
  }
  close(listenfd);
  return 0;
}
```

==== `epoll`优缺点
优点：

+ 高效
+ 可以突破文件描述符的最大上限

缺点：

+ 不能跨平台

=== `epoll`反应堆模型
- `epoll` ET模式 + 非阻塞，轮询 + `void *ptr`

对比：

- 原来：`socket,bind,listen` -- `epoll_create` -- `epoll_ctl` -- `epoll-wait` -- 对应监听`fd`有事件产生 -- 返回监听满足数组 -- 判断返回的元素 -- `lfd`满足`accept` / `cfd`满足处理事物 -- `write`

- 反应堆：不但要监听`cfd`的读事件，还要监听`cfd`的写事件

  `socket,bind,listen` -- `epoll_create` -- `epoll_ctl` -- `epoll-wait` -- 对应监听`fd`有事件产生 -- 返回监听满足数组 -- 判断返回的元素 -- `lfd`满足`accept` / `cfd`满足处理事物 -\> 将`cfd`从监听红黑树上摘下 -\> `EPOLLOUT` -\> 回调函数 -\> `epoll_ctl` -\> `EPOLL_CTL_ADD` 重新放回红黑树上，监听写事件 -\> 等待`epoll_wait`返回（说明`cfd`可写） -\> `write`写 -\> `cfd`从监听树上摘下 -\>`EPOLLIN` -\> `epoll_wait` -\> `EPOLL_CTL_ADD` 重新放回红黑树上，监听写事件 -\> `epoll_wait`

==== 代码实现
```cpp
/* epoll反应堆模型
 *
 *
 *
 */

#include "wrap.h"
#include <fcntl.h>
#include <sys/epoll.h>
#include <time.h>

#define MAX_EVENTS 1024   // 最大的连接数
#define BUFLEN 4096       // 缓冲区的大小
#define SERV_PORT 443     // 服务器的端口

void recvdata(int fd, int events, void *arg);       // 发送数据的函数
void senddata(int fd, int events, void *arg);       // 接收数据的函数

struct myevent_s {
  int fd;         // 当前socket操作符
  int events;     // 当前的状态，是输入还是读出
  void *arg;      // 当前结构体在数组上的位置
  void (*call_back)(int fd, int events, void *arg);   // 回调函数，对应着events的这个状态
  int status;     // 若为0则不在监听， 1则在监听
  char buf[BUFLEN]; // 缓冲区
  int len;          // 缓冲区的大小
  long last_active; // 上一次活动的事件（用于将无活动的连接中断）
};

int g_efd;        // 监听树的根节点
struct myevent_s g_events[MAX_EVENTS + 1];    // 已经存在的连接

// 设置回调函数
void eventset(struct myevent_s *ev, int fd, void (*call_back)(int, int, void *), void *arg)
{
  ev->fd = fd;
  ev->call_back = call_back;
  ev->events = 0;
  ev->arg = arg;
  ev->status = 0;
  if (ev->len <= 0) {       // 若缓冲区中已经有数据了，则不重置为0（否则在输出的时候会输出空的字符串）
    memset(ev->buf, 0, sizeof(ev->buf));
    ev->len = 0;
  }
  ev->last_active = time(NULL);   // 取得当前的时间
  return ;
}

// 添加到监听红黑树，设置监听读事件还是监听写事件
void eventadd(int efd, int events, struct myevent_s *ev) {
  struct epoll_event epv = {0, {0}};    // 初始化
  int op = 0;
  epv.data.ptr = ev;          // 初始化epv
  epv.events = ev->events = events;

  if (ev->status == 0) {      // 当没有被监听的时候
    op = EPOLL_CTL_ADD;
    ev->status = 1;
  }

  if (epoll_ctl(efd, op, ev->fd, &epv) < 0) {   // 将其监听
    printf("event add failed [fd = %d], events[%d]\n", ev->fd, events);
  } else {
    printf("event add OK [fd = %d], op = %d, events[%0x]\n", ev->fd, op, events);
  }
  return ;
}

// 从监听树中删除一个节点
void eventdel(int efd, struct myevent_s *ev) {
  struct epoll_event epv = {0, {0}};

  if (ev->status != 1)
      return ;

  epv.data.ptr = NULL;
  ev->status = 0;
  epoll_ctl(efd, EPOLL_CTL_DEL, ev->fd, &epv);  // 删除节点
  return ;
}

// 连接请求
void acceptconn(int lfd, int events, void *arg) {
  struct sockaddr_in cin;
  socklen_t len = sizeof(cin);
  int cfd, i;

  if ((cfd = accept(lfd, (struct sockaddr*)&cin, &len)) == -1) {  // 获取当前的cfd
    if (errno != EAGAIN && errno != EINTR) {
      /*暂时不做处理*/
    }
    printf("%s:accept, %s\n", __func__ , strerror(errno));
    return ;
  }

  do {
    for (i = 0; i < MAX_EVENTS; i++)  // 从小往大枚举可以插入的数字
      if (g_events[i].status == 0) {
        break;
      }

    if (i == MAX_EVENTS) {
      printf("%s: max connect limit[%d]\n", __func__, MAX_EVENTS);
      break;
    }

    int flag = 0;   // 设置为非阻塞
    if ((flag = fcntl(cfd, F_SETFL, O_NONBLOCK)) < 0) {
      printf("%s:fcntl no-blocking error, %s\n", __func__, strerror(errno));
      break;
    }

    // 设置当前的点，然后将其添加到监听树中
    eventset(&g_events[i], cfd, recvdata, &g_events[i]);
    eventadd(g_efd, EPOLLIN, &g_events[i]);
  }while (0);

  printf("new connect [%s:%d][time:%ld], pos[%d]\n",
         inet_ntoa(cin.sin_addr), ntohs(cin.sin_port), g_events[i].last_active, i);
  return ;
}

void recvdata(int fd, int events, void *arg) {
  struct myevent_s *ev = (struct myevent_s *)arg;   // 取得当前的点在数组上的位置
  int len;

  len = recv(fd, ev->buf, sizeof(ev->buf), 0);    // 相当于read
  eventdel(g_efd, ev);    // 将当前的点删除

  if (len > 0) {
    ev->len = len;            // 将数组的长度传入到结构体中
    ev->buf[len] = '\0';      // 将末尾置为0
    printf("C[%d]:%s\n", fd, ev->buf);

    eventset(ev, fd, senddata ,ev); // 将当前的点由监听 读 改为监听 写
    eventadd(g_efd, EPOLLOUT, ev);
  } else if (len == 0) {  // 对端关闭
    close(ev->fd);
    printf("[fd = %d] pos[%ld], closed\n", fd, ev - g_events);
  } else {                // 若存在异常
    close(ev->fd);
    printf("revc[fd = %d] error[%d]:%s\n", fd, errno, strerror(errno));
  }
  return;
}

void senddata(int fd, int events, void *arg) {
  struct myevent_s *ev = (struct myevent_s*)arg;
  int len;

  len = write(fd, ev->buf, ev->len);    // 发送数据
  eventdel(g_efd, ev);    // 将当前的点从监听树中删去

  if (len > 0) {
    printf("send[fd = %d], [%d]%s\n", fd, len, ev->buf);
    eventset(ev, fd, recvdata,ev);    // 由监听写改为监听读
    eventadd(g_efd, EPOLLIN, ev);
  } else {
    close(ev->fd);
    printf("send[fd = %d]error len = %d ,%s\n", fd, len, strerror(errno));
  }
  return ;
}


// 初始化监听红黑树
void initlistensocket(int efd, short port) {
  struct sockaddr_in sin;
  int lfd = socket(AF_INET, SOCK_STREAM, 0);
  fcntl(lfd, F_SETFL, O_NONBLOCK);

  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl(INADDR_ANY);
  sin.sin_port = htons(port);

  bind(lfd, (struct sockaddr*)&sin, sizeof(sin));

  listen(lfd, 20);

  // 将lfd放到了最后一个空位上
  eventset(&g_events[MAX_EVENTS], lfd, acceptconn, &g_events[MAX_EVENTS]);

  eventadd(efd, EPOLLIN, &g_events[MAX_EVENTS]);

  return ;
}

int main(int argc, char *argv[]) {
  unsigned short port = SERV_PORT;

  if (argc == 2) {
    port = atoi(argv[1]);
  }

  g_efd = epoll_create(MAX_EVENTS + 1);
  if (g_efd <= 0) {
    printf("create efd in %s err %s\n", __func__ , strerror(errno));
  }

  initlistensocket(g_efd, port);        // 初始化监听树

  struct epoll_event events[MAX_EVENTS + 1];
  printf("server running :port[%d]\n", port);

  int checkpos = 0, i;
  while (1) {
    long now = time(NULL);

    for (i = 0; i < 100; i ++, checkpos ++) {   // 将长时间无活动的连接中断
      if (checkpos == MAX_EVENTS)
          checkpos = 0;
      if (g_events[checkpos].status != 1)
          continue;

      long duration = now - g_events[checkpos].last_active;
      if (duration >= 60) {           // 大于60s无操作， 则
        close(g_events[checkpos].fd);
        printf("[fd = %d] timeout\n", g_events[checkpos].fd);
        eventdel(g_efd, &g_events[checkpos]);
      }
    }

    // 监听
    int nfd = epoll_wait(g_efd, events, MAX_EVENTS + 1, 1000);
    if (nfd < 0) {
      printf("epoll_wait error\n");
      exit(-1);
    }

    for (i = 0; i < nfd; i ++) {
      struct myevent_s *ev = (struct myevent_s *)events[i].data.ptr;

      if ((events[i].events & EPOLLIN) && (ev->events & EPOLLIN)) {
        ev->call_back(ev->fd, events[i].events, ev->arg);
      }

      if ((events[i].events & EPOLLOUT) && (ev->events & EPOLLOUT)) {
        ev->call_back(ev->fd, events[i].events, ev->arg);
      }
    }
  }
  return 0;
}
```

== 线程池
=== 与多路IO转接的区别：
- 多路IO转接处理的是#strong[客户端]和#strong[服务器]的#strong[连接和传输数据]的问题
- 线程池处理的是#strong[服务器]在拿到数据以后，#strong[处理数据]的问题

=== 线程池结构体
```
struct threadpool_t {
    pthread_mutex_t lock;               // 用于锁住本结构体
    pthread_mutex_t thread_counter;     // 记录忙状态线程个数的锁
    
    pthread_cond_t queue_not_full;      // 当任务队列满时， 添加人物的线程阻塞， 等待此条件变量
    pthread_cond_t queue_not_empty;     // 任务队列不为空时， 通知等待任务的线程
    
    pthread_t *threads;                 // 存放线程池中每个线程的tid.数组
    pthread_t adjust_tid;               // 存任务管理线程tid
    threadpool_task_t *task_queue;      // 任务队列
    
    int min_thr_num;                    // 线程池最小线程数
    int max_thr_num;                    // 线程池最大线程数
    int live_thr_num;                   // 当前存活线程个数
    int busy_thr_num;                   // 忙状态线程个数
    int wait_exit_thr_num;              // 要销毁的线程个数
    
    int queue_front;                    // task_queue队头下标
    int queue_rear;                     // task_queue队尾下标
    int queue_size;                     // task_queue中实际的任务数
    int queue_max_size;                 // task_queue中可容纳的任务数的上限
    
    int shutdown;                       // 标志位，线程池的状态， true或false
};
```

=== 线程池`main`架构
```
1. main
    创建线程池
    向线程池中添加任务， 借助回调处理任务
    销毁线程池
2. pthreadpool_create()
    创建线程池结构体指针
    初始化线程池结构体（N个成员变量）
    创建N个任务
    创建1个管理线程
    失败时销毁开辟的空间
3. threadpool_thread()
    进入子线程回调函数
    接受参数    void*arg --> pool 结构体
    加锁  --> 整个结构体的锁
    判断条件变量      --> wait
4. adjust_thread()
    循环10s一次
    进入管理者线程
    接受参数void *arg -->pool 结构体
    加锁  --> lock --> 整个结构体锁
    获取管理线程池要用到的变量           task_num live_num, busy_num
    根据既定算法，使用上述3变量，判断是否应该创建，销毁，线程池中指定步长的线程
5. threadpool_add()
    模拟产生任务
    设置回调函数的处理， 处理任务。sleep（1）
    
    内部实现：
        加锁
        初始化任务队列结构体成员（回调函数function, arg）
        用环形队列机制，实现添加任务。借助队尾指针挪动 % 实现
        唤醒阻塞在条件变量上的线程
        解锁
6.  从3.中的wait之后继续执行，处理任务
    加锁
    获取任务的回调函数， 参数
    用环形队列机制，实现处理任务。借助队头指针挪动 % 实现
    唤醒阻塞在条件变量上的server
    解锁
    加锁
    改忙线程数
    解锁
    执行处理任务的线程
    加锁
7. 创建，销毁线程
    管理线程根据task_num, live_num, busy_num
    根据既定算法，使用上述3变量，判断是否应该创建，销毁，线程池中指定步长的线程
    如果满足，创建条件：
        pthread_create() 回调任务线程函数
    如果满足，销毁条件
        wait_exit_thr_num = 10;
        signal给阻塞在条件变量山的线程发送假条件满足先好
        从而使得wait的线程会被唤醒，然后pthread_exit()
```

=== 代码实现
```cpp
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <errno.h>

#define DEFAULT_TIME 5                       // 10s检测一次
#define MIN_WAIT_TASK_NUM 10                  // 如果queue_size > MIN_WAIT_TASK_MIN -》 添加新的线程到线程池
#define DEFAULT_THREAD_VARY 10                // 每次创建和销毁线程的个数
#define true 1
#define false 0

struct threadpool_task_t {
  void *(*function)(void *);
  void *arg;
};

struct threadpool_t {
  pthread_mutex_t lock;             // 用于锁住本结构体
  pthread_mutex_t thread_counter;       // 记录忙状态线程个数的锁

  pthread_cond_t queue_not_full;        // 当任务队列满时， 添加人物的线程阻塞， 等待此条件变量
  pthread_cond_t queue_not_empty;       // 任务队列不为空时， 通知等待任务的线程

  pthread_t *threads;                   // 存放线程池中每个线程的tid.数组
  pthread_t adjust_tid;             // 存任务管理线程tid
  threadpool_task_t *task_queue;        // 任务队列

  int min_thr_num;                  // 线程池最小线程数
  int max_thr_num;                  // 线程池最大线程数
  int live_thr_num;                 // 当前存活线程个数
  int busy_thr_num;                 // 忙状态线程个数
  int wait_exit_thr_num;                // 要销毁的线程个数

  int queue_front;                  // task_queue队头下标
  int queue_rear;                       // task_queue队尾下标
  int queue_size;                       // task_queue中实际的任务数
  int queue_max_size;                   // task_queue中可容纳的任务数的上限

  int shutdown;                     // 标志位，线程池的状态， true或false
};

threadpool_t *threadpool_create(int min_thr_num, int max_thr_num, int queue_max_size);
void *threadpool_thread(void *threadpool);
void *adjust_thread(void *threadpool);
void *process(void *arg);
int threadpool_add(threadpool_t *pool, void*(*function)(void *arg), void *arg);
int threadpool_destory(threadpool_t *pool);
int threadpool_free(threadpool_t *pool);

int is_thread_alive(pthread_t i) {
  int ret = pthread_kill(i, 0);
  if (ret == ESRCH)
    return false;
  return true;
}

threadpool_t *threadpool_create(int min_thr_num, int max_thr_num, int queue_max_size) {
  threadpool_t *pool = NULL;        // 初始化线程池，先将其设为空值

  do{
    // 为这个结构体分配空间
    if ((pool = (threadpool_t *)malloc(sizeof(threadpool_t))) == NULL) {    // 判断是否可以分配空间
      printf("malloc threadpool error");
      break;
    }

    pool->min_thr_num = min_thr_num;
    pool->max_thr_num = max_thr_num;
    pool->live_thr_num = min_thr_num;
    pool->busy_thr_num = 0;
    pool->wait_exit_thr_num = 0;
    pool->queue_front = 0;
    pool->queue_rear = 0;
    pool->queue_size = 0;
    pool->queue_max_size = queue_max_size;
    pool->shutdown = false;

    // 根据最大线程上限数，给工作线程数组开辟空间，并清零
    pool->threads = (pthread_t *)malloc(sizeof(pthread_t)*max_thr_num);
    if (pool->threads == NULL) {
      printf("malloc threads fail");
      break;
    }
    memset(pool->threads, 0, sizeof(pthread_t)*max_thr_num);

    // 初始化任务列表
    pool->task_queue = (threadpool_task_t *)malloc(sizeof(threadpool_task_t)*queue_max_size);
    if (pool->task_queue == NULL) {
      printf("malloc task_queue error");
      break;
    }

    // 初始化锁
    if (pthread_mutex_init(&(pool->lock), NULL) != 0 ||
        pthread_mutex_init(&(pool->thread_counter), NULL) != 0 ||
        pthread_cond_init(&(pool->queue_not_empty), NULL) != 0 ||
        pthread_cond_init(&(pool->queue_not_full), NULL) != 0)  {
        printf("init lock failed");
        break;
    }

    // 初始化三个默认的线程
    for(int i = 0; i < min_thr_num; i++) {
      pthread_create(&(pool->threads[i]), NULL, threadpool_thread, (void *) pool);    // pool 指向线程池
      printf("start thread 0x%x...\n", (unsigned int)pool->threads[i]);
    }
    // 初始化管理线程
    pthread_create(&(pool->adjust_tid), NULL, adjust_thread, (void *)pool);
    return pool;
  }while (0);
  // 创建失败， 撤销分配的空间
  threadpool_free(pool);
  return NULL;
}

// 线程池中各个工作线程
void *threadpool_thread(void *threadpool) {
  threadpool_t *pool = (threadpool_t *)threadpool;  // 取得当前的线程池
  threadpool_task_t task;

  while (true) {
    // 刚创建出线程， 等待任务队列里有任务， 否则阻塞在等待任务队列里有任务后再唤醒接受任务
    pthread_mutex_lock(&(pool->lock));

    // queue_size == 0说明没有任务， 调wait阻塞在条件变量上，若有任务，跳过该while
    while ((pool->queue_size == 0) && (!pool->shutdown)) {
      printf("thread 0x%x is waiting\n", (unsigned int)pthread_self());
      pthread_cond_wait(&(pool->queue_not_empty), &(pool->lock));

      // 清除指定数目的空闲线程，如果要结束的线程个数大于0,结束线程
      if (pool->wait_exit_thr_num > 0) {
        pool->wait_exit_thr_num --;

        // 如果线程池里线程个数大于最小值时可以结束当前线程
        if (pool->live_thr_num > pool->min_thr_num) {
          printf("thread 0x%x is exiting\n", (unsigned int) pthread_self());
          pool->live_thr_num --;
          pthread_mutex_unlock(&(pool->lock));

          pthread_exit(NULL);
        }
      }
    }

    // 若指定了true, 则关闭线程池里的每个线程， 自行退出处理
    if (pool->shutdown) {
      printf("------shutdown\n");
      pthread_mutex_unlock(&(pool->lock));
      printf("thread 0x%x is exiting\n", (unsigned int)pthread_self());
      // pthread_detach(pthread_self());
      pthread_exit(NULL);   // 线程自行结束
    }

    // 从任务队列里获取任务，是一个出队操作
    task.function = pool->task_queue[pool->queue_front].function;
    task.arg = pool->task_queue[pool->queue_front].arg;

    pool->queue_front = (pool->queue_front + 1) % pool->queue_max_size;
    pool->queue_size --;
    // 通知可以有新的进程可以添加进来了
    pthread_cond_broadcast(&(pool->queue_not_full));
    // 任务取出后， 立刻将线程池锁释放
    pthread_mutex_unlock(&(pool->lock));

    printf("thread 0x%x start working\n", (unsigned int)pthread_self());
    pthread_mutex_lock(&(pool->thread_counter));
    pool->busy_thr_num ++;
    pthread_mutex_unlock(&(pool->thread_counter));

    (*(task.function))(task.arg);

    printf("thread 0x%x end working\n", (unsigned int)pthread_self());
    pthread_mutex_lock(&(pool->thread_counter));
    pool->busy_thr_num--;
    pthread_mutex_unlock(&(pool->thread_counter));
  }
  pthread_exit(NULL);
}

void *adjust_thread(void *threadpool) {
  int i;
  threadpool_t *pool = (threadpool_t *)threadpool;
  while (!pool->shutdown) {
    sleep(DEFAULT_TIME);

    pthread_mutex_lock(&(pool->lock));
    int queue_size = pool->queue_size;
    int live_thr_num = pool->live_thr_num;
    pthread_mutex_unlock(&(pool->lock));

    pthread_mutex_lock(&(pool->thread_counter));
    int busy_thr_num = pool->busy_thr_num;
    pthread_mutex_unlock(&(pool->thread_counter));

    // 任务数大于最小线程池的个数的时候，且存活的线程数小于最大线程个数的时候添加新的线程
    if (queue_size >= MIN_WAIT_TASK_NUM && live_thr_num < pool->max_thr_num) {
      pthread_mutex_lock(&(pool->lock));
      int add = 0;
      printf("-----add more thread!!!\n");
      for (i = 0; i < pool->max_thr_num && add < DEFAULT_THREAD_VARY
                  && pool->live_thr_num < pool->max_thr_num; i++) {
        if (pool->threads[i] == 0 || !is_thread_alive(pool->threads[i])) {
          pthread_create(&(pool->threads[i]), NULL,
                         threadpool_thread, (void *)pool);
          add++;
          pool->live_thr_num++;
        }
      }
      pthread_mutex_unlock(&(pool->lock));
    }

    // 当忙线程*2小于存活的线程数 且 存活的线程数大于最小线程数的时候
    if ((busy_thr_num * 2) < live_thr_num && live_thr_num > pool->min_thr_num) {
      printf("-----remove more thread!!!\n");
      pthread_mutex_lock(&(pool->lock));
      pool->wait_exit_thr_num = DEFAULT_THREAD_VARY;
      pthread_mutex_unlock(&(pool->lock));

      for (i = 0; i < DEFAULT_THREAD_VARY; i++) {
        pthread_cond_signal(&(pool->queue_not_empty));
      }
    }
  }
  return NULL;
}

void *process(void *arg) {
  printf("thread 0x%x working on task %d\n", (unsigned int) pthread_self(), (long long) arg);
  sleep(1);
  printf("task %d end\n", (long long)arg);
  return NULL;
}

int threadpool_add(threadpool_t *pool, void*(*function)(void *arg), void *arg) {
  pthread_mutex_lock(&(pool->lock));

  while ((pool->queue_size == pool->queue_max_size) && (!pool->shutdown)) {
    pthread_cond_wait(&(pool->queue_not_full), &(pool->lock));
  }

  if (pool->shutdown) {
    pthread_cond_broadcast(&(pool->queue_not_empty));
    pthread_mutex_unlock(&(pool->lock));
    return 0;
  }

  // 清空工作线程调用的回调函数的参数arg
  if (pool->task_queue[pool->queue_rear].arg != NULL) {
    pool->task_queue[pool->queue_rear].arg = NULL;
  }

  // 将任务添加到任务队列里
  pool->task_queue[pool->queue_rear].function = function;
  pool->task_queue[pool->queue_rear].arg = arg;
  pool->queue_rear = (pool->queue_rear + 1) % pool->queue_max_size;
  pool->queue_size++;

  // 添加完任务后，队列不为空， 唤醒线程池中的等待处理任务的线程
  pthread_cond_signal(&(pool->queue_not_empty));
  pthread_mutex_unlock(&(pool->lock));

  return 0;
}

int threadpool_destory(threadpool_t *pool) {
  int i;
  if (pool == NULL) {
    return -1;
  }
  pool->shutdown = true;

  // 先销毁管理线程
  pthread_join(pool->adjust_tid, NULL);

  for (i = 0; i < pool->live_thr_num; i++) {
    // 通知所有空闲线程->让所有的线程全部死亡
    pthread_cond_broadcast(&(pool->queue_not_empty));
  }
  for (i = 0; i < pool->live_thr_num; i++) {
    pthread_join(pool->threads[i], NULL);
  }
  threadpool_free(pool);
  return 0;
}

int threadpool_free(threadpool_t *pool) {
  if (pool == NULL) {
    return -1;
  }
  if (pool -> task_queue) {
    free(pool->task_queue);
  }
  if (pool->threads) {
    free(pool->threads);
    pthread_mutex_lock(&(pool->lock));
    pthread_mutex_destroy(&(pool->lock));
    pthread_mutex_lock(&(pool->thread_counter));
    pthread_mutex_destroy(&(pool->thread_counter));
    pthread_cond_destroy(&(pool->queue_not_empty));
    pthread_cond_destroy(&(pool->queue_not_full));
  }
  free(pool);
  pool = NULL;
  return 0;
}

int main() {
  // 创建一个线程池，最小的线程是3，最大的线程是100
  threadpool_t *thp = threadpool_create(3, 100, 100);
  printf("pool inited\n");

  int num[100], i;
  for (i = 0; i < 100; i++) {  // 模拟20个任务
    num[i] = i;
    printf("add task %d\n", i);

    threadpool_add(thp, process, (void*)&num[i]);   // 向线程池中添加任务
  }

  sleep(15);
  threadpool_destory(thp);     // 等待子线程完成任务

  return 0;

}
```

== UDP服务器
=== TCP通信和UDP通信的优缺点：
#strong[TCP：]面向连接的，可靠数据包传输

- 对于不稳定的网络层，采用完全弥补的通信方式 ---\> 丢包重传

#strong[优点：]

- 稳定
  - 数据的流量，速度，顺序稳定

#strong[缺点：]

- 传输速度慢，效率相对较低，系统资源开销大。

#strong[使用场景：]数据的完整性要求较高， 不追求效率。（大数据，文件的传输）

#html.hr()

#strong[UDP：]无连接的，不可靠的数据包传递

- 对于不稳定的网络层，采取完全不弥补的通信方式 ---\> 默认还原网络状况

优点：

- 传输速度快，效率相对较高， 系统资源开销小。

缺点：

- 不稳定
  - 数据的流量，速度，顺序不稳定

使用场景：时效性要求较高，稳定性其次。（游戏，视频会议，视频电话）

#strong[可以在应用层进行数据校验，从而来弥补udp的不足]

#html.hr()

=== UDP实现的C/S模型
- `accept()和connect()被舍弃`

- `recv()/ send()`只能用于TCP通信。用来代替`read()/write()`

#strong[server:]

```
lfd = socket(AF_INET, SOCK_DGRAM, 0);
bind();
listen();       ---可有可无
while(1) {
    recvfrom(cfd, buf, )    --- 被替换为recvfrom()
    { ... }
    write();            --- 被替换为sendto()
}
close();
```

#strong[client:]

```
connfd = socket(AF_INET, SOCK_DGRAM, 0);
sendto(connfd, "服务器的地址结构"， 地址结构的大小);
recvfrom();
close();
```

==== recvfrom函数
```
作用：连接并从一个地方读取数据
ssize_t recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len);
参数：
    socket：套接字
    buffer：读取的数据存放的缓冲区
    length：缓冲区的大小
    flags：默认传0
    address：传出参数，对端的地址结构
    address_len：传入传出参数，对端的地址结构的大小
返回值：
    成功：接收数据字节数
    失败：-1, 设置errno
    0：对端关闭
```

==== sendto函数
```
作用：向指定的地方发送数据
ssize_t sendto(int socket, const void *message, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
参数：
    socket: 套接字
    message: 存储数据的缓冲区
    length: 数据长度
    flags: 默认为0
    dest_addr: 目标的地址结构(不可以省略)
    dest_len: 目标地址结构的长度
返回值：
    成功：成功写出的数据字节数
    失败：-1,设置errno
```

=== 代码实现
#strong[server.cpp]

```cpp
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <ctype.h>

#define server_port 6666

int main() {
  struct sockaddr_in serv_addr, clie_addr;
  socklen_t clie_addr_len;
  int sockfd;
  char buf[BUFSIZ];
  char str[INET_ADDRSTRLEN];
  int i, n;

  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  bzero(&serv_addr, sizeof(serv_addr));
  serv_addr.sin_port = htons(server_port);
  serv_addr.sin_family = htonl(AF_INET);
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);

  bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));

  printf("accepting connections \n");
  while (1) {
    clie_addr_len = sizeof(clie_addr);
    n = recvfrom(sockfd, buf, BUFSIZ, 0, (struct sockaddr *)&clie_addr, &clie_addr_len);
    if (n == -1) {
      perror("recv error\n");
    }

    printf("receive from &s at PORT %d\n", inet_ntop(AF_INET, &clie_addr.sin_addr.s_addr, str, sizeof(str)), ntohs(clie_addr.sin_port));

    for (int i = 0; i < n; i++) {
      buf[i] = toupper(buf[i]);
    }

    n = sendto(sockfd, buf, n, 0, (struct sockaddr*)&clie_addr, sizeof(clie_addr));
    if (n == -1) {
      perror("sendto error");
    }
  }

  close(sockfd);
  return 0;
}
```

#strong[client.cpp]

```cpp
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ctype.h>

const int  SERV_PORT = 6666;
#define BUFSIZE 4096

void sys_err(const char * str) {
    perror("str");
    exit(1);
}

int main() {
    sockaddr_in serv_addr;
    int sockfd, n;
    char buf[BUFSIZ];

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr);
    serv_addr.sin_port = htons(SERV_PORT);

    // bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
    printf("init end\n");
    int ret;
    while (1) {
        scanf("%s", buf);
        n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
        if (n == -1) 
            perror("sendto error");
        
        n = recvfrom(sockfd, buf, BUFSIZ, 0, NULL, 0);
        if (n == -1)
            perror("recvfrom error");
        write(STDOUT_FILENO, buf, n);
    }

    close(sockfd);
    return 0;
}
```

=== 本地套接字
#strong[IPC（进程间通信）：]pipe, fifo, mmap, 信号， 本地套接字（domain）

对比网络编程TCP C/S模型：

- socket函数的参数domain：应取`AT_UNIX`, type:无限制， protocal：无限制
- bind函数的地址结构：取`sockaddr_un`类型
- 初始化

```
struct sockaddr_un {
    sa_family_t sun_family;               /* 地址结构类型 */
    char        sun_path[108];            /* socket文件名（路径） 路径的长度最大为108*/
};

初始化示例：
srv_addr.sun_family = AF_UNIX;
strcpy(srv.addr.sum_path, "srv.socket");
```

- 获取地址类型的大小需要用`offsetof()`函数

```
作用：获取成员的偏移量
size_t offsetof(type, member);
参数：
    type：类型
    member：成员
返回值：
    偏移量
```

```
len = offsetof(struct sockaddr_un, sun_path) + strlen("srv.socket");
bind(fd, (struct sockaddr*)&srv_addr, len);
```

- `bind`函数创建成功，会创建一个socket。因此，为了保证`bind`成功，通常会在`bind`前，`unlink()`

- 客户端不能依赖隐式绑定。并且在通信建立的过程中，创建且初始化2个地址结构：

  - client\_addr -\> bind
  - server\_addr -\> connect

#strong[注意点：]

server和client的socket文件都是伪文件，即不占用磁盘的空间（通过bind函数创建出来的）

==== 代码实现
注意：在本代码中，server和client要在同一个目录下

#strong[server]

```cpp
#include "wrap.h"
#include <sys/un.h>
#include <stddef.h>
#include <sys/socket.h>

#define SERV_ADDR "serv.socket"

int main() {
  int lfd, cfd, len, size, i;
  sockaddr_un servaddr, cliaddr;
  char buf[4096];

  lfd = Socket(AF_UNIX, SOCK_STREAM, 0);

  bzero(&servaddr, sizeof(servaddr));
  servaddr.sun_family = AF_UNIX;
  strcpy(servaddr.sun_path, SERV_ADDR);

  len = offsetof(struct sockaddr_un, sun_path) + strlen(servaddr.sun_path);

  unlink(SERV_ADDR);        // 确保bind之前serv.sock文件不存在，因为bind会创建该文件
  bind(lfd, (struct sockaddr *)&servaddr, len);   // 参三不能是sizeof(servaddr)

  Listen(lfd, 20);

  printf("accept...\n");
  while (1) {
    len = sizeof(cliaddr);
    cfd = accept(lfd, (struct sockaddr *)&cliaddr, (socklen_t *)&len);
    len -= offsetof(struct sockaddr_un, sun_path);      // 取得文件名的长度
    cliaddr.sun_path[len] = '\0';

    printf("client bind filename %s\n", cliaddr.sun_path);

    while ((size = read(cfd, buf, sizeof(buf))) > 0) {
      for (i = 0; i < size; i++) {
        buf[i] = toupper(buf[i]);
      }
      write(cfd, buf, len);
    }
    close(cfd);
  }
  close(lfd);
}
```

#strong[client]

```cpp
#include <stdlib.h>
#include <unistd.h>
#include <sys/un.h>
#include <stddef.h>
#include <sys/socket.h>
#include <stdio.h>
#include <ctype.h>

#define SERV_ADDR "serv.socket"
#define CLIE_ADDR "clie.socket"

int main() {
    int cfd, len;
    sockaddr_un servaddr, cliaddr;
    char buf[4096];

    cfd = socket(AF_UNIX, SOCK_STREAM, 0);

    bzero(&cliaddr, sizeof(cliaddr));
    cliaddr.sun_family = AF_UNIX;
    strcpy(cliaddr.sun_path, CLIE_ADDR);

    len = offsetof(struct sockaddr_un, sun_path) + strlen(cliaddr.sun_path);

    unlink(CLIE_ADDR);        // 确保bind之前serv.sock文件不存在，因为bind会创建该文件
    bind(cfd, (struct sockaddr *)&cliaddr, len);   // 参三不能是sizeof(servaddr)

    ///////

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sun_family = AF_UNIX;
    strcpy(servaddr.sun_path, SERV_ADDR);

    len = offsetof(struct sockaddr_un, sun_path) + strlen(servaddr.sun_path);

    connect(cfd, (struct sockaddr *)&servaddr, len);

    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        write(cfd, buf, strlen(buf));
        len = read(cfd, buf, sizeof(buf));
        write(STDOUT_FILENO, buf, len);
    }
    close(cfd);
    return 0;
}
```
