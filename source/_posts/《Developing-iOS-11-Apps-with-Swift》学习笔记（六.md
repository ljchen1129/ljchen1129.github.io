---
title: 《Developing-iOS-11-Apps-with-Swift》学习笔记（六)
date: 2019-01-17 16:43:23
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


这节课通过讲解扑克牌绘制的Demo。将上一节课里面讲到的绘图、触摸事件、手势等知识点串联起来了，另外插入了一些 AutoLayout 相关的知识点。

<!-- more -->


## 手势 Gestrue

### 手势基本概念


- UIGestureRecognizer 是一个抽象父类，具体实现有其具体的子类实现
- 步骤：
	1. 添加手势到具体的视图上
	2. 处理手势反馈的事件（非必须）

#### 1. 添加手势
可以在视图属性 didSet 时添加上去

- 在 iOS runtime 时，当这个视图和控制器相关联时就会调用
- 参数：target 是获取手势通知对象
- 参数：action 是手势响应时的方法，方法的参数是手势 recognizer 对象

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_10-21-04.png?imageView2/2/w/700)

#### 2. 处理手势

每个具体子类都提供了具体的特殊的方法来处理，如 UIPanGestureRecognizer 提供了三个方法

```swift
// 
func translation(in: UIView?) -> CGPoint 
// 手势速度
func velocity(in: UIView?) -> CGPoint 

func setTranslation(CGPoint, in: UIView?)
```

抽象父类也提供了诸如手势状态的一些属性，描述手势的状态信息

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-11-47.png)

### 手势分类

#### 1. UIPanGestureRecognizer：拖动手势

```swift

func translation(in: UIView?) -> CGPoint 
func velocity(in: UIView?) -> CGPoint 
func setTranslation(CGPoint, in: UIView?)
```

#### 2. UIPinchGestureRecognizer：捏合手势，用于缩放

```swift
var scale: CGFloat 
var velocity: CGFloat { get } 
```

#### 3. UIRotationGestureRecognizer：旋转手势

```swift
var rotation: CGFloat 
var velocity: CGFloat { get } // radians per second
```

#### 4. UISwipeGestureRecognizer：滑动手势

```swift

// 滑动支持的方向，可以组合
var direction: UISwipeGestureRecoginzerDirection 
// 触发手势时手指的数量
var numberOfTouchesRequired: Int 
```
#### 5. UITapGestureRecognizer：点击手势

```swift

// 单击，双击，N击
var numberOfTapsRequired: Int 
// 点击屏幕是要求手指的数量
var numberOfTouchesRequired: Int 
```

#### 6. UILongPressRecognizer：长按手势

```swfit

// 最小触摸时间
var minimumPressDuration: TimeInterval 
// 点击屏幕是要求手指的数量
var numberOfTouchesRequired: Int 
// 在至少多少范围内移动手势依然生效
var allowableMovement: CGFloat 
```


## DEMO

### 自定义实现对象的打印日志

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-38-00.png)
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-38-30.png)
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-39-01.png)
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-39-22.png)

### 设置字体大小随系统设置改变而即时改变

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_17-08-42.png)
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_17-09-10.png)

### AutoLayout 设置约束优先级

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-59-58.png)

### @IBDesignable 和 @IBInspectable

- `@IBDesignable`： 将代码的设置显示到IB监视器中去，直接在IB中观察而不用重新运行模拟器
- `@IBInspectable`：将属性显示到IB监视器中去设置

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-54-12.png)
![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_16-55-47.png)


### 将图片绘制到视图上

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Xnip2019-01-18_17-11-56.png)