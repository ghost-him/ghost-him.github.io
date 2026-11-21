#import "../../index.typ": template, tufted
#show: template.with(title: "windows环境下安装gcc")

今天在配置 windows 环境下的开发环境，随手写一下安装记录，同时当做一个笔记。

以下是 `MinGW-w64` 的下载网址： https:/\/sourceforge.net/projects/mingw-w64/

在 `file` 目录下，我们可以看到 `MinGW-W64 GCC-8.1.0` 这个有好几个版本，这里简述一下各个版本的区别：

= `x86_64` 与 `i686`
`x86_64` 和 `i686` 是两种不同的计算机架构标识，它们代表了不同的指令集和处理器能力。

- #strong[x86\_64]是64位的，可以支持更多的内存，可以运行64位和32位的软件。目前主流的个人 pc 都是 64 位的。
- #strong[i686]是32位的，主要用于早期的 Intel 处理器，只能运行32位软件并且内存支持有限。

= `POSIX` 与 `Win32`
- #strong[POSIX]: 选择 POSIX 线程模型是为了更好的兼容性，尤其是如果你打算写的代码需要在 Linux 环境下编译和运行。POSIX 线程模型（pthread）是跨平台的，这意味着在编写线程相关的代码时，你可以使用一套相同的 API，这些 API 在 Linux 中也是可用的。因此，如果通用性是主要目标，POSIX 是一个更好的选择。
- #strong[Win32]: Win32线程模型更紧密地集成于 Windows 操作系统。如果主要关注的是在 Windows 上的性能和与 Windows 特定功能的集成，那么 Win32可能是更合适的选择。但是，这会牺牲掉与 Linux 的兼容性。

= `SEH` 与 `SJLJ`
- #strong[SEH (Structured Exception Handling)]: SEH 是 Windows 特有的异常处理机制。mingw-w64支持 SEH 的原因之一是它可以提供更好的性能和与 Windows 平台的集成。如果代码主要运行在 Windows 上，并且需要最大程度的性能和与 Windows 特性的兼容性，SEH 可能是更好的选择。
- #strong[SJLJ (SetJump/LongJump)]: SJLJ异常处理机制是一种更通用的机制，它在多种平台上都有支持。如果你的目标是跨平台的兼容性，那么SJLJ可能是更好的选择。SJLJ通常有更高的性能开销，但它的优势在于它在不同平台间提供了一致的异常处理机制。
