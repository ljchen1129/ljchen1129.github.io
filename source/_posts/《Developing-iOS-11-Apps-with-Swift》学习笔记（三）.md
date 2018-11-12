---
title: 《Developing iOS 11 Apps with Swift》学习笔记（三）
date: 2018-02-09 12:16:46
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

这一节课主要讲的是 Swift 的一些语法。如 Tuples(元组)、Computed Propertys (计算属性)、Access Control(访问控制)、Assertions(断言)、extensions(扩展)、enum(枚举）以及一些界面布局相关的 UIStackView 、 autolayout（自动布局）知识点。

## 索引

[UIStackView](#UIStackView)
[Range（区间）](#Range（区间）)
[Tuples（元组）](#Tuples（元组）)
[Computed Properties（计算属性）](#Computed Properties（计算属性）)
[Access Control（访问控制）](#Access Control（访问控制）)
[Assertions(断言)](#Assertions(断言))
[Extensions（扩展）](#Extensions（扩展）)
[enum(枚举)](#enum(枚举))
[Optionals(可选)](#Optionals(可选))
[Memory Management(内存管理)](#Memory Management(内存管理))


## UIStackView
`UIStackView` 是 iOS 9 推出的一项用于自动布局的技术。只要将需要布局的控件放入到 UIStackView 容器中，容器里面的控件的约束就不需要管理了，UIStackView 会自动管理。

![](http://liangjinggege.com/Snip20180209_29.png?imageView2/2/w/600)
<!-- more -->
设置 UIStackView 属性

![](http://liangjinggege.com/Snip20180209_30.png?imageView2/2/w/600)


## Range（区间）
Swift 中没有 C 语言的那种 `for` 循环。

```c
for(i = 0.5; i <= 15.25; i += 0.3)
```

而 `0.5...15.25` 只是一个Range（区间），不是 `CountableRange`，不能直接用来循环。`CountableRange `是可以用来循环的区间，每隔多少单位循环一次。

在 Swift 中，有一个全局函数，可以用来创建一个 `CountableRange` 的循环区间。

```swift
for i in stride(from:0.5, through:15.25, by:0.3) {
}
```
![](http://liangjinggege.com/Snip20180209_31.png?imageView2/2/w/600)

>注意1：在这里，`through:`表示的是一个闭区间，包括 15.25 这个数，如果将 `through:` 换成 `to:`，将表示是一个`左闭右开`区间，不包括最后的 15.25。
>注意2：`CountableRange `是个 `generic Type(泛型)`，不只适用于 Ints，同样适用于 String 等其他类型.

## Tuples（元组）

Tuples（元组）是一种轻量级的数据类型，里面只有值，没有属性，也没有方法。可以在任何地方使用元组：

```swift
let x: (String, Int, Double) = (“hello”, 5, 0.85) // the type of x is “a tuple”
let (word, number, value) = x // this names the tuple elements when accessing the tuple print(word) // prints hello
print(number) // prints 5
print(value) // prints 0.85

```
元组中的元素在声明之后也能够通过变量名访问：

```swift
let x: (w: String, i: Int, v: Double) = (“hello”, 5, 0.85) print(x.w) // prints hello
print(x.i) // prints 5
print(x.v) // prints 0.85
let (wrd, num, val) = x // this is also legal (renames the tuple’s elements on access)
```
`Tuples（元组）`非常适合在函数和方法中有多个返回值时使用：

```swift
func getSize() -> (weight: Double, height: Double) { return (250, 80) }
let x = getSize()
print(“weight is \(x.weight)”) // weight is 250
... or ...
print(“height is \(getSize().height)”) // height is 80
```

## Computed Properties（计算属性）
在 Swift 中，属性可以分为存储属性（Stored property）和计算属性(Computed Properties)。

```swift
<!--存储属性-->
  var foo: Double
<!--计算属性-->
  var foo: Double {
      get {
			// return the calculated value of foo 
	  }
      set(newValue) {
			// do something based on the fact that foo has changed to newValue }
	  }
 }
```

>注意：如果计算属性，只有实现了 get，而没有实现 set，那么该计算属性是只读的（read only）。 

- 计算属性的作用

![](http://liangjinggege.com/Snip20180209_33.png?imageView2/2/w/600)

![](http://liangjinggege.com/Snip20180209_34.png?imageView2/2/w/600)


## Access Control（访问控制）
- `internal`: 默认。表示可以仅在这个 App、或者框架framework 都能够访问。
- `private`: 私有。表示仅在这个对象作用域内才能访问。
- `private(set) `: 私有set。表示这个属性在这个对象外部是只读的。
- `fileprivate`: 文件私有。表示仅在这个源文件内都能够访问。
- `public`: 框架framework专有。表示在框架外面也能够访问到。 
- `open`: 框架framework专有。框架外面不只能够访问，还能继承。

## Assertions(断言)
`Assertions(断言)` 是一个函数，可以用来在开发中保护 API，调试定位程序的 bug。

![](http://liangjinggege.com/Snip20180209_36.png?imageView2/2/w/700)

## Extensions（扩展）
在 Swift 语法中，可以为 Struct、Class、Enum 添加方法、属性，即使不知道 Struct、Class、Enum 的实现。

![](http://liangjinggege.com/Snip20180209_37.png?imageView2/2/w/700)

## enum(枚举)
`enum(枚举)` 是一种出 struct 和 class 外另一种常用的`数据结构`。`enum(枚举)` 和 struct 一样是值类型。

- 用来分离不同状态。
	
```
enum FastFoodMenuItem {
	case hamburger
	case fries
	case drink
	case cookie 
}
```

- 关联值（Associated Data）
	- 枚举的每一种状态都可以关联各自的值

```swift
enum FastFoodMenuItem {
    case hamburger(numberOfPatties: Int)
    case fries(size: FryOrderSize)
	case drink(String, ounces: Int) // the unnamed String is the brand, e.g. “Coke”
	case cookie 
}

enum FryOrderSize {
    case large
	case small 
}
```

- 给枚举设置值
	
```swift
let menuItem: FastFoodMenuItem = FastFoodMenuItem.hamburger(patties: 2) 
var otherItem: FastFoodMenuItem = FastFoodMenuItem.cookie
```
>注意：如果枚举有关联值，必须同时设置关联值，这是唯一一次设置关联值得时刻。

- 类型推断

```swift
Swift can infer the type on one side of the assignment or the other (but not both) ...
let menuItem = FastFoodMenuItem.hamburger(patties: 2)
var otherItem: FastFoodMenuItem = .cookie
错误 var yetAnotherItem = .cookie // Swift can’t figure this out 
```

- 检测一个枚举的状态，使用 switch，switch 也可以类型推断，所以也可以不写类型

```swift
var menuItem = FastFoodMenuItem.hamburger(patties: 2)
switch menuItem {
  case FastFoodMenuItem.hamburger: print(“burger”)
  case FastFoodMenuItem.fries: print(“fries”)
  case FastFoodMenuItem.drink: print(“drink”)
  case FastFoodMenuItem.cookie: print(“cookie”)
}
```

- 使用 `break` 跳过其中的一个枚举状态

```swift
var menuItem = FastFoodMenuItem.hamburger(patties: 2)
switch menuItem {
	case .hamburger: break
	case .fries: print(“fries”)
	case .drink: print(“drink”)
	case .cookie: print(“cookie”)
}
``` 

- 使用 `default` 表示余下的所有状态

```swift
var menuItem = FastFoodMenuItem.cookie
switch menuItem {
    case .hamburger: break
    case .fries: print(“fries”)
    default: print(“other”)
}
```

>注意：必须列举完一个枚举的所有状态。

- `switch` 中一个 case 可以写多行代码，并且不会 `fall through(贯穿)`到下一个 case

```swift
var menuItem = FastFoodMenuItem.fries(size: FryOrderSize.large)
switch menuItem {
  case .hamburger: print(“burger”)
  case .fries:
      print(“yummy”)
      print(“fries”)
case .drink:
      print(“drink”)
  case .cookie: print(“cookie”)
}
```

- 可以使用 `let` 来访问枚举关联的关联值

```swift
var menuItem = FastFoodMenuItem.drink(“Coke”, ounces: 32)
switch menuItem {
  case .hamburger(let pattyCount): print(“a burger with \(pattyCount) patties!”)
  case .fries(let size): print(“a \(size) order of fries!”)
  case .drink(let brand, let ounces): print(“a \(ounces)oz \(brand)”)
  case .cookie: print(“a cookie!”)
}
```

>注意：和元组一样。关联值变量，可以重命名，不需要和定义时的变量名称一样。

- 方法、计算属性
	- 枚举和 struct 、class 一样，可以在内部定义方法和计算属性，不能定义存储属性，存储值可以使用关联值。

```swift
enum FastFoodMenuItem { 
	...
   func isIncludedInSpecialOrder(number: Int) -> Bool {
          switch self {
             case .hamburger(let pattyCount): return pattyCount == number
				case .fries, .cookie: return true // a drink and cookie in every special order
				case .drink(_, let ounces): return ounces == 16 // & 16oz drink of any kind }
 	} 
}
```

>一个 `switch case` 可以并列多个枚举状态，中间用` , `好隔开。


在枚举内部，可以使用 `self` 来检测枚举的状态

```swift
enum FastFoodMenuItem { 
	...
  func isIncludedInSpecialOrder(number: Int) -> Bool {
       switch self {
          case .hamburger(let pattyCount): return pattyCount == number
			case .fries, .cookie: return true // a drink and cookie in every special order
			case .drink(_, let ounces): return ounces == 16 // & 16oz drink of any kind  }
	} 
}
```

>可以使用 `_` 忽略不关心的关联值。

在枚举内部，可以使用 `mutating ` 关键字的方法来修改枚举的状态

```swift
enum FastFoodMenuItem { 
	...
	mutating func switchToBeingACookie() {
		self = .cookie // this works even if self is a .hamburger, .fries or .drink
	}
}

```
> 为什么要加 `mutating 关键字`？因为枚举是值类型，在传递的时候是`写时复制`，当值发生改变了，才会真正的复制，所以需要标识这个有改变枚举值的方法，就使用 `mutating 关键字`。struct 中有修改 到 struct 的方法也一样。

## Optionals(可选)

Optionals(可选) 就是一种枚举。有两个状态，一种是没有设置值 none，一种有设置值 some(<T>)。

```swift
enum Optional<T> { // a generic type, like Array<Element> or Dictionary<Key,Value> 
	case none
	case some(<T>) // the some case has associated data of type T 
}
```
![](http://liangjinggege.com/Snip20180209_39.png?imageView2/2/w/600)

- `可选链`
使用 ？对多个可选值链式调用，当其中一个可选解包失败，整个表达式就会返回 nil。

![](http://liangjinggege.com/Snip20180209_40.png?imageView2/2/w/600)

## Memory Management(内存管理)
- ARC（自动引用计数）
	- 引用类型的数据存储在`堆（heap）`里面。
	- 每个引用类型，都有一个与之关联的引用计数，当引用计数为 0 是，系统就会回收。这些都是自动的。

- 影响引用计数(使用一些关键字声明来影响一个引用类型的 ARC)
	- strong: ARC 默认关键字，只有有一个 strong 类型的指针指向引用类型，该引用类型就不会被回收，就一直在内存`堆（heap）`里面。
	- weak: weak 关键字，对引用类型的 ARC 不发生作用。表示只要有一个其他的 strong 指针指向了该引用类型，该应用类型就 weak 指针变量访问，如果没有一个其他的 strong 指针指向了该引用类型，该引用类型就是从内存`堆（heap）`里面释放，同时将该 weak 指针变量指 `nil`。weak 关键字 只修饰`可选的引用类型`，最常用到 weak 关键字的地方一个是 Outlet，一个是 delegate。
	- unownd: 无主引用表示像 strong 一样指向引用类型，但是不影响引用计数。并且告诉系统，当该引用类型回收后，保证不再访问该引用类型。通常用在解决循环引用的问题上，在 `闭包` 中常用。