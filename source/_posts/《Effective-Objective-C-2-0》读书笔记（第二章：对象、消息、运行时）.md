---
title: 《Effective Objective-C 2.0》读书笔记（第二章：对象、消息、运行时）
date: 2017-04-20 16:37:07
tags:
- iOS
- Objective-C
categories:
- iOS
- Objective-C
---
## 前言
正在读[《Effective Objective-C 2.0》](https://book.douban.com/subject/25829244/)这本书，这本书主要介绍了一些使用 Objective-C 语言编写代码方面的 52 个有效方法，并且介绍了相应的原理。准备按章节写下读书笔记，并贴出实际的验证代码。
<!-- more -->
1. [《Effective Objective-C 2.0》读书笔记（第一章：熟悉 Objective-C）](http://chenliangjing.me/2017/03/27/%E3%80%8AEffective-Objective-C-2-0%E3%80%8B%EF%BC%88%E4%B8%80%EF%BC%89-%E7%86%9F%E6%82%89-Objective-C/)
2. [《Effective Objective-C 2.0》读书笔记（第二章：对象、消息、运行时）](http://chenliangjing.me/2017/03/27/%E3%80%8AEffective-Objective-C-2-0%E3%80%8B%EF%BC%88%E4%B8%80%EF%BC%89-%E7%86%9F%E6%82%89-Objective-C/)
3. 《Effective Objective-C 2.0》读书笔记（第三章：接口与 API 设计）
4. 《Effective Objective-C 2.0》读书笔记（第四章：协议与分类）
5. 《Effective Objective-C 2.0》读书笔记（第五章：内存管理）
6. 《Effective Objective-C 2.0》读书笔记（第六章：block 与 GCD）
7. 《Effective Objective-C 2.0》读书笔记（第七章：系统框架）

### 对象
`对象`是使用 Objective-C 编程使用的`基本构造单元`，通过对象用来`存储`和`传递`数据。

### 消息
在对象之间`传递数据`并`执行任务`的过程叫做`消息传递（Messaging）`。

### 运行时
应用程序运行后，为应用程序提供`相关支持的代码`叫做 `Objective-C runtime`。`运行时`提供了一些让对象之间能够`传递消息的重要函数`，并且包含`创建实例`所用的`全部逻辑`。

## 理解”属性“概念
### 属性
用于`封装`对象中的数据。


## 在对象内部尽量直接访问实例变量



## 理解对象“等同性”概念


### 特定类所具有的等同性判定方法

### 等同性判断的执行深度


### 容器中可变类的等同性




## 使用“类簇模式”隐藏实现细节



### 创建类簇


### Cocoa 里面的类簇



## 在既有类中使用关联对象存放自定义数据



### 关联对象用法举例




## objc_msgSend 的作用



## 消息转发机制


### 动态方法解析

### 备援接收者

### 完整的消息转发

### 动态方法解析举例



## 使用 method swizzling 调试“黑盒方法”



## 类对象的用意



### 在类继承体系中查询类型信息





