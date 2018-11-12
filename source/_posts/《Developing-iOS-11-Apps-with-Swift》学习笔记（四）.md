---
title: 《Developing iOS 11 Apps with Swift》学习笔记（四）
date: 2018-02-09 22:16:58
tags:
- iOS 
- Swift
categories:
- iOS 
- Swift
---

## 前言

这套课程是苹果官方推荐的入门 iOS 开发的学习课程。之前也听过，Paul 老爷子讲的非常好，这次准备重看一遍，顺便把 swift 和 iOS 相关的一些基础知识点复习一遍。文章会按照视频的次序写笔记，记录重点以及自己的理解。

[课程地址](https://itunes.apple.com/cn/podcast/developing-ios-11-apps-with-swift/id1315130780?mt=2)

[Demo 示例地址](https://github.com/ljchen1129/-Developing-iOS-11-Apps-with-Swift-Demos/tree/master)

[参考资料一：官方文档](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/index.html)
[参考资料二：官方文档中文翻译](https://www.cnswift.org/)

这节课主要讲述了 Swift 中 protocols(协议) 和 Closures（闭包）、NSAttributedString 的语法和注意点。

## 索引
[mutating 关键字](#mutating 关键字)

## mutating 关键字

在`值类型`中，如果方法需要改变值类型，那么就需要在方法声明中使用 `mutating` 关键字标识。

- 未使用 `mutating` 关键字 

![](http://liangjinggege.com/Snip20180222_2.png?imageView2/2/w/700)

- 使用 `mutating` 关键字 

![](http://liangjinggege.com/Snip20180222_4.png?imageView2/2/w/700)

## protocols(协议)

protocols(协议)是一组属性和没有实现的方法的集合，是一种用来表达 API 更加简洁的方式。使用 protocols(协议)，可以让调用者传递他们想要的任何Class类/struct结构体、enum枚举，但是通常调用者需要实现协议规定的方法和属性。

>注意1：protocols(协议)中可以通过给方法使用 `@objc` 关键字标记，标识这个方法可以可选实现。其中使用 `@objc` 关键字是为了`向后兼容backwards compatibility`。
>注意2：任何有实现`可选协议`的 `class类`，都必须继承自 `NSObject`。这种可选协议常常用来实现 iOS 中的`代理delegation`。

**protocols(协议) 语法**

- 声明一个protocols(协议)

	```
	protocol SomeProtocol : InheritedProtocol1, InheritedProtocol2 {
	  var someProperty: Int { get set }
	  func aMethod(arg1: Double, anotherArgument: String) -> SomeType
	  mutating func changeIt()
	  init(arg: Type)
	}
	```
	
	>注意1：如果要实现 SomeProtocol 协议，就必须实现 SomeProtocol 继承的父协议InheritedProtocol1 和 InheritedProtocol2。
	>注意2：必须指定一个协议中的每个属性是只有 get，还是 get 和 set 都有。
	>注意3：如果协议被结构体或者枚举实现，如果协议方法存在需要改变结构体或者枚举的，必须在协议方法前面使用 `mutating` 关键字标识。
	>注意4：可以指定实现者实现协议指定的`构造方法initializer`。
	>注意5：协议中的类型属性使用 `static` 关键字标识。
	>注意6：协议中的方法方法参数不能使用`默认值`。
	
- 指定协议只能被类实现，使用 `AnyObject` 关键字标识:

	```
	protocol SomeProtocol : AnyObject, InheritedProtocol1, InheritedProtocol2 {
	
	}
	```

- 实现一个protocols(协议)

	```
	<!--类实现-->
	class SomeClass : SuperclassOfSomeClass, SomeProtocol, AnotherProtocol {
		// implementation of SomeClass here
		// which must include all the properties and methods in SomeProtocol & AnotherProtocol
		required init(...)
	}
	 
	<!--结构体实现-->
	struct SomeStruct : SomeProtocol, AnotherProtocol {
		// implementation of SomeStruct here
		// which must include all the properties and methods in SomeProtocol & AnotherProtocol
	}
	
	<!--枚举实现-->
	enum SomeEnum : SomeProtocol, AnotherProtocol {
		// implementation of SomeEnum here
		// which must include all the properties and methods in SomeProtocol & AnotherProtocol
	}
	``` 
	
	>注意1：必须实现协议以及他所有继承的父协议中的所有的属性和方法。并且任意数量的协议都可以被类，结构体，枚举实现。
	>注意2：在类实现中，协议的初始化方法需要加上 `required` 关键字。否则子类可能不遵守。
	


	
	
	








