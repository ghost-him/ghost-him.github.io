#import "../../index.typ": template, tufted
#show: template.with(title: "SimVP-- Simpler yet Better Video Prediction")

论文地址：#link("https://arxiv.org/abs/2206.05099")[arxiv]

= 摘要
作者认为，现有的CNN，RNN，Transformer 之类的视频预测领域的模型都过于复杂了，作者想要找到一个简单的方式，同时可以达到与之相当的效果。

作者提出了 SimVP，这是一个简单的视频预测模型，完全基于 CNN 构建，通过均方误差（MSE）损失函数以端到端的方式进行训练。在不引入任何额外技巧与复杂策略的情况下，就可以实现最先进的性能。

= 正文
深度视频预测模型当前主要有 4 类，如图所示：

#figure(image("assets/20240828134220-5868ff7b.webp"))

分别是:

+ RNN-RNN-RNN
+ CNN-RNN-CNN
+ CNN-ViT-CNN
+ CNN-CNN-CNN

在纯 CNN 基础模型方面，要提高准确度，通常要使用各种技术，但是作者探索出了一个简单模型的新高度。

== 问题描述
给定一个在时间 $t$ 的包含过去 $T$ 帧的视频序列 $X_(t \, T) = { x_i }_(t - T + 1)^t$，而目标是在时间 $t$ 预测未来的序列 $Y_(t \, T') = { x_i }_t^(t + T')$。该序列包含接下来的 $T'$ 帧，其中 $x_i$ 是一个具有通道数 $C$，高度 $H$ 和宽度 $W$ 的图像。形式上，预测模型是一个映射 $F_Theta : X_(t \, T) - > Y_(t \, T')$，其中的可学习参数 $Theta$ 通过以下公式优化：

$ Theta^(*) = arg min_Theta cal(L) \( cal(F)_Theta \( bold(X)_(t \, T) \) \, bold(Y)_(t \, T') \) $ $L$ 可以是各种损失函数。

== 模型架构
#figure(image("assets/20240828135852-474b7c51.webp"))

SimVP 由一个编码器，一个翻译器，一个解码器组成。

- 编码器用于提取空间特征
- 翻译器学习时间演变
- 解码器则整合时间信息以预测未来帧

=== 编码器
编码器堆叠了 $N_s$ 个 ConvNormReLU 块（Conv2d+LayerNorm+LeakyReLU）来提取空间特征，即在 （H，W）上进行 C 通道的卷积。隐藏特征表示为：

$ z_i = sigma \( upright(L a y e r N o r m) \( upright(C o n v 2 d) \( z_(i - 1) \) \) \) \, 1 lt.eq i lt.eq N_s $

其中输入 $z_(i - 1)$ ​和输出 $z_i$ 的形状分别为 $\( T \, C \, H \, W \)$ 和 $\( T \, C \, hat(H) \, hat(W) \)$。

=== 翻译器
翻译器使用 $N_t$ 个 Inception 模块来学习时间演变，即在 $\( H \, W \)$ 上进行 $T * C$ 通道的卷积。

Inception 模块由一个 `1*1` 大小的 `Conv2d` 后接并行的 `GroupConv2d` 操作符完成。隐藏特征表示为： $ z_j = upright(I n c e p t i o n) \( z_(j - 1) \) \, N_s < j lt.eq N_s + N_t $ 其中输入 $z_(j - 1)$ 和输出 $z_j$ 的形状分别为 $\( T * C \, H \, W \)$ 和 $\( hat(T) * hat(C) \, H \, W \)$。

=== 解码器
解码器使用 $N_s$ 个 `unConvNormReLU` 块（ConvTranspose2d+GroupNorm+LeakyReLU）来重建真实帧，在（H, W）上进行 C 通道的卷积。隐藏特征表示为

\$\$
z\_{k} = \\sigma (\\mathrm {GroupNorm} (\\mathrm {unConv2d}(z\_{k-1}))),\\\\ N\_s+N\_t \< k \\leq 2N\_s + N\_t
\$\$

其中，输入 $z_(k - 1)$ 与输出 $z_k$ 的形状分别为 $\( T \, hat(C) \, hat(H) \, hat(W) \)$ 与 $\( T \, C \, H \, W \)$。使用 `ConvTransposed2d` 作为 `unConv2d` 操作符。

== 模型评估
使用均方误差（MSE）、平均绝对误差（MAE）、结构相似性指数（SSIM）和峰值信噪比（PSNR）来评估预测质量。

在五个数据集上进行实验，从而来进行评估，如下所示：

#figure(image("assets/20240828142638-525226bf.webp"))

=== 性能评估
#figure(image("assets/20240828143006-788189b6.webp"))

可以看到，SimVP、PhyDNet和CrevNet显著优于先前的方法，MSE降低达到42%。然而，SimVP比PhyDNet和CrevNet简单得多，没有使用RNN、LSTM或复杂模块。

=== 训练时间
#figure(image("assets/20240828143140-d65ed5dc.webp"))

由上可知，SimVP 的训练过程比其他方法快得多，所以 SimVP 可以更容易地使用与扩展。

=== 翻译器的使用
使用 RNN 和 Transformer 替换了 CNN ，再进行测试。使用了不同模型中的翻译器来，测试后得到以下结果：

#figure(image("assets/20240828143526-883b69a2.webp"))

#figure(image("assets/20240828143834-030ae2ea.webp"))

可以得出结论：

+ CNN和RNN在有限的计算成本下实现了最先进的性能。
+ 如果模型容量足够，RNN在长期内收敛速度更快。
+ CNN训练更稳健，在大学习率下不会剧烈波动。
+ 在类似的资源消耗下，Transformer在我们的SimVP框架中没有优势。

=== 评判能否到 SOTA 水平
#figure(image("assets/20240828144532-d5c4c6e7.webp"))

SimVP可以在轻量级其次上达到 SOTA 结果。此外，与 PhyDNet 相比，SimVP 的训练时间更短。

#figure(image("assets/20240828144656-1fa6238a.webp"))

可以看到在不同的数据集上有良好的泛化能力。

#figure(image("assets/20240828144751-878e7373.webp"))

可以看到，SimVP 在灵活预测长度的情况下扩展良好。SimVP 达到了最新的性能。

== 消融实验
=== 哪个架构的设计对于性能有关键的作用？
#figure(image("assets/20240828145309-883c02ed.webp"))

由上图 1-4 可知：空间UNet、时间UNet、分组卷积和分组归一化都能带来性能提升，其重要性排序为：分组卷积 \> 分组归一化 ≈ 空间UNet ≈ 时间UNet。

=== 卷积核对性能的影响
由上图 5-8 可知，随着核大小的增加，可以看到显著的性能提升。通过将模型 8 的隐藏维度加倍构建于模型 9，这种提高可以进一步增强。

=== 编码器，转换器，解码器的角色
#figure(image("assets/20240828145550-ec251bb2.webp"))

- 转换器主要关注预测物体的位置和内容。
- 解码器负责优化前景物体的形状。
- 编码器可以通过空间UNet连接消除背景误差。
