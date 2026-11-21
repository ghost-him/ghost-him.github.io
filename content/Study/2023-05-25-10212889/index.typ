#import "../../index.typ": template, tufted
#show: template.with(title: "linux 网络编程（2） --- socket编程")

= socket编程
== 套接字的概念
- socket

- 在通信过程中，套接字一定是成对出现的

- 一个文件描述符指向一个套接字，该套接字内部借助两个缓冲区实现，一个用于收，一个用于发

== 预备知识
=== 网络字节序
小端法（pc本地存储）：高位存高地址， 低位存低地址 大端法（网络存储）：高位存低地址， 低位存高地址

```
htonl   本地->网络（ip） 
htons   本地->网络（port）
ntohl   网络->本地（ip）
ntohs   网络->本地（port）
```

=== IP地址转换函数
==== inet\_pton函数
```
作用：将本地的点分十进制的ip字符串转换为一个网络字节序   本地字节序（string IP）->网络字节序
int inet_pton(int af, const char *restrict src, void *restrict dst);
参数：
    af:当前ip版本的
        AF_INET： IPv4
        AF_INET6： IPv6
    src：IP地址（点分十进制）
    dst：传出参数：转换后的网络字节序的ip地址
返回值：
    成功： 1
    异常： 0 说明src指向的不是一个有效的ip地址（即当前的网络中没有这个ip）
    失败： -1， 设置errno
```

==== inet\_ntop函数
```
作用：将网络字节序转换为本地的点分十进制的ip     网络字节序->本地字节序（string IP）
const char *inet_ntop(int af, const void *restrict src, char *restrict dst, socklen_t size);
参数：
    af:当前的ip版本
        AF_INET： IPv4
        AF_INET6： IPv6
    src：网络字节序ip地址
    dst：本地字节序
    size：dst的大小
返回值：
    成功：dst
    失败：NULL
```

=== sockaddr数据结构
- 要定义`sockaddr_in`的数据结构
- 使用时要强制转换

#strong[sockaddr\_in 数据结构]

```
struct sockaddr_in {
    sa_family_t    sin_family; /* 用于指定是IPv4还是IPv6*/
    in_port_t      sin_port;   /* 网络字节序的端口号*/
    struct in_addr sin_addr;   /* 网络字节序的IP地址*/
};

/* Internet address */
struct in_addr {
    uint32_t       s_addr;     /* 网络字节序的IP地址 */
};
```

#strong[用法]

```
struct sockaddr_in addr;

addr.sin_family = AF_INET;
addr.sin_port = htons(9527);
// === 法一 ===
int dst;
inet_pton(AF_INET, "192.157.22.42", (void *)&dst);
addr.sin_addr.s_addr = dst;
// === 法二 ===
addr.sin_addr.s_addr = htonl(INADDR_ANY);   //出去当前系统中有效的ip地址（int），并且将其转换为网络字节序

bind(fd, (struct addr*)&addr);
```

=== 读与写
使用系统调用来读取数据与发送数据

#strong[注意]

使用`read`函数的时候

```
返回值：
    > 0: 实际读到的字节序
    = 0： 表示已经读到了结尾，即对端已经关闭（***）
    < 0: 此时应该进一步判断errno
        errno = EAGAIN 或者是 EWOULDBLOCK 以非阻塞的方式读取数据， 但是没有数据， 需要再次读
        errno = EINTR 慢速系统调用被中断,  需要重启
        errno = ECONNRESET 说明连接被重置->关闭当前的文件描述符
        errno = 其他异常
```

== 网络套接字函数
#figure(
  table(
    columns: 2,
    align: (auto,auto,),
    table.header([函数], [作用],),
    table.hline(),
    [`socket()`], [创建套接字],
    [`bind()`], [绑定IP + port],
    [`listen()`], [设置#strong[同时]监听上限],
    [`accept()`], [阻塞监听客户端建立连接],
    [`connect()`], [与目标建立连接],
  )
  , kind: table
  )

=== socket函数
```
作用：创建一个套接字
int socket(int domain, int type, int protocol);
参数：
    domain:ip地址协议
        AF_INET
        AF_INET6
        AF_UNIX     本地套接字
    type:数据传输协议
        SOCK_STREAM 流式协议
        SOCK_DGRAM  报式协议
    protocol:所选协议中的代表协议 
        0: 根据type默认选择 流式协议默认为tcp, 报式协议默认为udp
返回值：
    成功：新套接字所对应的文件描述符
    失败： -1, errno
```

=== bind函数
```
作用：给socket绑定一个地址结构（ip + port）
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
参数：
    sockfd：目标的套接字
    addr：传入参数，被绑定的地址结构（地址结构里的sin_family应该与socket的domain保持一致）
    addrlen: 地址结构的大小
返回值：
    成功：0
    失败：-1,errno
```

=== listen函数
```
作用：设置可以同时进行3次握手的客户端（同时与服务器建立的上限数）
int listen(int sockfd, int backlog);
参数：
    sockfd：目标的套接字
    backlog：上限值，最大值为128
返回值：
    成功：0
    失败：-1,errno
```

=== accpet函数
```
作用：阻塞等待客户端建立连接， 成功的话， 返回一个与客户端成功连接的socket文件描述符
int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen);
参数：
    sockfd：目标的套接字
    addr：传出参数，成功与服务器建立连接的那个客户端的地址结构
    addrlen：传入传出参数。
        入：addr的大小。
        出：客户端addr的实际的大小
返回值：
    成功：能与服务器进行数据通信的socket对应的文件描述符
    失败： -1, errno
```

```
socklen_t client_addr_len = sizeof(addr);
accept(...,..., &client_addr_len);
```

=== connect函数
```
作用：使用现有的socket与服务器建立连接
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
参数：
    sockfd：目标的套接字
    addr：传入参数，目标服务器的地址结构
    addrlen：服务器地址结构的大小
返回值：
    成功：0
    失败：-1,errno
```

如果不是用bind绑定客户端地址结构，则采用“隐式绑定”

== 错误处理函数封装
- 将系统调用封装成自己的函数
- + 完成系统调用的工作 2. 检查返回值，查看函数是否正确工作
- 命名规则：保持与系统调用相同的命名规则， 可以将首字母大写

实现目标：

+ 功能一样
+ 不用进行错误判断

== 多进程并发服务器
#strong[设计思路]

+ Socket() 创建监听套接字

+ Bind() 绑定地址结构

+ Listen()

+ while(1) { cfd = Accpet(); 接受客户端连接请求 pid = fork();

  if (pid == 0) { 子进程： read() -- 处理 --- write() close(lfd) 关闭用于建立连接的套接字lfd while(1){ … } 处理 } else if (pid \> 0) { 父进程 close(cfd) 关闭用于与客户端通信的套接字 {…} 用于回收子进程的函数 continue; } }

+ 子进程： `close(lfd)  read()  { ... }  一系列动作  write()` 父进程： `注册信号捕捉函数：       SIGCHLD  在回调函数中，完成子进程回收  while(waitpid())`

== 多线程并发服务器
#strong[设计思路]

+ Socket() 创建监听套接字

+ Bind() 绑定地址结构

+ Listen()

+ while(1) {

  cfd = Accept(lfd);

  pthread\_create(&tid, NULL, tfn, NULL);

  pthread\_detach(tid) 不获取线程的值/\/ pthread\_join(tid, void \*\*) 获取线程的值， 为了防止线程阻塞， 可以新开一个线程来回收

+ 子线程：

  void #emph[tfn(void ]arg) {

  ​ close(lfd);

  ​ read(cfd)

  ​ 功能

  ​ write(cfd)

  }

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


void sys_err(const char * str);

int Socket(int domain, int type, int protocol);
int Bind(int socket, const struct sockaddr_in *address, socklen_t address_len);
int Listen(int sockfd, int backlog);
int Accept(int socket, sockaddr_in *address, socklen_t *address_len);
int Connect(int socket, const struct sockaddr_in *address, socklen_t address_len);

void thread_error(const char * message);

void sys_err(const char *str)
{
    perror(str);
    exit(1);
}

int Socket(int domain, int type, int protocol)
{
  int n;
  n = socket(domain, type, protocol);
  if (n == -1)
  {
    sys_err("socket error");
  }

  return n;
}

int Bind(int socket, const struct sockaddr_in *address, socklen_t address_len)
{
  int n;
  n = bind(socket, (struct sockaddr *)address, address_len);
  if (n == -1)
  {
    sys_err("bind error");
  }
  return 0;
}

int Listen(int sockfd, int backlog)
{
  int ret = listen(sockfd, backlog);
  if (ret == -1)
  {
    sys_err("listen error");
  }
  return 0;
}

int Accept(int socket, struct sockaddr_in *address, socklen_t *address_len)
{
  int n;
  n = accept(socket, (struct sockaddr *)address, address_len);
  if (n == -1)
  {
    sys_err("accept error");
  }
  return n;
}

int Connect(int socket, const struct sockaddr_in *address, socklen_t address_len)
{
  int ret;
  if ((ret = connect(socket, (struct sockaddr *)address, address_len)) == -1)
  {
    sys_err("connect error");
  }
  return ret;
}

void thread_error(const char *message)
{
  fprintf(stderr, "%s\n", message);
}


struct s_info
{
    sockaddr_in s_addr;
    int fd;
} ts[256];

const int BUFSIZE = 1024;

void *connect_client(void *arg)
{
    struct s_info *ts = (struct s_info *)arg;
    ssize_t size_len = 0;
    char buf[BUFSIZE];
    while (1)
    {
        size_len = read(ts->fd, buf, BUFSIZE);
        if (size_len == 0)
        {
            close(ts->fd);
            pthread_exit(NULL);
        }
        for (int i = 0; i < size_len; i++)
        {
            buf[i] = toupper(buf[i]);
        }
        write(ts->fd, buf, size_len);
    }
}

int main(int argc, char **argv)
{
    int server_socket = Socket(AF_INET, SOCK_STREAM, 0);

    int opt = 1;
    setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, (void *)&opt, sizeof(opt));

    sockaddr_in addr, client;
    socklen_t len = sizeof(client);

    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(443);

    Bind(server_socket, &addr, sizeof(addr));

    Listen(server_socket, 127);

    int i = 0;
    while (1)
    {
        int client_fd = Accept(server_socket, &client, &len);

        ts[i].s_addr = client;
        ts[i].fd = client_fd;

        pthread_t tid;
        pthread_create(&tid, NULL, connect_client, (void *)&ts[i]);
        pthread_detach(tid);
        i++;
    }
    return 0;
}
```

== 端口复用
- 即创建端口号相同， 但是ip地址不同的socket（一般用在断开了连接，但是没有完全断开的情况），比如快速重启服务器
- 在`socket()` 和`bind()`之间插入代码

```
int opt = 0 / 1;            // 0为不复用（默认）， 1为复用
setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, (void *)&opt, sizeof(opt))
```
