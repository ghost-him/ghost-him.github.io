#import "../../index.typ": template, tufted
#show: template.with(title: "6.5840 2025 Spring Lab2")


= 记录一下 6.5840 2025 Spring Lab2 的过程

== 实验要求

#tufted.margin-note[
  该实验的地址如下：#link("https://pdos.csail.mit.edu/6.824/labs/lab-kvsrv1.html")[mit 6.824] \
  实验要求的部分为原文翻译并做适当的修改
]

要求：为单机构建一个键值（KV）服务器。该服务器需要确保即使在网络故障的情况下，每个 Put 操作也只会被执行最多一次，并且所有操作都满足线性一致性#footnote[linearizable, 也可以称为原子一致性。线性一致性的系统会让使用者觉得整个系统就像只有一台机器，且所有的操作都是按顺序原子化执行的。在本次实验中，表示：1.不会读到过时的数据 2. Put 与 Get 都是在某个瞬间完成的 3.可靠的 4.使用者只需要像操作本地内存的 Map 一样思考即可]。同时会将使用这个 KV 服务器来实验一个锁（lock）。在之后的实验中会对服务器进行副本化，以便处理服务器崩溃的情况。

=== KV 服务器

KV 服务器保存的是 (string, string) 的一个 Map 映射，所以它支持的 Key 与 Value 都必须是 string 类型的。

每个客户端通过一个 Clerk 与键值服务器交互，Clerk 负责向服务器发送 RPC。客户端可以向服务器发送两种不同的 RPC：Put(key, value, version) 和 Get(key)。服务器维护一个内存映射（in-memory map），为每个键记录一个 (value, version) 元组。键和值均为字符串。版本号（version）记录了该键被写入的次数。

只有当 Put 操作提供的版本号与服务器中该键当前的版本号匹配时，Put(key, value, version) 才会存入或替换映射中特定键的值。如果版本号匹配，服务器还会递增该键的版本号。如果版本号不匹配，服务器应返回 rpc.ErrVersion。客户端可以通过调用版本号为 0 的 Put 来创建一个新键（服务器随后存储的版本号将为 1）。如果 Put 的版本号大于 0 且该键不存在，服务器应返回 rpc.ErrNoKey。

Get(key) 用于获取该键的当前值及其关联的版本号。如果键在服务器上不存在，服务器应返回 rpc.ErrNoKey。

为每个键维护版本号对于使用 Put 实现锁，以及在网络不可靠且客户端重传时确保 Put 操作的“最多一次”语义非常有用。

=== 目标

当你完成本实验并通过所有测试后，从调用 Clerk.Get 和 Clerk.Put 的客户端角度来看，你将拥有一个线性一致的键值服务。也就是说，如果客户端操作不是并发的，那么每个客户端的 Clerk.Get 和 Clerk.Put 都将观察到由先前操作序列所产生的状态变更。对于并发操作，其返回值和最终状态将与这些操作按某种顺序逐个执行时的结果一致。如果操作在时间上存在重叠，则称它们是并发的：例如，客户端 X 调用 Clerk.Put()，随后客户端 Y 调用 Clerk.Put()，然后客户端 X 的调用才返回。一个操作必须能够观察到在它开始之前已经完成的所有操作的影响。有关更多背景信息，请参阅关于线性一致性（linearizability）的 FAQ。

线性一致性对应用程序来说非常方便，因为它的表现就像是一台单服务器在按顺序逐个处理请求。例如，如果一个客户端针对更新请求收到了来自服务器的成功响应，那么随后由其他客户端发起的读取操作保证能看到该更新的结果。对于单台服务器而言，提供线性一致性是相对容易的。


== 笔记内容

#tufted.margin-note[
  服务端\
  Get 操作：如果 args.Key 存在，则返回其对应的值（value）和版本号（version）。否则，Get 返回 ErrNoKey。\
  Put 操作： 如果 args.Version 与服务器上该键的版本号匹配，则更新该键的值。如果版本号不匹配，则返回 ErrVersion。如果该键不存在：当 args.Version 为 0 时，Put 会安装（设置）该值；否则返回 ErrNoKey。\
]

这个实验主要就是要求实现一个Put与Get操作，然后再基于这个Put与Get操作实现Acquire与Release操作。Put操作用于向服务器存入键值对，而Get操作则用于从服务器中获取键值对。


对于分布式数据库来说，如何要保证一定是最新的值被替换了呢，则通过版本号来判断。

对于服务器来说，Put与Get操作都是在操作本地的Map函数，这个就特别的简单，只需要维护一个(Key, Value)的Map容器与(Key, Version)的Map容器就可以了。后面的表示当前的Value是哪个版本的。如果当前没有这个键，那么Version版本为0。每次更新的时候Version + 1即可#footnote[注意，这里的更新也包含插入操作，所以当客户端向服务器插入了一个新的键值对时，其版本为1，我一开始理解错了，将默认的Version版本设置为0，导致测试没有通过]，实验。

#tufted.margin-note[
  客户端\
  Get 操作：Get 获取一个键（key）的当前值（value）和版本号（version）。如果该键不存在，则返回 ErrNoKey。面对所有其他错误时，它会无限期地持续尝试。\
  Put 操作：Put 仅在请求中的版本号与服务器上该键的版本号匹配时，才会使用新值更新该键。如果版本号不匹配，服务器应当返回 ErrVersion。如果 Put 在其第一次 RPC 请求时收到 ErrVersion，则 Put 应当返回 ErrVersion，因为该 Put 操作肯定没有在服务器上执行。如果服务器在重发（resend）的 RPC 中返回 ErrVersion，那么 Put 必须向应用程序返回 ErrMaybe，因为其早前的 RPC 可能已被服务器成功处理，但响应丢失了，导致 Clerk 无法确定 Put 是否执行成功。\
]

对于客户端来说，需要考虑的东西就比较多了。不过好在实验2中给的基础代码中，已经使用了详细的注释介绍了客户端代码的完整的处理的流程，这里就不再赘述了，具体的流程可在侧边栏中看到。

之后的任务就是基于客户端的 Put 与 Get 操作，实现一个 Acquire 与 lock 操作。Acquire 操作是向服务端上锁，上锁以后，其他的客户端无法再对这个服务端上锁。只有当这个客户端执行 Release 操作以后，其他的客户端才能继续上锁。实验要求，客户端在上锁的过程中如果发生了冲突，则需要阻塞等待直到成功上锁。由于该实验给的接口很少，实现的也是非常轻量级的kv服务器，所以客户端只能通过轮询的方式完成上锁#footnote[实验中给的要求是每 100ms 轮询一次]。

这里再简单介绍一下 Acquire 与 Release 的逻辑

这里的 Acquire 与 Release 操作都是借助一个特定的键#footnote[实验中是由外部传入这个键的 string 是什么]来实现，这个键我定义为：指明了当前有效上锁的客户端是哪一个，默认为 "00000000"#footnote[为什么是 8 个 "0" 呢，因为我看hint中说，call kvtest.RandValue(8) to generate a random string. 这里他使用了8位作为客户端的id，所以我将 8 位 "0" 定义为无锁状态]，在本文中，我把它叫成 LockKey 吧。所以如果要让服务器知道当前是哪个客户端，就要让客户端在初始化的时候生成一个随机的，同时排除默认#footnote[即"00000000"]的8位字符串。

那么，当前无锁就一共有这样两个状态：1. LockKey 的值为 "00000000"。2.当前没有 LockKey#footnote[服务器没有这个键，说明当前还没有任何一个客户端向服务器发送加锁的请求，此时的版本号必须为0]。

那么上锁的逻辑就可以很清楚的写出来了（逻辑多，但是代码其实还是很简洁的）：
+ 首先，获取 LockKey 所对应的值
  + 如果没有 LockKey 或者 值为 "00000000"，则说明没有其他的客户端加了锁，当前可以加锁#footnote[即使用Put操作，将服务器中的 LockKey 的值设置为自己的 id]
  + 如果 LockKey 的值为 "00000000" 以外的字符串，说明当前已经有客户端对服务端上锁了，等待100ms再次尝试
+ 加锁了以后可能会有这样的几个状态
  + 得到了 OK，表示已成功上锁，此时需要再次获取最新的版本
  + 得到限 ErrMaybe，表示信息在传输的过程中可能发生了丢失，需要再次获取最新的值
    + 如果该值是等于自己的id，则说明自己加锁成功，那么同时传来的版本就是最新的版本
    + 如果不等于自己的id，则说明在上锁的过程中，被其他的客户端抢先一步上锁了。自己需要等待100ms再次尝试

解锁的逻辑比上锁的逻辑简单很多
+ 直接向服务器解锁，即使用Put操作，将 LockKey 设置成 "00000000"
  + 然后为了防止在传输的过程中发生错误，需要再次获取最新的 LockKey 值
    + 如果确认等于了 "00000000"，则解锁成功
    + 如果不等于 "00000000"，则再次发送解锁命令

由于Put操作需要版本参数，所以需要在客户端管理一下当前键的版本。

== 我的实现

以下是代码的定义：

```go
type KVServer struct {
	mu sync.Mutex

	// 核心的存储
	db map[string]string
	// 当前key的版本
	version map[string]rpc.Tversion
}

// 这个客户端没变，还是框架中默认的
type Clerk struct {
	clnt   *tester.Clnt
	server string
}

type Lock struct {
	// IKVClerk is a go interface for k/v clerks: the interface hides
	// the specific Clerk type of ck but promises that ck supports
	// Put and Get.  The tester passes the clerk in when calling
	// MakeLock().
	ck       kvtest.IKVClerk
	clientID string
	// 表示版本
	version       rpc.Tversion
	lockClientKey string
}

```
