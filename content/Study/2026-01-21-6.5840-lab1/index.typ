#import "../../index.typ": template, tufted
#show: template.with(title: "6.5840 2025 Spring Lab1")


= 记录一下 6.5840 2025 Spring Lab1 的过程

== 实验要求

#tufted.margin-note[
  该实验的地址如下：#link("https://pdos.csail.mit.edu/6.824/labs/lab-mr.html")[mit 6.824] \
  实验要求的部分为原文翻译并做适当的修改
]

要求：要求实现一个分布式的 MapReduce，包含两个程序，一个协调器（Coordinator）#footnote[Coordinator 结点就是论文中的 Master 结点。但是这个是我为实验写的笔记，所以我选择了与实验中相同的名词]，多个工作节点（worker）。

+ 将会只有一个协调器进程以及一个或更多的工作进程同时执行
+ 工作进程将会通过 RPC 来与协调器沟通
+ 每一个工作进程的的处理流程如下：
  + 在一个循环中
  + 向协调器请求一个任务
  + 从一个或多个文件中读取任务的输入
  + 执行该任务
  + 将任务的结果输出到一个或多个文件中
  + 再一次向协调器请求一个新的任务
+ 对于协调器来说，如果一个工作进程在一定的时间内#footnote[在本实验中是10秒钟]没有完成该任务，那么就将相同的任务给另一个工作进程中

== 笔记内容

#tufted.margin-note[
  这个MapReduce的论文的地址如下: #link("https://pdos.csail.mit.edu/6.824/papers/mapreduce.pdf")[mit]
]

MapReduce是一个用于处理和生成大规模数据集的一种编程模型。它可以让数千台机器同时工作，从而大大加速计算的速度。它主要处理的是那种单任务简单，但是数据量巨大的那种任务，比如单词统计，url 访问次数统计等等。

它一共有两个操作，一个是Map，一个是Reduce。这两个操作都需要由用户来写。它们的输入如下

```
map    (k1,v1) -> list (k2,v2)
reduce (k2,list(v2)) -> list (v2)
```

MapReduce的整体的处理流程如下#footnote[推荐去打开论文，对应 Figure 1: Execution overview 来理解]：

+ 用户程序中的 MapReduce 库首先将输入文件切分为 M 个分片，每个分片的大小通常为 16MB 到 64MB（用户可以通过可选参数进行控制）。然后，它在集群机器上启动该程序的多个副本。
+ 在这些程序副本中，有一个是特殊的——主节点（Coordinator）。其余的是工作节点（Workers），由 Coordinator 分配工作。共有 M 个 Map 任务和 R 个 Reduce 任务待分配。Coordinator 会挑选空闲的 Worker，并为每个 Worker 分配一个 Map 任务或 Reduce 任务。
+ 被分配了 Map 任务的 Worker 会读取对应输入分片的内容。它从输入数据中解析出键/值对（key/value pairs），并将每个对传递给用户定义的 Map 函数。Map 函数生成的中间键/值对会缓存在内存中。
+ 缓存的键值对会周期性地写入本地磁盘，并通过分区函数划分为 R 个区域。这些缓存在本地磁盘上的位置会被传回给 Coordinator，Coordinator 负责将这些位置转发给 Reduce Worker。
+ 当 Reduce Worker 收到 Coordinator 发来的位置信息后，它使用远程过程调用（RPC）从 Map Worker 的本地磁盘读取这些缓存数据。当 Reduce Worker 读取了所有的中间数据后，它会根据中间键进行排序，以便+ 将所有具有相同键的项组合在一起。排序是必要的，因为通常会有许多不同的键映射到同一个 Reduce 任务。如果中间数据量过大，内存无法容纳，则会使用外部排序。
+ Reduce Worker 遍历排序后的中间数据，对于遇到的每个唯一的中间键，它将该键及对应的中间值集合传递给用户定义的 Reduce 函数。Reduce 函数的输出会被追加到该 Reduce 分区的最终输出文件中。
+ 当所有的 Map 任务和 Reduce 任务都完成后，Coordinator 会唤醒用户程序。此时，用户程序中的 MapReduce 调用返回到用户代码中。

当然，MapReduce是会由多个机器共同组成的一个集群。那么机器越多，出故障的可能性就会越大。因此，MapReduce定义了一套容错机制：

如果是 Worker 出现了故障，那么当前 Worker 所做的工作会由 Coordinator 分配给其他的 Worker 做。Coordinator是怎么知道一个 Worker 有没有发生故障的呢？-> 通过心跳检测。

Worker 从全局文件系统（Global File System, GFS）中读取到了要处理的文件。Map 任务产生的中间数据存储在 Worker 的本地磁盘上，而不是 GFS。也正因此，当它发生故障以后，它已经处理好的数据无法被其他的机器读取到#footnote[因为机器是物理上隔离的，只有通过全局文件系统才能访问到其他机器处理后的文件。而 Worker 只要当处理完所有的文件以后，才可以将已经处理好的数据放到全局文件系统中]。所以新的 Worker 会重新读取输入，重新完成任务后再传到全局文件系统中。而 Reduce 任务可以不需要再次运行，因为 Reduce 任务的结果是直接保存到全局文件系统中的。

已完成的 Map 任务在发生故障时需要重新执行#footnote[论文中花了一小节讲述了: 大多数的 Map 与 Reduce 操作的运算符都是确定性的，所以可以通过再次运行来得到相同的结果]，因为它们的输出存储在失效机器的本地磁盘上，因此无法访问。而已完成的 Reduce 任务不需要重新执行，因为它们的输出存储在全局文件系统中。

如果是 Coordinator 出现了故障，那么只能在运行时周期性的检查点，然后发生故障后需要从检查点恢复。同时论文里也指出：“然而，考虑到只有一个 Coordinator，其失效的概率很低”

如果将 Map 阶段划分为 M 个部分，将 Reduce 阶段划分为 R 个部分，那么在理想状态下，M 与 R 都应该远大于工作机器的数量，这样 Coordinator 可以根据负载动态调整。但是也不能将 M 与 R 设置的过大，因为在一整个任务中， Coordinator 需要做出 $O(M + R)$ 次调度决策，同时需要保留 $O(M * R)$个状态#footnote[之所以需要保留 $O(M * R)$ 个状态，是因为 Coordinator要记录这 $M * R$ 个中间数据保存的位置与状态。每个 Map 任务完成后，会产生 R 个针对不同 Reduce 任务的分区文件，Coordinator 必须维护这些信息的映射，以便在 Reduce 阶段告知 Worker 去哪些机器的本地磁盘拉取数据。]。

对于因为各种原因#footnote[比如硬盘损坏，比如高温降频等]导致任务处理时间延长的 Worker，Coordinator 可以将该任务重新分配给其他的 Worker，两个机器同时运行，哪个先返回结果就采纳哪个的结果。通过这种机制，可以显著减少完成大型 MapReduce 的时间。

== 我的实现

以上就是 MapReduce 的核心处理流程，我也是边写代码边看论文边问ai才完全理解了。

```go
const (
	Idle       int = iota // 等待分配
	InProgress            // 正在处理
	Completed             // 已完成
)

// 描述一个任务
type TaskInfo struct {
	Status    int       // 当前任务的状态
	StartTime time.Time // 分配的时间（用于检测当前任务有没有超时）
}

type Coordinator struct {
	mu      sync.Mutex // 并发控制
	NMap    int        // map任务的个数（等于文件的个数）
	NReduce int        // reduce任务的个数（等于传入的值）
	Phase   int        // 0: map阶段 1: reduce阶段 2:完成

	MapTasks      []TaskInfo // 记录 map 任务的状态与开始的时间
	NMapTasksDone int        // 表示 map 完成的总数

	ReduceTasks      []TaskInfo // 记录reduce任务的状态与开始的时间
	NReduceTasksDone int        // 表示reduce完成的总数

	FileNames []string // 表示第i个Map任务处理哪个File
}


type WorkerRequest struct {
}

type WorkerFinish struct {
	Command string // 表示当前处理的操作是哪个
	TaskID  int    // 表示当前哪个任务完成了

}

type CoordinatorReply struct {
	Command  string // map: 调用 map 函数， reduce: 调用 reduce 函数 wait: 等待
	TaskID   int    // 表示该任务的编号
	NMap     int    // 表示 Map 的数量
	NReduce  int    // 表示 Reduce 的数量
	FileName string // map 阶段执行的文件的名字，reduce阶段不需要该信息
}

```

具体的实现细节就先不讲了，还不知道后面的实验会不会要改现在写好的代码呢。万一要改不就白写了==
