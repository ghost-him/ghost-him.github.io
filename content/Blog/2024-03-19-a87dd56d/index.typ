#import "../../index.typ": template, tufted
#show: template.with(title: "线上编程课学习经验")

现在线上的课的质量已经不比线下的课差了，有很多线上培训机构讲的内容会比一些学校老师讲的还要好。因此我写一下这个文章来总结一下我线上学习 3 年经验。

= 找资源
== Bilibili
我最常用的学习网站就是 b 站。比如 c++ 语言，java，linux，linux 系统编程，linux 网络编程等等课程，都是在 b 站上学习的。如果要学习什么内容，直接在 b 站上搜就可以了。

b 站上的课程会比较偏向工程应用，说的通俗一些就是：比较适合要找工作的人。

== CSDIY
还有一个指南性的网站，我也很推荐，比较适合本科生，或者时间很多的人来学：#link("https://csdiy.wiki/")[CS自学指南]

其自我介绍：

#quote(block: true)[
这是一本计算机的自学指南，也是对自己大学三年自学生涯的一个纪念。

这同时也是一份献给北大信科学弟学妹们的礼物。如果这本书能对你们的信科生涯有哪怕一丝一毫的帮助，都是对我极大的鼓励和慰藉。
]

这个网站里包含着国外优秀的课程，并且计算机的各个方面都有涉及。如果你对计算机感兴趣，你一定可以在这个网站里找到你感兴趣的课程。

= 学习的过程
对于要写代码的课程，比如 c++语言。一定要跟着老师敲代码。老师敲了什么代码，你就要敲什么代码。不要把代码抄在笔记本上，要写在电脑上!!

同时，如果一个课程中有什么比较重要的知识点，可以用注释的方式写下来。这样在以后复习代码的时候可以同时复习一下这个章节比较重要的知识点。此外，如果你这样写一下注释，你会对这个章节的重要的知识点印象更深。就算你不用你的代码复习，你也知道去网上要找什么内容。

对于代码的存储，可以用以下的结构，这里用我学 html 时的代码来演示：

```
C:.
├───第1章
│   │   a超链接.html
│   │   p段落标签.html
│   │   图像.html
│   │   字体样式.html
│   │   换行标签br.html
│   │   标题标签.html
│   │   水平线hr.html
│   │   特殊符号.html
│   │   跨页的锚链接.html
│   │   锚链接.html
│   │
│   └───image
│           hetao.jpg
│
├───第2章
│       内联框架iframe.html
│       学生表.html
│       定义列表.html
│       无序列表.html
│       有序列表.html
│       表格.html
│       表格的跨列.html
│       表格的跨行.html
│
├───第3章
│   │   form.html
│   │   输入框.html
│   │
│   └───课后作业
│       │   作业1.html
│       │   作业2.html
│       │   作业3.html
│       │
│       └───asset
│               button.gif
│               logo.gif
│               temp.html
│               title.jpg
│               verycode.gif
│
├───第4章
│       id选择器.html
│       one.css
│       交集选择器.html
│       内部样式.html
│       后代选择器.html
│       基本选择器的优先级.html
│       导入式.html
│       并集选择器.html
│       类选择器.html
│       行内样式.html
│       链接式导入.html
│
├───第5章
│   │   div.html
│   │   span.html
│   │   字体的类型.html
│   │   字体的粗细.html
│   │   字体的风格.html
│   │   文本的垂直居中.html
│   │   文本的水平对齐方式.html
│   │   文本装饰.html
│   │   背景图片.html
│   │   背景颜色.html
│   │   设置鼠标形状.html
│   │   超链接的伪类.html
│   │
│   ├───image
│   │       hetao.jpg
│   │
│   └───练习
│           练习1.html
│
├───第6章
│   │   内联元素和块级元素之间的转换.html
│   │   外边距.html
│   │   盒子.html
│   │   边框的样式.html
│   │   边框的颜色.html
│   │
│   └───练习
│           练习.html
│
├───第7章
│       浮动1.html
│       浮动2.html
│
├───第8章
│       固定定位.html
│       相对定位.html
│       绝对定位.html
│
├───练习
│   └───练习1
│       │   question.html
│       │
│       └───asset
│               bottom.jpg
│               faq.jpg
│               head.jpg
│
└───结业
    │   historic.html
    │   index.html
    │
    └───images
```

同时，每个 html 中的代码，以一个为例：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    
    <p>北京欢迎您</p>
    <p>有梦想谁都了不起</p>
    <p>----------------------</p>
    北京欢迎您
    有梦想谁都了不起
    
    <p style="border: solid 1px red">你好</p>
    <a herf="" style="border: solid 1px green">点击</a>
  
</body>
</html>
```

学完一个课程以后，可以尝试着自己用课程中的内容做一个小项目来练手。
