---
title: iOS 设计模式-单例模式
date: 2017-03-17 22:33:16
tags:
- 设计模式
- iOS
categories:
- iOS
---

## 单例简介
- 作用
	1. 保证`类`在`程序运行过程`中只有`一个实例`，而且该实例易于外界访问。
	2. 方便地控制了实例的个数，节约系统资源。

- 使用场景
	1. 在整个应用程序中，共享一份资源（这份资源只需要创建初始化 1 次）

## 源代码
[地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/iOS%20%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F-%E5%8D%95%E4%BE%8B%E6%A8%A1%E5%BC%8F)


## 怎么实现？
1. 保证外界每次调用 alloc 方法时要只非配一次内存。
2. 保证外界调用 copy 方法时不会创建新的对象实例。
3. 提供给外界一个快速方便获取单例的类方法，同时要保证返回同一个对象实例。
4. 宏定义定义一个单例，方便整个应用中类的单例实现。
<!-- more -->

## 具体实现- GCD
- 在 .m 文件中保留一个全局的 static 实例。static 关键字保证变量只能在本文件中访问。

```
static id _instance;

```

- 保证外界每次调用 alloc 方法时要只非配一次内存。

```
// alloc 内部是调用 allocWithZone: 方法，所以应该重写 allocWithZone: 方法，保证每次分配内存空间时只会分配一次
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       _person = [super allocWithZone:zone];
    });
    
    return _person;
}

```
	
	
- 保证外界调用 copy 方法时不会创建新的对象实例。

```
// 保证外界调用 copy 方法也不会创建新的对象实例
- (id)copyWithZone:(NSZone *)zone
{
    return _person;
}

```


- 提供给外界一个快速方便获取单例的类方法，同时要保证返回同一个对象实例。

```

// 快速方便获取单例，保证返回同一个对象
+ (instancetype)sharedPerson
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _person = [[self alloc] init];
    });
    
    return _person;
}

```

- 宏定义定义一个单例，方便整个应用中类的单例实现。

```
// .h 文件
#define SingletonH + (instancetype)sharedInstance;

// .m 文件
#define SingletonM \
static id _instance;\
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    \
    return _instance;\
}\
\
+ (instancetype)sharedInstance\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    \
    return _instance;\
} \
\
- (id)copyWithZone:(NSZone *)zone\
{\
    return _instance;\
}

```

- 那个类需要实现单例，是需要在 .h 文件中写入 `SingletonH`，在 .m 文件中写入 `SingletonM` 就可以了

```
// .h 文件
@interface Person : NSObject
///
@property(nonatomic, copy) NSString *name;

SingletonH;

@end

// .m 文件

@implementation Person

SingletonM;

@end

```

- 优化。实现单例类方法名替换，根据具体类在宏定义中替换。

```
// .h 文件
#define SingletonH(name) + (instancetype)shared##name;

// .m 文件
#define SingletonM(name) \
static id _instance;\
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    \
    return _instance;\
}\
\
+ (instancetype)shared##name\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    \
    return _instance;\
} \
\
- (id)copyWithZone:(NSZone *)zone\
{\
    return _instance;\
}

```

- 外界调用

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170502_1.png?imageView/0/h/400)

## 非 GCD 实现

```
static id _instance;

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    // 加锁，保证线程安全
    @synchronized (self)
    {
        if (_instance == nil)
        {
            _instance = [super allocWithZone:zone];
        }
    }
    
    return _instance;
}

+ (instancetype)sharedInstance
{
    // 加锁，保证线程安全
    @synchronized (self) {
        if (_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;

}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

```