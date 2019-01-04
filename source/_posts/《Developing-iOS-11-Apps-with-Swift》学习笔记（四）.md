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
[mutating 关键字](mutating 关键字)
[protocols(协议)](protocols(协议))
[String 字符串](String 字符串)
[NSAttributedString](NSAttributedString)
[Closures 闭包](Closures 闭包)

## mutating 关键字
<!-- more -->

在`值类型`中，如果方法需要改变值类型，那么就需要在方法声明中使用 `mutating` 关键字标识。

- 未使用 `mutating` 关键字 

![](http://liangjinggege.com/Snip20180222_2.png?imageView2/2/w/700)

- 使用 `mutating` 关键字 

![](http://liangjinggege.com/Snip20180222_4.png?imageView2/2/w/700)

## protocols(协议)

protocols(协议)是一组属性和没有实现的方法的集合，是一种用来表达 API 更加简洁的方式。使用 protocols(协议)，可以让调用者传递他们想要的任何Class类/struct结构体、enum枚举，但是通常调用者需要实现协议规定的方法和属性。

>注意1：protocols(协议)中可以通过给方法使用 `@objc` 关键字标记，标识这个方法可以可选实现。其中使用 `@objc` 关键字是为了`向后兼容backwards compatibility`。
>注意2：任何有实现`可选协议`的 `class类`，都必须继承自 `NSObject`。这种可选协议常常用来实现 iOS 中的`代理delegation`。

### protocols(协议) 语法

#### #声明一个protocols(协议)

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

	
#### #指定协议只能被类实现，使用 `AnyObject` 关键字标识:

	```
	protocol SomeProtocol : AnyObject, InheritedProtocol1, InheritedProtocol2 {
	
	}
	```

#### #实现一个protocols(协议)

```swift
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
	
### protocols(协议) 应用场景

#### 1. 像 Type 一样使用 protocols(协议)

```
protocol Moveable {
    mutating func move(to point: CGPoint)
}
class Car : Moveable {
    func move(to point: CGPoint) { ... }
    func changeOil()
}
struct Shape : Moveable {
    mutating func move(to point: CGPoint) { ... }
func draw() }


let prius: Car = Car()
let square: Shape = Shape()

var thingToMove: Moveable = prius
thingToMove.move(to: ...)
thingToMove.changeOil()
thingToMove = square

let thingsToMove: [Moveable] = [prius, square]
func slide(slider: Moveable) {
    let positionToSlideTo = ...
    slider.move(to: positionToSlideTo)
}

slide(prius)
slide(square)
func slipAndSlide(x: Slippery & Moveable)
slipAndSlide(prius)

```


#### 2. 代理 Delegation

一种典型的使用 Procotol 的场景是 MVC 模式中 View 和 Controller 的通信。步骤是：

1. View 定义了代理协议；
2. View 的 API 中包含了一个 weak 修饰的 delegation protocol 类型的 delegate property；
3. View 使用 delegate 来获取/做一些 View 自己做不到的事情；
4. Controller 声明遵守协议；
5. Controller 设置 View 的 delegate 属性为自己；
6. Controller 实现协议；


这里举了 UIScrollViewDelegate 的例子

```swift

// UIScrollView
weak var delegate: UIScrollViewDelegate?

@objc protocol UIScrollViewDelegate {
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    optional func viewForZooming(in scrollView: UIScrollView) -> UIView
... and many more ...
}


// Controller
class MyViewController : UIViewController, UIScrollViewDelegate { 
	... 
}

scrollView.delegate = self

```

#### 3. 其他用法

##### 当做 Dictionary 的 key
 
Dictionary 的 key 是遵循了 Hashable 协议的，而同时 Hashable 协议是继承自 Equatable 的。

```swift

protocol Hashable: Equatable {
    var hashValue: Int { get }
}

// Equatable
protocol Equatable {
   static func ==(lhs: Self, rhs: Self) -> Bool
}

```

在 Demo 中，可以直接使用 Card 结构体当做 cards 字典的 key，只需要 Card 结构体遵循 Hashable 协议：

![](http://liangjinggege.com/Xnip2019-01-04_08-40-55.png?imageView2/2/w/700)

![](http://liangjinggege.com/Xnip2019-01-04_08-50-01.png?imageView2/2/w/700)


#### 4. 高级使用

##### 多继承

- CountableRange : 实现了很多协议
- Sequence: 迭代器，for in 等
- Collection：下标访问等

>苹果创造了一种泛型代码（generic code），使得对于所有的 Collection 都能生效。

##### 使用 extension 提供 prococol 的实现

extension 能够被用来给 prococol 添加默认实现，例如 Sequences 协议，实际上只需要实现迭代器方法 next()，但是却免费获得了其他的如：contains()、forEach()、joined(separator:)、min()、max()，甚至是filter()、map()的实现，所有的这些都是通过对 prococol 的 extension 来实现的。

```swift
extension Sequence {
  	func contains(_ element: Element) -> Bool { }
	// etc.
}
```
 
##### Funtional Programming 

Swift 语言中 value type、var、let、procotol、generic、extension 的设计，使得 Swift 语言也支持函数式编程范式。

>通过将 procotol 和 generic 以及 extension 等特性组合在一起，Swift 代码可以更加聚焦于数据结构的行为上。

## String 字符串

### #character

- `character` 是人类能够觉察到的 String 最小的组成单位字符，而其实 character 是由`Unicodes` 所组成的，因此即使是单个 character 字符，也有可能由多个 `Unicodes` 所组成。
- Unicodes 能够代表地球上所有的字符。
- Unicodes 包含有口音 Unicode，如：café 有可能是 4 个 Unicodes (c-a-f-é) 或者有可能是 5 个 Unicodes (c-a-f-e-’)。因此使用 Int 类型的 index 来标识字符串的索引会造成歧义，而使用 `String.index` 类型来专门表示字符串的索引index。

### #String的一些方法

```swift
let pizzaJoint = "café pesto"

// 字符串起始索引
let firstCharcterIndex = pizzaJoint.startIndex

// 索引偏移
let fourthCharcterIndex = pizzaJoint.index(firstCharcterIndex, offsetBy: 3)

// 下标访问
let fourthCharcter = pizzaJoint[fourthCharcterIndex]


```


### #String是 value type

```
var str = "Hello, playground"

str.insert("d", at: str.startIndex)
str.remove(at: str.startIndex)
str.append("p")


var str = "Hello, playground"

str.insert("d", at: str.startIndex) // 
str.remove(at: str.startIndex)
str.append("p")

str.hasPrefix("Hello")
str.hasSuffix(",")
str.lowercased()
str.uppercased()

```

### #demo 中将纸牌的emojis又数组结构改成字符串

![](http://liangjinggege.com/Xnip2019-01-04_10-44-44.png?imageView2/2/w/700)
![](http://liangjinggege.com/Xnip2019-01-04_10-45-04.png?imageView2/2/w/700)



## NSAttributedString

NSAttributedString 是一个字符串中的每一个字符 character 都有一个相关联的属性字典，关联着character的字体，颜色等一些绘制到屏幕的时候将要生效的特性。

- NSAttributedString 是来自于 Objective-C 中的 NSStirng 构造的
- NSAttributedString 是引用类型，不是值类型，所以使用可变的时候需要使用 NSMutableAttributedString 对象

![](http://liangjinggege.com/Xnip2019-01-04_11-04-04.png?imageView2/2/w/700)

## Closures 闭包
	
闭包是一种 Function Type，可以当做一种数据类型一样使用，同时闭包是引用类型，可以捕获周围的变量到堆里去，供闭包使用，并随着闭包的生命周期结束。

```swift
var operation: (Double) -> Double
operation = { -$0 }
let result = operation(4.0) // result will be -4.0

// 捕获
var ltuae = 42
operation = { ltuae * $0 } // “captures” the ltuae var because it’s needed for this closure arrayOfOperations.append(operation)
```

### 应用场景
#### #常常当做方法的参数
- 一些异步方法，完成时出现错误需要做些什么
- 让一个方法重复执行一个函数

#### #Array、Dictionary、String、Set 等遵循 Collection 协议的一些高阶函数，如：map、filter、reduce等

```swift
let primes = [2.0, 3.0, 5.0, 7.0, 11.0]
let negativePrimes = primes.map({ -$0 }) // [-2.0, -3.0, -5.0, -7.0, -11.0]
let invertedPrimes = primes.map() { 1.0/$0 } // [0.5, 0.333, 0.2, etc.]
let primeStrings = primes.map { String($0) } // [“2.0”,”3.0”,”5.0”,”7.0”,”11.0”]
```

#### #初始化属性是懒加载

```swift
var someProperty: Type = {
// construct the value of someProperty here return <the constructed value>
}()

```

#### #Demo 中应用
![](http://liangjinggege.com/Xnip2019-01-04_12-03-17.png?imageView2/2/w/700)

对 Collection 协议扩展，添加一个属性

![](http://liangjinggege.com/Xnip2019-01-04_12-04-58.png?imageView2/2/w/500)

然后修改为仅用一行代码：

![](http://liangjinggege.com/Xnip2019-01-04_12-06-23.png?imageView2/2/w/700)