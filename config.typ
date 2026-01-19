#import "tufted-lib/tufted.typ" as tufted

#let template = tufted.tufted-web.with(
  // 你可以在 header-links 中修改网站上方的导航栏都包含哪些页面
  // 例如，如果你想添加一个 Entry 页，你需要添加 `"/Entry/": "Entry"`
  // 然后在 `content/` 路径中新建 `Entry/`路径，在其中添加 `index.typ` 作为 Entry 页的内容
  header-links: (
    "/": "主页",
    "/Blog/": "博客",
    "/Study/": "学习笔记",
    "/Thoughts/": "想法",
    "/About/": "关于我",
  ),
  lang: "zh",
  title: "ghost-him|🏠个人网站", // 你的网站在浏览器中显示的标题

  // 自定义 header 和 footer 元素
  // 数组格式，可以添加任意数量的内容，内容之间使用换行分隔
  header-elements: (
    [Ciallo～(∠・ω< )⌒☆],
  ),
  footer-elements: (
    "© 2026 ghost-him",
    [Powered by #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]],
  ),
)
