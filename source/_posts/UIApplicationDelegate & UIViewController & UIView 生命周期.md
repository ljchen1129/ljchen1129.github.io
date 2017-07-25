---
title: UIApplication && UIViewController && UIView 生命周期
date: 2017-06-02 09:23:26
tags:
- iOS
- 生命周期
categories:
- iOS
- UIApplication
- UIViewController
- UIView
---

## UIApplicationDelegate

**几个角色：**

* UIApplication 对象
	1. 处理用户与 iOS 设备交互时产生的事件（Multitouch Events，Motion Event，Remote Control Event）交由 UIApplication 对象来分发给 UIControl 对应的 target 对象来处理并且管理整个事件，而一些关于 App 运行时重要事件委托给 App delegate 来处理。
	2. 负责初始化并显示 UIWindow，并负责加载应用程序的第一个 UIView 到 UIWindow 窗体中。
	3. 帮助管理应用程序的生命周期，通过 UIApplicationDelegate 代理类来实现，UIApplication 对象接收这些生命周期事件，UIApplicationDelegate 决定如何响应这些事件(应用程序的生命周期事件（比如程序启动和关闭）、系统事件（比如来电、记事项警告）)
	
* App delegate 对象
	* 遵循 UIApplicationDelegate 协议，响应 app 运行时重要事件（App 启动、App 内存不足、App 终止、切换到另一个 App、切回 App），主要用于在 App 启动时初始化一些重要的数据结构，如：初始化 UIWindow，设置一些属性，为 window 添加 rootViewController（self.window.rootViewController = [[XXXViewController alloc] init] 相当于 [self.window addSubview: [[XXXViewController alloc] init].view]）。
	
* UIWidow 对象
	* UIWidow 对象位于 view 层次结构中的最顶层，充当一个基本容器但不显示内容的角色，如显示内容要添加一个 content view 到 window。
	
* View、Control、Layer 对象
	* View：通过 addSubview 和 removeFromSuperView 等方法管理 view 的层次结构，使用 layoutSubviews、layoutIfNeeded 和 setNeedsLayout 等方法布局 view 的层次结构，通过重写 drawRect 方法或通过 layer 属性来构造更复杂的图形界面和动画，UIView 继承自 UIResponder，同样能够处理用户事件。
	* Control：通常是处理特定类型用户交互的 View，常用有 button、switch、textField 等。
	* Layer：Core Animation 框架的 Layer 对象，可以用来渲染 view 的界面和构建复杂的动画。
	
* ViewController 对象
	* ViewController 有一个 view 属性是 view 层次结构中的根 view，可以添加子 view 来构建复杂的 view，ViewController 的一些 ViewDidLoad、ViewWillAppear、ViewDidAppear、ViewWillDisAppear、ViewDidDisAppear、LoadView 方法来管理 view 的生命周期，ViewController 还继承自 UIResponser，还可以响应和处理用户事件。

**应用程序启动：**

![](http://o6heygfyq.bkt.clouddn.com/1933920-acb1107656c1a483.png)

应用程序启动 -> 执行 main 函数 -> 执行 UIApplicationMain 函数 -> 初始化 UIApplication 对象（创建和设置代理对象，开启主线程 ranloop）-> 代理对象监听系统事件（程序加载完毕、程序获取焦点、程序进入后台、程序失去焦点、程序从后台回到前台、内存警告、程序即将退出）-> 结束程序

**应用程序的状态和多任务：**
应用程序有好几种状态，当按下 Home 键，锁屏、电话打来，切换 App 等中断情况时都会造成应用程序的状态发生改变。

![](http://o6heygfyq.bkt.clouddn.com/5588c94641d3a.jpg)

* Not running：App 还没运行
* Inactive：App 运行在前台但没有接收事件
* Active：App 运行在前台和正在接收事件
* Running：App 运行在后台和正在执行代码
* Suspended：App 运行在后台但没有执行代码

```
// 这个方法是在程序启动时的第一次机会执行代码
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"程序将要启动完成%s", __func__);
    return YES;
}

// 这个方法允许在显示 app 给用户之前执行最后的初始化操作
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"程序启动完成%s", __func__);
    return YES;
}

// app 将要从前台切换到后台时需要执行的操作
- (void)applicationWillResignActive:(UIApplication *)application {
{
   NSLog(@"程序将要失去焦点%s", __func__);
}

// app 已经进入后台后需要执行的操作
- (void)applicationDidEnterBackground:(UIApplication *)application {
{
    NSLog(@"程序已经进入后台%s", __func__);
}

// app 将要从后台切换到前台需要执行的操作，但 app 还不是 active 状态
- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"程序即将进入前台%s", __func__);
}

// app 已经切换到 active 状态后需要执行的操作
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"程序已经获得焦点%s", __func__);
}

// app将要结束时需要执行的操作， 可以做一些数据保存工作
- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序将要退出%s", __func__);
}

```

* App 启动和 active/inactive
	
	App 一启动，由	Not running 状态变成 Inactive 状态，调用 `application didFinishLaunchingWithOptions` 方法，然后由 Inactive 状态变成 Active 状态，调用 `applicationDidBecomeActive` 方法
	![](http://o6heygfyq.bkt.clouddn.com/5588d15fc4c41.gif)
	
	
	当 App 由于一些原因（来电等系统事件）发生中断时，由 Active 状态变成 Inactive 状态，调用 `applicationWillResignActive` 方法。
	![](http://o6heygfyq.bkt.clouddn.com/5588d56cdc36a.gif)
	
* 来回切换App
	
	当 App 切换到另一个 App 时，先由 Active 状态变成 Inactive 状态，调用 `applicationWillResignActive` 方法，然后再从 Inactive 状态变成 running 状态，调用 `applicationDidEnterBackground` 方法。
	![](http://o6heygfyq.bkt.clouddn.com/5588d259ba79b.gif)
	
	当切换回本 App 时，先由 running 状态变为 Inactive 状态，调用 `applicationWillEnterForeground` 方法，然后由 Inactive 状态变为 Active 状态，调用 `applicationDidBecomeActive` 方法。
	![](http://o6heygfyq.bkt.clouddn.com/5588d2941520f.gif)
	
* 锁屏
	
	锁屏时，先由 Active 状态变成 Inactive 状态，调用 `applicationWillResignActive` 方法，然后由 Inactive 状态变为 Running 状态，调用 `applicationDidEnterBackground` 方法。
	![](http://o6heygfyq.bkt.clouddn.com/5588d2a8aa73a.gif)
	
* 应用程序终止

	当应用程序由于内存警告或长时间驻留后台等一些原因需要被操作系统终止时，系统还在应用程序终止前调用一次 `applicationWillTerminate` 方法，用来保存用户的一些重要数据以便于下次启动时恢复到 app 原来的状态。

## UIViewController

**UIView 的加载**

![](http://o6heygfyq.bkt.clouddn.com/1354776680_2123.png)

控制器 view 的加载时懒加载的，只用用到时才会去加载，首先调用的 loadView 方法，

**UIView 的卸载**


### 1. 通过 XIB 加载

通过 XIB 这种方式加载视图，需要调用 UIViewController 类的`initWithNibName:bundle:` 方法

```
TestVC_XIB *vc = [[TestVC_XIB alloc] initWithNibName:@"TestVC_XIB" bundle:nil];
[self.navigationController pushViewController:vc animated:YES];

```

**打印结果：**

```
2017-06-07 16:10:45.971 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB initWithNibName:bundle:]
2017-06-07 16:10:45.973 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB loadView]
2017-06-07 16:10:45.973 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewDidLoad]
2017-06-07 16:10:45.974 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewWillAppear:]
2017-06-07 16:10:45.978 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewWillLayoutSubviews]
2017-06-07 16:10:45.978 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewDidLayoutSubviews]
2017-06-07 16:10:45.979 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewWillLayoutSubviews]
2017-06-07 16:10:45.979 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewDidLayoutSubviews]
2017-06-07 16:10:46.551 UIApplicationDelegate & UIViewController & UIView 生命周期[12890:696585] -[TestVC_XIB viewDidAppear:]

```


### 2. 通过 StoryBoard 加载

通过这种方式创建 UIViewController 对象的话，首先生成 `UIStoryboard 类型的对象，然后调用这个对象的`instantiateViewControllerWithIdentifier:` 方法

```
UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TestVC_SB" bundle:nil];
    TestVC_SB *sbVC = [sb instantiateViewControllerWithIdentifier:@"TestVC_SB"];
    [self.navigationController pushViewController:sbVC animated:YES];
    
```

**打印结果：**

```
2017-06-07 16:13:40.326 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB initWithCoder:]
2017-06-07 16:13:40.326 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB awakeFromNib]
2017-06-07 16:13:40.328 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB loadView]
2017-06-07 16:13:40.329 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewDidLoad]
2017-06-07 16:13:40.329 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewWillAppear:]
2017-06-07 16:13:40.334 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewWillLayoutSubviews]
2017-06-07 16:13:40.335 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewDidLayoutSubviews]
2017-06-07 16:13:40.335 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewWillLayoutSubviews]
2017-06-07 16:13:40.335 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewDidLayoutSubviews]
2017-06-07 16:13:40.894 UIApplicationDelegate & UIViewController & UIView 生命周期[12957:699432] -[TestVC_SB viewDidAppear:]

```

### 3. 通过 NSCoding 协议加载



### 4. 通过代码加载

```
2017-06-07 16:07:03.799 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code initWithNibName:bundle:]
2017-06-07 16:07:03.800 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code init]
2017-06-07 16:07:03.802 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code loadView]
2017-06-07 16:07:03.803 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewDidLoad]
2017-06-07 16:07:03.803 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewWillAppear:]
2017-06-07 16:07:03.809 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewWillLayoutSubviews]
2017-06-07 16:07:03.809 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewDidLayoutSubviews]
2017-06-07 16:07:03.809 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewWillLayoutSubviews]
2017-06-07 16:07:03.810 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewDidLayoutSubviews]
2017-06-07 16:07:04.373 UIApplicationDelegate & UIViewController & UIView 生命周期[12823:692994] -[TestVC_Code viewDidAppear:]

```


## UIView


### 1. 通过 Xib 加载

### 2. 通过代码加载


## 参考资料
[iOS UIApplicationDelegate与UIViewController生命周期](http://www.imlifengfeng.com/blog/?p=478)
[UIView的生命周期总结](https://bestswifter.com/uiviewlifetime/)
[深度解析iOS应用程序的生命周期](http://www.csdn.net/article/2015-06-23/2825023/1)
[UIViewController和UIView不同加载方式的生命周期函数](http://www.jianshu.com/p/73879a117d2d)
[iOS-控制器View的创建和生命周期](http://www.jianshu.com/p/b3b4f08e88c4)
[UIView的生命周期](http://www.jianshu.com/p/9d98fad685c8)
