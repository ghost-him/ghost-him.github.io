#import "../../index.typ": template, tufted
#import "@preview/mmdr:0.1.0": mermaid
#show: template.with(title: "记录一下 6.5840 2025 Spring Lab4 的过程")

= 记录一下 6.5840 2025 Spring Lab4 的过程

== 实验要求

在完成了lab3以后，现在有了一个可以正确运行的 Raft 算法。所以这个实验就是要求将实验2的 kv 服务器通过实验3的 Raft 算法变成一个允许有错误的 kv 服务器。只要大多数服务器存活且能正常通信，即使存在其他故障或网络分区，该键值服务也应继续处理客户端请求。

== 笔记内容

RSM 是介于应用层服务（如 KV 存储）与 Raft 共识层之间的 *中间件层*。它的核心作用是将复杂的 Raft 日志同步与状态机执行逻辑进行封装，实现应用逻辑与共识协议的解耦。

=== 1. 核心职责
- *解耦应用与共识*：应用层只需实现 `StateMachine` 接口（即 `DoOp` 方法），无需感知 Raft 的复杂交互。
- *请求追踪*：通过唯一标识符（Unique Identifier）匹配提交的操作，确保 `Submit` 能准确返回对应操作的执行结果。
- *并发控制*：协调处理多个并发的客户端请求，并处理因领导权变更（Leadership Change）导致的日志丢失问题。

=== 2. 关键组件
- *Submit(op)*：
  - 由服务处理器（Service Handler）调用。
  - 负责将操作封装并调用 `raft.Start()`。
  - *阻塞等待* 读取器协程通过内部通道（channel）返回的执行结果。
- *Reader 协程*：
  - 后台运行，持续监听 Raft 的 `applyCh`。
  - 负责将已提交（Committed）的操作交给状态机执行（调用 `DoOp`）。
  - 如果当前是 Leader，则需将执行结果派发给对应的 `Submit` 协程。
- *StateMachine (接口)*：
  - 由上层服务#footnote[例如本实验中的键值数据库。]实现。
  - `DoOp(any) -> any`：定义了状态机的具体转换逻辑。

=== 3. 交互流程图

#mermaid("
    sequenceDiagram

      C->>S: Request (Put/Get)
      S->>RSM_S: Submit(op)
      RSM_S->>R: raft.Start(op)
      
      Note over RSM_S: 阻塞并监听结果通道...

      R-->>RSM_R: applyCh (Committed Op)
      
      RSM_R->>SM: DoOp(op)
      SM-->>RSM_R: Result
      
      RSM_R->>RSM_S: 通过操作 ID 交付结果
      RSM_S-->>S: 返回执行结果
      S-->>C: Response
  ")

=== 4. 详细交互细节
+ *客户端* 发送请求至 Leader。
+ *Leader Service* 调用 `rsm.Submit(op)`。
+ *rsm.Submit* 记录当前操作 ID，调用 `raft.Start(op)`，随后开始在内部数据结构（如 Map + Channel）上 *阻塞*。
+ *Raft* 集群完成共识，将操作推入所有节点的 `applyCh`。
+ *rsm Reader 协程* 从 `applyCh` 读取该操作，调用 `service.DoOp(op)` 更新本地状态并获取结果。
+ *Leader 侧 Reader* 发现该操作 ID 匹配某个等待中的 `Submit` 协程，将结果通过 Channel 发送。
+ *rsm.Submit* 被唤醒，将执行结果返回给 Service 层，最后由 Service 响应客户端。

== 我的实现

=== 任务A

任务A要求实现复制状态机（RSM）。

在实现 `Submit` 函数时，我遇到了一个关于指令标识与追踪的逻辑矛盾，代码如下：

```go
func (rsm *RSM) Submit(req any) (rpc.Err, any) {

	// Submit creates an Op structure to run a command through Raft;
	// for example: op := Op{Me: rsm.me, Id: id, Req: req}, where req
	// is the argument to Submit and id is a unique id for the op.
	op := Op{Me: rsm.me, Id: id, Req: req}
	index, term, isLeader := rsm.rf.Start(op)
	

	// your code here
	return rpc.ErrWrongLeader, nil // i'm dead, try another server.
}
```

可以看到，我打算采用 Channel（通道）方案来实现同步。该方案的核心是维护一个映射表（Map），用于在后台协程监听到 `applyCh` 时，能够快速定位并唤醒对应的等待协程。按照常规思路，我需要在构建 `Op` 结构体时存入一个id。如果以 Raft 日志的索引（`index`）作为 id，就会陷入一个“先有鸡还是先有蛋”的困境：在调用 `rf.Start(op)` 将命令传入 Raft 之前，我无法预知该命令会被分配到哪个 `index`；但如果不把这个 id 封装进 `Op`，后续处理 `applyCh` 时似乎就无法实现快速定位。

不过，根据 `ApplyMsg` 的结构定义，可以发现：

```go
type ApplyMsg struct {
    CommandValid bool
    Command      any    // 这就是你当初存进去的 Op
    CommandIndex int    // Raft 会告诉这个 Op 所在的 index
    // ... 其他字段
}
```

可以看到，`ApplyMsg` 结构体本身已经包含了 `CommandIndex` 字段。这意味着当 Raft 完成共识并将指令应用到状态机时，它会主动告知该指令对应的日志索引。因此，我不需要在自定义的 `Op` 结构体中冗余地记录 `index`，只需利用 `rf.Start` 返回的索引建立映射，并在监听 `applyCh` 时通过 `CommandIndex` 进行匹配即可。

在写这个任务A时，需要注意 applyCh 的重要性：它是所发出来的每一个命令都是一个既定的事实。它要求状态机执行的命令是一定要执行的，不需要做任何多余的判断。它的正确性由 Raft 算法保证。

这个任务A 中有一个实验特别坑 `TestShutdown4A`。这个实验好像就只是用于测试 Shutdown 后 Submit 不会永远阻塞。所以它的正常的反映就是会在超时前返回。不过这个我也不太确信，我总感觉这个是有些问题的。但是我问了 Opus 4.6 以后，它一直碎碎念，念了快10多分钟，最后得出的这个结论。不过我先把后面的任务写完，如果当前的实现是有问题的，那么我在写后面的任务时，一定是会报错的。进而可以解决前面的问题。相信后人的智慧。


=== 任务B

任务B分为了两个小步骤。第一个小步骤就是将lab2的单机服务变成基于raft的多机服务。非常的简单啊。没什么好记的，一次性就跑通了ヾ(≧▽≦\*)o

第二个小步骤其实也很简单，但是有一个小坑：测试用例 TestOnePartition4B 的测试逻辑是：一共有5个服务器，先选一个领导者，然后将该领导者变成少数派。然后再向多数派中添加新的数据。这里有一个特别小的坑：如果没有设置最大的重试次数，那么客户端会不断的向少数派中的领导者发送请求，而多数派中的领导者则一直无法处理客户端的请求。添加了最大重试次数以后就可以过了这个用例。

此外，还有一个关键细节：在错误处理逻辑中，必须准确区分操作的“初始尝试”与“后续重试”——若首次请求因版本冲突失败应返回 ErrVersion，而重发过程中的冲突则必须返回 ErrMaybe 以表示状态不确定。在单服务器场景下，简单的局部变量即可记录发送次数；但在多服务器（如 Raft）集群中，如果重试计数的生命周期仅限制在*单个服务器*的循环内部，那么每当发生 Leader 切换或网络分区并尝试下一个服务器时，计数器都会被重置。这会导致原本的重发请求被误判为首次请求，从而无法准确识别该操作是否已被之前的服务器成功应用。因此，必须将重试计数器的作用域提升至整个操作的生命周期（全局粒度），确保计数在跨服务器重试时保持连续递增，从而严格保证分布式系统下状态判断的准确性。



