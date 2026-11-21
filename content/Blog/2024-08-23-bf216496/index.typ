#import "../../index.typ": template, tufted
#show: template.with(title: "使用 OpenSTL完成模型训练与评估")

项目地址：#link("https://github.com/chengtan9907/OpenSTL")[github]

主要的步骤：

+ 数据的预处理：将原始的视频格式转换成 `.npy` 格式。这种格式是 python 中常见的数值数组存储格式，可以更高效地存储与读取大量数值数据
+ 自定义数据使用： 展示如何在 OpenSTL 框架中导入和使用自定义的数据集。这对于研究者使用自己的特定数据集很有帮助。
+ 模型训练和评估： 利用 OpenSTL 提供的工具和 API 来训练时空学习（STL）模型，并对模型性能进行评估。
+ 结果可视化： 将模型预测的视频帧进行可视化处理。这包括生成 `.gif` 动图或完整视频，以直观地展示模型的预测效果。

== 制作数据集
在预测时，通常要使用以下的步骤：

定义两个参数：`pre_seq_length` 与 `aft_seq_length`。其作用分别是：观察的帧数（历史的帧数）与未来的帧数（要预测的帧数）

以下是从视频中均匀采样指定数量的帧的函数：

```python
import cv2
import numpy as np
import os

def sample_frames(video_path, num_frames=20):
    """
    从视频中均匀采样指定数量的帧。

    参数:
    video_path (str): 视频文件的路径
    num_frames (int): 要采样的帧数，默认为20

    返回:
    np.array: 包含采样帧的NumPy数组，形状为(num_frames, height, width, channels)
    """
    # 读取视频
    video = cv2.VideoCapture(video_path)
    # 获取视频总帧数
    total_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # 在视频总帧数范围内均匀生成采样帧的索引
    frame_idxs = np.linspace(0, total_frames-1, num_frames, dtype=int)
    
    frames = []
    for idx in frame_idxs:
        # 设置视频读取位置到指定帧
        video.set(cv2.CAP_PROP_POS_FRAMES, idx)
        # 读取该帧
        _, frame = video.read()
        # 可以在这里添加frame的resize操作，如果需要的话
        # frame = cv2.resize(frame, (height, width))
        frames.append(frame)
    
    # 释放视频对象
    video.release()
    
    # 将采样的帧堆叠成一个NumPy数组并返回
    return np.stack(frames)

def process_folder(folder_path, pre_slen=10, aft_slen=10, suffix='.avi'):
    """
    处理指定文件夹中的所有视频，采样帧并进行数据处理。

    参数:
    folder_path (str): 包含视频文件的文件夹路径
    pre_slen (int): 前半部分视频的帧数，默认为10
    aft_slen (int): 后半部分视频的帧数，默认为10
    suffix (str): 视频文件的后缀名，默认为'.avi'

    返回:
    tuple: 包含两个NumPy数组，分别是前半部分和后半部分的处理后的视频数据
    """
    # 获取文件夹中所有的视频
    videos = []
    files = os.listdir(folder_path)
    for file in files:
        video_path = os.path.join(folder_path, file)
        # 检查文件是否为指定后缀的视频文件
        if os.path.isfile(video_path) and file.endswith(suffix):
            # 对每个视频进行采样
            video = sample_frames(video_path, pre_slen + aft_slen)
            videos.append(video)
    
    # 将所有视频的帧堆叠起来，并调整维度顺序
    # 最终形状为 (num_videos, num_frames, channels, height, width)
    data = np.stack(videos).transpose(0, 1, 4, 2, 3)

    # 如果数据范围在[0, 255]，则将其缩放到[0, 1]
    if data.max() > 1.0:
        data = data.astype(np.float32) / 255.0

    # 返回前半部分和后半部分的数据
    return data[:, :pre_slen], data[:, pre_slen:]
```

`np.linspace` 的作用是创建等间距的数字序列。其作用是在指定的区间内生成均匀分布的数值数组。

`np.stack` 的作用是沿着新轴将一系列数组堆叠起来。由于使用 `cv2.imread()` 或 `cv2.VideoCapture().read()` 读取图像或视频帧时，返回的是 NumPy 数组。所以可以使用这个函数将其堆叠起来。

之后，可以使用以下的函数，完成对数据集的制作与保存

```python
# 导入pickle模块，用于序列化和反序列化Python对象
import pickle

# 初始化一个空字典，用于存储数据集
dataset = {}

# 定义包含数据集文件夹名称的列表
folders = ['train', 'val', 'test']

# 遍历每个文件夹
for folder in folders:
    # 调用process_folder函数处理每个文件夹，返回数据和标签
    # 参数pre_slen和aft_slen用于指定序列长度，suffix用于指定文件后缀
    data_x, data_y = process_folder(folder, pre_slen=pre_seq_length, aft_slen=aft_seq_length, suffix='.avi')
    
    # 将处理后的数据和标签存储在字典中，键名为'X_'或'Y_'加上文件夹名称
    dataset['X_' + folder] = data_x
    dataset['Y_' + folder] = data_y

# 将数据集保存为pkl文件
with open('dataset.pkl', 'wb') as f:
    # 使用pickle模块将'dataset'对象序列化，并写入文件
    pickle.dump(dataset, f)
```

`pickle` 模块可以序列化与反序列化一个 python 对象。

== 加载数据集
通过以上代码，可以得知，本地目录下 `dataset.pkl` 存放的是一个数据集，所以可以使用 `pickle` 从本地中加载这个数据集。

```python
import pickle

# 加载数据集
# 打开名为'dataset.pkl'的文件，模式为读取二进制('rb')
with open('dataset.pkl', 'rb') as f:
    # 使用pickle模块反序列化文件内容，加载到'dataset'对象中
    dataset = pickle.load(f)

# 从数据集中提取训练数据和标签
train_x, train_y = dataset['X_train'], dataset['Y_train']

# 打印训练数据的形状
print(train_x.shape)

# 形状说明为B x T x C x H x W
# B: 样本数量
# T: 每个样本中的帧数
# C: 每帧的通道数
# H: 每帧的高度
# W: 每帧的宽度
```

对于已经加载好的数据集，可以使用 `show_video_line` 函数来进行可视化处理

```python
from openstl.utils import show_video_line
# show the given frames from an example

example_idx = 0
show_video_line(train_x[example_idx], ncols=pre_seq_length, vmax=0.6, cbar=False, out_path=None, format='png', use_rgb=True)
```

这个函数的定义与作用如下：

```python
def show_video_line(data, ncols, vmax=0.6, vmin=0.0, cmap='gray', norm=None, cbar=False, format='png', out_path=None, use_rgb=False):
    """
    生成并显示视频序列的图像

    参数:
    data: 包含视频帧的数组
    ncols: 要显示的列数（即视频帧数）
    vmax: 颜色映射的最大值 (默认 0.6)
    vmin: 颜色映射的最小值 (默认 0.0)
    cmap: 颜色映射 (默认 'gray')
    norm: 归一化对象 (默认 None)
    cbar: 是否显示颜色条 (默认 False)
    format: 输出图像格式 (默认 'png')
    out_path: 输出图像路径 (默认 None)
    use_rgb: 是否使用RGB颜色空间 (默认 False)
    """
```

== 自定义数据集
对于实际的视频预测，一般使用 `float32` 来表示帧，并将其值限制在 $\[ 0 \, 1 \]$ 之间。其优势有：

+ 浮点数据更适合神经网络的处理与优化。
+ 归一化到 $\[ 0 \, 1 \]$ 满园有助于模型的数值稳定性与收敛性。

以下是常见的模板

```python
class CustomDataset(Dataset):
def __init__(self, X, Y, normalize=False, data_name='custom'):
    super(CustomDataset, self).__init__()
    self.X = X  # 输入数据
    self.Y = Y  # 标签数据
    self.mean = None  # 用于存储数据的平均值
    self.std = None   # 用于存储数据的标准差
    self.data_name = data_name  # 数据集的名称

    if normalize:
        # 如果需要归一化，计算并应用均值和标准差
        mean = data.mean(axis=(0, 1, 2, 3)).reshape(1, 1, -1, 1, 1)
        std = data.std(axis=(0, 1, 2, 3)).reshape(1, 1, -1, 1, 1)
        data = (data - mean) / std    # 这样就可以使数据的分布大致以 0 为中心，标准差为 1。
        self.mean = mean
        self.std = std

def __len__(self):
    # 返回数据集的长度
    return self.X.shape[0]

def __getitem__(self, index):
    # 返回指定索引的数据项和标签
    data = torch.tensor(self.X[index]).float()
    labels = torch.tensor(self.Y[index]).float()
    return data, labels
```

接下来就可以使用自定义数据集来加载数据了

```python
batch_size = 1

X_train, X_val, X_test, Y_train, Y_val, Y_test = dataset['X_train'], dataset['X_val'], dataset['X_test'], dataset['Y_train'], dataset['Y_val'], dataset['Y_test']

train_set = CustomDataset(X=X_train, Y=Y_train)
val_set = CustomDataset(X=X_val, Y=Y_val)
test_set = CustomDataset(X=X_test, Y=Y_test)

dataloader_train = torch.utils.data.DataLoader(train_set, batch_size=batch_size, shuffle=True, pin_memory=True)

dataloader_val = torch.utils.data.DataLoader(val_set, batch_size=batch_size, shuffle=True, pin_memory=True)

dataloader_test = torch.utils.data.DataLoader(test_set, batch_size=batch_size, shuffle=True, pin_memory=True)
```

== 训练与评估
在训练开始前，要先设置一些超参数

首先设置 `epoch`，一般来说，要将 `epoch` 设置成 100 或更高。之后用户需要加载一个时空预测学习模型。以 `MetaVP` 模型为例，其比较重要的参数有：`N_S`、`N_T`、`hid_S`、`hid_T` 和 `model_type`。可以通过配置文件来加载，也可以通过自定义来设置。

```python
custom_training_config = {
    'pre_seq_length': pre_seq_length,
    'aft_seq_length': aft_seq_length,
    'total_length': pre_seq_length + aft_seq_length,
    'batch_size': batch_size,
    'val_batch_size': batch_size,
    'epoch': 3,
    'lr': 0.001,  
    'metrics': ['mse', 'mae'],
  
    'ex_name': 'custom_exp',
    'dataname': 'custom',
    'in_shape': [10, 3, 32, 32],
}

  

custom_model_config = {
    # For MetaVP models, the most important hyperparameters are:
    # N_S, N_T, hid_S, hid_T, model_type
    'method': 'SimVP',
    # Users can either using a config file or directly set these hyperparameters
    # 'config_file': 'configs/custom/example_model.py',
    # Here, we directly set these parameters
    'model_type': 'gSTA',
    'N_S': 4,
    'N_T': 8,
    'hid_S': 64,
    'hid_T': 256
}
```

```python
from openstl.api import BaseExperiment
from openstl.utils import create_parser, default_parser
  
args = create_parser().parse_args([])
config = args.__dict__
  
# update the training config
config.update(custom_training_config)
# update the model config
config.update(custom_model_config)
# fulfill with default values
default_values = default_parser()
for attribute in default_values.keys():
    if config[attribute] is None:
        config[attribute] = default_values[attribute]
  
exp = BaseExperiment(args, dataloaders=(dataloader_train, dataloader_val, dataloader_test), strategy='auto')
```

设置好了超参数了以后就可以训练模型了

```python
print('>'*35 + ' training ' + '<'*35)
exp.train()
  
print('>'*35 + ' testing  ' + '<'*35)
exp.test()
```

== 可视化
可以通过使用 `OpenSTL` 提供的 `show_video_line` 与 `show_gif_multiple` 函数，从而实现可视化输入，真实值和预测帧，同时生成 gif。

```python
import numpy as np
from openstl.utils import show_video_line
  
# show the given frames from an example
inputs = np.load('./work_dirs/custom_exp/saved/inputs.npy')
preds = np.load('./work_dirs/custom_exp/saved/preds.npy')
trues = np.load('./work_dirs/custom_exp/saved/trues.npy')
  
example_idx = 0
show_video_line(trues[example_idx], ncols=aft_seq_length, vmax=0.6, cbar=False, out_path=None, format='png', use_rgb=True)
```

与

```python
example_idx = 0

show_video_line(preds[example_idx], ncols=aft_seq_length, vmax=0.6, cbar=False, out_path=None, format='png', use_rgb=True)
```

以下是生成 gif 的示例

```python
from openstl.utils import show_video_gif_multiple
  
example_idx = 0
show_video_gif_multiple(inputs[example_idx], trues[example_idx], preds[example_idx], use_rgb=True, out_path='example.gif')
```

= 好用的函数
```
x = rearrange(x, 'b t c h w -> b c t h w')
```

这行代码使用了 `einops` 库中的 `rearrange` 函数。`rearrange` 函数用于重新排列张量的维度。它接受两个主要参数：

- 第一个参数是要重排的张量（这里是~`x`）
- 第二个参数是一个字符串，描述了如何重排维度

参数解释：`'b t c h w -> b c t h w'`

- 箭头左边~`'b t c h w'`~描述了输入张量的当前维度顺序
- 箭头右边~`'b c t h w'`~描述了期望的输出张量的维度顺序

这个库会自动处理层的 `reshape` 与 `permute` 操作。
