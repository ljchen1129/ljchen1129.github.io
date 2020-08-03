---
title: '《Effective Objective-C 2.0》读书笔记（第一章：熟悉 Objective-C）'
date: 2017-03-27 16:10:42
tags:
- iOS
- Objective-C
categories:
- iOS
- Objective-C
---

## 前言
正在读[《Effective Objective-C 2.0》](https://book.douban.com/subject/25829244/)这本书，这本书主要介绍了一些使用 Objective-C 语言编写代码方面的 52 个有效方法，并且介绍了相应的原理。准备按章节写下读书笔记，并贴出实际的验证代码。
<!-- more -->
1. [《Effective Objective-C 2.0》读书笔记（第一章：熟悉 Objective-C）](http://chenliangjing.me/2017/03/27/%E3%80%8AEffective-Objective-C-2-0%E3%80%8B%EF%BC%88%E4%B8%80%EF%BC%89-%E7%86%9F%E6%82%89-Objective-C/)
2. 《Effective Objective-C 2.0》读书笔记（第二章：对象、消息、运行时）
3. 《Effective Objective-C 2.0》读书笔记（第三章：接口与 API 设计）
4. 《Effective Objective-C 2.0》读书笔记（第四章：协议与分类）
5. 《Effective Objective-C 2.0》读书笔记（第五章：内存管理）
6. 《Effective Objective-C 2.0》读书笔记（第六章：block 与 GCD）
7. 《Effective Objective-C 2.0》读书笔记（第七章：系统框架）

##   Objective-C 语言的起源
Objective-C 语言是在 C 语言的基础上添加了一层面向对象，是 C 语言的超集。由 Smalltalk 演化而来，使用动态绑定的`消息结构（messaging structrue）`而不是`函数调用（function calling）`。在运行时才会检查对象类型，接收一条消息后，究竟该执行何种代码，由运行时环境而不是编译器来决定。

### #区别
- 函数调用（function calling）：运行时所应执行的代码由`编译器`决定。如果调用的函数是多态的，运行时按照`虚方法表（virtual table）`来查出到底执行那个函数实现。
- 消息结构（messaging structrue）：运行时所应执行的代码由`运行环境`决定。不论是否多态，总是在运行时才去查看所要执行的的方法。

### #内存模型

- Objective-C 对象所占内存分配在`堆空间（heap space）`

	```
	NSString stackString;
	```
	
- 直接这样定义，会报如下错误：
	
	![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170327_2.png?imageView2/0/h/100)
	
> 原因：Objective-C 对象所占的内存总是分配在`堆（heap）`空间上，而不是在`栈空间（stack space）`，不能在栈中分配 OC 对象。

-  Objective-C 对象的内存布局

	```
	// 定义两个指针变量 oneString 和 twoString，指向同一个 NSString 类型的对象实例
	NSString *oneString = @"I am String";
   NSString *twoString = oneString; 
	```
	
- 此时的内存布局：
	
![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170327_3.png?imageView2/0/h/250)
	
> 此时图中演示了一个分配在堆中的 NSString 实例，还有两个分配在栈上的指针指向该实例。其中，分配在堆中的内存必须直接管理，而分配在栈上用于保存变量的内存则会在其栈帧（stack frame）弹出时自动清理。

## 在类头文件中尽量少引用其他头文件
在 .h 声明文件中，如果不是必须要引用到其他的类，只是使用到其他类的类名，可以使用`向前声明（forward declaring）`。

- 举个栗子：有一个 LJPerson 类，需要提及 LJStudent 类，并不需要知道 LJStudent 类里面的细节，可以使用向前声明。

	```
	#import <Foundation/Foundation.h>
	@class LJStudent; // 向前声明
	
	@interface LJPerson : NSObject
	
	/// 姓名
	@property(nonatomic, copy) NSString *name;
	/// 年龄
	@property(nonatomic, assign) NSUInteger age;
	/// 学生
	@property(nonatomic, strong) LJStudent *stu;
	
	@end

	```

- 这样做的好处：
	1. 解决两个类`互相引用`的问题；
	2. 减少类的使用者所需引入头文件的数量，这样也就减少了编译时间；

- 必须引入的情况：
	1. 如果这个类继承自其他类，假设 LJTeacher 类继承自 LJPerson 类，那么在 LJTeacher 的头文件中必须引入 LJPerson 类；
	
	```
	#import "LJPerson.h"

	@interface LJTeacher : LJPerson
	
	@end
	```
	
	
	2. 如果要声明类遵从某个协议，该协议必须要有完整的定义，不能使用向前声明，也必须在头文件中引入包含该协议的类；

- 原则：
	1. 除非有必要，否则不要引入头文件。一般做法：在头文件中使用`向前声明`来提及其他类，然后在实现文件中再引入这个类的头文件。这样做可以尽量降低类之间的`耦合（couping）`。
	2. 有时无法使用向前声明，比如声明某个类遵循某一协议。这种情况，尽量把`该类遵循某项协议`的这条声明移到分类中去。比如 UITableViewDataSource 这种委托协议，这种协议只有与接收委托的类放在一起才有意义，可以在 .m 文件中引入协议的头文件，声明和实现协议。如果不行的话，就把协议单独放在一个头文件中，然后将其引入。

## 多用字面量语法，少用与之等价的方法
- 使用`字面量语法（literal syntax）`的好处：
	1. 缩短源代码长度；
	2. 可读性更强；
	3. 在初始化数组和字典时更为安全，如果数组或者字典中的元素有 nil 值时，会及时抛出异常；
	
### #字面量数值
可以使用 NSNumber 类将整数、浮点数、布尔值转化成 Objective-C 对象。

- 不用字面量方式：

	```
	// 整数
	NSNumber *someInt = [NSNumber numberWithInt:29];
	    
	// 浮点数
	NSNumber *someFloat = [NSNumber numberWithFloat:2.9];
	    
	// 布尔值
	NSNumber *someBool = [NSNumber numberWithBool:YES];
	    
	// char
	NSNumber *someChar = [NSNumber numberWithChar:'a'];
	
	```

- 使用字面量方式：
	
	```
	 // 整数
    NSNumber *someInt = @29;
    
    // 浮点数
    NSNumber *someFloat = @2.9f;
    
    // 布尔值
    NSNumber *someBool = @YES;
    
    // char
    NSNumber *someChar = @'a';
    
    // 表达式
    int x = 3;
    float y = 5.8f;
    NSNumber *expressionNumber = @(x * y);
	
	```

### #字面量数组
使用字面量创建数更简洁和会更安全。

- 不用字面量方式：
	
	```
	
	NSArray *sports = [NSArray arrayWithObjects:@"basketball",
                                                @"football",
                                                @"swimming",
                                                @"running", nil];
                                                
	// 操作数组
   NSString *running = [sports objectAtIndex:3];
    
	```
	
	
	
- 使用字面量方式：

	```
	NSArray *sports = @[@"basketball", @"football", @"swimming", @"running"];
	
	// 操作数组
   NSString *running = sports[3];
	
	```
- 更安全？

	假设有三个对象实例obj1、obj2、obj3，其中 obj2 为 `nil`，分别使用两种方式创建数组 arrayA、arrayB，看下会发生什么情况：
	
	```
	
	id obj1 = @"obj1";
	id obj2 = nil;
	id obj3 = @2;
	    
	NSArray *arrayA = [NSArray arrayWithObjects:obj1, obj2, obj3, nil];
	NSLog(@"arrayA=%@",arrayA);
	NSArray *arrayB = @[obj1, obj2, obj3];
	NSLog(@"arrayB=%@",arrayB);

	```
	看下打印：
	
	![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170327_5.png?imageView2/0/h/150)
	
	> 结果：没有使用字面量方式创建的数组 arrayA 只有 obj1 一个元素加进去了，而使用字面量创建的数组 arrayB 崩溃了。
	
	>原因：arrayWithObjects 方法会依次处理各个参数，直到发现 nil 为止，由于 obj2 是 nil，所以该方法会提前结束；而使用字面量创建的数组的效果时先创建了一个数组，然后把 `[]` 内所有的对象都加入到这个数组，当发现了 为 nil 的对象加进数组时会抛出异常，可以很快的发现编程中的错误，所以更安全。

### #字面量数组
和字面量数组类似

- 不使用字面量
	
	```
	
	// 字典
	NSDictionary *notLiteralDic = [NSDictionary dictionaryWithObjectsAndKeys: @"chenlj",@"name", @25, @"age", @"iOS", @"job", nil];
	    
	// 读取
	NSString *job = [notLiteralDic valueForKey:@"job"];
	NSLog(@"job=%@", job);
	    
	// 可变
	NSMutableDictionary *notLiteralMdic = [notLiteralDic mutableCopy];
	
	// 写入
	[notLiteralMdic setObject:@"Andriod" forKey:@"job"];
	NSLog(@"notLiteralMdic=%@", notLiteralMdic);
    
	```
	
- 使用字面量

	```
	// 字典
	NSDictionary *literalDic = @{@"name" : @"chenlj", @"age" : @25, @"job" : @"iOS"};
	    
	// 读取
	NSString *job = literalDic[@"job"];
	NSLog(@"job=%@", job);
	    
	// 可变
	NSMutableDictionary *literalMdic = [literalDic mutableCopy];
	    
	// 写入
	literalMdic[@"job"] = @"Andriod";
	NSLog(@"literalMdic=%@", literalMdic);
	
	```
	
- 打印：
	
	![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Snip20170327_6.png?imageView2/0/h/100)
	
- **要点**
	- 应该使用字面量语法来创建字符串、数值、数组、字典。与创建此类对象的常规方法相比，更加简明扼要。
	- 应该通过取下标操作来访问数组小标或字典的键所对应的元素；
	- 用字面量语法创建数组或字典时，若值中有 nil，则会抛出异常。因此，需要务必确保值里不含 nil。

## 多用类型常量，少用 #define 宏定义







## 用枚举表示状态、选项、状态码


















