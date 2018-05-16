---
title: 男衣库 App_iOS 性能优化实践总结
date: 2018-05-16 22:10:55
tags:
categories:
---

## 前言

随着业务开发的不停迭代，如果没有很严格的执行代码开发规范、性能监控、测试覆盖等。容易引发一些 App 的性能问题，如崩溃率高、内存占用过高，安装包体积过大、启动时间过长，页面卡顿等一些性能问题，进而影响 App 的整体使用体验。 其中，主要优化的几个常见场景如下：

- 业务优化
	- 未使用到的业务代码，以前旧版本的一些业务逻辑，没有及时删除。
- 内存优化
	- 内存泄漏和大量数据加载导致收到系统内存警告
- 卡顿优化
	- 监控页面实时滑动帧率 FPS
- 布局优化
	- 大量的布局重复运算，没有适当的缓存设计 	
- 电量优化
	- 一些硬件的操作、持续后台定位等 	
- 安装包体积优化
	- 无用资源、如图片、文档等数据，无用的代码，图片未压缩处理
- 启动时间优化
	- 大量的业务逻辑代码堆积在启动的时候执行
- 网络优化
	- 网络安全

## 现状
`以下所有测试都是使用 iphone 6/iOS 8.3 版本测试真机在 release 环境下测试的。`
<!-- more -->

### crash

- App Store 统计数据，过去 90 天，主包的崩溃次数，89 次

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-102203.jpg?imageView2/2/w/700)

- 具体崩溃详情

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-102051.jpg?imageView2/2/w/700)
	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-103323.jpg?imageView2/2/w/700)
	
### 启动时间
`启动时间是用户点击 App 图标，到第一个界面展示的时间。`

iOS App 的启动时间分为两个部分，一个是 main 函数执行之前的 preMain 时间，另一个是 main()函数 -> 第一个页面渲染完成，用户看到界面的时间。

- preMain 时间

	![](http://o6heygfyq.bkt.clouddn.com/屏幕快照 2018-04-18 上午9.44.20.png)
	
	- main 函数之前总共使用了 730 ms;
	
	- 在 307ms 中，加载动态库用了 307ms，指针重定位使用了 85 ms，ObjC 类初始化使用了 172 ms，各种初始化使用了 165 ms;
	
	- 在初始化耗费的 165 ms 中，用时最多的初始化是 AFNetworking，用时 110 ms;

- main 函数 -> 第一个页面渲染完成，用户看到界面的时间，这一个阶段通过在相关函数执行的地方打点计时可以测量出来：
	
	![](http://o6heygfyq.bkt.clouddn.com/lanchTime.png?imageView2/2/w/300)
	- 这个阶段主要有第三方 SDK 的初始化，获取系统的配置，初始化页面tabbar，总共耗时 0.481s;

- 启动总耗时：`0.73 s + 0.481 s = 1.211 s`

### 内存

- Xcode Analyze 静态分析工具分析可疑泄露点，有些真的存在，有些不存在，可以通过结合 Instruments 动态分析工具以及代码上下文排除解决
	
	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180423-141346.jpg?imageView2/2/w/700)
	- 663 个隐藏泄露点，主要包含以下几个部分：
	- 面向用户的文本应该使用本地化;
	- 无效数据监测;
	- 逻辑错误：访问空指针或未初始化的变量等；
  	- 内存管理错误：如内存泄漏等；
 	- 声明错误：从未使用过的变量；
  	- API 调用错误：未包含使用的库和框架;
  
- Xcode Instruments 动态分析工具中的 Leaks 和 Allocations 跟踪模板进行动态跟踪分析, 确认这些点是否真的泄漏, 或者是否有新的泄漏点出现

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180423-160117.jpg?imageView2/2/w/700)

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180423-161838.jpg?imageView2/2/w/700)
	
- 使用 Instruments 中 Time Profile 工具检测耗时严重的方法

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-154721.jpg)	
		
### 页面刷新帧率

 ![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-141007.gif)

- 首页、买家秀列表页快速滑动的时候有轻微出现掉帧现象。

### 安装包体积

![](http://o6heygfyq.bkt.clouddn.com/Jietu20180424-142406.jpg)


- 安装包构成

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180425-193322.jpg?imageView2/2/w/500)
	
	- 二进制代码文件
	- 资源（图片、文档）
	- 配置文件

- 工程中没有使用到的资源文件

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180424-144901.jpg?imageView2/2/w/500)

- 编译后 arm64 架构各个类所占空间大小：

	![](http://o6heygfyq.bkt.clouddn.com/Jietu20180424-153029.jpg?imageView2/2/w/500)

### 子线程 UI 操作

在子线程中操作 UI 可能会引发一些未知的 bug，比如一些动画丢失问题，因此需要将所有有关 UI 的操作都放在主线程中进行，目前男衣库有一些页面的 UI 操作是在子线程中进行的，这些通过苹果iOS 9 系统上的 libMainThreadChecker.dylib 动态库都能检测出来。

目前男衣库 iOS App 中有多处存在子线程刷新 UI 的情况，分别在首页，个人中心都存在。

![](http://o6heygfyq.bkt.clouddn.com/Jietu20180424-155631.jpg?imageView2/2/w/700)

### 布局约束警告

使用 Autolayout 进行页面布局，目前男衣库 App 存在多处约束警告，约束警告指对控件或者视图添加了重复或者多余的约束，不处理的话有可能引起页面显示错乱，多次重复布局等不必要的 CPU 操作等问题。

![](http://o6heygfyq.bkt.clouddn.com/Jietu20180424-160133.jpg?imageView2/2/w/700)
	
## 优化方案和目标
过早的优化是万恶之源。优化要站在实际的需求角度出发，不能为了优化而优化，应该优化那些真正的性能瓶颈，体验落后，性价比最高、最值得优化的地方，同时又要站在整体的角度，做一些取舍和权衡，比如为了卡顿优化，往往需要缓存一些数据到内存中，从而会引起内存增长，如果内存中缓存的数据过多，内存就容易出现性能瓶颈，为了更好更快的监控一些数据，往往会集成一些第三方 SDK，这就又会导致安装包体积的增加。

具体应该通过检测到的性能数据指标来做具体优化，可以使用苹果自带的 instruments 工具来检测，找到突破点，优化一点，检测一下，观察性能数据的变化，如此反复。

### 第一步目标

1. 首先解决 crash，将现有的线上崩溃都清理解决掉。
2. 子线程 UI 操作，约束警告全部解决掉；
3. 静态分析工具分析出来的可能泄露点的地方逐一排除修复；
		
### 第二步目标
#### 1. 启动时间

- preMain 时间
	- preMain 时间在小于 400ms 是最佳的，因为从点击图标到显示启动图，再到启动图消失这段时间是 400ms。同时启动时间不可以大于 20s，否则会被系统杀掉。
	- 这里面主要做了一些 iOS 系统动态库的链接、App 中 objc 类的加载。
	- 针对这里的优化：
		1. 合并自己添加的动态库，减少动态库的数量，目前我们没有使用自己添加的动态库；
		2. 合并 Category 和功能类似的类，这个确实存在不少；
		3. 删除无用的方法和类；
		4. 用 initialize 方法替代 load，减少每个类的 load 方法的执行时间，经`符号断点`检测，也有一些类是这样的；

		
- main()函数 -> 第一个页面渲染完成，用户看到界面的时间。这里可以做的优化有：
	- 能延迟执行的就延迟执行。比如 SDK 的初始化，界面的创建，将页面请求加载数据、渲染等操作转移到viewWillAppear 方法中去；
	- 不能延迟执行的，尽量放到后台执行，比如一些读取沙盒用户偏好缓存的数据操作；
	

#### 3. 页面卡顿

`根据苹果官方说法，当 FPS 低于 45 的时候，用户就会察觉到到滑动有卡顿`，男衣库 App 在这一块并不是很明显

- 日常开发时，做好 FPS 实时监控，在出现掉帧的页面，可做如下优化：
	- 清除在主线程中进行的耗时操作
	- 建立缓存机制，如缓存表格视图中 cell 的高度；
	- 避免离屏渲染，尽量避免使用 layer 的 border、corner、shadow、mask 等属性，在后台线程预先绘制好对应内容；


#### 4. 内存

`一般在占用系统内存超过 20% 的时候会有内存警告，而超过 50% 的时候，就很容易被系统 Crash。`

iOS 中内存问题主要包含两个部分:

- 循环引用
	- Delegate：检查所有用到的代理对象属性是否是使用weak内存管理策略
	- NSTimer：使用 GCD 定时器代替 NSTimer，GCD 定时器的优点是时间误差小，不会发生循环引用；
	- Block: 检查所有用到 Block 的地方，是否存在循环引用问题；
	- NSNotificationCenter：检查 NSNotification addObserver 后是否有移除；
	
- 大量数据加载及使用导致的内存警告
	- 处理每个单独页面以及整个 App 收到的内存警告，及时释放掉相关的资源；

#### 5. 包体积
- 图片优化：使用 ImageOptim 图片压缩工具对工程中的图片做一次压缩处理；
- 清除无用的资源：使用 [LSUnusedResources](https://github.com/tinymind/LSUnusedResources) 工具，清除掉工程中未使用到的资源文件；
- 二进制文件优化：使用[LinkMap](https://github.com/huanxsd/LinkMap) 工具检测出每个类在最终的可执行文件中占据的大小，进行针对性的优化；
- 一些编译选项优化的开关开启；

## 其他

1. TestFight preRelease 测试，App 性能指标专项测试
2. 多个包管理，Xcode 多 target 管理
3. git flow 工作流
4. 自动化打包，CI 持续集成环境

## 参考资料
[iOS App 启动性能优化](https://mp.weixin.qq.com/s?__biz=MzA3NTYzODYzMg==&mid=2653579242&idx=1&sn=8f2313711f96a62e7a80d63851653639&chksm=84b3b5edb3c43cfb08e30f2affb1895e8bac8c5c433a50e74e18cda794dcc5bd53287ba69025&mpshare=1&scene=1&srcid=081075Vt9sYPaGgAWwb7xd1x&key=4b95006583a3cb388791057645bf19a825b73affa9d3c1303dbc0040c75548ef548be21acce6a577731a08112119a29dfa75505399bba67497ad729187c6a98469674924c7b447788c7370f6c2003fb4&ascene=0&uin=NDA2NTgwNjc1&devicetype=iMac16%2C2+OSX+OSX+10.12.6+build(16G29)&version=12020110&nettype=WIFI&fontScale=100&pass_ticket=IDZVtt6EyfPD9ZLcACRVJZYH8WaaMPtT%2BF3nfv7yZUQBCMKM4H1rDCbevGd7bXoG)

[iOS-Performance-Optimization](https://github.com/skyming/iOS-Performance-Optimization)

[[iOS]一次立竿见影的启动时间优化](https://www.jianshu.com/p/c1734cbdf39b)

[实现60fps的网易云音乐首页](https://blog.csdn.net/hello_hwc/article/details/76255527)
