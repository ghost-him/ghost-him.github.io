#import "../../index.typ": template, tufted
#show: template.with(title: "U-Net网络结构")

笔记来源：#link("https://www.bilibili.com/video/BV1Vq4y127fB/")[bilibili]

U-Net 网络的结构

#figure(image("assets/20240906130655-051b7c9b.webp"))

U-Net 是一个 encoder-decoder 结构。Encoder 对应着 u 型左半部分的结构，该部分的作用是特征提取以及下采样。Decode 对应着 u 型的右半部分，内容为一系列上采样。

对于左侧，作者将其称为 contracting path，对于右侧，作者将其称为 expansive path。

每一次下采样时，图像的尺寸为输入图像的一半，而通道数翻倍，同理，每一次上采样，图像的为输入图像的 2 倍，通道数减半。

将图片从左侧复制到右侧时，使用 concat 完成拼接，并使用 CNN 完成图像通道数的减半（拼接后，通道数为 2 倍）。

在当前最新的实现中，U-Net 网络通常会使用 padding，这样可以确保经过 CNN 的图像后不会发生尺寸的变化，同时，会添加一个 BN 层。
