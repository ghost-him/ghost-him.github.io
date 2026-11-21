#import "../../index.typ": template, tufted
#show: template.with(title: "训练进度监视器")

用于深度学习中监测任务的运行时间

代码如下：

```python
import time
from datetime import datetime, timedelta
  
class ProgressMonitor:
    def __init__(self, total_count):
        self.total_count = total_count
        self.start_time = time.time()
        self.count = 0
  
    def format_time(self, seconds):
        return str(timedelta(seconds=int(seconds)))
  
    def format_datetime(self, timestamp):
        return datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M:%S")
  
    def step(self, message=""):
        self.count += 1
        current_time = time.time()
        elapsed_time = current_time - self.start_time
  
        if self.count > 0:
            time_per_item = elapsed_time / self.count
            remaining_items = self.total_count - self.count
            estimated_time_left = time_per_item * remaining_items
            estimated_completion_time = current_time + estimated_time_left
  
            progress = (self.count / self.total_count) * 100
  
            status = (
                f"Progress: {self.count}/{self.total_count} ({progress:.2f}%)\n"
                f"Current time: {self.format_datetime(current_time)}\n"
                f"Elapsed time: {self.format_time(elapsed_time)}\n"
                f"Estimated time remaining: {self.format_time(estimated_time_left)}\n"
                f"Estimated completion time: {self.format_datetime(estimated_completion_time)}\n"
            )
  
            if message:
                status += f"Message: {message}\n"
  
            print(status)
        else:
            print("Started monitoring progress.")
  
    def finish(self):
        end_time = time.time()
        total_time = end_time - self.start_time
        print(f"\nTask completed in {self.format_time(total_time)}")
```

使用方法如下：

```python
from monitor import ProgressMonitor
import time
  
epochs = 10
monitor = ProgressMonitor(epochs)
for i in range(epochs):
    time.sleep(5) # 模型训练任务
  
    monitor.step('111') # 在每一轮的结尾记录，可自定义输出，比如损失率，准确率等
monitor.finish()
```

输出如下：

```
Progress: 1/10 (10.00%)
Current time: 2024-09-18 14:46:12
Elapsed time: 0:00:05
Estimated time remaining: 0:00:45
Estimated completion time: 2024-09-18 14:46:57
Message: 111

...

Progress: 10/10 (100.00%)
Current time: 2024-09-18 14:46:57
Elapsed time: 0:00:50
Estimated time remaining: 0:00:00
Estimated completion time: 2024-09-18 14:46:57
Message: 111


Task completed in 0:00:50
```
