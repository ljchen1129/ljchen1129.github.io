---
title: iOS 多线程-GCD
date: 2017-03-17 16:02:58
tags:
- iOS
- 多线程
categories:
- iOS
- 多线程
---

# GCD 基本介绍
## 什么是 GCD？

- 全称是 Grand Gentral Dispatch，可翻译为“牛逼的中枢调度器”
- 纯 C 语言，提供了非常强大的函数
	
## GCD 的优势？

- GCD 是苹果公司为`多核`的`并行`运算提出的解决方案
- GCD 会自动利用更多的 CPU 内核（比如双核，四核）
- GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
- 程序员只需要告诉 GCD 想要执行什么任务，不需要编写任何线程管理代码

## 任务和队列

- 任务：执行什么操作
- 队列：用来存放任务
<!-- more -->
# GCD 的使用

## 定制任务
- 确定想做的事情

## 将任务添加到队列中
- GCD 会自动将队列中的任务取出，放到对应的线程中去执行
- 任务的取出遵循队列的 FIFO(先进先出，后进后出)

## 执行任务

```
// 用`同步`的方式执行任务
// queue：队列
// block：任务
dispatch_sync(dispatch_queue_t  _Nonnull queue, ^(void)block)

// 用`异步`的方式执行任务
// queue：队列
// block：任务
dispatch_async(dispatch_queue_t  _Nonnull queue, ^(void)block)

```

## 同步和异步
- 同步：只能在`当前线程`中执行任务，`不具备`开启新线程的能力
- 异步：可以在`新的线程`中执行任务，`具备`开启线程的能力
	
## 队列的类型
### 并发队列(Concurrent Dispatch Queue)
- 可以让多个任务`并发（同时）`执行（自动开启多个线程同时执行任务）
- 并发功能只有在异步（dispatch_async）函数下才有效
	
### 串行队列（Serial Dispatch Queue）
- 让任务一个接着一个得执行（一个任务执行完毕后，再执行下一个任务） 

# GCD 基本使用
## 并发队列

- `方法一：`GCD 默认已经提供了`全局的并发队列`，共整个应用使用，可以无需手动创建
	
	```
	
	/**
    获的系统全局并发队列
	
    @param identifier：队列的优先级：DISPATCH_QUEUE_PRIORITY_HIGH 2，
    									 DISPATCH_QUEUE_PRIORITY_DEFAULT 0，										 DISPATCH_QUEUE_PRIORITY_LOW （-2），
    									 DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
    @param flags：默认传 0，无用的参数
    @return 返回一个全局并发队列
    */
   dispatch_queue_t queue = dispatch_get_global_queue(long identifier, unsigned long flags)
   
	```
	
- `方法二：`创建并发队列
	
	```
	// 1.创建一个并发队列
/**
 @param label: 相当于队列的名字
 @param attr: 串行队列：DISPATCH_QUEUE_SERIAL；并发队列：DISPATCH_QUEUE_CONCURRENT；
 @return 返回一个队列
 */
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);

	```
	
## 串行队列
- `方法一`：创建串行队列
	
	```
    // 1.创建串行队列
// 队列类型传 DISPATCH_QUEUE_SERIAL 或者 NULL
dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
	
	```
	
- 方法二：系统`主队列`(跟主线程相关的队列)。主队列是 GCD 自带的一中特殊的串行队列，放到`主队列`中的任务，都会放到`主线程中执行`
	
	```
	// 获取主队列
 dispatch_queue_t queue = dispatch_get_main_queue();
 
	```
	
## 组合形式	
### 1. 异步函数 + 并发队列
	
```
/// 异步函数 + 并发队列：可以同时开启多条线程
- (void)asyncConurrent
{
    // 1.创建一个并发队列
    /**
     @param label: 相当于队列的名字
     @param attr: 串行队列：DISPATCH_QUEUE_SERIAL；并发队列：DISPATCH_QUEUE_CONCURRENT；
     @return 返回一个队列
     */
    //    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    /**
     获的系统全局并发队列
     
     @param identifier：队列的优先级：DISPATCH_QUEUE_PRIORITY_HIGH 2，
								    DISPATCH_QUEUE_PRIORITY_DEFAULT 0，
								    DISPATCH_QUEUE_PRIORITY_LOW （-2），
								    DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
     @param flags：默认传 0，无用的参数
     @return 返回一个全局并发队列
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 2. 将任务加入到队列
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```
**打印结果：**

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170316_19.png?imageView2/0/h/360/)

> 结论：异步函数 + 并发队列，可以同时开启多个线程，多个任务能并发执行

### 2. 同步函数 + 并发队列

```
/// 同步函数 + 并发队列：不能开启多条线程
- (void)syncConurrent
{
    // 1. 获得全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 2. 将任务加入到队列
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```

打印结果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_2.png?imageView2/0/h/360/)

>结论：同步函数 + 并发队列：不能开启新的线程

### 3. 同步函数 + 手动创建串行队列
	
```
/// 同步函数 + 串行队列：：不会开启新的线程，任务一个接一个地执行
- (void)syncSerial
{
    // 1.创建串行队列
    // 队列类型传 DISPATCH_QUEUE_SERIAL 或者 NULL
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);

    
    // 2. 将任务加入到队列
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```

打印结果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_5.png?imageView2/0/h/400/)

>结论：同步函数 + 串行队列：不会开启新的线程，任务一个接一个地执行 

### 4. 异步函数 + 手动创建串行队列

```
/// 异步函数 + 串行队列
- (void)asyncSerial
{
    // 1.创建串行队列
    // 获取主队列
//     dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    
    // 2. 将任务加入到队列
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```

打印结果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_6.png?imageView2/0/h/400/)

> 结论：异步函数 + 手动创建串行队列：会开启新的线程，另外任务是串行执行的。

### 5. 异步函数 + 主队列

```
/// 异步函数 + 主队列
- (void)asyncMain
{
    // 1.获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 2. 将任务加入到队列
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```

打印输出：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_7.png?imageView2/0/h/400/)

>结论：异步函数 + 主队列：主队列优先级更高，不会开启新的线程，会在主线程中执行，任务也是一个接一个执行。

### 6. 同步函数 + 主队列

```
/// 同步函数 + 主队列
- (void)syncMain
{
    // 1.获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 2. 将任务加入到队列
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务01----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务02----%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++)
        {
            NSLog(@"任务03----%@", [NSThread currentThread]);
        }
    });
}

```

- 情况一：如果同步函数在`主线程`被调用，那么会崩溃：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_9.png?imageView2/0/h/400/)

- 情况二：如果同步函数在`子线程`被调用，会怎么样呢？

```
[self performSelectorInBackground:@selector(syncMain) withObject:nil];

```

看打印输出：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_11.png?imageView2/0/h/400/)

结果不会崩溃，任务会在主线程中被执行，而且是串行执行

>结论：同步函数 + 主队列：同步函数如果在主线程被调用，会崩溃。如果在子线程中被调用，任务会在主线程中被执行，而且是串行执行。

### 总结
所以，总结一下，各种队列的执行效果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_12.png?imageView2/0/h/400/)

### 注意
- 如果往`当前串行队列`中添加任务，会阻塞住当前的串行队列，应用也会崩溃。如这样：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_16.png?imageView2/0/h/400/)

- 如果把队列改成串行队列改成并发队列，再看一下结果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_17.png?imageView2/0/h/200/)

- 如果还是串行队列，就把同步函数改成异步函数，再来看下结果打印：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_18.png?imageView2/0/h/200/)

>同步函数和异步函数的执行：异步函数中的任务执行会等一会儿执行，如果是同步函数，那么同步函数中的任务会立即执行。

# GCD 线程间通信
### 从子线程回到主线程

```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
	// 执行耗时的异步操作...
	
	dispatch_async(dispatch_get_main_queue(), ^{
	   // 回到主线程，执行刷新UI操作
	   
	});
});
    
```

# GCD 中的其他函数
### barrier 函数

```
// 作用：在他前面的任务结束后他才执行，而且他后面的任务等他执行完成后才会执行
dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);

```

>注意： barrier 函数里面的队列 queue 不能是全局并发队列

```
for (NSInteger i = 0; i < 3; i ++)
{
    // dispatch_barrier_async 的队列不能是是全局并发队列
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"-----01----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"-----02-----%@", [NSThread currentThread]);
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"-----barrier-----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"-----03----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"-----04----%@", [NSThread currentThread]);
    });
}
    
```

控制台输出：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_20.png?imageView2/0/h/300/)


### 延时执行函数

iOS 常见的延时执行方法:

1. 调用 NSObject 的方法
	
```
// 几秒后执行 aSelector 方法
- (void)performSelector:(SEL)aSelector withObject:(nullable id)anArgument afterDelay:(NSTimeInterval)delay;
	
```
	
2. 使用 GCD 函数
	
```
dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block);
	
```
	
3. 使用 NSTimer 方法
	
```
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
	
```
	
效果都一样：

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchBegin");
    
    // 方法一，调用 NSObject 方法
//    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    
    // 方法二，使用 GCD 函数
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"---run");
//    });
    
    // 方法三，NSTimer 定时器
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:NO];
}

- (void)run
{
    NSLog(@"---run");
}

```

打印结果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_21.png?imageView2/0/h/75/)

### 一次性代码函数

- 使用 dispatch_once 函数能保证某段代码在程序运行过程中只被执行一次

```
static dispatch_once_t onceTaken;
dispatch_once(&onceTaken, ^{
    // 只执行一次的代码（这里默认是线程安全的）
});

```

### 快速迭代函数
- 使用 dispatch_apply 函数能进行快速迭代遍历

```
dispatch_apply(size_t iterations, dispatch_queue_t queue, DISPATCH_NOESCAPE void (^block)(size_t));

```

- 应用场景-将一个文件夹中的所有文件拷贝到另一个文件夹里面去

```
// 设置起始文件夹路径和目标文件夹路径
NSString *fromPath = @"/Users/chenliangjing/Desktop/from";
NSString *toPath = @"/Users/chenliangjing/Desktop/to";
    
// 遍历出起始文件夹下的所有子路径
NSFileManager *fm = [NSFileManager defaultManager];
NSArray *fromSubpath = [fm subpathsOfDirectoryAtPath:fromPath error:nil];
NSArray *toBeginSubpath = [fm subpathsOfDirectoryAtPath:toPath error:nil];
NSLog(@"beginSubpath:%@",toBeginSubpath);
    
// 使用 dispatch_apply 函数快速遍历
dispatch_apply(fromSubpath.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
    
    // 获得起始文件夹下文件的全路径，以及目标文件夹下的全路径
    NSString *fromFullPath = [fromPath stringByAppendingPathComponent:fromSubpath[index]];
    NSString *toFullPath = [toPath stringByAppendingPathComponent:fromSubpath[index]];
    
    // 剪切
    [fm moveItemAtPath:fromFullPath toPath:toFullPath error:nil];
    NSLog(@"---%@----%@",toFullPath, [NSThread currentThread]);
});

```

控制台输出：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_22.png?imageView2/0/h/400/)

### 队列组函数

- 开发有时会有这样一个需求：首先分别异步执行多个耗时操作，然后需要等这多个耗时操作都执行完毕再回到主线程执行其他操作。这个时候可以用 GCD 的队列组实现，步骤如下：

```
// 创建队列和队列组
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
    
dispatch_group_async(group, queue, ^{
	// 执行一个耗时操作
});
    
dispatch_group_async(group, queue, ^{
   // 执行一个耗时操作
});
    
// 回到主线程，执行其他操作
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
	// 等前面的任务都执行完毕后，回到主线程
});
    
```

- 应用场景-去网络上下载两张图片，等两张图片都下载完成后拼接成一张显示到 imageView 上，可以这样做：

```

// 创建队列和队列组
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
    
dispatch_group_async(group, queue, ^{
    // 1.下载第一张图片
    // 获取图片地址url
    NSURL *url1 = [NSURL URLWithString:@"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=596812886,3493058479&fm=58"];
    
    // 下载图片,耗时操作
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    self.image1 = [UIImage imageWithData:data1];
});
    
    
// 2.下载第一张图片
dispatch_group_async(group, queue, ^{
    // 获取图片地址url
    NSURL *url2 = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=92e00c9b8f5494ee8722081f15ce87c3/29381f30e924b899c83ff41c6d061d950a7bf697.jpg"];
    
    // 下载图片,耗时操作
    NSData *data2 = [NSData dataWithContentsOfURL:url2];
    self.image2 = [UIImage imageWithData:data2];
});
    
// 3. 将下载的两张图片合成一张
dispatch_group_notify(group, queue, ^{
    // 开启图形上下文
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    
    // 绘制图片
    [self.image1 drawInRect:CGRectMake(0, 0, 150, 300)];
    [self.image2 drawInRect:CGRectMake(150, 0, 150, 300)];
    
    // 从图形上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        // 4. 将图片显示到 imageView 上去
        self.imageView.image = image;
    });
});

```

看下效果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170317_24.png?imageView2/0/h/300/)