#import "../index.typ": template, tufted
#show: template.with(title: "博客 / Blog")

= 博客 / Blog

== 2026

#tufted.blog-entry(date: datetime(year: 2026, month: 2, day: 15), path: "2026-02-15-2025-recap/", title: "2025 年终总结")
#tufted.blog-entry(date: datetime(year: 2026, month: 1, day: 20), path: "2026-01-20-training-bug/", title: "单 epoch 训练时间逐渐变长的 bug 记录")

== 2024

#tufted.blog-entry(date: datetime(year: 2024, month: 3, day: 4), path: "2024-03-04-blog-building/", title: "个人博客搭建指南")

== 2023

#tufted.blog-entry(date: datetime(year: 2023, month: 12, day: 26), path: "2023-12-26-postgraduate-exam", title: "考研初试经验分享")
