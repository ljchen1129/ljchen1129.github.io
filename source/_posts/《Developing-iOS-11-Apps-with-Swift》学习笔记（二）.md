---
title: 《Developing iOS 11 Apps with Swift》学习笔记（二）
date: 2018-02-08 16:58:20
tags:
- iOS 
- Swift
categories:
- iOS 
- Swift
---

## 前言

这套课程是苹果官方推荐的入门 iOS 开发的学习课程。之前也听过，Paul 老爷子讲的非常好，这次准备重看一遍，顺便把 swift 和 iOS 相关的一些基础知识点复习一遍。文章会按照视频的次序写笔记，记录重点以及自己的理解。

[课程地址](https://itunes.apple.com/cn/podcast/developing-ios-11-apps-with-swift/id1315130780?mt=2)

[Demo 示例地址](https://github.com/ljchen1129/-Developing-iOS-11-Apps-with-Swift-Demos/tree/master)

[参考资料一：官方文档](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/index.html)
[参考资料二：官方文档中文翻译](https://www.cnswift.org/)

这一节课主要将的是 MVC 设计模式，以及优化上节课的翻纸牌游戏 demo，在优化 Demo 中讲解了 Swift 中的几个语法。Initialization(构造器)、struct（结构体）和 class（类）、static methods（静态方法）和 properties（属性）、optionals（可选）Dictionary<KeyType,ValueType>(字典)、UIStackView 、 autolayout（自动布局）

## 索引

[MVC 设计模式](#MVC 设计模式)
[struct（结构体）和 class（类）](#struct（结构体）和 class（类）)
[static methods（静态方法）和 properties（属性）](#static methods（静态方法）和 properties（属性）)
[_ 忽略下标](#_ 忽略下标)
[数组拼接元素](#数组拼接元素)
[lazy 懒加载](#lazy 懒加载)
[并列表达式](#并列表达式)
[空合运算符 ??](#空合运算符 ??)

## MVC 设计模式

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180208_14.png?imageView2/2/w/600)

MVC 是苹果官方推荐的构建 App 的一种设计模式。它由三个角色组成。View、Controller、Model 组成。各个角色的分工如下：
<!-- more -->
- View：展示给用户的界面，例如用户看到的所有 UI 元素、按钮、标签、表格等等。
- Controller：主管逻辑。控制 Model 层的数据怎样显示到 View 上。
- Model：负责数据部分，和 UI 独立，View 视图显示的数据。

**通信：**

- View 和 Model
	- 不能直接相互通信。
- Controller 和 View
	- Controller 持有 View，可以主动和 View 通信，但 View 不能直接和 Controller 通信。 View 上发生一些用户响应想要告诉 Controller 可以通过 `action/target` 的方式，将 Controller 和 view 进行绑定。除此之外，view 还可以通过 `delegate（代理）`的方式，让 Controller 成为自己的代理，实现代理的协议方法，View 将自己发生的一些变化告诉自己的代理。其中给 View 提供数据的 `delegate（代理）`叫做 `DataSource`.
		
- Controller 和 Model
	- Controller 持有模型，可以直接主动和 Model 通信，获取 Model 的数据，但 Model 不能直接和 Controller 通信。Model 发生数据改变想要主动告诉 Controller，Controller 可以通过` KVO` 监听 Model 属性的方式。
	
![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180208_15.png?imageView2/2/w/600)

**MVCS：**

单个页面可以是 MVC，一个 App 通常有多个页面，这些 MVC 组合成一起，就是 `MVCS`。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180208_16.png?imageView2/2/w/600)

## struct（结构体）和 class（类）

- 相同点：
	- 都能定义变量和方法。
	
- 不同点：
	1. struct（结构体）`没有继承`。
	2. struct（结构体）是值类型（Value Type），class（类）是引用类型（refrence Type）。Swift 中大部分的数据类型都是`值类型`，除了`类和闭包`。值类型的数据传递是通过复制进行的，但不是每次传递都会真正的复制，Swift 有一种智能的机制，只有当值真正被修改了才会被复制传递，这种机制叫做`写时复制（copy on write）`。引用类型是一种存储在`堆（heap）`里面，使用指针指向的数据类型，传递值时，是传递该值的`引用指针`，也即时传递的是`值的地址`。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_18.png?imageView2/2/w/700)


## static methods（静态方法）和 properties（属性）
在结构体中可以定义` static methods（静态方法）` 和`静态变量`，用 `static 关键字`修饰,静态方法和静态变量只有结构体的类型才有的方法，不是实例拥有的，只有该结构体的类型才能调用。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_22.png?imageView2/2/w/700)

## _ 忽略下标
1. 当遍历一个 `sequence` 的下标，不需要用到该下标值。
2. 省略`函数`的外部参数（external parameter）

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_23.png?imageView2/2/w/700)

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_28.png?imageView2/2/w/500)

## 数组拼接元素

直接通过` + `运算符就可以对数组进行拼接操作。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_23.png?imageView2/2/w/700)

## lazy 懒加载

用时加载，没有使用到时不加载。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_25.png?imageView2/2/w/700)

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_24.png?imageView2/2/w/700)

## 并列表达式
可以将多个条件表达式并列在一起写，用 `,` 隔开，表示这几个表达式的逻辑值都要为真。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_26.png?imageView2/2/w/500)


## 空合运算符 ??
和三目运算符相似。`??` 前面是一个可选类型的值，表示解包这个可选值，如果解包成功，就返回可选类型的值，如果解包失败就返回 `??` 后面的`默认值`。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20180209_27.png?imageView2/2/w/400) 