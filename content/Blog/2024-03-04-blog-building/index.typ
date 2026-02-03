#import "../../index.typ": template, tufted
#show: template.with(title: "个人博客搭建指南")

= 2026/2/3 更新

该指南的搭建效果如下所示：#link("https://ghost-him.netlify.app")[https://ghost-him.netlify.app]。*并不是当前博客使用的模板*，如果想要使用当前博客的模板，可以访问：#link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[https://github.com/Yousa-Mirage/Tufted-Blog-Template]。

== 前提准备

搭建网站前，首先要确保你有以下的能力

- 使用linux基本的命令
- 会使用markdown语法（半小时即可学会）

== 购买域名与服务器

这一步其实可以直接用 github 来代替的。这样每年还可以省下一笔钱。使用github + hexo搭建网站的教程如下：#link("https://zhuanlan.zhihu.com/p/60578464")[链接]

我的域名和服务器都是在#link("https://cloud.tencent.com/")[腾讯云]上买的。

我买的是 `轻量应用服务器`，配置是 `2核2G4M`。当时的费用是 400 元 3 年。如果可以买 3 年，那最好直接买 3 年。第一买的时候会有首发优惠，之后续费的时候差不多 1 年就要 300 多了。买服务器的时候可以多对比几家，选个便宜的，国内的几家服务器商的优惠力度都比较大。

然后是选择域名，域名的价格由后缀决定，我的 `.com` 的后缀大概要 85 一年。可以选其他后缀的域名。域名的内容是自己定的，比如我的域名就是 `ghost-him`。买的是二级域名。比如：我买的是 `ghost-him.com`。有了二级域名以后就可以自己添加三级，四级域名，在域名管理商（如果是腾讯云，则是 #link("https://www.dnspod.cn/")[DNSpod]）里直接添加就可以了。比如：`kodo.ghost-him.com`。

== 备案

如果你买的服务器与域名是国内的，则要给服务器与域名备案。

买了域名以后，要先给域名实名认证。在域名的页面应该是可以看到认证的按钮的。

之后则是给域名备案，备案的教程：#link("https://cloud.tencent.com/document/product/243")[ICP 备案]

备案好以后，你就可以获得自己的一个 ICP 备案号，比如我的是: `苏ICP备2023005708号-1`。对域名进行备案的时候，我记得要求是要停止对域名的解析，如果通过腾讯云备案，那么腾讯云的工作人员会提前帮你审核一下的，如果有不满足要求的地方，会给你打电话提醒的。

域名备案结束以后，就可以使用域名解析到服务器 ip 上，并且可以通过域名访问服务器了。接下来就是公安备案，教程：#link("https://cloud.tencent.com/document/product/243/19142")[公安备案]

如果那个页面进不去，可以试试 ie 浏览器，我当时使用的是 edge 浏览器，然后页面出 bug 了。

备案好以后就可以得到网页的备案号。比如我的是：`苏公网安备 32040402000470号`

== 解析 dns 到 ip

如果是从腾讯云上买的，那么对应的域名管理商为 #link("https://www.dnspod.cn/")[DNSpod]。

登陆以后就可以看到以下的页面，然后点击 `解析` 按钮就可以进入管理页面，然后点 `添加记录` 就可以了。

- 主机记录：主机名，一般的为 `www`
- 记录类型：没有特殊要求就为 `A`，如果要改，那么会告诉你改成什么值的。
- 线路类型：默认
- 记录值：你的 ip 地址
- 权重：默认
- 优先级：默认
- TTL：默认

这样就可以设置 `www.ghost-him.com` 指向网站，`kodo.ghost-him.com` 指向自己的对象存储。（区别：主机名不一样，记录类型不一样，下文会讲）

== 选择一个适合自己的博客框架

现在常用的博客框架有：

- #link("https://hexo.io/zh-cn/index.html")[`hexo`]
- #link("https://cn.wordpress.org/")[`wordpress`]
- #link("https://vuepress.vuejs.org/zh/")[`vuepress`]
- #link("https://gitee.com/halo-dev/halo")[`halo`]
- ...

框架有很多种，可以去网上看看其他适合自己的。

博客分为静态网页与动态网页，github 上只能使用生成静态网页的框架，比如我现在使用的 `hexo` 框架。每个框架都有自己的优点与缺点，比如 `hexo` 框架只能在控制台上添加文章，现在与 `hexo-admin` 插件搭配后才能在页面上添加文章。而 `halo` 框架则提供了完整的管理页面。可以直接在网上编辑文章。

== hexo框架搭建指南

这里讲一下 hexo 框架的安装与使用教程。

=== 初始化hexo网站

进入服务器的控制台，输入

```bash
npm install -g hexo-cli
```

来安装 `hexo` 框架。如果没有 `npm` 则要自己安装一下 `npm`。

如果出现了以下类似的报错内容：

```bash
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules'
```

则说明是权限不够，加上`sudo`或使用`root`用户来执行即可。

```bash
sudo npm install -g hexo-cli
```

然后在一个指定的位置新建一个文件夹，用于存放网页的内容，比如我在 `~` 目录下新建一个文件夹 `blog` 来存放网页的相关信息

```bash
mkdir ~/blog
```

进入文件夹

```bash
cd ~/blog
```

安装初始化网页

```bash
hexo init .
npm install
```

这样就已经完成了`hexo`网站的初始化。

=== 常用的命令

常用的命令

==== 创建一个文章

```bash
hexo new [文章名字]
```

例：创建一个名字为`first_article`的文章

```bash
hexo new first_article
```

所有发布的文章都会存放在

```
./source/_posts
```

文件夹内

==== 生成文章的静态网页

```bash
hexo generate
```

==== 运行服务器

```bash
hexo server
```

==== 将服务器在后台运行

在`blog`文件夹内创建`hexo_run.js`文件

然后将以下内容写入该文件

```js
//run
const { exec } = require('child_process')
exec('sudo hexo server -p 80',(error, stdout, stderr) => {
        if(error){
                console.log('exec error: ${error}')
                return
        }
        console.log('stdout: ${stdout}');
        console.log('stderr: ${stderr}');
})
```

然后输入该命令即可实现服务器在后台运行，并且可以直接使用浏览器访问，无需输入端口号。

```bash
sudo pm2 start hexo_run.js
```

如果要暂停服务器，则输入

```bash
sudo pm2 stop hexo_run.js
```

如果没有`pm2`命令，则使用以下命令安装，如果出现了`permission denied`报错，则用`sudo`或`root`用户安装，方法如上文所示。

```bash
npm install -g pm2
```

如果是在本地运行，使用`http://localhost/`即可运行，如果已经部署在了云服务器上，则使用`http://[服务器ip]/`，如果已经将域名解析到了ip,则使用`http://[域名]/`

=== 修改网站的基本信息

打开hexo的全局配置文件（存放于`blog`目录下），然后找到

```
title:
subtitle: ''
description:
keywords:
author:
language: zh-CN
timezone: Asia/Shanghai
url:
```

修改对应的位置即可。

=== 美化hexo框架

这里展示安装`next`主题，我的网站现在使用的就是该主题。还有其他很多很好看的主题，可以访问以下网站来查看：#link("https://github.com/Ailln/awesome-hexo-theme")[链接]

配置的时候可以将hexo服务器打开，这样可以直观的看到修改配置文件以后的样子。

==== 安装next主题

```bash
npm install hexo-theme-next
```

该主题的相关配置文件会存放在

```
~/blog/node_modules/hexo-theme-next/
```

文件夹下

==== 启用next主题

打开`~/blog`文件夹下的`_config.yml`配置文件，该配置文件是全局的配置文件。不同的主题也有自己的配置文件，存放在各自主题的目录内。

找到

```
# Extensions
== Plugins: https://hexo.io/plugins/
== Themes: https://hexo.io/themes/
theme: landscape
```

将`landscape`改为`next`即可完成主题的更改

然后运行服务器测试一下，如果出现

```
Error: Cannot find module 'css'
Require stack:
....(省略)
```

则输入

```bash
npm install css
```

即可。

==== 配置next框架

进入`next`配置文件夹下

```bash
cd ~/blog/node_modules/hexo-theme-next
```

打开`_config.yml`修改即可

这里举几个可能会用到的，对于我没讲到的配置，自己可以多试试，在这里改改配置是不会把服务器改坏的。

==== 更改风格

next主题内置了4种风格，默认是Muse风格，更改方法：将对应风格前面的注释去除即可。

配置文件如下：

```
# Schemes
scheme: Muse
#scheme: Mist
#scheme: Pisces
#scheme: Gemini
```

==== 更改文件的许可证

不同的许可证有不同的效力，可以自己去查一下相关的内容。

配置文件如下

```
license: by-nc-sa
```

==== 开启菜单栏

找到以下配置，将前面的注释去掉就可以开启对应的菜单

```
menu:
  #home: / || fa fa-home
  #about: /about/ || fa fa-user
  #tags: /tags/ || fa fa-tags
  #categories: /categories/ || fa fa-th
  #archives: /archives/ || fa fa-archive
  #schedule: /schedule/ || fa fa-calendar
  #sitemap: /sitemap.xml || fa fa-sitemap
  #commonweal: /404/ || fa fa-heartbeat
```

现在解释其中的一行：

```
home: / || fa fa-home
```

- `home`：在页面上显示的名字是home，可以改成中文
- `/`: 跳转到的地址是`/`
- `fa fa-home`：使用的图标为`fa fa-home`，更多图标：#link("https://fontawesome.com/icons/")[链接]

如果你开启了`categories`，但是你点击了对应的标签，然后跳转失败了，则可以用以下方法修复：

在`~/blog/source`文件夹下创建`categories`文件夹，然后在该文件夹下创建`index.md`，向里面填写（title,date默认即可）

```md
---
title: 分类
date: 2023-03-11 21:33:40
type: categories
---
```

`type`改成`categories`，相关的内容会由框架自己完成填写。

其他的几个类似。如果不想由框架填写，则可以自己添加内容，`type`这一行去除。

比如我的捐献页面的内容，没有上文的相关信息，纯文本：

```
大家好，为了不影响您的阅读体验，我最初放置的文章底部捐赠按钮已经移至侧边栏。您完全可以自由浏览网站，无需捐赠。我维护这个网站并非为了盈利，且网站的运营成本并不高，不会给我的经济状况带来负担。当然，如果您愿意支持，我会非常感激。

感谢大家的支持！

wechatpay: <img src="http://kodo.ghost-him.com/wechat.jpg" alt="微信支付" style="zoom:20%;" />
alipay: <img src="http://kodo.ghost-him.com/alipay.jpg" alt="微信支付" style="zoom:20%;" />
```

==== 更多设置

通过以上几个案例的演示，应该是基本会通过配置文件来配置网站了。如果还有其他的特殊需求，可以去网上搜搜。hexo还可以自己安装插件，比如我的网站中自动生成短链接的插件，还有只在主页展示部分的内容等等。

可以参考一下这个文章#link("https://zhuanlan.zhihu.com/p/618864711")[链接]

=== 将网站的备案信息添加到网页上（重要）

以下是#link("https://cloud.tencent.com/document/product/243/61412")[备案号悬挂说明]

如果你使用的是`next`主题，则该主题已经为你准备好了一个模板，只需要在配置文件处修改一下相关的配置即可。

打开`next`主题的配置文件，然后找到

```
# Beian ICP and gongan information for Chinese users. See: https://beian.miit.gov.cn, https://beian.mps.gov.cn
  beian:
    enable: false
    icp:
    # The digit in the num of gongan beian.
    gongan_id:
    # The full num of gongan beian.
    gongan_num:
    # The icon for gongan beian. Login and See: https://beian.mps.gov.cn/web/business/businessHome/website
    gongan_icon_url:
```

在对应的位置填写自己的信息即可，记得把`enable`打开

`gongan_icon_url`中填写图片在服务器中的相对位置即可，如果你想折腾，可以去配置一下对象存储，我使用的是七牛云，每个月有免费的流量。使用对象存储，可以减少服务器的宽带压力。配置的过程在七牛云的官网上写的蛮详细的，这里就不展示了。
