#import "../../index.typ": template, tufted
#show: template.with(title: "arch linux安装nvidia驱动")

#quote(block: true)[
该笔记用于记录我在arch上安装nvidia驱动的过程。

写该笔记时已安装完成，在安装过程中没有做记录，因此该笔记可能会有遗漏。

本笔记的唯一参考资料：#link("https://wiki.archlinuxcn.org/wiki/NVIDIA")[arch linux 中文维基]，如果该笔记与维基有出入，以维基为准。
]

= 下载驱动如果显卡的型号为GeForce 930 起、10 系至 20 系、 Quadro / Tesla / Tegra K-系列以及更新的显卡（NV110 以及更新的显卡家族）及以上，则可以安装`nvidia`驱动
```
sudo pacman -S nvidia nvidia-utils nvidia-settings 
```

= 禁用`nouveau`模块
+ 确保内核在早启动阶段不会加载

- 修改`/etc/mkinitcpio.conf`：

```bash
sudo vim /etc/mkinitcpio.conf
```

- 查找`HOOKS=(base udev autodetect modconf keyboard keymap kms consolefont block filesystems fsck)`这一行后，删除`kms`，使得修改后的内容如下： `HOOKS=(base udev autodetect modconf keyboard keymap consolefont block filesystems fsck)`

- 执行`sudo mkinitcpio -P`

```bash
sudo mkinitcpio -P
```

#block[
#set enum(numbering: "1.", start: 2)
+ 修改内核参数（双重禁用）
]

我使用的是`grub`作为引导程序，同时还使用`btrfs + timeshift`作为系统的备份方案，因此修改内容参数这里的内容可能会有所不同

- 修改`/etc/default/grub`的内容

```bash
sudo vim /etc/default/grub
```

- 找到 `GRUB_CMDLINE_LINUX_DEFAULT` 行，并在引号内添加 `nouveau.modeset=0`。

修改后的内容如下：`GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nouveau.modeset=0"`

- 更新`grub`的信息

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#strong[以下内容可能有所不同，请根据自己的情况来操作（作用：刷新引导程序中的配置）]

如果你的系统引导分区位于 `/dev/nvme0n1p1`，则使用 Linux 中的 `grub-mkconfig` 命令不会真正改变引导程序的配置。

- 使用`root`用户

```bash
su
```

- 挂载`/dev/nvme0n1p1`到`/mnt`文件夹下

```bash
mount /dev/nvme0n1p1 /mnt
```

- 将更新后的`grub`信息复制到系统的引导程序中

```bash
cp -a /boot/* /mnt
```

- 卸载`/dev/nvme0n1p1`

```bash
umount /dev/nvme0n1p1
```

= 重启
```bash
reboot
```

= 可能的问题
如果重启以后发现进入不了系统，则要启用DRM 内核级显示模式。启用的方法也很简单，使用上文所示的方法，修改内核参数：添加 `nvidia_drm.modeset=1`

- 修改`/etc/default/grub`的内容

```bash
sudo vim /etc/default/grub
```

- 找到 `GRUB_CMDLINE_LINUX_DEFAULT` 行，并在引号内添加 `nvidia_drm.modeset=1`。

修改后的内容如下：`GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nouveau.modeset=0 nvidia_drm.modeset=1"`。#strong[之前添加的参数也要写上]。

- 更新`grub`的信息

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#strong[刷新grub的信息到系统引导程序目录下]

如上文方法所示。

= 验证安装
+ nvidia方式

```bash
nvidia-smi
```

如果成功打印信息，则成功

#block[
#set enum(numbering: "1.", start: 2)
+ linux内核方式
]

```
lspci -k | grep -A 2 -E "(VGA|3D)"
```

如果出现：`Kernel driver in use: nvidia`，则成功。
