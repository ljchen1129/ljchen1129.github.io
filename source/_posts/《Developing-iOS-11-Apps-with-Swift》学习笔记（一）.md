---
title: 《Developing iOS 11 Apps with Swift》学习笔记（一）
date: 2018-02-08 14:19:45
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

第一节课主要是介绍了 iOS 开发的一些基本知识点，iOS 系统的框架层级，Swift 语言的基础知识以及一个翻卡片游戏的 demo。

## 索引

[iOS 框架层级](#iOS 框架层级)
[iOS 开发平台组件](#iOS 开发平台组件)
[翻纸牌游戏 demo](#翻纸牌游戏 demo)

## iOS 框架层级

分为四层，分别是 Core OS、Core Services、Media 以及 Cocoa Touch 层。其中最底层最接近硬件，最顶层最接近用户。

- Core OS（系统核心层）

由于 iOS 是有 Unix 分出来的，所以这一层的大部分都是一些用 C 语言写的 UNIX 操作系统的接口，主要有系统内核、Mach 3.0、BSD、Sockets（套接字）、Security（安全）、Power Managerment（电量管理）、Keychain Access（钥匙串访问）、Certificates（证书）、File System（文件管理）、Bonjour。

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_3.png?imageView2/2/w/600)

<!-- more -->
- Core Services（系统服务层）

这层是面向对象的，iOS 开发中经常用到的。主要封装有 Collections（集合类型）、Core Location(核心定位)、Address Book(地址簿)、Net Services(网络服务)、Networking(网络)、Theading (线程)、File Access(文件访问)、Preferences(偏好设置)、SQLite(数据库)、URL 实体等。

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_4.png?imageView2/2/w/600)

- Media（媒体层）

这层主要封装有 Core Audio(核心音频) JPEG,PNG,TIFF(不同图片格式)、OpenAL、PDF（文档）、Audio Mixing(音频合成)、Quartz(2D)(绘图)、Audio Recording(录音)、Core Animation(核心动画)、Video Playback(视频播放)、OpenGL ES（图形渲染）

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_5.png?imageView2/2/w/600)

- Cocoa Touch（用户界面层）

最顶层是用户直接接触的，是 UI 用户界面层。所有的视图、view、控件、地图、本地化、相机相册、多点触控等都是在这一层，日常的界面开发就是在这一层。

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_6.png?imageView2/2/w/600)


## iOS 开发平台组件

- 工具：Xocde（IDE）、Instrument(辅助调试、内存溢出什么的)
- 语言：Objective-C、Swift、C、C++
- 框架：Foundation、UIKit 
- 设计模式：MVC、MVP、MVVM 

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_7.png?imageView2/2/w/700)

## 翻纸牌游戏 demo

- 字符串常量拼接变量
	
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_8.png?imageView2/2/w/700)

- 类型推断
自动推断出变量的类型

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_10.png?imageView2/2/w/700)

- 计算属性
监听属性的赋值操作

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_11.png?imageView2/2/w/700)


- 可选绑定
给一个可选类型解包

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180208_12.png?imageView2/2/w/700)