---
title: 《Objective-C 高级编程》读书笔记-内存管理
date: 2017-03-30 12:41:27
tags:
- iOS
- 内存管理
- Objective-C
categories: 
- iOS
- Objective-C
---
## 什么是自动引用计数？
`自动引用计数`（ARC，Automatic Reference Counting）。指内存管理中对引用采取自动计数的技术。只要在 LLVM 编译器中设置了 ARC 为有效状态，那么编译器将自动进行内存管理。

## 内存管理/引用计数
### 举个栗子
<!-- more -->
以开关房间的灯为实例，假设房间的灯只有一盏，上班进入办公室需要开灯，下班离开办公室需要关灯。但是，办公室一般有多人一起上班，上下班时间上各自有前后顺序，只有来的最早的人才需要开灯，走的最晚的人才需要关灯，同时所有人都需要照明。分解需求如下：

1. 最早进入办公室的人需要开灯；
2. 之后进入办公室的人需要照明；
3. 下班离开办公室的人不需要照明；
4. 最后离开办公室的人需要关灯（此时无人需要照明）；

此时为了判断是否还有人在办公室，需要导入一个计数变量来记录`需要照明的人数`，看一下对应关系：

1. 当第一个人进入办公室，`需要照明的人数`加 1。计数值从 0 变为 1，因此需要开灯；
2. 之后每当有人进入办公室，`需要照明的人数`就加 1；
3. 每当有人下班离开办公室，`需要照明的人数`就减 1；
4. 最后一个人下班离开办公室，`需要照明的人数`减 1，这时计数值从 1 变为 0，因此需要关灯；

对应 Objective-C 中对象的内存管理如下表：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_1.png?imageView/0/h/200)

### 内存管理的思考方式
> 注意：以下代码在 MRC 环境下。

- 自己生成的对象，自己所持有
- 非自己生成的对象，自己也能持有
- 不再需要自己持有的对象时，释放对象
- 非自己持有的对象无法释放

对象操作与 Objective-C 中方法对应如下：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_2.png?imageView/0/h/200)

>注意：Objective-C 中对象的`内存管理方法`都在所有类的基类 NSObject 中定义，包括 alloc 类方法，retain/release/dealloc 对象方法。


#### #自己生成的对象，自己持有

使用以下名称开头的方法名生成的对象只有自己持有：

- alloc
- new
- copy
- mutableCopy

```
/// 自己生成并持有对象-alloc
NSObject *obj1 = [[NSObject alloc] init];
    
/// 自己生成并持有对象-new
NSObject *obj2 = [NSObject new];

```

>[[NSObject alloc] init] 和 [NSObject new] 两种方法的效果一致。

copy 方法利用基于 `<NSCopying>` 协议约定，由各类实现 copyWithZone：方法生成并持有对象的副本。同样，mutableCopy 方法利用基于 `<NSMutableCopying>` 协议，由各类实现 mutableCopyWithZone: 方法生成并持有对象的副本，两者的区别是：copy 方法生成不可变的对象，mutableCopy 方法生成可变的对象。其中 Foundation 类已经遵守了 `<NSCopying>` 和 `<NSMutableCopying>` 协议。

```
LJStudent *stu1 = [[LJStudent alloc] init];
/// 自己生成并持有对象
LJStudent *stu2 = [stu1 copy];
NSLog(@"stu1:%p---stu2:%p",stu1, stu2);

```

打印结果：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_3.png?imageView/0/h/100)

mutableCopy 方法类似。

除了这些方法，使用`以下名称开头的方法名`也意味着自己`生成并持有对象`：

- **alloc**MyObject
- **new**ThatObject
- **copy**This
- **mutableCopy**YourObject


#### #非自己生成的对象，自己也能持有

```
/// 取得非自己生成但自己持有的对象
id obj = [NSMutableArray array]; // 取得的对象存在，但变量 obj 并不持有
NSLog(@"Reference Count=%lu",[obj retainCount]);
[obj retain]; // obj 变量自己持有对象
NSLog(@"Reference Count=%lu",[obj retainCount]);

```

打印结果：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_4.png?imageView/0/h/80)

>为什么打印结果是 1 和 2，不是 0 和 1 ?不解？？？？？？？？？。做个标记~~~~~~~~

>答案：因为类似`[NSMutableArray array]`方法生成的对象，内部是使用了 `autorelease` 方法实现，将其注册到 `artoreleasepool` 中去了，所以第一次打印也是 1。如何证明，通过给对象发送 release 消息，应用程序将会崩溃。

这种`能够取得对象但又不持有对象`的方法内部实现是：

```
id obj = [[[self class] alloc] init]; // 生成对象并自己持有
[obj autorelease]; // 对象存在但自己不持有对象
    
return obj;

```

> `autorelease` 能够使对象在超出指定生存范围时能够自动并正确的释放。（也是通过对对象调用 release 方法实现）


#### #不再需要自己持有的对象时，释放对象
自己持有的对象，一旦不再需要，持有者有义务释放该对象，使用 release 方法：

```
/// 通过alloc/new/copy/mutableCopy 方法生成并持有的对象
id obj1 = [[NSObject alloc] init]; // Reference Count 等于 1
[obj1 release]; // Reference Count 等于 0
    
/// 通过 retain 持有的对象
id obj2 = [NSMutableArray array]; // Reference Count 等于 2
[obj2 retain]; // Reference Count 等于 2
[obj2 release]; // Reference Count 等于 1，对象不可再调用 release 方法释放

```


#### #非自己持有的对象无法释放
释放非自己持有的对象时应用程序会发生崩溃:

```
/// 1. 释放完后不再需要的对象
id obj1 = [[NSObject alloc] init];
[obj1 release]; // 对象已释放
[obj1 release]; // 再次释放，程序崩溃
    
/// 2. 取得的对象存在，但自己不持有
id obj2 = [NSMutableArray array];
[obj2 release]; // 程序崩溃

```


### alloc/retain/release/dealloc 实现
可以使用能够和 Cocoa 框架互换的 [GNUstep 框架源码](https://github.com/gnustep/base/blob/master/Source/NSObject.m)中 `NSObject 类的 .m 文件`进行分析，来分析 alloc/retain/release/dealloc 的实现。代码经过简化处理，只保留相关联的部分。

#### #alloc

```
/// alloc 生成对象
+ (id)alloc
{
  return [self allocWithZone: NSDefaultMallocZone()];
}

/// 给对象分配内存
+ (id)allocWithZone: (NSZone*)z
{
  return NSAllocateObject (self, 0, z);
}

/// 内联函数
inline id
NSAllocateObject (Class aClass, NSUInteger extraBytes, NSZone *zone)
{
	id	new;
	int	size;
	
	// 计算所需要的内存空间	大小，包括对象大小、 obj_layout 的大小、额外的字节
	size = class_getInstanceSize(aClass) + extraBytes + sizeof(struct obj_layout);
	
	// 分配存放对象所需的内存空间	
	new = NSZoneMalloc(zone, size);
	// 将该内存空间置 0
	memset (new, 0, size);
	
	// 返回作为对象而使用的指针
	new = (id)&((struct obj_layout *)new)[1];
	return new;
}

// obj_layout 结构体
struct obj_layout {
	// 不懂这个东东是干什么的
	char	padding[__BIGGEST_ALIGNMENT__ - ((UNP % __BIGGEST_ALIGNMENT__)
	? (UNP % __BIGGEST_ALIGNMENT__) : __BIGGEST_ALIGNMENT__)];
	
	// 这个东东是一个 long 类型
	gsrefcount_t	retained;
};

```

> NSDefaultMallocZone、NSZoneMalloc 中包含的 NSZone 是为了防止内存碎片化而引入的结构，通过对内存分配的区域本身进行多重化管理，根据使用对象的目的、对象的大小分配内存，从而提高了内存管理的效率。

去掉 NSZone 之后的简化代码：

```
+ (id)alloc
{	
	// 计算所需要的内存空间	大小，包括 obj_layout 的大小
	int size = sizeof(struct obj_layout) + 对象大小;
	
	// obj_layout 结构体的指针，calloc() 函数用来动态的分配内存空间，并将每一个字节都初始化为 0，空间大小等于 1 * size，分配成功返回指向该内存的地址
	struct obj_layout *p = (struct obj_layout *)calloc(1, size);
	
	// 返回作为对象而使用的指针
	return (id)(p + 1);
}

// obj_layout 结构体
struct obj_layout {
	// 这个东东是一个 long 类型
	gsrefcount_t	retained;
};

```

> alloc 类方法用 struct obj_layout 中 long 类型整数 `retained` 来保存`引用计数`，并将其写入对象内存头部，该对象内存块全部置 0 后返回。


![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_6.png?imageView/0/h/200)
<center>alloc 返回对象内存图</center>

对象的引用计数可以通过 `retainCount` 实例方法得到，来看对象 alloc 后 `retainCount` 实例方法做了什么：

```

- (NSUInteger)retainCount
{
	// 让 struct obj_layout 中保存的 retained 变量加 1 后返回，最开始 retained 的值为 0
	return NSExtraRefCount(self) + 1;
}

/// 内联函数 
inline NSUInteger
NSExtraRefCount(id anObject)
{
	// 返回 struct obj_layout 中的 retained 变量
	return ((struct obj_layout *)anObject)[-1].retained;
}

```

![](http://o6heygfyq.bkt.clouddn.com/Snip20170330_7.png?imageView/0/h/200)

>由对象寻址找到对象内存头部，从而访问其中的 retained 变量。由于分配时全部置为 0，所以 retained 的值为 0。


#### #retain

再看 retain 是怎么实现的：

```
- (id)retain
{
	NSIncrementExtraRefCount(self);
	return self;
}

/// 内联函数，去除了一些异常判断和线程安全的代码
inline void
NSIncrementExtraRefCount(id anObject)
{
	((struct obj_layout)anObject)[-1].retained++;
}

```

>可以发现：对对象 retain 操作就是对 struct obj_layout 中的 retained 变量进行 ++ 操作。


#### #release

看对对象 release 操作发生了什么：

```
- (oneway void)release
{
	// 判断当前 retained 变量的值是否为 0，如果为 0，直接调用 dealloc 方法销毁对象
	if (NSDecrementExtraRefCountWasZero(self))
	{
		#	ifdef OBJC_CAP_ARC
		objc_delete_weak_refs(self);
		#	endif
		[self dealloc];
	}
}

/// 内联函数
inline BOOL
NSDecrementExtraRefCountWasZero(id anObject)
{
if (((struct obj_layout)anObject)[-1].retained == 0)
	{
		return YES;
	}
	else
	{
		((struct obj_layout)anObject)[-1].retained--;
		    
		return NO;
	}
}

```

> 对对象 release 操作的内部实现是：判断当前 `retained ` 变量的值，如果大于 0 就减 1，等于 0，等于 0 就调用 dealloc 方法销毁对象。


#### #dealloc

最后，看一下对对象执行 dealloc 操作背后的实现：

```
- (void)dealloc
{
	NSDeallocateObject (self);
}

// inline 标识内联函数，用于经常会使用到的函数，可以提高性能
inline void
NSDeallocateObject(id anObject)
{
	struct obj_layout *o = &((struct obj_layout)anObject)[-1];
		
	free(o);
}

```

对对象执行 dealloc 操作，相当于会释放掉由 alloc 方法申请分配的内存。

以上就是 alloc/retain/release/dealloc 方法在 GNUstep 框架中的实现，具体总结如下：

- 在 Objective-C 的对象中存在`引用计数`这一整数值；
- 调用 `alloc` 或是 `retain` 方法后，引用计数`加 1`；
- 调用 `release` 方法后，引用计数`减 1`；
- 当引用计数为 `0` 时，调用 `dealloc` 方法`销毁对象`；


### apple 的实现

[源码地址](https://opensource.apple.com/source/objc4/objc4-706/)，先来看 alloc 类方法实现：

```
+ (id)alloc {
    return _objc_rootAlloc(self);
}

id
_objc_rootAlloc(Class cls)
{
    return callAlloc(cls, false, true);
}

static ALWAYS_INLINE id
callAlloc(Class cls, bool checkNil, bool allocWithZone=false)
{
    id obj = class_createInstance(cls, 0);
    
    return obj;
}

id class_createInstance(Class cls, size_t extraBytes)
{
    return (*_alloc)(cls, extraBytes);
}

id (*_alloc)(Class, size_t) = _class_createInstance;

static id _class_createInstance(Class cls, size_t extraBytes)
{
    return _class_createInstanceFromZone (cls, extraBytes, nil);
}

id 
_class_createInstanceFromZone(Class cls, size_t extraBytes, void *zone)
{
    void *bytes;
    size_t size;
    
    // Allocate and initialize
    size = cls->alignedInstanceSize() + extraBytes;

    // CF requires all objects be at least 16 bytes.
    if (size < 16) size = 16;

    if (zone) {
        bytes = malloc_zone_calloc((malloc_zone_t *)zone, 1, size);
    } else {
        bytes = calloc(1, size);
    }

    return objc_constructInstance(cls, bytes);
}

```

retainCount

```
- (NSUInteger)retainCount {
    return ((id)self)->rootRetainCount();
}

inline uintptr_t 
objc_object::rootRetainCount()
{
    if (isTaggedPointer()) return (uintptr_t)this;
    return sidetable_retainCount();
}

uintptr_t
objc_object::sidetable_retainCount()
{
    SideTable& table = SideTables()[this];

    size_t refcnt_result = 1;
    
    table.lock();
    RefcountMap::iterator it = table.refcnts.find(this);
    if (it != table.refcnts.end()) {
        // this is valid for SIDE_TABLE_RC_PINNED too
        refcnt_result += it->second >> SIDE_TABLE_RC_SHIFT;
    }
    table.unlock();
    return refcnt_result;
}

```


### autorelease


### autorelease 实现





### apple 实现



## ARC 规则
### 概要


### 内存管理的思考方式



### 所有权修饰符


### 规则


### 属性

### 数组

## ARC实现
### __strong 修饰符


### __weak 修饰符



### __autoreleasing 修饰符


### 引用计数

