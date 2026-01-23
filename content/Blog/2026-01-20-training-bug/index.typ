#import "../../index.typ": template, tufted
#show: template.with(title: "training bug record")


= 单 epoch 训练时间逐渐变长的 bug 记录

前两天在训练一个模型，遇到这样的问题：模型在训练时，第 1 轮花费大约 6 小时，但是第 2 轮的训练就大概需要8小时，第 3 轮可能就会需要 10 小时，以此类推。整体就是训练时间越来越长，最后模型无法正确的训练下去。

我也查过gpu占用率，cpu占用率。感觉都没有什么问题。之后我又在想是不是在训练的时候内存瓶颈或硬盘瓶颈。后来忘记用了什么命令，发现都不是。我甚至还在想是不是因为电脑的温度太高导致降频了，但是在nvidia-smi里的温度记录也是正常的。

以下是当时的训练代码，对代码做了一些调整：

```python
def train(self, *, load_weights: Optional[str] = None, resume_weights: Optional[str] = None, resume_state: Optional[str] = None):
    # 省略加载和初始化代码...

    # 数据加载
    train_loader, val_loader = create_random_sr_loaders(...)
    has_validation = val_loader is not None

    for epoch in range(self.cfg.epochs):

        self.model.train()
        train_loss_sum = 0.0
        train_psnr_sum = 0.0
        train_ssim_sum = 0.0
        batch_count = 0

        for lr_img, hr_img in train_loader:
            lr_img = lr_img.to(self.device)
            hr_img = hr_img.to(self.device)
            sr_img = self.model(lr_img)
            total_loss, parts = self._compute_total_loss(sr_img, hr_img)

            self.opt.zero_grad()
            total_loss.backward()
            self.opt.step()

            metrics = self._compute_metrics(sr_img.detach(), hr_img)
            train_loss_sum += total_loss.item()
            train_psnr_sum += metrics['psnr']
            train_ssim_sum += metrics['ssim']
            batch_count += 1

        avg_train_loss = train_loss_sum / batch_count
        avg_train_psnr = train_psnr_sum / batch_count
        avg_train_ssim = train_ssim_sum / batch_count

        # 验证
        if has_validation and (epoch % self.cfg.val_every) == 0:
            self.model.eval()

            val_losses = []
            val_psnr = []
            val_ssim = []
            with torch.no_grad():
                for lr_img, hr_img in val_loader:
                    lr_img = lr_img.to(self.device)
                    hr_img = hr_img.to(self.device)
                    sr_img = self.model(lr_img)
                    total_loss, _ = self._compute_total_loss(sr_img, hr_img)
                    metrics = self._compute_metrics(sr_img, hr_img)
                    val_losses.append(total_loss.item())
                    val_psnr.append(metrics['psnr'])
                    val_ssim.append(metrics['ssim'])

            avg_loss = sum(val_losses) / len(val_losses)
            avg_psnr = sum(val_psnr) / len(val_psnr)
            avg_ssim = sum(val_ssim) / len(val_ssim)

            # 保存检查点等...
```

可以看到整体都是没有什么问题的，然后也整体也和以前的训练代码都差不多。

后来我才知道，原来是 psnr, ssim, lpips 这些指标，在每轮训练结束以后都需要重置，重置完了以后每轮的训练时间都是差不多的了。

```python
self.psnr.reset()
self.ssim.reset()
if self.lpips is not None:
    self.lpips.reset()
```

差不多就这样了喵，看到网上基本没人提到这个问题，就写下来记录一下喵
