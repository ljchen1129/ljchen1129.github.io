---
title: Objective-C 语言基础（一、基础知识）
date: 2017-04-06 21:42:49
tags: 
- iOS
- Objective-C
categories: 
- Objective-C
- iOS
---

## Objective-C 简介
- Objective-C 是一门面向对象的计算机语言
- Objective-C 是在 C 语言的基础上增加了一层面向对象的语法
- Objective-C 完全兼容 C 语言
- 可以在 Objective-C 中混入 C 语言代码
- 可以使用 Objective-C 开发 Mac OS 平台和 iOS 平台的应用程序

## C 和 Objective-C 比较
### 1. 源文件对比
- C 语言中常见源文件 .h 开头、.c 文件
	
文件扩展名  | 源类型
------------- | -------------
.h  			| 头文件，用于存放函数声明
.c  | C 语言源文件，用于实现头文件中声明的方法
	
- Objective-C 语言中源文件 .h 头文件、.m 与 .mm 实现文件
	
文件扩展名  | 源类型
------------- | -------------
.h  			| 头文件，头文件包含类、方法、属性的声明
.m/.mm  		| 类的实现文件，参与编译的文件，用来实现类中声明的方法
	
### 2. 关键字对比
- C 语言关键字度可以在 Objective-C 源程序中使用
- Objective-C 新增的关键字在使用时，注意部分关键字以`@`开头
	
### 3. 数据类型
#### #C 语言数据类型
- 基本数据类型
	- 整型
		- 短整型：short
		- 整型：int
		- 长整型：long
	- 字符型：char
	- 实型（浮点型）
		- 单精度：float
		- 双精度：double
- 构造类型
	- 数组
	- 结构体
	- 枚举
	- 共用体
- 指针类型
- 空类型（Void）


#### #Objective-C 语言数据类型
- 基本数据类型
	- 整型
		- 短整型：short
		- 整型：int
		- 长整型：long
		- 布尔类型：BOOL
	- 字符型：char
	- 实型（浮点型）
		- 单精度：float
		- 双精度：double
- Block 类型
- 构造类型
	- 数组
	- 结构体
	- 枚举
	- 共用体
- 指针类型
	- 类：class
	- id 类型
- 空类型：Void
- 特殊类型：SEL、nil
	
类型  | 描述
------------- | -------------
BOOL 			| 只有两个取值，真和假
NSObject *  		| Objective-C 中对象类型				id  		| 动态对象类型，万能指针
SEL  		| 选择器数据类型
block  		| 代码块数据类型


### 4. 流程控制语句
#### #C 语言中使用的流程控制语句都可以在 Objective-C 语言中应用

	if 语句
	switch 语句
	while 语句
	do while 语句
	for 语句
	break 语句
	continue 语句

#### #增强 for 循环，用于快速迭代数组或者集合
- C 语言 for 循环

```
for (int i = 0; i < 10; i++)
{
    printf("%d", i);
}
    
```

- Objective-C 语言增强 for 循环

```
for (NSString *string in NSArray)
{
    NSLog(@"%@", string);
}

```

### 5. 函数（方法）定义和声明对比
- C 语言中函数的声明和实现
	- 函数声明：int sum(int a, int b);
	- 函数实现：int sum（int a, int b）{ return a + b; }

- Objective-C 中的方法
	- 方法声明：- (int)sum:(int)a andB:(int)b;
	- 方法实现：- (int)sum:(int)a andB:(int)b { return a + b } 

- 注意：方法只能写在类里面，而函数可以写在任何地方
	- 对象方法：使用对象调用的方法
	- 类方法：使用类名调用的方法

	```
	// 对象方法
	- (id)initWithString:(NSString *)name;
	// 类方法
	+ (MyClass *)creatMyClassWithString:(NSString *)name;
	
	```

### 6. 面向对象新增特性
- 封装性
- 继承性
- 多态性


### 7. 面向对象新增语法
- 属性生成器
	- @property
	- @synthesize

	```
	// 声明属性
	@property (nonatomic, strong) NSString *name;
	
	// 合成属性
	@synthesize name = _name;
	
	```

- 分类
	- 分类与集成
	- 使用分类扩展类，无需子类化

	```
	@interface NSString (MyNSString)
	
	- (NSString *)encrypWithMD5;
	
	@end
	
	```

- 协议
	- 使用协议声明方法
	- 协议类似于 C#，Java 中的接口

	```
	@protocol MyProtocol
	
	- (void) MyProtocolMethod;
	
	@end
	
	```

- Foundation 框架
	- 创建和管理集合，如数组和字典
	- 访问存储在应用中的图像和其他资源
	- 创建和管理字符串
	- 发布和观察通知
	- 创建日期和时间对象
	- 操控 URL 流
	- 异步执行代码

### 8. 新增异常处理
- 用于处理错误信息
- 格式：
	- @try ..... @catch ..... @finally
- 示例
	
	```
	// 创建对象per
    Person *per = [Person new];
    @try {
        // 调用一个没有实现的方法
        [per test];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.name);
    } @finally {
        NSLog(@"继续执行\n");
    }

	```
	
## include 和 import
- import 和 include 功能一样，是将右边的文件拷贝到当前 import 的位置
- import 是一个预处理指令，会自动防止重复拷贝
	
## 类和对象
- Objective-C 是一种面向对象的语言，定义类是他的基本能力
- 类是用来描述对象的，是一系列方法和属性的集合
- Objective-C 的类声明和实现包括两个部分：接口部分和实现部分
- 想要定义方法，就必须先有类的存在

### 如何设计一个类
- 生活中描述事物，一般有名称/属性，行为
	- 如：人有身高，体重等属性，有说话，吃饭等行为
	
	```
	事物名称（类名）：人（Person）
	属性：身高（height），年龄（age）
	行为（功能）：说话（say），吃饭（eat）
	
	```
	
- Objective-C 中用类来描述事物也是如此
	- 属性：对应类中的成员变量
	- 行为：对应类中的成员方法
		
- 定义类其实是在定义类中的成员（成员变量和成员方法）
	
	
### 如何分析一个类

- 一般名词都是类（名词提炼法）
	- 飞机发射两颗炮弹摧毁了 8 辆装甲车
	
	```
	飞机
	炮弹
	装甲车
	
	```

- 拥有相同（或者类似）属性（状态特征）和行为的对象都可以抽象成为一个类
- 定义行为（方法）时注意：谁最清楚这个行为，那么该行为就属于谁

## 对象的内存存储细节
首先定义一个类，Person 类，拥有属性：age，height，weight，方法：eat，sleep，walk。

```
@interface Person : NSObject
{
    int _age;
    double _height;
    double _weight;
}

- (void)eat:(char *)food;
- (void)sleep;
- (void)walk;

@end

@implementation Person

- (void)eat:(char *)food
{
    NSLog(@"eat");
}

- (void)sleep
{
    NSLog(@"sleep");
}

- (void)walk
{
    NSLog(@"walk");
}

```

### 通过类创建对象

1. 开辟存储空间，通过 new 方法创建对象会在`堆`内存中开辟一块存储空间
2. 初始化所有属性
3. 返回指针地址

> 创建对象的时候返回的地址其实就是类的第 0 个属性的地址，因为类对象的本质就是一个结构体，结构体的地址就是结构体中第 0 个属性的地址。但是类的第 0 个属性并不是当前 Person 类的第 0 个属性 _age，而是一个叫做 `isa` 的属性，`isa` 是一个指针，占 8 个字节。

> 其实类也是一个对象，也就意味着 Person 也是一个对象，平常所说的创建对象就是通过一个`类对象`来创建一个新的`实例对象`。`类对象`是系统自动帮我们创建的，里面保存了当前对象的所有方法，而实例对象是程序员手动创建的，实例对象中有一个 `isa` 指针，指向了那个创建他的`类对象`。
 

```
Person *p = [Person new];

```

在内存中的存储情况：

![](http://o6heygfyq.bkt.clouddn.com/object%20memory.001.jpeg?imageView/0/h/450)

### 过程描述：

首先程序启动，Person 类代码被加载进`代码区`， 系统会自动根据 Person 类代码在`堆`中分配存储空间创建一个 `Person 类对象`，里面保存着 Person 类所有的方法。 接着调用 new 方法，从  `Person 类对象`里面查找 new 方法，也是在`堆`中分配存储空间创建一个 `Person 实例对象`，`实例对象`默认的第 0 个属性就是一个 `isa` 指针，这个指针就是指向 `Person 类对象`，接着初始化 Person 类中的所有属性，其中`isa` 指针会被初始化为指向创建他的对象地址，初始化完成后返回 `Person 实例对象` 的地址，保存在`栈`中的指针变量 p。

## 局部变量&&全局变量&&成员变量
### 局部变量
- 写在函数或者代码块中的变量，称为局部变量
- 作用域：从定义的那一行开始，一直到文件的末尾
- 局部变量可以先定义再初始化，也可以定义的同时初始化
- 存储：栈
- 存储在栈中的数据系统会自动释放

### 全局变量
- 写在函数和大括号外部的变量，称为全局变量
- 作用域：从定义的那一行开始，一直到文件的末尾
- 全局变量可以先定义再初始化，也可以定义的同时初始化
- 存储：静态区
- 程序一启动就会分配存储空间，直到程序结束才会释放

### 成员变量
- 写在类声明的大括号中的变量，称为成员变量（属性、实例变量）
- 成员变量只能通过对象来访问
- 注意：成员变量不能离开类，离开类以后就不是成员变量，成员变量不能在定义的同时进行初始化
- 存储：堆区
- 存储在堆区的数据，不会被自动释放，需要程序员手动释放


## 方法和函数
- 函数属于整个文件，方法属于某一个类，方法离开类就不行
- 函数可以直接调用，方法必须用对象来调用。注意： 虽然函数属于整个文件，但是如果把函数写到类的声明中会不识别
- 不能把函数当方法来调用，也不能把方法当函数来调用
- 方法可以没有声明只有实现
- 方法如果只有声明没有实现，编译不会报错，但是运行会报错

## 常见错误
1. 只有类的声明，没有类的实现
2. 漏了@end
3. @interface 和 @implemention 嵌套
4. 成员变量没有写在大括号里面
5. 方法声明写在大括号里面
6. 成员变量不能在 {} 中进行初始化，不能被直接拿出去访问
7. 方法不能当做函数一样调用
8. Objective-C 方法只能声明在 @interface 和 @end 之间，只能实现在 @implemention 和 @end 之间。Objective-C 方法不能独立于类存在。
9. C 函数不属于类，跟类没有关系，只归定义函数的文件所有
10. C 函数不能访问 Objective-C 对象的成员
11. 成员变量和方法不能用 `static` 关键字修饰
12. 类的实现可以写在 main 函数后面，在使用之前只要声明就可以

## 结构体作为对象属性

```
typedef struct {
    int year;
    int month;
    int day;
}Date;
	
@interface Person : NSObject
{
    @public
    Date _brithday;
}
	
- (void)sayBrithday;
	
@end
	
@implementation Person
- (void)sayBrithday
{
    NSLog(@"brithday.year = %i, brithday.mouth = %i, brithday.day = %i",_brithday.year, _brithday.month, _brithday.day);
}
	
@end
	
int main(int argc, const char * argv[]) {
  
    // 通过类创建对象
    /*
     1. 开辟存储空间
     2. 初始化所有属性
     3. 返回指针地址
     */
    Person *p = [Person new];
    p->_brithday = (Date){1991, 5, 23};
    
    // 等价于下面这种，本质是复制了一份一模一样副本
    Date d1 = {1991, 5, 23};
    Date d2;
    d2 = d1;
	
    [p sayBrithday];
    
    return 0;
}

```
## 匿名对象
没有名字的对象叫做匿名对象。但是无论有没有名字，只要调用 new 方法就都会返回对象的地址，每次 new 都会开辟一块新的存储空间

```
// 非匿名对象
Person *p1 = [Person new];
// 匿名对象
[Person new];

```
- 匿名对象的应用场景
	- 当对象只需要使用一次的时候就可以使用匿名对象
	- 匿名对象可以作为方法的实参


## 修改项目模板
可以修改每次新增项目文件的默认内容，比如新文件的默认说明。
地址：/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates

在里面进行相应的配置修改，有文件模板，还有工程模板。

## 阅读 Xcode 文档
- 文档关键字说明
	- Getting Started --- 新手入门建议初学者看，里面有一些建立观念的东西。
	- Guides --- 指南。指南是 Xcode 中最酷最好的东西，能够从一个问题，或者系统的一个方面出发，一步一步详 细介绍怎么使用 Cocoa 文档，能帮助整理好学校的脉络。
	- Reference --- 参考资料。一个一个框架一个一个类组织起来的文档，包含了每个方法的使用方法。
	- Release Notes --- 发布说明。一个 iOS 新版本带来了哪些新特性，熟悉新 iOS，比较不同 iOS 版本 API 不同，都需要参考这些信息。
	- Sample Code --- 示例代码。苹果官方提供的一些示例代码，帮助学习某些技术某些 API，可以从示例代码中看出苹果官方的编码风格，以及帮助了解文档具体是怎么回事。
	- Technical Notes --- 技术说明。一些技术文章。
	- Technical Q&A --- 常见技术问答。技术社区里面的一些常见问题及回答整理。
	- Viedo --- 视频。主要是 WWDC 的视频，有空的话，建议都看，也可以练习英文。 


- 一些有价值的文档
	- [Start Developing iOS Apps Today](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/index.html)
		- 马上着手开发 iOS 应用程序，建立基本 iOS 开发概览
	- [iOS Thechnology Overview](https://developer.apple.com/library/content/documentation/Miscellaneous/Conceptual/iPhoneOSTechOverview/Introduction/Introduction.html)
		- iOS 技术概览，阅读这个文档的目的和检测标准是，遇到具体问题，知道应该去看哪方面的文档。
	- [iOS Human Interface GuideLines](https://developer.apple.com/ios/human-interface-guidelines/overview/design-principles/)
		- iOS 人机交互指南，阅读这个文档的目的和检测标准是，看到任何一个 App，可以知道他的任何一个 UI 是系统控件，还是自定义的，他的层次关系是怎样的。
	- [Programming with Objective-C](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)
		- 学习这个 Objective-C 基础语法，阅读这个文档的目的和检测标准是，看的懂基本的 Objective-C 代码，方便后面学习和阅读各种示例代码
	- [App Programming Guide for iOS](https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html)
		- iOS 应用程序编程指南，介绍的及时开发一个 App 的完整流程，包括从 App 的生命周期，休眠，激活等等，阅读这个文档的目的和检测标准是，了解全部流程和很多细节问题。
	- [View Programmming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009503)
	- [View Controller Programmming Guide for iOS](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/#//apple_ref/doc/uid/TP40007457-CH2-SW1)
		- 阅读这两个文档的目的和检测标准是，深刻理解什么是 View，什么是 View Controller，理解生命情况下用 View，什么情况下用 View Controller。
	- [Table View Programmming Guide for iOS](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html#//apple_ref/doc/uid/TP40007451)
		- 阅读这个文档的目的和检测标准是，深刻理解 UITableView/ UITableViewController 的理论和使用方法。	