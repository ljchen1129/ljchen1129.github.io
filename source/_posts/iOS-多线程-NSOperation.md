---
title: iOS 多线程-NSOperation
date: 2017-03-17 22:32:06
tags:
- iOS
- 多线程
categories:
- iOS
- 多线程
---

## 简介
### NSOperation 的作用
- 配合 NSOperation 和 NSOperationQueue 也能实现多线程编程。

### NSOperation 和 NSOperationQueue 实现多线程的步骤
- 先将需要执行的操作封装到一个 NSOperation 对象中
- 然后将 NSOperation 对象添加到 NSOperationQueue 中
- 系统会自动将 NSOperationQueue 中的 NSOperation 取出来
- 将取出的 NSOperation 封装的操作放到一条线程中执行

### NSOperation 的子类
- NSOperation 是个抽象类，并不具备封装操作的能力，必须使用他的子类
- 使用 NSOperation 子类方式有 3 中
	1. NSInvocationOperation
	2. NSBlockOperation
	3. 自定义类集成 NSOperation，实现内部相应的方法

- NSInvocationOperation
<!-- more -->
```
// NSInvocationOperation 对象不会开启线程
- (void)invocationOperation
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test:) object:@"chenlianging"];
    NSLog(@"Current Thread = %@", [NSThread currentThread]); // Current Thread = <NSThread: 0x60800006d1c0>{number = 1, name = main}
    
    // 开启
    [op start];
}

- (void)test:(NSString *)prames
{
    NSLog(@"params = %@", prames); // params = chenlianging
    NSLog(@"Current Thread = %@", [NSThread currentThread]); // Current Thread = <NSThread: 0x60800006d1c0>{number = 1, name = main}
}

```
>结论：NSInvocationOperation 对象不会开启线程，任务在主线程执行。

- NSBlockOperation

```
// NSBlockOperation 单独使用不会开启线程，但是添加额外的任务情况下会开启新线程
- (void)blockOperation
{
    NSLog(@"Current Thread = %@", [NSThread currentThread]); // Current Thread = <NSThread: 0x60800007e5c0>{number = 1, name = main}
    
    // 在主线程执行
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载一");
        NSLog(@"Current Thread = %@", [NSThread currentThread]); // Current Thread = <NSThread: 0x60800007e5c0>{number = 1, name = main}
    }];
    
    // 在子线程执行
    [op addExecutionBlock:^{
        NSLog(@"下载二——————Current Thread = %@", [NSThread currentThread]); // 下载二——————Current Thread = <NSThread: 0x610000264e80>{number = 3, name = (null)}
    }];
    
    // 在子线程执行
    [op addExecutionBlock:^{
        NSLog(@"下载三——————Current Thread = %@", [NSThread currentThread]); // 下载三——————Current Thread = <NSThread: 0x618000262dc0>{number = 4, name = (null)}

    }];
    
    // 在子线程执行
    [op addExecutionBlock:^{
        NSLog(@"下载四——————Current Thread = %@", [NSThread currentThread]); // 下载四——————Current Thread = <NSThread: 0x60000007e240>{number = 5, name = (null)}
    }];
    
    // 开启
    [op start];
}

```

>结论：NSBlockOperation 单独使用不会开启线程，但是添加额外的任务情况下会开启新线程，在子线程中执行。

## NSOperationQueue

- NSOpreation 可以调用 start 方法来执行任务，但默认是`同步执行`的。
- 如果将 NSOpreation 添加到 NSOperationQueue （操作队列）中，系统会`自动异步执行` NSOpreation 中的操作。
- 主队列：[NSOperationQueue mainQueue]。凡是添加到主队列中的任务，都会放到主线程中执行
- 其他队列：(串行、并发) [[NSOperationQueue alloc] init]。添加到这种队列中的任务，会自动在子线程中执行。
 
	![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170502_2.png?imageView/0/h/450) 

### 最大并发数

- maxConcurrentOperationCount
	- 设置为 0：任务不会执行
	- 设置为 1：表示创建的是串行队列
	- 设置大于 1：表示创建的是并发队列
	
### 挂起和取消
- suspended：挂起
	- YES：挂起任务，暂停执行
	- NO：恢复暂停
	- 特点：挂起后还可以恢复。

-  cancelAllOperations
	- 特点：取消后不能恢复。

```
// 取消所有操作
[self.queue cancelAllOperations];

// 取消某一个操作
[self.op cancel];

```

>注意一：如果当前某一个任务正在执行，不管使用`挂起`还是`取消`操作，都不能让那个正在执行的任务暂停或者取消执行，只会暂停或者取消接下来还没开始执行的任务。

>注意二：在自定义任务中，可以在 main 方法中，对每一段耗时操作进行一次判断，判断当前任务是否取消，配合 cancelAllOperations 操作，可以实现控制某一个正在执行的任务的取消操作。
	
>	```
>	// 自定义 Opreation 需要重写 main 方法，将需要执行的任务封装到 main 方法中
>	- (void)main
>	{
>	    for (int i = 0; i < 1000; i ++)
>	    {
>	        NSLog(@"CustomOpreation1------%zd---%@", i, [NSThread currentThread]);
	    }
	    
>	    if (self.isCancelled) return;
	    
>	    for (int i = 0; i < 1000; i ++)
	    {
>	        NSLog(@"CustomOpreation2------%zd---%@", i, [NSThread currentThread]);
	    }
	    
>	    if (self.isCancelled) return;
	
>	    for (int i = 0; i < 1000; i ++)
	    {
>	        NSLog(@"CustomOpreation3------%zd---%@", i, [NSThread currentThread]);
	    }
	    
>	    if (self.isCancelled) return;
	}

>	```

	
## 自定义 NSOperation
- 自定义 Opreation 需要重写 main 方法，将需要执行的任务封装到 main 方法中。
- 使用场景：将经常需要执行的任务封装起来，以后不管哪里要用到同一个操作任务都能方便使用。

```
#import "CustomOpreation.h"

@implementation CustomOpreation

// 自定义 Opreation 需要重写 main 方法，将需要执行的任务封装到 main 方法中
- (void)main
{
    NSLog(@"CustomOpreation-----%@", [NSThread currentThread]);
}

@end

```

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170502_3.png?imageView/0/h/300) 

## NSOperation 的依赖和监听
- NSOperation 之间可以通过设置依赖来保证执行顺序
- 可以在不同 queue 的 NSOperation 对象之间设置依赖关系

```
// 1. 创建队列
NSOperationQueue *q1 = [[NSOperationQueue alloc] init];
NSOperationQueue *q2 = [[NSOperationQueue alloc] init];
    
// 2. 创建操作
NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"download1------%@", [NSThread currentThread]);
}];
    
NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"download2------%@", [NSThread currentThread]);
}];

NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"download3------%@", [NSThread currentThread]);
}];
    
NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
    for (int i = 0; i < 10; i ++)
    {
        NSLog(@"download4------%@", [NSThread currentThread]);
    }
}];
    
NSBlockOperation *op5 = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"download5------%@", [NSThread currentThread]);
}];
    
// 3. 设置依赖
[op3 addDependency:op1]; // op1 执行完了才能执行 op3
[op3 addDependency:op2]; // op2 执行完了才能执行 op3
[op3 addDependency:op4]; // op4 执行完了才能执行 op3
    
// 4. 将操作加入到队列中
[q1 addOperation:op1];
[q1 addOperation:op2];
[q1 addOperation:op3];
[q2 addOperation:op4];
[q2 addOperation:op5];

```

- 打印结果：

	![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170502_4.png?imageView/0/h/230)

>注意：不能相互设置依赖。造成结果，两个操作都不会执行。


- 监听 NSOpration 执行完毕

```
// 监听操作的执行完毕
op5.completionBlock = ^{
    NSLog(@"op5 执行完毕%@", [NSThread currentThread]); // 在子线程中执行，但不一定是和操作在同一一个子线程
};

```

## NSOperationQuene 线程间通信

```
// 创建队列
NSOperationQueue *q = [[NSOperationQueue alloc] init];
    
__block UIImage *image1 = nil;
__block UIImage *image2 = nil;
    
// 1. 下载图片1
NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
    NSURL *url = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=92e00c9b8f5494ee8722081f15ce87c3/29381f30e924b899c83ff41c6d061d950a7bf697.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    image1 = [UIImage imageWithData:data];
    NSLog(@"op1 ---- current thread = %@", [NSThread currentThread]); // op1 ---- current thread = <NSThread: 0x61000007bb00>{number = 4, name = (null)}
}];
    
    
// 2. 下载图片2
NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
    NSURL *url = [NSURL URLWithString:@"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=596812886,3493058479&fm=58"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    image2 = [UIImage imageWithData:data];
    NSLog(@"op2 ---- current thread = %@", [NSThread currentThread]); // op2 ---- current thread = <NSThread: 0x6000000783c0>{number = 5, name = (null)}
}];
    
    
// 3. 合成图片
NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
    
    // 开启图形上下文
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    
    // 绘制图片
    [image1 drawInRect:CGRectMake(0, 0, 150, 300)];
    image1 = nil;
    [image2 drawInRect:CGRectMake(150, 0, 150, 300)];
    image2 = nil;
    
    // 获取图片
    UIImage *combineImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    NSLog(@"op3 ---- current thread = %@", [NSThread currentThread]); // op3 ---- current thread = <NSThread: 0x608000073d80>{number = 6, name = (null)}
    
    // 回到主线程，渲染 UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.imageView.image = combineImage;
        NSLog(@"mainQueue ---- current thread = %@", [NSThread currentThread]); // mainQueue ---- current thread = <NSThread: 0x61000006ffc0>{number = 1, name = main}
    }];
}];
    
// 4. 设置依赖
[op3 addDependency:op1];
[op3 addDependency:op2];
    
// 5. 将操作加入到队列
[q addOperation:op1];
[q addOperation:op2];
[q addOperation:op3];

```

显示效果：

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170502_5.png?imageView/0/h/300)

## NSOperation 实现多图下载
- 需要解决的问题
	1. 在内存中缓存图片
	2. 在沙盒中缓存图片数据
	3. 缓存下载图片操作
	4. 下载过程中显示占位图片
	5. 滑动 tableView 导致的 cell 显示图片错乱问题
	6. 重复下载问题
	7. 下载失败异常处理

- 注意事项：
	1. 将下载图片的操作缓存到字典中，避免重复多次下载操作
	2. 下载未完成之前，显示占位图片
	3. 直接给 cell 设置图片在滑动 tableView 的时候会出现错误，因为如果图片还没有下载完成，就已经滑动了，当图片下载完成时要显示的 cell 已经不是当时的 cell 了，下载完成时，应当刷新表格视图当前行，这样才能意义对应的找到需要设置图片的 cell
	4. 当下载失败时，需要移除下载操作，并且直接返回，不然会导致设置图片内存缓存由于图片为 nil 而出现崩溃，同时避免下载失败后不再重新下载了
	5. 下载完成后，移除下载操作
	6. 将下载图片操作添加到队列中，下载完成无须将操作从队列中移除，队列会自动移除下载完成的操作
	7. 图片下载完成后，需要将图片数据缓存到内存以及沙盒中
	8. 从沙盒中加载图片数据后，需要将图片缓存到内存字典中
	9. 沙盒目录
		- Documents：在 itnues 连接时会备份到苹果服务器
		- Library
			- Caches：
			- Preference：偏好设置
		- tmp：临时文件，随时会被清理
	10. 出现内存警告时，需要清空内存缓存以及取消正在下载的操作
		
		```
		- (void)didReceiveMemoryWarning
		{
		    // 清除所有内存缓存
		    [self.imageCache removeAllObjects];
		    
		    // 取消所有正在进行的操作
		    [self.queue cancelAllOperations];
		}

		```
	

- 实现代码
	
```
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
if (cell == nil)
{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellId"];
}
    
App *a = self.apps[indexPath.row];
cell.textLabel.text = a.name;
cell.detailTextLabel.text = a.download;
    
// 从内存中取出图片
UIImage *image = self.imageCache[a.icon];
if (image)
{
    // 内存中有图片
    cell.imageView.image = image;
}
else
{
    // 从沙盒中获取图片数据
    // 获取 Caches 的目录
    NSString *cachesPath =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    // 获取文件名
    NSString *fileName = [a.icon lastPathComponent];
    // 计算文件的全路径
    NSString *file = [cachesPath stringByAppendingPathComponent:fileName];
    // 加载沙盒中文件数据
    NSData *data = [NSData dataWithContentsOfFile:file];
    if (data)
    {   // 沙盒中有图片
        UIImage *imageCache = [UIImage imageWithData:data];
        cell.imageView.image = imageCache;
    
        // 注意8：从沙盒中加载图片数据后，需要将图片缓存到内存字典中
        self.imageCache[a.icon] = cell.imageView.image;
    }
    else
    {
        NSOperation *op = self.operationCache[a.icon];
        // 注意2：下载未完成之前，显示占位图片
        cell.imageView.image = [UIImage imageNamed:@"placeHolder"];
        if (op == nil)
        {
            op = [NSBlockOperation blockOperationWithBlock:^{
                // 下载图片
                NSLog(@"下载图片");
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:a.icon]];
                // 注意4：当下载失败时，需要移除下载操作，并且直接返回
                if (data == nil)
                {
                    [self.operationCache removeObjectForKey:a.icon];
                    return;
                }
                
                UIImage *downLoadImage = [UIImage imageWithData:data];
                
                                // 注意7：图片下载完成后，需要将图片数据缓存到内存以及沙盒中
                // 保存到内存字典中
                self.imageCache[a.icon] = downLoadImage;
                // 将图片文件数据写入沙盒中
                [data writeToFile:file atomically:YES];

                // 回到主线程刷新 UI
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    // 注意3：直接给 cell 设置图片在滑动 tableView 的时候会出现错误，因为如果图片还没有下载完成，就已经滑动了，当图片下载完成时要显示的 cell 已经不是当时的 cell 了
//                        cell.imageView.image = image;
                    
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
                           
                // 注意5：下载完成后，移除下载操作
                [self.operationCache removeObjectForKey:a.icon];
            }];
            
            // 注意6：将下载图片操作添加到队列中，下载完成无须将操作从队列中移除，队列会自动移除下载完成的操作
            [self.queue addOperation:op];
            
            // 注意1：将下载图片的操作缓存到字典中，避免重复多次下载操作
            self.operationCache[a.icon] = op;
        }
    }
}
    
return cell;
	
```

- 流程图

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/%E5%A4%9A%E5%9B%BE%E4%B8%8B%E8%BD%BD-%E4%B8%89%E7%BA%A7%E7%BC%93%E5%AD%98%E6%B5%81%E7%A8%8B%E5%9B%BE.001.jpeg)

- 扩展
	1. 设置缓存过期，缓存多久，一周，一月还是一天？
	2. 设置缓存大小，大于多少需要清除？按照什么顺序清除？
	3. 使用 SDWebImage 一行代码实现图片缓存和异步下载，具体是怎么实现的？ 
	
## 源代码
[地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/iOS%20%E5%A4%9A%E7%BA%BF%E7%A8%8B-NSOperation)