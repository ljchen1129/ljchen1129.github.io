---
title: GCD 实现定时器
date: 2017-05-09 23:08:06
tags:
- iOS
- GCD
categories: iOS
---

## NSTimer 实现定时器

```
// 在主线程中实现定时器
- (void)OCTimerInMainThread
{
    // 1.
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"我是OCTimer");
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    // 2.
//    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"我也是OCTimer");
//    }];
}
<!-- more -->
// 在子线程中实现定时器
- (void)OCTimerInBackgroudThread
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
//        // 1. 
//        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"我是OCTimerInBackgroudThread");
//        }];
//        
//        // 启动子线程 RunLoop
//        [[NSRunLoop currentRunLoop] run];
        
        // 2.
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"我是OCTimerInBackgroudThread");
        }];
        
        // 将 timer 加入到当前子线程 RunLoop
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        // 启动子线程 RunLoop
        [[NSRunLoop currentRunLoop] run];
        
        NSLog(@"我是子线程 = %@", [NSThread currentThread]);
    });
}

```

## GCD 实现定时器

```
// 开启定时器
- (IBAction)startTimer:(id)sender
{
    [self gcdTimer];
}

// 取消定时器
- (IBAction)cacelTimer:(id)sender
{
    dispatch_cancel(self.timer);
    self.timer = nil;
}

- (void)gcdTimer
{
    // 1. 创建定时器源对象
    // 注意：dispatch_source_t 是一个局部变量，本质是一个 OC 对象，需要用一个强引用
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    // 2. 设置定时器间隔时间
    // 第一个参数：源对象
    // 第二个参数：从什么时候开始
    // 第三个参数：间隔时间
    // 第四个参数：传 0
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
    
    // 3. 设置定时器处理事件
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"我是GCD定时器！");
        NSLog(@"current Thread = %@", [NSThread currentThread]);
    });
    
    // 4. 开启定时器
    dispatch_resume(self.timer);
    
}

```


## 总结

NSTimer 定时器受 RunLoop 的 Mode 影响，而 GCD 的定时器不受 RunLoop 的 Mode 影响。 