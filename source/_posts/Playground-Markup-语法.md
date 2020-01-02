---
title: Playground Markup 语法
date: 2019-10-11 09:24:42
tags: others
categories: others
---



### 前言

学习 Swift 语法最好的工具是 Xcode 配套的 Playground，所见即所得。除了实时显示变量的值，还可以加载资源，呈现视图，多文件管理等。

![image-20191011093609289](http://liangjinggege.com/2019-10-11-013609.png)

<!--more-->

但还不止如此，还可以在写注释文档的时候使用 Markup 语法，写出非常漂亮的注释。

### Markup && Markdown

 Markup 语法和 Markdown 基本一致：

```markdown
//: [Previous](@previous)

/*:
 # 一级标题
 ## 二级标题
 ## 二级标题
 ### 三级标题
 ### 三级标题
 
 
 ## 无序列表
 - 无序列表1
 - 无序列表2
 - 无序列表3
 
 ## 有序列表
 1. 有序列表1
 2. 有序列表2
 3. 有序列表3
 
 ## 图片
 ![我是图片](myIcon.jpg)
 
 ## 链接
 [在水一方](https://chenliangjing.me)
*/

//: [下一页](@next)

```

查看效果：

<img src="http://liangjinggege.com/2019-10-11-013229.png" alt="image-20191011093224523" style="zoom:50%;" />

<img src="http://liangjinggege.com/2019-10-11-013338.png" alt="image-20191011093338195" style="zoom:50%;" />

---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「by在水一方」。

![by在水一方](http://liangjinggege.com/qrcode_for_gh_0be790c1f754_258.jpg)