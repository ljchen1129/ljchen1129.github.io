---
title: iOS 多线程-NSThread
date: 2017-03-17 16:02:43
tags:
- iOS
- 多线程
categories:
- iOS
- 多线程
---

# 前言
`NSThread` 是实现 iOS 多线程技术的一种方案。是用 OC 语言编写的，由程序员管理线程生命周期，简单易用，可直接操作，使用更加地面向对象。

# 创建线程

```
- (IBAction)buttonClick:(id)sender
{
    // 1.创建线程对象
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:@"testParm"];
    
    // 2. 启动线程
    [thread start];
}

- (void)run:(NSString *)parm
{
    // 获取当前线程对象
    NSThread *currentThread = [NSThread currentThread];
    NSLog(@"----run----%@---%@", parm, currentThread);
}

```

控制台打印，可以看到：

1. 确实创建了一个新的线程；
2. 参数也已经成功传递过去了；

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_11.png?imageView2/0/h/45/)

> 注意：NSThread 创建的线程对象，系统会保证他的生命周期直到线程要执行的任务完成。

可以测试一下，新建一个类 TestThread，继承自 NSThread，重写他的 dealloc 方法：

```
- (IBAction)buttonClick:(id)sender
{
    // 1.创建线程对象
    TestThread *thread = [[TestThread alloc] initWithTarget:self selector:@selector(run:) object:@"testParm"];
    
    // 2. 启动线程
    [thread start];
}

- (void)run:(NSString *)parm
{
    for (int i = 0; i < 50; i++)
    {
        // 获取当前线程对象
        NSThread *currentThread = [NSThread currentThread];
        NSLog(@"run-%zd---%@---%@", i, parm, currentThread);
    }
}

```

查看控制台输出：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_12.png?imageView2/0/h/120/)

## 方法二
创建线程后自动启动线程：

```
[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"testParm"];

```

## 方法三

创建一个后台线程后自动启动线程：

```
[self performSelectorInBackground:@selector(run:) withObject:@"testParm"];

```

## 总结
>方法二和方法三比方法一更能简单快捷的创建线程，但是无法对线程进行更详细的设置



# 主线程相关方法

```
[NSThread mainThread];// 获得主线程（类方法）
[thread isMainThread]; // 是否为主线程（对象方法）
[NSThread isMainThread];// 是否为主线程（类方法）

```

# 线程其他方法

```
// 获取当前线程对象
NSThread *currentThread = [NSThread currentThread];

// 设置线程名字
- （void）setName:(NSString:)name;

```

# 线程的状态
## 线程总共有五种状态

1. **新建（New）：**当线程刚新建时的状态，还没有调用 start 方法
2. **就绪（Runnable）：**
	- `新建状态`的线程调用了开启线程的 start 方法会进入`就绪状态`；
	- 处于`阻塞状态`下的线程由于 sleep 到时或者得到同步锁，也会进入`就绪状态`；
	- 处于`运行状态`下的线程，当 CPU 去转换调度其他线程时，当前线程就会进入到`就绪状态`； 
3. **运行（Running）：**CPU 调度`就绪状态`的当前线程，当前线程就进入`运行状态`
4. **阻塞（Blocked）：**处于`运行状态`的线程调用了 sleep 方法或者在等待同步锁时会进入到`阻塞状态`
5. **死亡（Dead）：**线程任务执行完毕、或异常退出、强制退出时线程会进入到`死亡状态`

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_14.png?imageView2/0/h/350/)

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_15.png?imageView2/0/h/170/)

## 控制线程状态

### #启动线程

```
// 进入就绪状态 -> 运行状态，当任务执行完毕，自动进入死亡状态
- (void)start;
	
```

### #阻塞（暂停）线程

```
// 进入阻塞状态
// 让线程睡到 date 日期
+ (void)sleepUntilDate:(date *)date;
// 线程睡 timeInterval 时间
+ (void)sleepForTimeInterval:(NSTimeInterval)timeInterval;
	
```

### #强制停止线程

```
// 线程进入死亡状态
+ (void)exit;
	
```

>注意：线程一旦停止（死亡）了，就不能再次开启任务

# 线程安全

## 资源共享

- 同块资源可能会被多个线程共享，也就是`多个线程可能会访问同一块资源`
- 比如多个线程访问同一个对象、同一个变量、同一个文件

>当多个线程访问同一块资源时，很容易引发`数据错乱和数据安全`问题

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_100.png?imageView2/0/h/350/)

## 解决方案 - `互斥锁`

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_102.png?imageView2/0/h/350/)

### #互斥锁使用格式

```
@synchronized(所对象)
{
	// 需要锁定的代码
}

```

### #互斥锁优缺点

- 优点：能有效防止因多线程抢夺资源造成的数据安全问题
- 缺点：需要消耗大量 CPU 资源

### #互斥锁使用前提

- 多条线程抢夺同一块资源

### #线程同步

- 线程同步：多条线程在同一条线上执行（按顺序地执行任务）
- 互斥锁：就是使用了线程同步技术

### #原子和非原子属性

- atomic：原子熟悉，会为 setter 方法加锁（默认就是 atomic）。线程安全，需要消耗大量的资源
- nonatomic：非原子属性，不会为 setter 方法加锁（默认就是 atomic）。非线程安全，适合内存小的移动设备

- 建议：

	1. 所有属性都声明为 nonatomic
	2. 尽量避免多线程抢夺同一块资源
	3. 尽量将加锁、资源抢夺的业务逻辑交给服务器处理，减小移动设备客户端的压力

- 以售票场景为例：

	```
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    
	    // 创建线程
	    self.thread01 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
	    self.thread01.name = @"售票员01";
	    
	    self.thread02 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
	    self.thread02.name = @"售票员02";
	
	    self.thread03 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
	    self.thread03.name = @"售票员03";
	    
	    self.ticketCount = 100;
	}
	
	- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
	{
	    // 开启线程
	    [self.thread01 start];
	    [self.thread02 start];
	    [self.thread03 start];
	}
	
	- (void)saleTicket
	{
	    while (1)
	    {
	        // 先取出总数
	        NSInteger count = self.ticketCount;
	        if (count > 0)
	        {
	            // 让线程睡 0.1 秒，进入阻塞状态
	            [NSThread sleepForTimeInterval:0.1];
	            
	            self.ticketCount = count - 1;
	            NSLog(@"%@卖了一张票，还剩下%ld张", [NSThread currentThread].name, self.ticketCount);
	        }
	        else
	        {
	            NSLog(@"票已经买完了");
	            break;
	        }
	    }
	}
	
	```

看控制台打印：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_16.png?imageView2/0/h/350/)

很明显出现了`数据错乱和数据安全`问题

在读写数据的地方加把`互斥锁`：

```
- (void)saleTicket
{
    while (1)
    {
        // self 用做锁对象，可保持所对象不发生变化
        @synchronized (self)
        {
            // 先取出总数
            NSInteger count = self.ticketCount;
            if (count > 0)
            {
                // 让线程睡 0.1 秒，进入阻塞状态
                [NSThread sleepForTimeInterval:0.1];
                
                self.ticketCount = count - 1;
                NSLog(@"%@卖了一张票，还剩下%ld张", [NSThread currentThread].name, self.ticketCount);
            }
            else
            {
                NSLog(@"票已经买完了");
                break;
            }
        }
    }
}

```

再看控制台打印：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_17.png?imageView2/0/h/350/)

# 线程间通信
## 什么叫做线程间通信？

- 在一个进程中，线程往往不是孤立存在的，多个线程之间需要经常进行通信
	- 一个线程传递数据给另一个线程
	- 在一个线程执行完特定任务后，在转到另一个线程继续执行任务
	
## 系统方法

```
performSelectorOnMainThread:@selector withObject: waitUntilDone:
performSelector:@selector(setImage:) onThread: withObject:image waitUntilDone: 

```

## Port 端口

- NSPort
- NSMessagePort
- NSMachPort
	
![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_105.png?imageView2/0/h/320/)

## 线程间通信示例 - 图片下载

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_103.png?imageView2/0/h/350/)


```
// 1. 获取图片地址url
NSURL *url = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=ca5abb5b7bf0f736ccf344536b3cd87c/29381f30e924b899c83ff41c6d061d950a7bf697.jpg"];
    
// 测试代码执行时间
//    NSDate *begin = [NSDate date];
CFTimeInterval begin = CFAbsoluteTimeGetCurrent();
// 2. 下载图片,耗时操作
NSData *data = [NSData dataWithContentsOfURL:url];
//    NSDate *end = [NSDate date];
CFTimeInterval end = CFAbsoluteTimeGetCurrent();
//    NSLog(@"%f",[end timeIntervalSinceDate:begin]);
NSLog(@"%f",end - begin);
    
// 3. 将图片显示到 imageView 上
self.imageView.image = [UIImage imageWithData:data];
    
```

可以发现下载图片这段耗时操作耗时：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170316_18.png?imageView2/0/h/60/)

而这种耗时操作不应该放在主线程中进行

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 开一个子线程去下载图片
    [self performSelectorInBackground:@selector(downImage) withObject:nil];
}

- (void)downImage
{
    // 1. 获取图片地址url
    NSURL *url = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=ca5abb5b7bf0f736ccf344536b3cd87c/29381f30e924b899c83ff41c6d061d950a7bf697.jpg"];
    
    // 2. 下载图片,耗时操作
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    // 3. 图片下载完成，回到主线程刷新 UI，并传递 image 参数回去
    // waitUntilDone 参数：指是否等主线程 showImage: 方法执行完成，如果 YES，则会等 showImage: 方法执行完毕才会继续		执行下面的代码
	[self performSelectorOnMainThread:@selector(showImage:) withObject:image waitUntilDone:YES];   
}

- (void)showImage:(UIImage *)image
{
    // 将图片显示到 imageView 上
    self.imageView.image = image;
}

```

回到主线程还有`方法二:`

```
[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];

```

`方法三:`

```
[self.imageView performSelector:@selector(setImage:) onThread:[NSThread mainThread] withObject:image waitUntilDone:NO];

```

>这样就实现了线程间的通信，现在主线程开一条子线程去执行下载图片的耗时操作，等到图片下载完成在从子线程回到主线程，并把图片传递到主线程，刷新 UI。