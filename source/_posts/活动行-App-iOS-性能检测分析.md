---
title: 活动行 App_iOS 性能检测分析
date: 2018-08-20 11:12:29
tags:
- iOS
- 性能优化
categories:
- iOS
- 性能优化
---


## 性能检测

### 使用到的相关工具

- instruments： XCode 内置的性能检测工具，可以实时查看程序内存占用，调试的内存泄漏，代码执行耗时，页面渲染，网络等，并可辅助定位到具体的代码；

![](https://liangjinggege.com/Xnip2018-07-13_19-21-39.png)

<!-- more -->

- [MLeaksFinder](https://github.com/Tencent/MLeaksFinder)：微信读书开源的一款 debeg 模式下精准 iOS 内存泄露检测工具；
- [BLStopwatch](https://github.com/beiliao-mobile/BLStopwatch)：代码耗时打点计时器
- [ImageOptim](https://github.com/ImageOptim/ImageOptim)：图片压缩工具；
- [LSUnusedResources](https://github.com/tinymind/LSUnusedResources)：扫描项目中未使用到的无用资源，一键清除；
- [LinkMap](https://github.com/huanxsd/LinkMap)：检测出每个类在最终的可执行文件中占据的大小；
- [FHHFPSIndicator](https://github.com/jvjishou/FHHFPSIndicator)：debug 模式下实时显示页面的滑动帧率；

### 测试环境

- 真机：iPhone 6 plus
- 系统：iOS 11.4
- 模式：release

### 1. 启动时间

>启动时间是从用户点击 App 图标开始，到用户看到第一个界面总耗费的时间。
>
>iOS App 的启动时间可以分为一下两个部分：

1. preMain 耗时
2. main 函数调用到第一个 ViewController 的 viewDidAppear 调用耗时

#### #1.1 preMain 耗时测量

preMain 耗时可以在 XCode -> Product -> Scheme -> Edit Shchem -> Run -> Environment Variables -> + -> 添加 name 为 `DYLD_PRINT_STATISTICS`，Value 为 `1` 的`环境变量`。

![](https://liangjinggege.com/Jietu20180627-152429.jpg)

在控制台就可以打印出 preMain 耗时的相关信息

![](https://liangjinggege.com/Jietu20180627-162633.jpg)

**信息解读**

- main()函数之前总共使用了 533.97 ms；
- 在 533.97 ms中，加载动态库用了 108.68ms，指针重定位使用了 74.48ms，ObjC 类初始化使用了56.81ms，各种初始化使用了 293.49 ms；
- 在初始化耗费的 293.49ms 中，用时最多的五个初始化是 libSystem.B.dylib、libBacktraceRecording.dylib、libMainThreadChecker.dylib、libglInterpose.dylib以及 hdx；

>**说明：**preMain 时间在小于 400ms 是最佳的，因为从点击图标到显示启动图，再到启动图消失这段时间是 400ms。同时启动时间不可以大于 20s，否则会被系统杀掉。

#### #1.2 main 函数调用之到第一个 ViewController 的 viewDidAppear 调用耗时测量
1. 手写统计耗时代码
![](https://liangjinggege.com/Xnip2018-06-28_16-12-22.png)
![](https://liangjinggege.com/Xnip2018-06-28_16-30-12.png)


2. 使用[打点计时器](https://github.com/beiliao-mobile/BLStopwatch)工具进行打点

![](https://liangjinggege.com/2122663-461126cdd47bbe16%20%281%29.png?imageView2/2/w/600)

>**工作原理：** 只需要在 main 函数中开启 start 方法计时，然后在 `didFinishLaunchingWithOptions` 方法中对启动时调用的相关方法做打点，最后在首页控制器 viewDidAppear 中结束打点计时，从而可以根据每个节点，统计出打点方法的调用时间以及总时间。

![](https://liangjinggege.com/Xnip2018-06-28_001.png)
![](https://liangjinggege.com/Xnip2018-06-28_002.png)
![](https://liangjinggege.com/Xnip2018-06-28_003.png)

![](https://liangjinggege.com/Xnip2018-07-13_19-27-12.png?imageView2/2/w/375)

#### #1.3 测量数据统计分析

>总共测试 5 次。

次数 | preMain | mian 到首屏控制器 viewDidAppear
:----:|:------:|:----:
第一次 | 584.76ms  |4.276s
第二次 | 628.80ms  |4.173s
第三次 | 815.88ms  |4.334s
第四次 | 610.94ms  |4.331s
第五次 | 590.88ms  |4.357s
平均值 | 646.25ms  | 4.294s

#### #1.4 优化方向

- preMain
	- preMain 时间在小于 400ms 是最佳的，因为从点击图标到显示启动图，再到启动图消失这段时间是 400ms。同时启动时间不可以大于 20s，否则会被系统杀掉。
	- 这里面主要做了一些 iOS 系统动态库的链接、App 中 objc 类的加载。
	- 针对这里的优化：
		- 合并自己添加的动态库，减少动态库的数量，目前我们没有使用自己添加的动态库；
		- 合并 Category 和功能类似的类，这个确实存在不少；
		- 删除无用的方法和类；
		- 用 initialize 方法替代 load，减少每个类的 load 方法的执行时间；

- main()函数 -> 第一个页面渲染完成，用户看到界面的时间。这里可以做的优化有：
	- 从几次测试数据可以看出，主要的耗时一个是在第三方 SDK 的初始化上，耗时超过 1s，另一个是根控制器极其相关控制器的初始化上。所以优化性价比最高的地方应该是这两个地方
		- 能延迟执行的就延迟执行。比如 SDK 的初始化，界面的创建，将页面请求加载数据、渲染等操作转移到viewWillAppear 方法中去；
		- 不能延迟执行的，尽量放到后台执行，比如一些读取沙盒用户偏好缓存的数据操作；

### 2. 安装包体积

### #2.1 包体积检测和分析

打包后的 ipa 包体积：

![](https://liangjinggege.com/Xnip2018-07-13_19-52-59.png)

解压缩后右键显示包内容：

![](https://liangjinggege.com/Xnip2018-07-13_19-52-41.png)


可以看到安装包主要构成：

![](https://liangjinggege.com/Xnip2018-07-13_19-56-14.png)

其中，主要的体积消耗在：

1. 二进制代码：31.2 M
2. .car 资源文件：11.2 M
3. 图片等资源文件：4.7 M

### #2.2 包体积优化

- 图片优化：使用 [ImageOptim](https://github.com/ImageOptim/ImageOptim) 图片压缩工具对工程中的图片做一次压缩处理；
- 清除无用的资源：使用 [LSUnusedResources](https://github.com/tinymind/LSUnusedResources) 工具，清除掉工程中未使用到的资源文件；

![](https://liangjinggege.com/Xnip2018-07-13_20-15-39.png)

>可以看到无用的资源文件特别多。

- 二进制文件优化：使用 [LinkMap](https://github.com/huanxsd/LinkMap) 工具检测出每个类或者库在最终的可执行文件中所占用的空间大小（代码段+数据段），进行针对性的优化；

编译后 arm 7 架构下每个库或者类在最终的可执行文件中所占用的空间大小：

![](https://liangjinggege.com/Xnip2018-07-13_20-25-07.png)

- 一些编译选项优化的开关开启；

### 3. 内存

- Xcode Analyze 静态分析工具分析可疑泄露点，有些真的存在，有些不存在，可以通过结合 Instruments 动态分析工具以及代码上下文排除解决

![](https://liangjinggege.com/Xnip2018-07-13_15-54-58.png)


- 主要包含以下几个部分：
	
	- 面向用户的文本应该使用本地化;
	- 无效数据监测;
	- 逻辑错误：访问空指针或未初始化的变量等；
	- 内存管理错误：如内存泄漏等；
	- 声明错误：从未使用过的变量；
	- API 调用错误：未包含使用的库和框架;

- Xcode Instruments 动态分析工具中的 Leaks 和 Allocations 跟踪模板进行动态跟踪分析, 确认这些点是否真的泄漏, 或者是否有新的泄漏点出现

![](https://liangjinggege.com/Xnip2018-07-13_19-09-50.png)
![](https://liangjinggege.com/Xnip2018-07-13_19-10-33.png)

### #3.1. 内存方面可做的优化
一般在占用系统内存超过 20% 的时候会有内存警告，而超过 50% 的时候，就很容易被系统 Crash。

- iOS 中内存问题主要包含两个部分:

- 循环引用

	- Delegate：检查所有用到的代理对象属性是否是使用weak内存管理策略
	- NSTimer：使用 GCD 定时器代替 NSTimer，GCD 定时器的优点是时间误差小，不会发生循环引用；
	- Block: 检查所有用到 Block 的地方，是否存在循环引用问题；
	- NSNotificationCenter：检查 NSNotification addObserver 后是否有移除；
- 大量数据加载及使用导致的内存警告

	- 处理每个单独页面以及整个 App 收到的内存警告，及时释放掉相关的资源；


### 4. 页面卡顿

根据苹果官方说法，当 FPS 低于 45 的时候，用户就会察觉到到滑动有卡顿

- 日常开发时，做好 FPS 实时监控，可使用 [FHHFPSIndicator](https://github.com/jvjishou/FHHFPSIndicator) 工具在 debug 模式下运行，在出现掉帧的页面，可做如下优化：

	- 清除在主线程中进行的耗时操作
	- 建立缓存机制，如缓存表格视图中 cell 的高度；
	- 避免离屏渲染，尽量避免使用 layer 的 border、corner、shadow、mask 等属性，在后台线程预先绘制好对应内容；


## 性能优化原则

过早的优化是万恶之源。优化要站在实际的需求角度出发，不能为了优化而优化，应该优化那些真正的性能瓶颈，体验落后，性价比最高、最值得优化的地方，同时又要站在整体的角度，做一些取舍和权衡，比如为了卡顿优化，往往需要缓存一些数据到内存中，从而会引起内存增长，如果内存中缓存的数据过多，内存就容易出现性能瓶颈，为了更好更快的监控一些数据，往往会集成一些第三方 SDK，这就又会导致安装包体积的增加。

具体应该通过检测到的性能数据指标来做具体优化，可以使用苹果自带的 instruments 工具来检测，找到突破点，优化一点，检测一下，观察性能数据的变化，如此反复。

[性能优化原则](https://juejin.im/post/5ac216075188255c93237306)

## 如何提高应用的质量

### 1. 开发日常避免

- 制定代码规范，严格遵守
- 定期代码审查（code review）
- 编写单元测试
- 引入一些 debeg 模式下的工具，如内存泄漏监控，FPS 等，在开发调试阶段将问题暴露出来；
- 定期进行代码重构，及时清理删除一些没有使用到的资源和代码；

### 2. 测试保障体系
- 将一些关键性能指标纳入测试上线标准
- 引入一些自动化测试，自动化打包，自动化代码集成的工具脚本，提高日常开发测试工作效率

### 3. 线上APM监控
- 自研或者借助第三方的 APM 工具。对线上应用进行监控、预警、快速修复。


## 参考资料

- [即刻 iOS App 启动速度研究实践](https://zhuanlan.zhihu.com/p/38183046)
- [腾讯 wifi 管家 iOS App 启动性能优化-](https://cloud.tencent.com/developer/article/1071732)
- [今日头条 iOS 客户端启动速度优化](https://techblog.toutiao.com/2017/01/17/iosspeed/)
- [今日头条 iPhone 安装包的优化](https://techblog.toutiao.com/2016/12/27/iphone/)
- [iOS 内存泄漏监测自动化](http://www.cocoachina.com/ios/20170102/18490.html)