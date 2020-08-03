---
title: 《Developing-iOS-11-Apps-with-Swift》学习笔记（五)
date: 2019-01-04 15:30:16
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


这节课主要讲了一些常用的系统对象，以及一个扑克牌绘制的Demo。

<!-- more -->

## Thrown Errors
抛出异常，在 swift 中，语法是：

```swift
// 抛出异常
func save() throws

// 处理异常
do {
      try context.save()
} catch let error {
	// 重新抛出异常
	throw error 
}

// 确定不会异常，可以使用`try! `
try! context.save() 
// 不确定，使用`try? `
let x = try? errorProneFunctionThatReturnsAnInt() 
```

## Any & AnyObject

### 介绍
- Any & AnyObject 过去常常是为了兼容 Objective-C 而存在的，但是自从在 iOS 11 后 Objective-C APIs 更新后就不在使用了
- **区别：**Any 可以表示任何类型，而 AnyObject 只能表示 Class 类
- swift 是一门`强类型`语言，不能直接对 Any & AnyObject 发送消息，必须要转成具体的类型先
- 为了体现 swift `强类型`语言的优点，在 swift 中我们要避免使用 Any
- 使用场景
	- `let attributes: [NSAttributedStringKey:Any]`：在字典表示中 value 可以是任何类型
	- 有时候但比较少见出现在函数的参数中，`func prepare(for segue: UIStoryboardSegue, sender: Any?)`
- 这些是旧的 Objective-C API，在 swift 中使用带关联值的枚举或者协议来代替。

### 类型转换

使用 as? 转换 Any 到具体的类型

```swift

let unknown: Any = ... 
if let foo = unknown as? MyType {

}
```

>注意：`as?` 并不是 Any 专有的，`as?` 其实经常用来将父类转成子类，从而调用子类的方法，另外也用来转化类型实现的协议。

## 其他一些类
### NSObject
- 所有 Objective-C 的基类
- 在 swift 中，一些高级特性需要定义子类继承自 NSObject

### NSNumber

- 数值泛型，是引用类型

```swift

// 将数值转成NSNumber
let n = NSNumber(35.5) or let n: NSNumber = 35.5
// 将NSNumber转成具体的数值
let intified: Int = n.intValue // also doubleValue, boolValue, etc.
```

### Date

过去，现在，将来的日期的时间对象，相关 Calendar, DateFormatter, DateComponents 等对象，结果是本地化后的结果。

### Data

二进制数据，在整个 iOS SDK 中，用来保存，重新存储、传递原始数据。

## 视图

- 一个视图（UIView 以及UIView的子类）表示了一块矩形区域：
	- 定义空间坐标
	- 绘图
	- 处理触摸事件
	
- 层次
	- 一个视图只有唯一的父视图：var superview: UIView?
	- 可以有许多或者没有子视图：var subviews: [UIView]
	- 子视图数组中的顺序：索引更后面的子视图越显示在索引更前面的子视图顶部
	- 一个视图可以决定是否裁剪他的子视图超出自己 bounds 部分

- UIWindow
	- UIWindow 是在整个视图层次中最最顶部的视图，甚至包含了状态栏
	- 整个 App 生命周期中只有一个 UIWindow 视图
	
- 可以使用 Xcode graphically 查看视图的层次结构
- 使用代码添加或者删除一个视图
- 视图的层次从哪里开始？
	- 最顶部的视图是控制器的 view 属性：var view: UIView.
	- 控制器的 view 在设备旋转时 bounds 会发生改变

### 初始化一个view

- 使用代码创建的view：构造器是 `init(frame: CGRect) `
- 使用storyboard创建的view：	构造器是 `init(coder: NSCoder)`
- 如果需要重载视图构造器，需要实现两个构造器

```swift
func setup() { ... }

override init(frame: CGRect) { 
	super.init(frame: frame)
	setup() 
}

// 可失败构造器，必须实现
requiredinit?(coderaDecoder:NSCoder){ 
   super.init(coder: aDecoder)
	setup()
}
```
 
>另一个可供替代的方案：`awakeFromNib()`，只有当视图从 storyboard 中创建才会调用，但不是一个构造器，在视图构造完成后会立即调用这个方法，所有在 storyboard 中继承自 NSObject 的对象都会调用这个方法。但调用顺序是不确定的。
	
### 坐标系统中的数据结构

#### CGFloat

总是用来在坐标系统中代替 Double 或者 Float，可以使用构造器相互转化：`let cgf = CGFloat(aDouble)`

#### CGPoint
表示坐标系中的一个点，数据结构中只用两个 CGFloat，x 和 y.

```swift
var point = CGPoint(x: 37.0, y: 55.2)
point.y -= 30
point.x += 20.0
```

#### CGSize
包含了两个 CGFloat，width 和 height。在坐标系统中用来表示视图的大小。

```swift
var size = CGSize(width: 100.0, height: 50.0) 
size.width += 42.5
size.height += 75
```

#### CGRect
包含了 CGPoint 和 CGSize 的结构体，用来表示视图的位置和大小。

```swift

// 结构体对象
struct CGRect {
   var origin: CGPoint
   var size: CGSize
}

// 初始化
let rect = CGRect(origin: aCGPoint, size: aCGSize)

// 最小的X
var minX: CGFloat
// 中间的Y
var midY: CGFloat
// 是否和给定的rect相交
intersects(CGRect) -> Bool
// 裁剪和给定的rect相交的部分
intersect(CGRect)

// 是否包含了一个给定的点point
contains(CGPoint)->Bool

```

### 视图坐标系统
- `原点`是`左上角`
- 实体是`点 Point`，不是`像素 Pixels`
	- `像素 Pixels` 是设备能够绘制的最小的实体
	- `点 Point` 是坐标系统中的最小实体
	- iOS 设备常见是每个点两个像素，有些是设备是 3 个
	- 每个点有多少个像素，视图有个属性：`var contentScaleFactor: CGFloat`

###  bounds vs frame

- bounds：视图内部能够绘图的矩形空间，包括 origin 和 size，是以自己的坐标系统做参考的。
- frame：在视图的父视图坐标系统中，包含视图的 rect。

> 注意：bounds 和 frame 不总是相等的，如当视图旋转、拉伸后 bounds 和 frame就不相等了。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_14-36-41.png?imageView2/2/w/700)

### 创建视图
创建视图的两种方式:

1. storyboard
2. 代码

```swift
let labelRect = CGRect(x: 20, y: 20, width: 100, height: 50)
let label = UILabel(frame: labelRect) 
label.text = “Hello”
view.addSubview(label)
```

### 自定义视图

#### 1. 自定义视图可以用来做什么？

1. 需要在屏幕上自定义绘图；
2. 需要用特殊的方式处理触摸事件，而不是像 button 或者 slider 控件等那样；

- 通过创建 UIView 的子类并重载 draw(CGRect) 来绘图

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_14-49-28.png?imageView2/2/w/700)

>注意：不要主动调用 `draw(CGRect)` 方法，如果需要重新绘图，可以调用 `setNeedsDisplay()`或者 `setNeedsDisplay(_ rect: CGRect) ` 告诉系统，系统将会在适合的时间调用 draw(CGRect) 方法，其中 rect 参数为需要重绘制的区域。

#### 2. 怎么绘图？

##### #绘图上下文

```swift

// 使用图像上下文绘制一个圆形
if let context = UIGraphicsGetCurrentContext() {
	 // 在当前图形上下文上添加一个圆形
	 // 参数 center：原点，radius：半径，startAngle：开始角度，endAngle：结束角度，clockwise：顺时针还是逆时针
    context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi , clockwise: true)
    // 设置边线宽度
    context.setLineWidth(5.0)
    // 设置填充颜色
    UIColor.red.setFill()
    // 设置边线颜色
    UIColor.green.setStroke()
    context.fillPath()
    context.strokePath()
}

```

##### #贝塞尔曲线

- UIBezierPath 能够自动绘制到当前的上文中去
- UIBezierPath 提供绘图的方式以及设置属性的方法

```swift

// 1. 使用 UIBezierPath 绘制三角形
// 创建UIBezierPath对象
let path = UIBezierPath()

// 定位到(80, 50)点
path.move(to: CGPoint(80, 50))
// 从(80, 50)点开始画直线到(140, 150)
path.addLine(to: CGPoint(140, 150))
// 从 (140, 150) 开始画直线到(10, 150)
path.addLine(to: CGPoint(10, 150))

// 封闭路径
path.close()

// 设置填充色
UIColor.green.setFill()
// 设置线框颜色
UIColor.red.setStroke()
// 设置线框宽度
path.linewidth = 3.0
path.fill()
path.stroke()


// 2. 使用贝塞尔曲线绘制一个圆
let path = UIBezierPath()
path.addArc(withCenter:  CGPoint(x: bounds.midX, y: bounds.midY), radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi , clockwise: true)
path.lineWidth = 5.0
UIColor.red.setFill()
UIColor.green.setStroke()
path.stroke()
path.fill()

// 3. 带圆角的矩形
let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadios)

// 裁剪
roundedRect.addClip()
UIColor.white.setFill()
roundedRect.fill()

// 判断给定点是否在路径里面，路径必须是关闭的
func contains(_ point: CGPoint) -> Bool
```

### UIColor

- let green = UIColor.green，定义颜色，其他方式如 RGB, HSB 等
- 带透明度的颜色：UIColor.yellow.withAlphaComponent(0.5)
- 设置整个 View 的透明度：var alpha: CGFloat

>注意：如果想要绘制带透明度的颜色，需要设置 `var opaque = false`


### Layers

- 在 UIView 下面，负责掌管绘图工作的是 `CALayer`，其中 CA 代表是“Core Animation”.
- 可以通过视图的属性直接访问：var layer: CALayer
- CALayer 中比较常用的几个属性

```swift

// 圆角
var cornerRadius: CGFloat
// 边框宽度
var borderWidth: CGFloat
// 变宽颜色
var borderColor: CGColor?

```

>注意：需要将颜色转成 cgColor.


### View Transparency

- 隐藏一个 View 而不用将 View 从视图层次中移除出去：`var isHidden: Bool`

### 绘制文本

- 通常，使用 UILabel 来在屏幕上显示文本
- 绘制文本使用 `NSAttributedString`


```swift

let text = NSAttributedString(string: “hello”) 
// 从给定点开始文本绘制
text.draw(at: aCGPoint) // or draw(in: CGRect)
let textSize: CGSize = text.size

```


### 字体

代码获取字体

- static func preferredFont(forTextStyle: UIFontTextStyle) -> UIFont：特别的，获取到的字体大小在 `系统->设置` 中修改后会`立即生效`
- 获取指定的字体：let font = UIFont(name: “Helvetica”, size: 36.0)
- static func systemFont(ofSize: CGFloat) -> UIFont 和 static func boldSystemFont(ofSize: CGFloat) -> UIFont

### 绘制图片

- UIImageView
- UIImage 对象
	1. 加载在 Assets.xcassets 存储的图片资源：UIImage(named: “foo”) 
	2. 通过图片文件路径加载：let image: UIImage? = UIImage(contentsOfFile: pathString)
	3. 通过图片的原始数据（jpg, png, tiff等）加载：let image: UIImage? = UIImage(data: aData) 
	4. 通过 Core Graphics 图形上下文创建

- 绘制图片

```swift

// 给定的的点作为左上点开始绘制图片
image.draw(at point: aCGPoint)  
// 将图片拉伸绘制到给定的 rect
image.draw(in rect: aCGRect) 
// 将图片平铺绘制到给定的 rect
image.drawAsPattern(in rect: aCGRect) // tiles the image into aCGRect
```

#### 视图 bounds 改变时是否重新绘制Redraw？
- 当视图 bounds 改变时，默认不会重新绘制
- UIViewContentMode：指定视图内容模式
	- .left/.right/.top/.bottom/.topRight/.topLeft/.bottomRight/.bottomLeft/.center：不拉伸视图，视图优先在指定位置开始绘制
	- .scaleToFill/.scaleAspectFill/.scaleAspectFit ：会拉伸视图， .scaleToFill 默认
	- .redraw：通过调用 `draw(CGRect)` 重新绘制

#### 视图 bounds 改变时是否重新布局Layout？

- 当视图 bounds 改变时，如果要重新布局子视图的话

	1. 通过 Autolayout 约束
	2. 通过重载 layoutSubviews 方法，手动重新布局子控件

```swift
override func layoutSubviews() {
    super.layoutSubviews()
	// reposition my subviews’s frames based on my new bounds 
}
```

## DEMO

- 构造一张扑克牌结构体，有四种花色，13 中大小，其中包括，ace、numeric、face，使用了带关联值的枚举。

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_16-27-01.png?imageView2/2/w/700)

- 一副扑克牌

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_16-27-16.png?imageView2/2/w/700)

- 随机抽取 10 张

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_16-27-51.png)

- 打印结果

![](https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/Xnip2019-01-17_16-28-02.png?imageView2/2/w/700)