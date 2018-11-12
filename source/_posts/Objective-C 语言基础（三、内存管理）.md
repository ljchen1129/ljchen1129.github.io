---
title: Objective-C 语言基础（三、内存管理）
date: 2017-04-08 11:14:18
tags:
- iOS
- Objective-C
categories:
- iOS
- Objective-C
---

## 内存管理
### 1. 内存管理的重要性
- 移动设备的内存极其有限，每个 app 所能占用的内存是有限制的
- 下列行为都会增加一个 app 的内存占用
	- 创建一个 Objective-C 对象
	- 定义一个变量
	- 调用一个函数或者方法
- 当 app 所占用的内存较多时，系统会发出内存警告，这时得回收一些不需要再使用的内存空间，比如回收一些不需要使用的对象，变量等
- 如果 app 内存占用过大，系统可能会强制关闭 app，造成闪退现象，影响用户体验


### 2. 什么是内存管理
- 如何回收那些不需要再使用的对象
- 内存管理，就是对内存进行管理，涉及的操作有
	- 分配内存：比如`创建`一个对象，会`增加`内存占用
	- 清除内存：比如`销毁`一个对象，会`减小`内存占用
- 内存管理的管理范围
	- 任何继承了 NSObject 的对象
	- 对其他非对象类型无效（int、char、float、double、struct、enum等）
- 只有对 Objective-C 对象才需要进行内存管理的本质原因
	- Objective-C 对象存放于`堆`里面
	- 非 Objective-C 对象一般放在`栈`里面（栈内存会被系统自动回收）
<!-- more -->
### 3. 堆和栈
- 栈（操作系统）：由操作系统自动分配释放，存放函数的参数值，局部变量的值等，其操作方式类似于数据结构中的栈（先进后出）。
- 堆（操作系统）：一般由程序员分配释放，若程序员不释放，程序结束时可能由系统回收，分配方式类似于链表。
- 举例

```

int main(int argc, const char * argv[]) {
 
    @autoreleasepool {
        int a = 10; // 局部变量：栈
        int b = 10; // 局部变量：栈
        
        // p（局部变量） ：栈
        // Person 对象（计数器 = 1）：堆
        Person *p = [[Person alloc] init];
    }
    // 出了 } 号，栈里面的变量 a/b/p 都会被回收
    // 但是堆里面的 Person 对象还会留在内存中，因为他的计数器依然是 1
    
    return 0;
}

```

![](http://liangjinggege.com/Snip20170408_1.png?imageView/0/h/300)


### 3. 引用计数器
#### #什么是引用计数
- 系统是如何判断什么时候需要回收一个对象所占的内存？
	- 通过对象的引用计数器
- 什么是引用计数器？
	- 每个 Objective-C 独享都有自己的引用计数器
	- 引用计数器是一个整数
	- 从字面上理解，表示“`对象被引用的次数`”
	- 也可以理解为：表示有多少人正在使用这个对象


#### #引用计数器的作用
- 引用计数器表述有多少人正在使用这个对象
- 当没有任何人使用这个对象时，系统才会回收这个对象
	- 即当对象的引用计数器为 0 时，对象占用的内存会被系统回收
	- 如果对象的引用计数器不为 0，那么在整个程序运行过程中，它占用的内存就不可能被回收（除非整个程序已经退出）
- 任何一个对象，刚出生的时候，引用计数器都为 1
	- 当使用 alloc/new/copy/mutableCopy 创建一个对象时，对象的引用计数器就是 1


#### #引用计数器的操作
- 管理对象所占用的内存，就是再操作对象的引用计数器
- 引用计数器常见操作
	- 给对象发送一条 retain 消息，引用计数器 +1（retain 方法返回对象本身）
	- 给对象发送一条 release 消息，引用计数器 -1
	- 给对象发送一条 retainCount 消息，可以获得对象当前的引用计数器值
- 需要注意：release 并不代表销毁/回收对象，仅仅是将引用计数器 -1


### 4. dealloc
- 当一个对象的引用计数器为 0 时，这个对象即将被销毁，其占用的内存被系统回收
- 当对象即将被销毁时，系统会自动给对象发送一条 dealloc 消息（因此，从 delloc 方法有没有被调用，就可以判断出对象是否被销毁）
- dealloc 方法的重写
	- 一般会重写 dealloc 方法，在这里释放相关的资源，dealloc 是对象的遗言
	- 一旦重写了 dealloc 方法，就必须调用 [super dealloc] 方法，并且在最后面调用


### 5. 单个对象内存管理
- 一个 alloc 对应一个 release
- 一个 retain 对应一个 release
- ARC 不同与 Java 的垃圾回收机制（gc），ARC 是编译器做的事情， Java 的垃圾回收是系统做的事情。

### 6.野指针和空指针
#### #野指针
- 只要一个对象被释放了，就称这个对象为“`僵尸对象`”
- 当一个指针指向一个`僵尸对象`，就称这个指针为“`野指针`”
- 只要给一个`野指针`发送消息就会报错

#### #Xcode 中监听僵尸对象

Xcoder->Product->Scheme->Edit Scheme->Run->Diagnostics->Zombie Objects

![](http://liangjinggege.com/Snip20170408_2.png?imageView/0/h/500)


#### #空指针
- 空指针：nil 0
- 为了避免给`野指针`发送消息会报错，一般情况下，当一个对象被释放后会将这个对象的指针设置为`空指针`，因为 Objective-C 中给`空指针`发送消息是`不会报错`的。

```
p = nil;

```

### 7. 多对象内存管理

- Objective-C 中不可避免的存在多个对象之间的内存管理，举个栗子：

```
@interface Room : NSObject

@property int roomNo;

@end

@implementation Room

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [super dealloc];
}

@end

@interface Person : NSObject
{
    Room *_room;
}

- (void)setRoom:(Room *)room;
- (Room *)room;

@end

@implementation Person

- (void)setRoom:(Room *)room
{
    _room = room;
}

- (Room *)room
{
    return _room;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [super dealloc];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Room *r = [[Room alloc] init];
        r.roomNo = 1111;
        
        Person *p = [[Person alloc] init];
        p.room = r;
        
        [r release];
        [p release];
        
    }
    
    return 0;
}

```

上面代码里面有两个类。 Person 类和 Room 类，Person 类拥有房间，做这个两个对象之间的内存管理要满足两个条件：

1. 人需要使用房间，那么只要人在房间就一定要在
2. 人不在了，房间也要不在；

要满足上述第一个个条件，就得在 Person 的 _room 的 setter 方法中对每一次传入的 room  引用计数器加 1 操作，要满足第二个条件，就得在 Person 的 dealloc 方法中，对 “_room” 做引用计数器减 1 操作：

```
- (void)setRoom:(Room *)room
{
	// 对房间的引用计数器 +1
    [room retain];
    _room = room;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    // 人释放了，那么房间也需要释放
    [_room release];
    [super dealloc];
}

```

>当 A 对象想使用 B 对象时，一定要对 B 对象进行一次 retain，这样才能保证 A 对象存在 B 对象就层，也就是说这样才能保证无论在什么时候在 A 对象中都可以使用 B 对象。

>当 A 对象释放的时候，一定要对 B 对象进行一次 release，这样才能保证 A 对象释放了， B 对象对应也会随之是否，避免内存泄漏。

>总之，对象引用计数器的加和减总是一一对应的，有加就有减。


### 8. set 方法内存管理

上述对多对象的内存管理还不完善，如果人需要换房间，那么又会出现内存泄漏：

![](http://liangjinggege.com/Snip20170410_4.png?imageView/0/h/350)

问题的原因是：换房的时候，Person 的成员变量 _room 由房间 1111 指向 8888，没有指向房间 1111 了，但是却没有对房间 1111 引用计数器`减一操作`，所以导致最终房间 1111 没有被释放，导致`内存泄漏`。

解决方法：每一次换房之前，都应该对以前的房间引用计数器减 1

```
- (void)setRoom:(Room *)room
{
	// 将以前的房间释放掉
	_room release];
	
	// 对房间的引用计数器 +1
    [room retain];
    _room = room;
}

```
![](http://liangjinggege.com/Snip20170410_5.png?imageView/0/h/200)

上述内存管理方案还不够完善，如果出现`重复赋值`时，即又给人一间 1111 的房间，应用程序将会崩溃，崩溃原因是`野指针`异常。具体原因是，由于人原本就拥有一间 1111 的房间，即对房间 1111 有一个引用，当再次给人赋值 1111 房间时，先会对 1111 房间 release 一次，release 完 1111 房间引用计数器变为 0，称为僵尸对象，然后又要对整个僵尸对象进行 retain 操作，给僵尸对象发送消息，程序崩溃。

解决方案：在每一个给 Person 的 _room 赋值之前，先判断新值是否和旧值一样，如果一样，什么都不做，如果不一样，才需要 release 旧值，retain 新值。

```
- (void)setRoom:(Room *)room
{
    // 判断旧值和新值是否一样
    if (_room != room)
    {
        // release 旧值
        [_room release];
        
        // retain 新值
        // retain 方法即让对象的引用计数器加 1，同时会返回当前对象
        _room = [room retain];
    }
}

```


### 9. property 修饰符
#### 1. 控制 set 方法的内存管理
- retain：release 旧值，retain 新值（用于 Objective-C 对象），自动生成 getter/setter 方法内存管理代码
- assign：直接赋值，不做任何内存管理（默认，用于非 Objective-C 对象），不会生成 set 方法内存管理代码，仅仅只会生成普通的 getter / setter
- copy：release 旧值，copy 新值（一般用于 NSString *）

#### 2. 控制需不需要生成 set 方法
- readwrite：同事生成 set 方法和 get 方法（默认）
- readonly：只会生成 get 方法

#### 3. 多线程管理
- atomic：线程安全，性能低（默认）
- nonatomic：非线程安全，性能高

#### 4. 控制 set 方法和 get 方法的名称
- setter：设置 set 方法名称，一定有一个冒号：
- getter：设置 get 方法名称

>注意：不同类型的参数可以组合在一起使用。

### 10. @class
- 作用
	- 可以简单的引用一个类
- 简单实用
	- @class Person;
	- 仅仅是告诉编译器，Person 是一个类，并不会包含 Person 这个类的所有内容
- 具体使用
	- 在 .h 文件中使用 @class 引用一个类
	- 在 .m 文件中使用 #import 包含这个类的 .h 文件
 
- 其他应用场景
	1. 解决循环引用，比如 A 类引用 B 类，B 类同时引用 A 类
	2. 
- 和 #import 的区别
	- import 是一个预编译指令，会将 `""` 中的文件拷贝到 import 所在的位置，并且只要  `""` 中的文件发生了变化，那么 import 就会重新拷贝一次（更新操作）
	- @class 仅仅是告诉编译器，@class 后面的名称是一个类，不会做拷贝操作。所以编译器并不知道这个类中有哪些属性和方法，所以在 .m 文件中使用这个类的时候需要 import 这个类，才能使用。

- @class 好处
	- 编译效率更快
	- 解决两个类相互拷贝形成的`死循环`

### 11. 循环 retain
如果 A 对象要拥有 B 对象，而 B 对象有要拥有 A 对象，此时就会形成循环 retain

解决方案：不要让 A retain B，B 又 retain A，让其中一方不要做 retain 操作。

### 12. 集合中对象的内存管理
1. 如果将一个对象添加到一个数组中，那么数组会对对象进行一次 retain

	![](http://liangjinggege.com/Snip20170411_10.png?imageView/0/h/250)
	
2. 当数组对象释放后，会给数组中所有的对象发送一条 release 消息

	![](http://liangjinggege.com/Snip20170411_11.png?imageView/0/h/250)

3. 当数组移除一个对象之后，会给对象发送一条 release 消息
	
	![](http://liangjinggege.com/Snip20170411_12.png?imageView/0/h/250)

## autorelease
### 1. autorelease 基本概念
- autorelease 是一种致辞引用计数的内存管理方式，只要给对象发送一条 autorelease 消息，就会将对象放到一个自动释放池中，当自动释放池被销毁时，会对池子中的所有对象做一次 release 操作
	>注意：这里只是发送 release 消息，如果当时的引用计数依然不为 0，则该对象依然不会被释放。
	
- autorelease 对象会返回对象本身

```
Person *p = [[Person alloc] init];
p = [p autorelease];
```


- 调用完 autorelease 后，对象的引用计数器不变

```
Person *p = [[Person alloc] init];
p = [p autorelease];
NSLog(@"%lu", [p retainCount]); // 1
	
```

- autorelease 的好处
	- 不用再关心对象的释放时间
	- 不用再关心什么时候调用 release

- autorelease 的原理
	- autorelease 实际上只是把 release 的调用延迟了，对于每一个 autorelease，系统只是把该对象放入了当前的 autorelease pool 中，该 pool 中的所有对象都会被调用 release。

### 2. autorelease pool

#### #autorelease pool 使用
- iOS 5 以后

```
@autoreleasepool
	{ // 创建一个自动释放池
	    Person *p = [[[Person alloc] init] autorelease];
	
	} // 销毁自动释放池（会给池子中的所有对象发送一条 release 消息）
	
```

</br>

- iOS 5 以前

```
// 创建自动释放池
NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
    
Person *p = [[[Person alloc] init] autorelease];
    
// 销毁自动释放池
[autoPool drain];
//    [autoPool release];

```

- autorelease pool 的嵌套使用
	- 自动释放池是以`栈`的形式存在
	- 由于栈只有一个入口，所以调用 autorelease 永远会将对象放到`栈顶`的自动释放池

	```
	@autoreleasepool { // 栈底自动释放池
	    @autoreleasepool {
	        @autoreleasepool { // 栈顶自动释放池
	            Person *p = [[[Person alloc] init] autorelease];
	            
	        } // 销毁自动释放池（会给池子中的所有对象发送一条 release 消息）
	        Person *p = [[[Person alloc] init] autorelease];
	    }
	}
	
	```
</br>

#### #autorelease pool 注意事项
1. 一定要在自动释放池中调用 autorelease，才会将对象放入自动释放池中
2. 自动释放池中不适宜放占用内存较大的对象
	- 尽量避免对大内存使用该方法，对于这种延迟释放机制，还是尽量少用
	- 不要把大量循环操作放到同一个 @autorelease 之间，这样会造成内存峰值的上升

3. 一个 alloc / new 对应一个 autorelease 或者 release，不要写多次 autorelease/release。


#### #autorelease pool 应用场景
- 类工厂方法

```
NSArray *array = [NSArray array];

```

内部实现是：

```
NSArray *array = [[[NSArray alloc] init] autorelease];

```

```
+ (instancetype)person
{
    return [[[self alloc] init] autorelease];
}

```
## ARC
### 1.ARC 基本概念
#### #什么是 ARC
- Automatic Reference Counting，自动引用计数，即 ARC。ARC 是 LLVM 3.0 编译器的一项特性，使用 ARC，基本一举解决了手动内存管理的麻烦问题。
- 在工程中使用 ARC 非常简单，只需要和往常一样编写代autorelease码，只不过不用写 retain，release 三个关键字，这是 ARC 的基本原则。
- 当开启 ARC 是，编译器将自动在代码合适的地方插入 retain，release，autorelease，而作为程序员，完全不用担心编译器会做错。


#### #ARC 的注意点和有点
- ARC 注意点
	- ARC 是编译器特性，不是运行时特性
	- ARC 不是其他语言中的垃圾回收，有本质的区别
- ARC 的有点
	- 完全消除了手动管理内存的繁琐，让程序员更加专注于 app 的业务
	- 基本避免了内存泄漏
	- 有时还能更加快捷，因为编译器还可以执行某些优化

#### #ARC 的判断原则
- ARC 的判断原则	
	- 只有要有一个`强指针`变量指向对象，对象就会保存在内存中
- 强指针
	- 默认所有的指针都是`强指针`
	- 被 __strong 修饰的指针
	
	````
	Person *p1 = [[Person alloc] init];
    __strong Person *p2 = [[Person alloc] init];
	```

	
- 弱指针
	- 被 __weak 修饰的指针
	
	```
	__weak Person *p3 = [[Person alloc] init];
	
	```

### 2. ARC 中对多个对象内存管理
#### #MRC 
- A 对象想要拥有 B 对象，就需要对 B 对象进行一次 retain
- A 对象不用 B 对象了，需要对 B 对象进行一次 release（property 的时候 retain，dealloc 时候 release）


#### #ARC
- A 对象想拥有 B 对象，就需要用一个强指针指向 B 对象
- A 对象不用 B 对象了，什么都不需要做，编译器会自动做这些事情
- 在 ARC 中保存一个对象用 strong，相当于 MRC 中的 retain

#### #循环引用
- 对象之间的相互引用，如 A 对象引用 B 对象， B 对象 引用 A 对象，在 ARC 中也会发生循环引用
- 解决方案
	- 一边用 strong，一边用 weak，相当于 MRC 中的 assign



### 3. ARC 和 MRC 混编
#### #MRC 转 ARC
- 在 ARC 环境下：

	- target －> build phases －> compile sources －> 单击MRC的文件将 compiler flags设置为：`－fno－objc－arc`

- 通过 Xcode，Edit -> Refactor -> Convert to Objective-C ARC

#### #ARC 转 MRC

- 在 MRC 环境下：

	- target －> build phases －> compile sources －> 单击ARC的文件将compiler flags设置为：`－fobjc-arc`


## Copy
[源码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/Copy)

### 1. Copy 基本使用（深浅拷贝）

#### #Copy 的基本概念
- 什么是 Copy
	- 字面意思是复制，拷贝，是产生一个`副本`的过程

- 常见的复制：文件复制
	- 作用：利用一个`源文件`产生一个`副本文件`
	- 修改`副本文件`的内容，不会影响到`源文件`

- Objective-C 中的 Copy
	- 作用：利用一个`源对象`产生一个`副本对象`

- 特点
	- 修改源对象的属性和行为，不会影响到副本对象
	- 修改副本对象的属性和行为，不会影响源对象


#### #Copy 的使用
- 如何使用 copy 功能
	- 一个对象可以调用 copy 或 mutableCopy 方法来创建一个对象
	- copy：创建的对象是`不可变副本`（如：NSString、NSArray、NSDictionary）
	- mutableCopy：创建的对象是`可变副本`（如：NSMutableString、NSMutableArray、NSMutableDictionary）
	
- 使用 copy 的前提
	- copy：需要遵守 NSCopying 协议，实现 copyWithZone 方法
	
	```
	@protocol NSCoping
	- (id)copyWithZone:(NSZone *)zone;
	@end
	
	```


- 使用 mutableCopy 的前提
	- mutableCopy：需要遵守 NSMutableCoping 协议，实现 mutableCopyWithZone 方法
	
	```
	@protocol NSMutableCoping
	- (id) mutableCopyWithZone:(NSZone *)zone;
	@end
	
	```
	
- 几种情况分析
	1. 可变对象调用 copy
	
		![](http://liangjinggege.com/Snip20170412_2.png?imageView/0/h/230)
	
	>结论： `可变对象`调用 copy 方法，`会生成`新的对象，并且新对象是`不可变`的。
	
	2. 可变对象调用 mutableCopy
	
		![](http://liangjinggege.com/Snip20170412_3.png?imageView/0/h/240)
	
	>结论： `可变对象`调用 mutableCopy，`会生成`新的对象，并且新对象是`可变的`。
	
	3. 不可变对象调用 mutableCopy
	
		![](http://liangjinggege.com/Snip20170412_4.png?imageView/0/h/240)
	
	>结论： `不可变对象`调用 mutableCopy，`会生成`新的对象，并且新对象是`可变的`。
	
	4. 不可变对象调用 copy
	
		![](http://liangjinggege.com/Snip20170412_5.png?imageView/0/h/230)
	
	>结论： `不可变对象`调用 copy，`不会生成`新的对象，并且新对象是`不可变的`。
	
	>原因：因为原来的对象时不可变的，拷贝出来的对象也是不能修改的，既然两个都不能修改，所以永远也不能影响到另外一个对象，那么已经符合要求，Objective-C 为了对内存进行优化，所以就不会生成一个新的对象。


#### #深浅拷贝
正是因为调用 copy 方法有时候会生成一个新的对象，有时候不会生成一个新的对象，所以：如果没有生成新的对象，则称为`浅拷贝`，本质就是`指针拷贝`，如果生成了新的对象，则称为`深拷贝`，本质就是会创建一个新的对象

>只有`源对象和副本对象都不可变`时，才是`浅拷贝`，其他都是`深拷贝`。

### 2. Copy 的内存管理
- 如果是浅拷贝（源对象和副本对象都不可变），由于不会生成新的对象，所以系统会对源对象进行一次 retain。所以对源对象一次 copy 操作，就要相应的做一次 release 操作。

	![](http://liangjinggege.com/Snip20170412_6.png?imageView/0/h/230)

- 如果是深拷贝。真是因为生成了新的对象，所以系统不会对源对象进行 retain，但是因为生成了新对象，所以需要对新对象进行一次 release。

	![](http://liangjinggege.com/Snip20170412_8.png?imageView/0/h/260)


### 3. Copy 和 Property
#### #修饰字符串类型
- Copy 是 Property 中内存管理的关键字。主要修饰 NSString 类型的属性。作用：为了防止修改了外界变量，影响到了对象中的属性。
		
```
@property(nonatomic, copy) NSString *name;

```
	
![](http://liangjinggege.com/Snip20170412_9.png?imageView/0/h/260)


#### #修饰 block
- 如果 block 存储在`栈`中，block 中访问了外界的对象，`不会`对对象进行一次 retain 操作
	
![](http://liangjinggege.com/Snip20170412_16.png?imageView/0/h/220)
		
- 如果 block 存储在`堆`中，block 中访问了外界的对象，`会`对对象进行一次 retain 操作
	
![](http://liangjinggege.com/Snip20170412_15.png?imageView/0/h/220)


- 修饰 block。可以使用 copy 来保存 block，这样可以让 block 中使用到的外界对象进行一次 retain 操作，避免以后调用 block 的时候，外界的对象已经释放了。（如果外界对象在调用 block 之前被释放了，那么程序就会崩溃）
	
```
// 注意：如果是 block 使用 copy 并不是拷贝，而是转移，将栈中的 block 转移到 堆中去
@property(nonatomic, copy) void (^myBlock)();
	
```
			
#### #copy block之后引发的循环引用
- 如果对象中的 block 又用到了对象自己，那么此时会产生循环引用，发生内存泄漏，为避免这种情况，应该将对象修饰为 `__block`。
	
![](http://liangjinggege.com/Snip20170412_17.png?imageView/0/h/250)
	
### 4. 自定义类实现 Copy
[源码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E8%87%AA%E5%AE%9A%E4%B9%89%E7%B1%BB%E5%AE%9E%E7%8E%B0%20Copy)

#### 自定义类实现 copy 操作
- 让类遵守 NSCopying 协议
- 实现 copyWithZone:方法，在该方法中返回一个对象的副本即可
- 在 copyWithZone:方法中，创建一个新的对象，并设置该对象的数据与现有对象一致，并返回该对象
	
#### #无父类实现

```
@interface Person : NSObject<NSCopying> // 遵守 NSCopying 协议
@property(nonatomic, copy) NSString *name;
@end
   
@implementation Person
// 实现 copyWithZone:方法
- (id)copyWithZone:(NSZone *)zone 
{
    // 1. 创建一个新的对象
    Person *p = [[[self class] alloc] init];
    // 2. 设置当前对象内容给新对象
    p.name = _name;
    // 3. 返回新对象
    return p;
}
@end

```
	
![](http://liangjinggege.com/Snip20170412_18.png?imageView/0/h/240)
	
	
#### #有父类实现
如果想让子类在 copy 的时候保留子类的属性，那么必须重写copyWithZone: 方法，在该方法中，先调用父类创建副本设置值，然后再设置子类特有值
	
```
@interface Student : Person
@property(nonatomic, assign) CGFloat height;
@end
	
@implementation Student
- (id)copyWithZone:(NSZone *)zone
{
    // 1. 调用父类创建副本设置值
    id obj = [super copyWithZone:zone];
    // 2. 设置数据给副本
    [obj setHeight:_height];
    // 3. 返回新对象
    return obj;
}
@end

```
	
![](http://liangjinggege.com/Snip20170412_19.png?imageView/0/h/240)
	

> MatableCopy 和 Copy 实现类似，只要遵守 NSMutableCoping 协议，然后实现 mutableCopyWithZone:方法。