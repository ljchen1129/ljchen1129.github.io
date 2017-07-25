---
title: iOS 进阶
date: 2017-04-23 20:01:18
---

## 语言
1. 《Efficeive Objective-C 2.0》
2. Objective-C Runtime
	- [https://opensource.apple.com/source/objc4/](https://opensource.apple.com/source/objc4/)
	- [Objective-C Runtime Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048-CH1-SW1)
	- objc_msgSend 实现细节
3. [The Swift Programming Language](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/)

## GUI
1. View
	- [View Programming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html)
	
2. Controller
	- [View Controller Programming Guide for iOS](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1)
	
	>1. 熟悉基本 View Controller 使用、transition
	>2. 熟悉 MVC 等设计模式
	
	
3. Event
	- [Event Handling Guide for UIKit Apps](https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/)
4. Layout
	- [Auto Layout Guide](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/index.html#//apple_ref/doc/uid/TP40010853-CH7-SW1)
5. Draw
	- [Drawing and Printing Guide for iOS](https://developer.apple.com/library/content/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html)
6. Animation
	- [Core Animation Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)

### 检测标准
>1. 自定义 UI，熟悉 UI 渲染机制（软渲染、硬件加速）
>2. 掌握基本排版机制，掌握 AutoLayout
>3. 熟悉事件传递机制，自定义手势


## Xcode

1. [Xcode Concepts](https://developer.apple.com/library/content/featuredarticles/XcodeConcepts/Concept-Targets.html)
2. [Debugging with Xcode](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/debugging_with_xcode/chapters/about_debugging_w_xcode.html)
3. llvm
	- [LLVM Compiler Overview](https://developer.apple.com/library/content/documentation/CompilerTools/Conceptual/LLVMCompilerOverview/)

### 检测标准
>1. 熟悉 Xcode 编译、链接、打包各个流程，Xcodeconfig，各种选项配置选项意义
>2. 熟悉 Xcode 管理多工程、多 target
>3. 熟练使用 cocoapods、plugin
>4. 熟悉 Instument Memory，CPU，GPU 工具使用
>5. 熟悉应用/库打包方式，熟悉应用发布流程

## 网络
1. 理解 NSURLConnection、NSURLSession、NSURLProtocol
2. Apple Guide
	- [URL Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html)
	- [CFNetwork Programming Guide](https://developer.apple.com/library/content/documentation/Networking/Conceptual/CFNetwork/Introduction/Introduction.html)

### 检测标准
>1. 熟悉常见网络库使用
>2. 熟悉 Cache、Cookie 管理


## 多线程
1. 《Objective-C 高级编程 iOS 与 OS X 多线程和内存管理》
2. Apple Guide
	- [Concurrency Programming Guide](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
	- [Threading Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i)

### 检测标准
>1. 熟悉多线程消息传递，同步机制，线程池设计和实现
>2. 掌握 NSOperation, GCD，Runloop 机制和实现

## 数据存储
### 检测标准
>1. 熟悉 SQLlite 使用，熟悉常见 ORM 系统设计和实现
>2. 熟悉系统常用本地存储机制
>3. 掌握 CoreData、sqllite、UserDefault


## 开源库实现原理
1. [SDWebImage](https://github.com/rs/SDWebImage)
2. [AFNetworking](https://github.com/AFNetworking/AFNetworking)
3. [AsyncDisplayKit](https://github.com/facebook/AsyncDisplayKit)/[pop](https://github.com/facebook/pop)/[react-native](https://github.com/facebook/react-native)
4. [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)


## 逆向安全
1. [Keychain Services Programming Guide](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html)
2. [《iOS 应用逆向工程》](https://book.douban.com/subject/25826902/)

## 其他
### 音视频
> 1. 熟悉音频，视频基本概念，熟悉相关系统接口
> 2. 熟悉拍照、录像等相关接口

### 性能调优
> 1. 熟悉移动端常见性能问题和解决方案：主线程 CPU 密集操作，主线程 IO 操作，排版、渲染耗时
> 2. 网络性能分析和调优[《Web 性能权威指南》](https://book.douban.com/subject/25856314/)
> 3. 熟练使用 Insrument 进行性能调优
 
## 学习资源
1. [WWDC session](https://developer.apple.com/wwdc/)
2. [objc.io](https://www.objccn.io/issues/)

## 计算机内功
1. 数学
	- 基础、高等数学
	- 数论
	- 概率论
	- [《具体数学》](https://book.douban.com/subject/21323941/)
2. 操作系统
	- [现代操作系统](https://book.douban.com/subject/3667744/)
	- 操作系统实现
3. 链接（linking）与加载（loading）
	- [《程序员的自我修养》](https://book.douban.com/subject/3652388/)

4. ARM 体系结构与编程
	- ARM 体系结构与编程
5. 语言
	- [Scheme](https://www.ibm.com/developerworks/cn/linux/l-schm/index1.html)、[Racket](https://en.wikipedia.org/wiki/Racket_(programming_language))、[Haskell](https://zh.wikibooks.org/zh-cn/Haskell)、[Prolog](https://en.wikipedia.org/wiki/Prolog)
	- C
		- [《C程序设计语言》](https://book.douban.com/subject/1139336/) - 入门
		- [《C程序设计语言》](https://book.douban.com/subject/1138919/) - 入门
		- [《C语言程序设计》](https://book.douban.com/subject/4279678/) - 入门
		- [《C Primer Plus(第6版)(中文版)》](https://book.douban.com/subject/ 26792521/) - 入门
		- [《C和指针》](https://book.douban.com/subject/3012360/) - 进阶
		- [《C陷阱与缺陷》](https://book.douban.com/subject/2778632/) - 进阶
		- [《Expert C Programming》](https://book.douban.com/subject/1784687/) - 进阶
	- C++
		- [《The C++ Programming Language》](https://book.douban.com/subject/7053134/)
		- [《C++ Primer》](https://book.douban.com/subject/10505113/)
		- [《Effective C++》](https://book.douban.com/subject/1453373/)
		- [《Effective C++ - 改善程序与设计的55个具体做法(第3版)》](https://book.douban.com/subject/5387403/)
		- [《The C++ Standard Library, 2nd Edition》](https://book.douban.com/subject/10440485/)
		- [《STL源码剖析》](https://book.douban.com/subject/1110934/)
	- [《面向对象编程导论》](https://book.douban.com/subject/1271329/)
	- [《编译原理》](https://book.douban.com/subject/3296317/)
	- [《计算机程序构造与解释》](https://book.douban.com/subject/1148282/)
	- java

6. 平台编程
	- [《Unix 高级环境编程》](https://book.douban.com/subject/1788421/)
7. 网络&数据库
	- 计算机网络
	- 数据库
8. 程序人生
	- [《十年学会编程》](http://daiyuwen.freeshell.org/gb/misc/21-days-cn.html)