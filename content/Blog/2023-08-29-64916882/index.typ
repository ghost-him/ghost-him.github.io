#import "../../index.typ": template, tufted
#show: template.with(title: "protocol库---快速构建与生成协议")

== 介绍
这个项目的目的是让人们可以快速的构建出属于自己的一个协议。

```markdown
protocolBuilder
protocolConverter

protocol: 一个协议本身
protocolOption: 一个协议格式本身
```

== protocolBuilder
协议生成器，通过设置协议的格式与输入数据内容，快速的生成可用于发送的协议

```cpp
// 设置协议格式
void load(std::shared_ptr<ProtocolOption> option);
参数：
    option：要使用的协议格式

// 设置头标记
// 下标从0开始
template<class Data>
void set_head(unsigned int index, Data data);
参数：
    index：要设置的头标记的下标
    data：头标记的内容

// 设置数据内容
std::shared_ptr<Protocol> set_data(void* data, unsigned int size);
参数：
    data：指向数据内容的指针
    size：数据的长度
返回：
    成功：生成的协议指针
    失败：nullptr（数据的长度超出了当前协议一次可以传输的长度）
```

== protocolConverter
协议转换器，通过指定的协议格式，实现存取协议的内容

```cpp
// 加载要解码的数据
void convert(unsigned char* data);
参数：
    data：要解析的数据
// 加载协议规则
void load(std::shared_ptr<ProtocolOption> option);
参数：
    option：加载要解析的格式

template<class res>
res get_head(unsigned int index);
参数：
    index：头标记的下标
返回：对应下标的头标记的值

void get_data(void* destination);
参数：
    destination：解析后的数据存放的位置，要自己确保有足够的空间
```

== protocol
一个协议本身

```cpp
Protocol(const Protocol& pro);
const Protocol& operator=(const Protocol& pro);

// 获取数据指针
void* data();
返回：数据指针

// 获取数据的长度
unsigned int size();
返回：数据的长度
```

== protocolOption
一个协议本身

在设计结构的时候，必须要添加`SIZE`字段。

```cpp
// 获取单次发送的最大长度
unsigned int size();
返回:单次发送的最大的长度（首部 + 数据）

// 添加一个头标记
bool append(unsigned int length, protocolType type, std::string description = "");
参数：
    length：当前头标记占用的字节数
    type：当前头标记的类型（一个协议必须要有一个SIZE字段的标记）
    description：头标记的描述
返回：是否添加成功
    
可用的字段：
enum protocolType {
    UINT,
    INT,
    STR,
    SIZE
};
特殊字段：SIZE
    SIZE字段是每个协议都必须要有的，同时，在构造一个协议的时候，生成器会根据消息数据的长度自动为这个头标记赋值，SIZE字段使用unsigned int的格式存储。
    
    
protocolOption中私有变量
control：使用位来控制信息
第 0 位：是否设置了消息长度 0 否 1 是
```

= 例
如果要构造以下的格式：

```
|1 字节版本号|1 字节信息类型|4 字节总长度|2 字节消息组|4 字节偏移量|3 字节消息长度|
解释：
1 字节版本号：可以有 256 种版本
1 字节信息类型：可以表示 256 种不同的信息格式
4 字节总长度：最大可以传输 2TB - 1B 的文件
2 字节消息组：一共可以同时支持 65536 个用户传输文件
4 字节消息偏移量：表示从 xxx 字节开始的数据
3 字节消息长度：最大可以表示 16MB-1B 的长度
规则：
相同的传送组的消息组号一样
协议在修改后，原先的内容会消失
```

可以写以下代码

```cpp
// 创建一个协议格式对象
std::shared_ptr<ProtocolOption> option = std::make_shared<ProtocolOption>();
// 初始化协议格式对象
void init() {
    option->append(1, UINT, "版本号");
    option->append(1, UINT, "消息类型");
    option->append(4, UINT, "总长度");
    option->append(2, UINT, "消息组");
    option->append(4, UINT, "偏移量");
    option->append(20, STR, "说明信息");
    option->append(3, SIZE, "消息长度");
}
```

接下来构建一个协议生成器

```cpp
// 初始化生成器
ProtocolBuilder builder;
// 加载协议的格式
builder.load(option);
// 设置头标记
builder.set_head(0, 1);     // 版本号          1
builder.set_head(1, 1);     // 消息类型        1
builder.set_head(2, 20);    // 总长度          20
builder.set_head(3, 0);     // 消息组          0
builder.set_head(4, 0);     // 当前消息的偏移量 0
builder.set_head(5, "支持字符");     // 说明信息 0
```

让生成器使用数据来生成协议

```cpp
// 如果要发送a数组
char a[3] = "10";
// 生成可用于发送的协议 
auto proto = builder.set_data(a, 2);
// 如果生成失败，则返回（如果当前的数据长度超过了一次可以传输的长度）
if (proto == nullptr)
    return ;
// proto对象就是根据a生成出来的协议
```

使用`socket`发送数据

```cpp
// 参数：数据内容，数据长度
m-socket(proto->data(), proto.size());
```

接收方

```cpp
设data为收到的unsigned char*数组，里面存放从发送方收到的字符流
unsigned char* data = new unsigned char[1024];
```

定义一个解码器

```cpp
// 解码器
ProtocolConverter converter;
// 加载相同的协议格式
converter.load(option);
// 这里要确保发送方与接收方使用的是同一个协议格式
```

将数据输入到解码器中就可以解析

```cpp
// 解码
converter.convert(data);
```

获取从协议中传送的信息

```cpp
// 输出首部信息
std::cout << "0 " << converter.get_head<unsigned int>(0) << std::endl;
std::cout << "1 " << converter.get_head<unsigned int>(1) << std::endl;
std::cout << "2 " << converter.get_head<unsigned int>(2) << std::endl;
std::cout << "3 " << converter.get_head<unsigned int>(3) << std::endl;
std::cout << "4 " << converter.get_head<unsigned int>(4) << std::endl;
std::cout << "5 " << converter.get_head<std::string>(5) << std::endl;
std::cout << "6 " << converter.get_head<unsigned int>(6) << std::endl;
 // 开一个空间，用于存放数据部分
 char b[5] = {};
 // 将数据部分放到b数组中
 converter.get_data(b);
 // 输出b的内容
 std::cout << b << std::endl;
```
