#import "../../index.typ": template, tufted
#show: template.with(title: "在windows环境中使用vcpkg+cmake完成类linux的c++开发环境配置")

由于众所周知的原因，在 windows 下进行 `c++` 开发是一件极其痛苦的事情。我也多次因为无法在 windows 下配置开发环境而转向 linux 开发。我在最近移植我的 linux 应用时，发现了一个在 windows 下非常方便的 `c++` 安装包管理器。这个就是 vcpkg。通过使用 vcpkg，可以在 windows 上实现 linux 一样的开发环境。

本篇文章旨在为各位提供一个新的环境配置思路。我本人也是刚开始研究这个软件，难免会有众多疏忽。

=== 1. 安装 vcpkg 与 cmake
首先要安装 vcpkg 与 cmake，安装的过程已经有很多人写了相应的文章了，这里就不赘述了。

=== 安装对应的库
安装库的命令是

```
vcpkg install [库的名字]
```

这里给几个示例：

==== 安装 `trantor` 库
```bash
vcpkg install trantor
```

==== 安装 `openssl` 库
```bash
vcpkg install openssl
```

=== 整合第三方库
使用命令 `vcpkg integrate install`。这个命令的作用是：配置vcpkg以便在Visual Studio项目中自动包含库文件。执行该命令后，通过vcpkg安装的库将被集成到Visual Studio的项目中，使得开发者无需手动配置库路径，可以直接在项目中包含和使用这些库。这简化了项目配置过程，提高了开发效率。

在运行后，可以看到提示：

```
CMake projects should use: "-DCMAKE_TOOLCHAIN_FILE=C:/software/vcpkg-2024.01.12/scripts/buildsystems/vcpkg.cmake"

All MSBuild C++ projects can now #include any installed libraries. Linking will be handled automatically. Installing new libraries will make them instantly available.
```

这里的意思就是，如果我们使用 cmake。则在构建时，应该添加上 `-DCMAKE_TOOLCHAIN_FILE=C:/software/vcpkg-2024.01.12/scripts/buildsystems/vcpkg.cmake` 。\*\* 每个人的 vcpkg 的安装目录均不同，所以要按照自己的提示来写！\*\*

=== 修改 `CMakeLists.txt`
每次添加完一个第三方库都要在 cmake 中添加 vcpkg 所给出的安装信息。

以 openssl 为例。

运行 `vcpkg install openssl`。以后，可以看到给出的信息：

```
PS C:\software\vcpkg-2024.01.12> .\vcpkg.exe install openssl
warning: In the September 2023 release, the default triplet for vcpkg libraries changed from x86-windows to the detected host triplet (x64-windows). For the old behavior, add --triplet x86-windows . To suppress this message, add --triplet x64-windows .
Computing installation plan...
The following packages are already installed:
    openssl:x64-windows@3.2.0#2
openssl:x64-windows is already installed
Total install time: 275 us
The package openssl is compatible with built-in CMake targets:

    find_package(OpenSSL REQUIRED)
    target_link_libraries(main PRIVATE OpenSSL::SSL OpenSSL::Crypto)

PS C:\software\vcpkg-2024.01.12>
```

这里的意思是如果使用 cmake，则要添加

```
find_package(OpenSSL REQUIRED)
target_link_libraries(main PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

（这里可以发现，使用 cmake 与 linux 基本一致，很方便，也不用自己去设置环境变量）

=== 编译运行
```
cmake -B build -DCMAKE_TOOLCHAIN_FILE=C:/software/vcpkg-2024.01.12/scripts/buildsystems/vcpkg.cmake

cmake --build build
```

完成。

=== 从头到尾的一个示例
安装 openssl（其它库的安装与这个库的安装流程一致）

```
vcpkg install openssl
```

整合

```
vcpkg integrate install
```

修改

```
cmake_minimum_required(VERSION 3.5)
project(vcpkgTest)

# Create the library
add_executable(common main.cpp)

# Find required packages
find_package(OpenSSL REQUIRED)

# Link with found packages
target_link_libraries(common PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

编写测试代码

`main.cpp`：（生成一对 ecc 公钥与私钥）

```cpp
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/err.h>
#include <iostream>
int main()
{
    std::string publicKey, privateKey;
    EC_KEY *ecKey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1); // 使用P-256曲线
    if (ecKey != nullptr && EC_KEY_generate_key(ecKey))
    {
        BIO *pub = BIO_new(BIO_s_mem());
        BIO *priv = BIO_new(BIO_s_mem());
        if (PEM_write_bio_EC_PUBKEY(pub, ecKey) && PEM_write_bio_ECPrivateKey(priv, ecKey, nullptr, nullptr, 0, nullptr, nullptr))
        {
            size_t pubLength = BIO_pending(pub);
            size_t privLength = BIO_pending(priv);
            publicKey.resize(pubLength + 1);
            privateKey.resize(privLength + 1);
            BIO_read(pub, (void *)publicKey.c_str(), pubLength);
            BIO_read(priv, (void *)privateKey.c_str(), privLength);
            
            publicKey[pubLength] = '\0';
            privateKey[privLength] = '\0';
        }
        BIO_free_all(pub);
        BIO_free_all(priv);
    }
    EC_KEY_free(ecKey);
    std::cout << publicKey << " | " << privateKey << std::endl;
    return 0;
}
```

构建

```
cmake -B build -DCMAKE_TOOLCHAIN_FILE=C:/software/vcpkg-2024.01.12/scripts/buildsystems/vcpkg.cmake
```

编译

```
cmake --build build
```
