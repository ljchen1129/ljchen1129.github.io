---
title: Objective-C 语言基础（四、Category&Extension&Block&Protocol）
date: 2017-04-10 21:38:05
tags:
- iOS
- Objective-C
- Category
- Extension
- Block
- Protocol
categories:
- iOS
- Objective-C
---

## Category
### 1. Category 基本概念
- Category 是 Objectvie-C 特有的语法，其他语言没有
- Category 作用
	- 可以在`不修改`原来类的基础上，为这个类`扩充一些方法`
	- 一个庞大的类可以分模块开发
	- 一个庞大的类可以有多个人编写，更有利于团队合作

### 2. Category 格式
- 在 .h 文件中声明类别
	- 新添加的方法必须写在 @interface 和 @end 之间
	- ClassNme（现有类的类名，要为那个类扩充方法） + CategoryName (待声明的类别名称)
	- NewMethod：先添加的方法

```
// Category 的声明
@interface ClassName (CategroyName)
NewMethod; // 在类别中添加方法
// 不允许在类别中添加成员变量
@end
	
```
<!-- more -->
- 在 .m 文件中实现类别

```
// Category 的实现
@implementation ClassName (CategoryName)
NewMethod
{
    // 扩充的方法的实现
}
@end
	
```

</br>
### 3. Category 注意事项
1. 分类是用来给原有类添加方法，它只能添加方法，不能添加属性（成员变量）
2. 分类中的 @property，只会生成 setter/getter 的声明，不会生成 setter/getter 的实现以及成员变量
3. 可以在分类中访问原有类中 .h 中属性
4. 如果分类中有和`原有类同名`的方法，会`调用分类`中的方法，会`忽略掉原有类`的方法，开发中要`谨慎`这样写代码。
5. 如果`多个分类`中都有和`原有类中同名`的方法，那么调用该方法的时候会执行谁由`编译器决定`，会执行`最后一个参与编译`的分类中的方法。
6. 分类中方法的调用顺序：分类 -> 本类 -> 父类

## Extension
### 1.什么是类扩展？
- 延展类别，又称为扩展（Extension），Extension 是 Category 的一个特例
- 可以为某一个类扩充一些`私有的成员变量`和`方法`
	- 写在 .m 文件中
	- 英文名是 Class Extension


### 2. 类扩展的书写格式

```
@interface ClassName ()
// 扩充成员变量和方法
@end

```

>对比分类，只是少了一个分类名称，因此也被称作“`匿名分类`”。

## Block
### 1. 什么是 Block？
- Block 是 iOS 中一种比较特使的`数据类型`
- Block 是苹果官方特别推荐使用的数据类型，应用场景广泛
	- 动画
	- 多线程
	- 集合遍历
	- 网络请求回调

- Block 的作用
	- 用来`保存一段代码`，可以在适当的时候再取出来调用
	- 功能类似于`函数和方法`


### 2. Block 的格式
#### #Block 的定义格式

```
返回值类型 (^blcok 变量名)(形参列表) = ^(形参列表) {
            
};

```

#### #Block 和指向函数的指针很像

```
int (* sumP)(int, int) = sum;
printf("%d" ,sumP(10, 20)); // print 30

```

>区别：`函数指针`保存的是`函数的地址`，而 block 保存的是`一段代码块`。


#### #Block 的最简单格式，无参数无返回值

```

// 无参数无返回值 Block
void (^block 变量名称) () = ^{ 代码块; }
// 举例
void (^block) () = ^{
    NSLog(@"我是 block");
};
block(); // 我是 block

```

#### #带有参数 Block 的定义和使用

```

// 格式
void (^block 变量名) (形参列表) = ^(形参列表) { 代码块; };

// 举例
void (^myBlock) (NSString *name, int age) = ^(NSString *name, int age) {
    NSLog(@"name = %@, age = %d", name, age);
};
myBlock(@"陈良静", 25); // name = 陈良静, age = 25

```


#### #带有参数和返回值的 Block 的定义和使用

```
// 格式
返回值类型 (^block 变量名称)(形参列表) = ^ (形参列表) { 代码实现; };

// 举例
int (^sumBlock)(int a, int b) = ^(int a, int b) {
    NSLog(@"%d", a + b);
    return a + b; 
};
// 调用 block
sumBlock(10, 20); // 30

```


#### #调用 block 保存的代码

```
block变量名(实参);

```

#### #Block 和 typedef
- 给 Block 数据类型取别名


```
// 格式
typedef 返回值类型 (^ Block类型别名) (形参列表);
// 举例
typedef int (^calculator) (int, int);

// 使用
calculator sumBlock = ^(int a, int b) { return a + b };
// 调用 block
sumBlock(10, 20); // 30 

```

>注意：利用 `typedef` 给 block 取别名，和指向函数的指针一样，block 变量名称就是别名。
 
### 3. Block 的应用场景
- 当发现代码的前面和后面都是一样的时候，这个时候就可以使用 block
- 举个栗子：每天上班前和上班后做的事情都一样，只有上班的时候做的事情才不一样，这个场景就可以使用 Block


```
void goWorkPrefix()
{
    NSLog(@"起床");
    NSLog(@"跑步去上班");
    NSLog(@"打开电脑");
}

void goWorkSufix()
{
    NSLog(@"关闭电脑");
    NSLog(@"收拾东西");
    NSLog(@"跑步回家");
}

void goWork(void (^workBlock)())
{
    // 上班前做的事情
    goWorkPrefix();
    
    // 上班中
    workBlock();
    
    // 下班前做的事情
    goWorkSufix();
}

void goWorkInDay1()
{
    goWork(^{
        NSLog(@"认识新同事");
    });
}

void goWorkInDay2()
{
    goWork(^{
        NSLog(@"熟悉项目");
    });
}

void goWorkInDay3()
{
    goWork(^{
        NSLog(@"开发新需求");
    });
}

void goWorkInDay4()
{
    goWork(^{
        NSLog(@"项目发布");
    });
}

// 调用
goWorkInDay1();
goWorkInDay2();
goWorkInDay3();
goWorkInDay4();

```

### 4. Block 的注意事项
#### #block 中可以访问外面的变量

```
// 1. block 中可以访问外面的变量
int a = 10;
void (^myBlock)() = ^{
    NSLog(@"%i", a);
};
myBlock(); // 10

```

#### #block 中可以定义和外界同名的变量
- 如果在 block 中定义了和外界同名的变量，在 block 中访问的是 block 中的变量

```
// 2. block 中可以定义和外界同名的变量
int a = 10;
void (^myBlock)() = ^{
    int a = 20;
    NSLog(@"%i", a);
};
myBlock(); // 20

```

#### #默认情况下，不可以在 block 中修改外界变量的值

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_1.png?imageView/0/h/120)

>原因：因为 block 中的变量和外界的变量并不是同一个变量。当 block 中访问到了外界的变量时，block 会将外界的变量拷贝一份到`堆内存`中。

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_2.png?imageView/0/h/220)

>所以，如果在调用之前修改外界变量的值，不会影响到 block 中的 copy 值。

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_3.png?imageView/0/h/220)

#### #在 block 中修改外界变量的值
- 如果想在 block 中修改外界变量的值，必须在外界变量前面加上 `__block`
- 如果在 block 中修改了外界变量的值，会影响到外界变量的值。

```
// 4. 在 block 中修改外界变量的值
__block int a = 10;
void (^myBlock)() = ^{
    a = 20;
    NSLog(@"a = %i", a);
};
myBlock(); // 20
// 在 block 中修改了外界变量的值，会影响到外界变量的值
NSLog(@"a = %i", a); // 20

```

- 为什么不加 __block 不能修改外界变量的值？
	- 因为此时外界变量的传递方式是`值传递`。
	
- 为什么加了 __block 就可以在 block 中修改外界变量的值？
	-  因为此时外界变量的传递方式是`地址传递`。
 
 
#### #block 存储在堆中还是栈中？
- 默认情况下，block 存储在`栈`中，如果对 block 进行一个 `copy 操作，block 会转移到`堆`中。
- 如果 block 存储在`栈`中，block 中访问了外界的`对象`，那么不会对对象进行 `retain` 操作。
	
	![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_5.png?imageView/0/h/220)

- 如果 block 存储在`堆`中，block 中访问了外界的`对象`，会对外界的对象进行一次 `reatin`操作。

	![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_6.png?imageView/0/h/220)
	
- 如果在 block 中访问了外界的对象，一定要给对象加上 `__block`，只要加上了 `__block`，不管 block 是在`栈`中还是在`堆`中，都不会对对象进行一次`reatin`操作。
	![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_7.png?imageView/0/h/230)


## Protocol
### 1. Protocol 基本概念
- Protocol 翻译过来，叫做“协议”
	- 很像 java 中的接口（interface）概念，java 中的接口是`一堆方法的声明，没有实现`，而 `Objective-C` 中的 `interface` 是`类头文件的声明`，并不是真正意义的接口的意思，在 Objective-C 中，接口是由一个叫协议的 `Protocol` 实现的。
	- Protocol 可以声明一些`必须实现的方法`和`选择实现的方法`，和 java 中的接口是`完全不同`的。

- Protocol 的作用
	- 用来声明一些方法
	- 一个 Protocol 是由一系列的方法声明组成的。


### 2. Protocol 语法格式
- Protocol 的定义

```
@protocol ProtocolName
// 方法声明列表
@end

```

- 类遵守协议
	- 一个类可以遵守 1 个或者多个协议
	- 任何类只要遵守了 Protocol，就相当于拥有了 Protocol 中的所有方法声明

```
@interface ClassName : SuperClassName <Procotol1, Procotol2, ...> // 遵守多个协议

@end

```

- 举个栗子

```
// 定义协议
@protocol SprotsProtocol <NSObject>
// 声明协议方法
- (void)playFootball;
- (void)playBasketball;
@end


#import "SprotsProtocol.h" // 导入协议
@interface Student : NSObject<SprotsProtocol> // 遵守协议
@end

```

### 3. Protocol 和继承的区别
1. 继承之后默认就有实现，而 Protocol 只有声明没有实现
2. 相同类型的类可以使用继承，但不同类型的类只能使用 Protocol
3. Protocol 可以用于存储方法的声明，可以将多个类中共同的方法抽取出来，以后让这些类遵守协议即可

### 4. Protocol 注意事项
#### #注意事项
1. Protocol 只能声明方法，不能声明属性
2. 如果父类遵守了某个协议，那么子类也会`自动遵守`这个协议。
3. Objective-C 中类可以遵守`一个或者多个协议`，但是继承只能`单继承`。
4. Objective-C 中的协议`可以遵守其他协议`，只要一个协议遵守了其他协议，那么这个协议中就会自动包含其他协议的声明。

```
#import "OtherProtocol.h" // 导入其他协议
@protocol SomeProtocol <OtherProtocol> // 遵守其他协议
@end

```

#### #基协议
- NSObject 是一个`基类`，最根本最基本的类，任何其他类都要继承他
- NSObject 也是一个`协议`，是一个`基协议`，最根本最基本的协议，默认通过 Xcode 模板创建的协议都遵守 NSObject 协议
- NSObject 协议中声明了很多最基本的方法
	- description
	- retain
	- release
	
- 建议每个新的协议都要遵守 NSObject 协议
 

#### #@required 和 @optional 关键字
- 协议中有两个关键字可以控制方法是否要实现（默认是 @required，在大多数情况下，用途在于程序员之间的交流）
	- @required：这个方法必须实现（若不实现，编译器会发出警告，但是并不能严格的控制某一个最受该协议的类必须要实现该方法）。
	- @optional：这个方法不一定要实现，可选


### 5. Protocol 应用场景
#### #类型限定
- 可以将协议写在数据类型的右边，明确地标注如果想要给变量赋值，那么该对象必须遵守某个协议。

- 假设一个学校要招收学生，要求学生要会学习和考试，只有遵守了这两个条件的学生才能成为学校的学生。那么代码实现如下：

```
@class Student; // 向前声明，引用 Student 类

@protocol StudentCondition <NSObject>
// 声明协议方法
- (void)study;
- (void)exam;
@end

@interface School : NSObject

/// 学生，限定 student 需要遵守 StudentCondition 协议
@property(nonatomic, strong) Student<StudentCondition> *student;

```


- 这时如果学生没有实现 StudentCondition 协议的话，那么就将会报警告

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_8.png?imageView/0/h/200)


>特别注意：就算 student 遵守了 StudentCondition 协议，但他却不一定实现了协议里面的方法，如果在 School 调用 Student 对象的协议方法时，需要加一层验证，验证 student 是否实现了协议中的方法。不然 student 如果没有实现协议方法，调用的话程序会崩溃。

```
- (void)studentStudy
{
    // 每次在调用对象的协议方法时应该进行一次验证
    if ([self.student respondsToSelector:@selector(study)])
    {
        [self.student study];
    }  
}

```

#### #代理设计模式
- 什么是设计模式？
	- 设计模式（design pattern）是一套被反复使用，多数人知晓、代码设计经验的总结。使用设计模式是为了可重用性代码，让代码更容易被他人理解，保证代码可靠性。

- 什么是代理设计模式？
	- 就是委托方不方便自己做一些事情，于是定义一个协议，让代理方去实现这个协议，帮助委托方做事情。

- 代理设计模式的场合：
	- 当对象 A 发生了一些行为，想告知对象 B（让对象 B 成为对象 A 的代理）
	- 对象 B 想监听 对象 A 的一些行为（让对象 B 成为对象 A 的代理）
	- 当对象 A 无法处理某些行为的时候，想让对象 B 帮忙处理（让对象 B 成为对象 A 的代理）

- 代理设计模式举例：人通过中介找房子
	
Person 类:
	
	@class Person;
	
	@protocol PersonProtocol <NSObject>
	
	- (void)personFindHourse:(Person *)person;
	
	@end
	
	@interface Person : NSObject
	
	/// 代理
	@property(nonatomic, strong) id<PersonProtocol> delegate;
	
	- (void)findHourse;
	@end
	
	@implementation Person
	
	- (void)findHourse
	{
	    if ([self.delegate respondsToSelector:@selector(personFindHourse:)])
	    {
	        [self.delegate personFindHourse:self];
	    }
	}
	
	@end
	
		
- 中介类

```
@protocol PersonProtocol;
	
@interface LinkHome : NSObject<PersonProtocol>
	
@end
	
	
#import "Person.h"
	
@implementation LinkHome
	
- (void)personFindHourse:(Person *)person
{
    NSLog(@"我们是链家房屋中介");
    NSLog(@"%s", __func__);
}
@end
	
```
		
- 调用
		
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170411_9.png?imageView/0/h/250)


- 协议的编写规范
	1. 一般情况下，当前协议属于谁，就将协议定义到谁的头文件中
	2. 协议的名称一般以它属于的那个类的类名开头，后面跟上 protocol 或者 delegate
	3. 协议中的方法名一般以协议的名称（protocol 之前）的作为开头
	4. 一般情况下，协议中的方法会将触发该协议的对象传递出去
	5. 一般情况下，一个类中的代理属性的名称叫做 delegate
	6. 当某一个类要成为另外一个类的代理的时候，一般情况下在 .h 用 @protocol 协议名称告诉当前类这是一个协议，在 .m 文件中才真正的导入一个协议的声明。
	
	```
	@protocol StudentCondition; // 在 .h 用 @protocol 协议名称告诉当前类这是一个协议

	@interface Student : NSObject<StudentCondition> // 遵守协议
	
	@end
	
	
	#import "School.h" // 在 .m 文件中才真正的导入一个协议的声明

	@implementation Student
	// 实现协议方法
	- (void)study
	{
	    NSLog(@"study:%s", __func__);
	}
	
	- (void)exam
	{
	    NSLog(@"exam:%s", __func__);
	}

	```
	
## 源码地址
[Category](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/Category)
[Block](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/Block)
[Protocol](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/Protocol)