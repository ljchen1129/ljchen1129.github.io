---
title: Swift 代码编译流程
date: 2019-10-11 09:37:14
tags:
- Swift
- 编译
categories:
- Swift
- 编译
---



### 



### 编程语言分类

编程语言按照不同的角度可以有不同的分类。

#### 按`与硬件的距离`分：

- 机器语言：根据硬件指令集的 0101 
- 汇编语言：对机器语言做了简单的封装
- 高级语言：C/C++/Java/Python/JavaScript/Swift 等

#### 按`编程范式`分：

<!--more-->

- 面向过程：
  - C
- 面向对象：
  - C++/Java
- 函数式

> 现在的很多高级语言都具备`多种编程范式`。

#### 按`是否需要编译`分：

- 编译型语言 Compiled Language，编译后可直接执行，执行效率高

  - C/C++/Objective-C/Swift（不依赖虚拟机）
  - Java (依赖虚拟机)，Java 源代码会先编译成为 .class（字节码）文件，再经过 JVM 一行一行的解释执行

- 解释型语言 Interpreted Language，也叫脚本语言 Scripting Language，运行在解释器上，解释一行代码，执行一行，执行效率相对编译型语言更低，但容易移植

  - Python/Ruby/JavaScript

  

Swift 是一门编译型语言，编译型语言的源代码要运行，首先是需要编译器（Complier）把源文件进行编译成目标文件，然后经过链接器（Linker）链接后才能够执行的。这篇主要记录的是 Swift 代码的编译过程。

### LLVM 编译器架构



![img](http://liangjinggege.com/2019-10-11-070906.png)



- Frontend 前端
  - 词法分析、语法分析、语义分析、生成中间代码
- Optimizer 优化器
  - 中间代码优化
- Backend 后端
  - 生成不同硬件平台的机器码



![img](http://liangjinggege.com/2019-10-11-071354.png)



>前后端依赖统一格式的中间代码(IR)，使得前后端可以独立的变化。新增一门语言只需要修改前端，而新增一个 CPU 架构只需要修改后端即可。



Objective C/C/C++使用的编译器前端是[clang](https://clang.llvm.org/docs/index.html)，swift是[swift](https://swift.org/compiler-stdlib/#compiler-architecture)，后端都是[LLVM](https://llvm.org/)。

### Objective-C 源代码编译流程







#### 单文件编译

![å±å¹å¿«ç§ 2018-09-16 ä¸å7.59.40](http://liangjinggege.com/2019-10-11-111143.png)

### 链接器



### Command + B 构建过程



### 提高构建速度

#### 统计构建时间



### 提高 App 启动时间



### Mach-O 文件格式







---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「by在水一方」。

![by在水一方](http://liangjinggege.com/qrcode_for_gh_0be790c1f754_258.jpg)