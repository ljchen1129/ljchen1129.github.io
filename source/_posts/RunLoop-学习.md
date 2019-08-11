---
title: RunLoop 学习
date: 2017-05-09 12:06:12
tags:
- iOS
- RunLoop
categories:
- iOS
- RunLoop
---

## 介绍
RunLoop：运行循环，每个线程对应一个 RunLoop，主线程的 RunLoop 默认启动，子线程的 RunLoop 需要手动启动。

![](https://liangjinggege.com/runloop.jpg)

**作用：**

- 使程序一直运行并接受用户输入
- 决定程序在何时应该处理那些事件
- 调用解耦（Message Queue）
- 节省 CPU 时间

RunLoop 实际上就是一个对象，这个对象管理了其需要处理的事件和消息，并提供了一个入口函数来执行上面事件循环的逻辑。线程执行了这个函数后，就会一直处于这个函数内部 "接受消息->等待->处理" 的循环中，直到这个循环结束（比如传入 quit 的消息），函数返回。

## 构成元素
<!-- more -->
**CFRunLoopRef** ：在 CoreFoundation 框架内的，提供了纯 C 函数的 API，所有这些 API 都是线程安全的。

**NSRunLoop** ：基于 CFRunLoopRef 的封装，提供了面向对象的 API，但是这些 API 不是线程安全的。

![](https://liangjinggege.com/RunLoop%20comm.001.jpeg)

**说明：**一个 RunLoop 包含若干个 Mode，每个 Mode 又包含若干个 Source/Timer/Observer。每次调用 RunLoop 的主函数时，只能指定其中一个 Mode，这个 Mode 被称作 CurrentMode。如果需要切换 Mode，只能退出 Loop，再重新指定一个 Mode 进入。这样做主要是为了分隔开不同组的 Source/Timer/Observer，让其互不影响。

![](https://liangjinggege.com/RunLoop_mode.png?imageView/0/h/300)

**CFRunLoopSourceRef**：事件产生的地方。有 `Source0` 和 `Source1` 两个版本。

-  **Source0：**只包含了一个回调（函数指针），并不能主动触发事件。使用时，需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。处理 App 累不时间，App 自己负责管理，如 UIEvent、CFSocket
-  **Source1：**包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。能主动唤醒 RunLoop 的线程。由 RunLoop 内核管理，Mach port 驱动，如 CFMachPort、CFMessagePort

**CFRunLoopTimerRef**：基于时间的触发器，和 NSTimer 是 toll-free bridged 的，可以混用。包含一个时间长度和一个回调（函数指针）。当加入到 RunLoop 时，RunLoop 会注册对应的时间点，当时间点到时，RunLoop 会被唤醒以执行那个回调。

**CFRunLoopObserverRef**：观察者。每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接收到这个变化。可以观测的时间点有：

```
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
	/// 即将进入 Loop
    kCFRunLoopEntry = (1UL << 0), 
    
    /// 即将处理 Timer 
    kCFRunLoopBeforeTimers = (1UL << 1), 
    
    /// 即将处理 Source
    kCFRunLoopBeforeSources = (1UL << 2), 
    
    /// 即将进入休眠
    kCFRunLoopBeforeWaiting = (1UL << 5), 
    
    /// 刚从休眠中醒来
    kCFRunLoopAfterWaiting = (1UL << 6), 
    
    /// 即将退出 Loop
    kCFRunLoopExit = (1UL << 7), 
    
    /// RunLoop 所有活动状态
    kCFRunLoopAllActivities = 0x0FFFFFFFU 
};

```

## RunLoop 内部逻辑

![](https://liangjinggege.com/RunLoop_process.png?imageView/0/h/450)

每次运行 `Run Loop`， 线程的 `Run Loop` 都会自动处理之前`未处理的的消`息，并通知相关的`观察者`。

1. 通知观察者 `Run Loop` 已经启动
2. 通知观察者`任何即将要开始`的`定时器`
3. 通知观察者`任何即将启动`的 `Source0`(非基于端口的源)
4. 通知观察者`任何准备好`的 `Source0`(非基于端口的源)
5. 如果 `Source1` （基于端口的源）准备好并处于等待状态，立即启动，并进入步骤 9
6. 通知观察者线程进入`休眠`
7. 将线程置于休眠直到任一下面的事件发生：
	- 某一事件到达 Source1 （基于端口的源）
	- 定时器启动
	- Run Loop 设置的时间已经超时
	- Run Loop 被`显式唤醒`
	
8. 通知观察者线程将`被唤醒`
9. 处理未处理的事件
	- 如果用户定义的定时器启动，处理定时器事件并重启 Run Loop，进入步骤 2
	- 如果输入源启动，传递相应的消息
	- 如果 Run Loop 被`显式唤醒`并且时间`还没超时`，重启 Run Loop，进入步骤 2
10. 通知观察者 Run Loop 结束。


## CFRunLoopMode

- **NSDefaultRunLoopMode**：默认状态，空闲状态。App的默认 Mode，通常主线程是在这个 Mode 下运行的
- **UITrackingRunLoopMode**：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响。
- **UIInitializationRunLoopMode**：刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用，私有。
- **NSRunLoopCommonModes**：UITrackingRunLoopMode 和 NSDefaultRunLoopMode

## 常用方法
### 1. 获取主线程 RunLoop

	CFRunLoopRef mainRunLoop = CFRunLoopGetMain();


### 2. 获取当前线程 RunLoop

	CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent()

### 3. 对 Mode 的管理接口

```
// 添加常用 CommonMode
// CFRunLoopRef ： RunLoop 实例对象
// CFRunLoopMode : mode 名称
CFRunLoopAddCommonMode(CFRunLoopRef rl, CFRunLoopMode mode)
    
/// RunLoop 运行在什么模式中
CFRunLoopRunInMode(CFRunLoopMode mode, CFTimeInterval seconds>, Boolean returnAfterSourceHandled)

```

### 4. Mode 对 mode item 的接口管理

	// 添加 Source/Timer/Observer
	CFRunLoopAddSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef modeName);
	CFRunLoopAddObserver(CFRunLoopRef rl, CFRunLoopObserverRef observer, CFStringRef modeName);
	CFRunLoopAddTimer(CFRunLoopRef rl, CFRunLoopTimerRef timer, CFStringRef mode);
	
	// 移除 Source/Timer/Observer
	CFRunLoopRemoveSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef modeName);
	CFRunLoopRemoveObserver(CFRunLoopRef rl, CFRunLoopObserverRef observer, CFStringRef modeName);
	CFRunLoopRemoveTimer(CFRunLoopRef rl, CFRunLoopTimerRef timer, CFStringRef mode);


>**说明：**只能通过 mode name 来操作内部的 mode，当传入一个新的 mode name 但 RunLoop 内部没有对应 mode 时，RunLoop 会自动创建对应的 CFRunLoopModeRef。对于一个 RunLoop 来说，其内部的 mode 只能增加不能删除。

### 5. 添加观察者，监听 RunLoop 活动状态的改变
![](https://liangjinggege.com/Snip20170509_13.png)


>注意：CF 对象的内存管理
>
>1. 凡是带有 Creat、Copy、Retain 的关键字的函数，都需要在最后做一次 release 操作
>2. release 函数：CFRealease(对象)

## 使用场景
### #1. 定时器
![](https://liangjinggege.com/Snip20170509_10.png)

### #2. 子线程异步通知
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSNotification%20%E5%AD%A6%E4%B9%A0)

通知的特点

- 通知`默认同步执行`的
- 当前发送通知的线程在那条线程，通知执行就会在那条线程。

![](https://liangjinggege.com/Snip20170509_9.png)

### #3. 创建常驻线程（线程保活）
子线程默认没有开启 Run Loop，开启子线程后，当任务一结束，子线程就会立即销毁。有时候需要子线程一直存在，做一些事情，这种情况下就可以使用 Run Loop 创建常驻线程。

![](https://liangjinggege.com/Snip20170509_14.png)


### #4. 自动释放池

- **第一次创建：**启动 Run Loop 时
- **最后一次销毁：** Run Loop 退出的时候
- **其他时候的创建和销毁：**当 Run Loop 即将睡眠的时候销毁之前的释放池，重新创建一个新的释放池  

### #5. ImageView 显示
指定 ImageView 视图不在 `UITrackingRunLoopMode` 模式下设置。

### #6. PerformSelector

```
// 指定在哪个 RunLoop 模式下执行方法
[self performSelector:@selector(run) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO modes:@[UITrackingRunLoopMode]];
    
```

## 总结

1. runloop 应用场景？
	- 开启一个常驻线程（让一个子线程不进入消亡状态，等待其他线程发来的消息，处理其他事件）
	- 在子线程中开启一个定时器
	- 在子线程中进行一些长期监控
	
2. 可以控制定时器在那种模式下运行
3. 可以设置某些事件（行为、任务）在特定模式下执行
4. 可以添加 Observer 监听 RunLoop 的状态，比如监听点击事件的处理，在所有点击事件之前做一些事情。

## 学习资料
[苹果官方文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html
)
[CFRunLoopRef 源代码](http://opensource.apple.com/source/CF/CF-1151.16/
)
[iOS线下分享《RunLoop》by 孙源@sunnyxx](http://v.youku.com/v_show/id_XODgxODkzODI0.html#paction)
[深入理解RunLoop](http://blog.ibireme.com/2015/05/18/runloop/)
