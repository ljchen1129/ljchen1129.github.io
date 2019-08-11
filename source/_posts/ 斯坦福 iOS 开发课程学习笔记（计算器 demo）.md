---
title: 斯坦福 iOS 开发课程学习笔记（计算器 demo）
date: 2016-10-27 20:24:30
tags:
- Swift
- iOS
categories: Swift
---
# 参考资料
> [Developing iOS 9 Apps with Swift
by Stanford](https://itunes.apple.com/us/course/developing-ios-9-apps-swift/id1104579961)

> [源代码](https://github.com/ljchen1129/SwiftLearningProctice)
<!-- more -->
# 开发环境
>系统：macOS Sierra 10.12

>x-code：Version 8.1 (8B62)

>Swift 3.0

# 实现？
## 分析需求
### UI 布局需求
1. 界面 UI 需要做成这样：
<div >
<center>
    <img src="https://liangjinggege.com/Portrait.png?imageView2/0/h/667/w/375" >
    </center>
</div>
2. 还需要适配横屏：
<div >
<center>
    <img src="https://liangjinggege.com/Horizontal.png?imageView2/0/h/375/w/667" >
    </center>
</div>
3. 界面元素：
	* 标签（UILable）：显示输入的操作数和计算结果；
	* 按钮（UIButton）：输入操作数和运算符。按钮分类：
	
		>数值型按钮： 0，1，2，3，4，5，6，7，8，9
		
		>常量型按钮： π，e
		
		>一元操作符按钮： √，cos
		
		>二元操作符按钮： +，—，×，÷
		
		>计算结果按钮： = 
	
### 功能需求
1. 输入显示：
	* 当没有在输入状态时，要将点击的按钮代表的操作数显示为标签的文本，如果是数值型按钮，直接显示按钮标题，如果是常量型按钮，显示常量代表的数值，其他类型的按钮按下后不要显示；
	* 当有在输入状态时，要将按下的按钮的标题拼接到标签文本上去，如输入先输入 1，再输入 2， 然后输入 3，则标签依次显示 1， 12， 123，如此类推；
	* 当按下常量型按钮时，要将常量型按钮的数值显示到标签文本上去，如按下 π，标签文本需显示 3.14159265358...；
	* 当按下一元操作符时，需要将一元操作后的计算结果显示到标签文本上去，如先按下 4，然后按下开方 √ 按钮，则应该把 4 开方后的计算结果 2 显示到标签文本上去；
	* 当按下二元操作符或 = 号时，要将当前的计算结果显示到标签文本上去；
	
2. 计算结果：需要保证计算结果的正确。

## 写代码
### 第一步
**实现点击数值型按钮，能够正确显示到标签文本中去：**

新建一个 Single View Application:
<div >
<center>
    <img src="https://liangjinggege.com/newProject.png?imageView2/0/h/600/w/575" >
  </center>
</div>

填写一下工程选项配置：

<div >
<center>
    <img src="https://liangjinggege.com/projectOptions.png?imageView2/0/h/600/w/575" >
  </center>
</div>

选择 Main.storyboard, 从 x-code 右下角的控件列表中拖拽一个 UIButton 进来，按住 Ctal 键，将按钮连线到 ViewController 控制器中来，选择 Connect 连接：

<div >
<center>
    <img src="https://liangjinggege.com/btnAction.png?imageView2/0/h/400/w/575" >
  </center>
</div>

选中按钮，按住 option 键，拖动鼠标，另外复制 8 个相同的按钮出来，效果如下：

<div >
<center>
    <img src="https://liangjinggege.com/calculator001.png?imageView2/0/h/600/w/375" >
  </center>
</div>

检查一下按钮的点击响应事件是否有效，在响应事件方法里打印一下按钮的标题，测试一下是否准确打印：

```
@IBAction func touchDigit(_ sender: UIButton) {
    let digit = sender.currentTitle!
     print("touch \(digit) digit")  
}
```

再从控件列表里面拖拽一个 UILabel 标签控件进来，像按钮一个连线，如下图所示：

<div >
<center>
    <img src="https://liangjinggege.com/calculator002.png?imageView2/0/h/300/w/375" >
  </center>
</div>

x-code 自动生成一个`隐式解析可选类型(implicitly unwrapped optionals)`的 UIlabel 类型的属性：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator003.png?imageView2/0/h/300/w/375" >
  </center>
</div>

接下来声明一个标识当前是否正在输入状态的变量 userIsInTheMiddleOfTyping 并初始化：

```
var userIsInTheMiddleOfTyping = false // 标识当前是否正在输入状态
```

实现点击按钮，能够正确显示到标签文本中去，没在输入状态时直接显示按钮标题，连续输入时，需要将按钮的标题拼接到标签文本上去：

```
@IBAction func touchDigit(_ sender: UIButton) {
    let digit = sender.currentTitle!
    if userIsInTheMiddleOfTyping {
        let textCurrentlyInDispaly = display.text!
        display.text = textCurrentlyInDispaly + digit
    } else {
        display.text = digit
    }
    
    userIsInTheMiddleOfTyping = true
}
```

### 第二步
**填加常量型按钮，实现点击常量型按钮，标签文本显示正确常量值：**

在 Main.storyboard 里复制两个按钮，修改按钮标题为 π 和 e，注意删掉存在的在 ViewController 中 touchDigit: 事件方法连线，重新拉拽到 ViewController 里去，选择 Action，命名为 performOpreation：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator004.png?imageView2/0/h/300/w/375" >
  </center>
</div>

在 performOpreation：方法里写代码，实现功能：

```
@IBAction func performOpreation(_ sender: UIButton) {
    let methemtiaclSymbol = sender.currentTitle!
    if methemtiaclSymbol == "π" {
        display.text = String(M_PI)
    }
    else if methemtiaclSymbol == "e" {
        display.text = String(M_E)
    }
    
    userIsInTheMiddleOfTyping = false
}
```

### 第三步
**增加一元操作符，点击一元操作符按钮，能将一元操作后的计算结果显示到标签文本上去：**

在 Main.storyboard 增加一元运算 √ 和 cos，调取 Emoji & Symbols 输入，快捷键：Ctrl + Commond + Shift，也可以像下图一样调取：

 <div >
<center>
    <img src="https://liangjinggege.com/Calculator005.png?imageView2/0/h/300/w/375" >
  </center>
</div>

在 performOpreation：方法里增加如下代码：

```
@IBAction func performOpreation(_ sender: UIButton) {
    let methemtiaclSymbol = sender.currentTitle!
    if methemtiaclSymbol == "π" {
        display.text = String(M_PI)
    }
    else if methemtiaclSymbol == "e" {
        display.text = String(M_E)
    }
    else if methemtiaclSymbol == "√" {
        display.text = String(sqrt(Double(display.text!)!))
    }
    else if methemtiaclSymbol == "cos" {
        display.text = String(cos(Double(display.text!)!))
    }
    
    userIsInTheMiddleOfTyping = false
}
```

也可以用 Switch 实现：

```
@IBAction func performOpreation(_ sender: UIButton) {
    let methemtiaclSymbol = sender.currentTitle!
    switch methemtiaclSymbol {
    case "π": display.text = String(M_PI)
    case "e": display.text = String(M_E)
    case "√": display.text = String(sqrt(Double(display.text!)!))
    case "cos": display.text = String(cos(Double(display.text!)!))
    default: break
    }
    
    userIsInTheMiddleOfTyping = false
}
```
>可以使用 Ctrl + I 快捷键，快速让选中区域的代码按照苹果官方的代码风格对齐缩进。

### 第四步
**增加一个计算型属性，简化代码：**

以上功能虽然实现了，但是发现计算每次都要将 String 类型的文本转换成 Double 类型的操作数，计算完成的 Double 类型的结果又要重新转换成 String 类型的文本，很麻烦，而且会造成代码冗余，可以定义一个计算性属性 displayValue，专门用来作计算结果和显示文本的数据类型之间的转换：

```
var displayValue: Double {
    get {
        return Double(display.text!)!
    }
    set {
        display.text = String(newValue)
    }
}
```
接下来修改 performOpreation：方法里面的代码：

```
@IBAction func performOpreation(_ sender: UIButton) {
    let methemtiaclSymbol = sender.currentTitle!
    switch methemtiaclSymbol {
    case "π": displayValue = M_PI
    case "e": displayValue = M_E
    case "√": displayValue = sqrt(displayValue)
    case "cos": displayValue = cos(displayValue)
    default: break
    }
    
    userIsInTheMiddleOfTyping = false
}
```

### 第五步
**新建一个类，专门负责计算：**

以上虽然实现功能，但是不应该把计算相关的代码写到控制器里去，如果计算一复杂，控制器会多很多代码，可读性和逻辑容易混乱，控制器只应该负责把计算结果显示到相关的视图上去就行，其他的事情应该交给专门的类去实现：

 <div >
<center>
    <img src="https://liangjinggege.com/Calculator006.png?imageView2/0/h/500/w/575" >
  </center>
</div>

选择 Swift File 文件，点 Next 下一步：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator007.png?imageView2/0/h/500/w/575" >
  </center>
</div>

新建一个类，命名为 CalculatorBrain，这个类专门负责接收操作数，执行运算，返回结果：

```
class CalculatorBrain {
    
}
```

定义属性和方法，accumulator 属性用来存储操作数以及计算结果，setOperand：方法用来接收操作数，performOperation：方法执行运算过程，result 只读属性返回计算结果：

```
class CalculatorBrain {
    
    var accumulator = 0.0
    
    func setOperand(operand: Double) { }
    
    func performOperation(symbol: String) {  }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}
```
然后在 ViewController 里面实例化 CalculatorBrain 类，再到 performOpreation：方法里修改代码为：

```
var brain = CalculatorBrain()
    
@IBAction func performOpreation(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
        brain.setOperand(operand: displayValue)
        userIsInTheMiddleOfTyping = false
    }
    
    if let methemtiaclSymbol = sender.currentTitle {
        brain.performOperation(symbol: methemtiaclSymbol)
    }
    
    displayValue = brain.result
}
```

相应地，实现 CalculatorBrain 中的方法：

```
class CalculatorBrain {
    
    var accumulator = 0.0
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    func performOperation(symbol: String) {
        switch symbol {
        case "π": accumulator = M_PI
        case "e": accumulator = M_E
        case "√": accumulator = sqrt(accumulator)
        case "cos": accumulator = cos(accumulator)
        default: break
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}
```
测试下功能，看效果是不是一样。

### 第六步
**优化一下代码：**

以上步骤虽然将计算相关的逻辑转移到 CalculatorBrain 类中去了，但是每次都要使用根据不同的运算符，然后在 Switch 中去执行不同的运算，能不能将运算类型进行抽象，使用枚举 Enum 来表示，不同的运算类型对应的运算再用一种数据结构 Dictionary 来表示和存储，这样代码可读性和可扩展性就能提高不少。 

1. 首先，定义一个关联值枚举，来存储抽象出的所有的运算类型：

	```
    enum Operation {
	    case Constrant(Double)
	    case UnaryOperation((Double) -> Double)
	    case BinaryOperation((Double, Double) -> Double)
	    case Equals
	}
	```
	该枚举将每一种运算类型对应到每一个枚举成员，并给枚举成员设置关联值类型，常量运算关联了一个 Double 类型，一元运算关联了一个 （Double）-> Double 类型的闭包，二元操作运算关联了一个 （Double, Double） -> Double 类型的闭包，Equals 运算没有设置关联值类型。

2. 再定义一个字典，来存储不同的运算符以及对应的运算操作：

	```
    var operations: Dictionary<String, Operation> = [
   "π": .Constrant(M_PI),
   "e": .Constrant(M_E),
   "√": Operation.UnaryOperation(sqrt),
   "cos": Operation.UnaryOperation(cos)
    ]
	```
	通过字典不同的 key, 来给枚举成员设置不同的关联值，并存储在字典里面。
	
3. 最后修改 performOperation：方法中的代码：

	```
	func performOperation(symbol: String) {
		if let operation = operations[symbol] {
		    switch operation {
		    case .Constrant(let value): accumulator = value
		    case .UnaryOperation(let function): accumulator = function(accumulator)
		    default: break
		    }
		}
	}
	```
	在 Switch 语句中，关联值可以被提取出来作为 switch 语句的一部分，第一个 case, 关联值是一个 Double 类型的常量，那么提取出来的关联值就是这个常量的值， 第二个 case, 关联值是一个 （Double） -> Double 类型的闭包，那么提取出来的关联值就是这个闭包。
	
	最后，测试一下，看功能是否正常。

### 第七步
**实现二元运算：**

二元运算不同常量和一元运算，二元运算不是一点击运算符就能知道结果，他是一个表达式，需要两个操作数和操作符都输入了才能计算他的值，所以这里需要定一个一种数据结构来保存二元操作的中间状态，既保存第一个操作数以及运算类型，所以可以定义一个结构体：

```
struct pendingBinaryOperationInfo {
    var firstOperand: Double
    var binaryOperation: (Double, Double) -> Double
}
```

定义一个这个结构体类型的属性，并让这个属性是可选类型，因为这个属性有时候需要为 nil,如每一次按 = 按钮计算结束后，这个属性就应该为 nil：

```
var pending: pendingBinaryOperationInfo?
```

在 Main.storyboard 里添加二元操作加，减，乘，除，调整下布局：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator008.png?imageView2/0/h/300/w/375" >
  </center>
</div>

相应地，在 operations 字典里添加二元操作的代码，先实现加法：

```
var operations: Dictionary<String, Operation> = [
   "π": .Constrant(M_PI),
   "e": .Constrant(M_E),
   "√": Operation.UnaryOperation(sqrt),
   "cos": Operation.UnaryOperation(cos),
   "+": Operation.BinaryOperation(add),
   "=": Operation.Equals
]
```
加法方法：

```
func add(op1: Double, op2: Double) -> Double {
    return op1 + op2
}
```
接下来，在 performOperation：里添加代码：

```
func performOperation(symbol: String) {
    if let operation = operations[symbol] {
        switch operation {
        case .Constrant(let value): accumulator = value
        case .UnaryOperation(let function): accumulator = function(accumulator)
        case.BinaryOperation(let function): pending = pendingBinaryOperationInfo(firstOperand: accumulator, binaryOperation: function)
        case.Equals:
            if pending != nil {
                accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
                pending = nil
            }
        }
    }
}
```

优化一下，将执行二元运算的操作抽出一个方法来，并且实现只要按一下二元操作符就计算出计算出结果，而不用每次都要按等号：

```
func executePendingBinaryOperation() {
    if pending != nil {
        accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
        pending = nil
    }
}
```

performOperation：方法里面代码变成这样：

```
func performOperation(symbol: String) {
    if let operation = operations[symbol] {
        switch operation {
        case .Constrant(let value):
            accumulator = value
        case .UnaryOperation(let function):
            accumulator = function(accumulator)
        case.BinaryOperation(let function):
            executePendingBinaryOperation()
            pending = pendingBinaryOperationInfo(firstOperand: accumulator, binaryOperation: function)
        case.Equals:
            executePendingBinaryOperation()
        }
    }
}
```

### 第八步
**利用闭包特性，简化代码：**

可以将二元操作的实现用闭包来简化，如加法运算：

```
"+": Operation.BinaryOperation({(op1: Double, op2: Double) -> Double in
        return op1 + op2 })
```

由于使用的枚举成员关联了类型，所以编译器能够根据上下文推断出闭包的参数和返回值类型，于是可以省略掉参数和返回值类型以及箭头和参数周围的括号，简化为：

```
"+": Operation.BinaryOperation({op1, op2 in return op1 + op2 })
```

由于闭包函数体只包含了一个单一表达式 (op1 + op2)，按照闭包语法，单表达式闭包可以隐式返回，还可以省略掉 return 关键字：

```
"+": Operation.BinaryOperation({op1, op2 in op1 + op2 })
```

还可以简化，闭包自动为内联闭包提供了参数名称缩写功能,可以直接通过 $0, $1, $2 来顺序调用闭包的参数，又由于使用了参数名称缩写，又可以省略参数列表，in 关键字也同样可以被省略，因为此时闭包表达式完全由闭包函数体构成:

```
"+": Operation.BinaryOperation({$0 + $1})
```

同理，实现其他的减，乘，除二元运算：

```
"−": Operation.BinaryOperation({$0 - $1}),
"×": Operation.BinaryOperation({$0 * $1}),
"÷": Operation.BinaryOperation({$0 / $1}),
```
测试一下，看功能是否能实现？

### 第九步
**给各个方法属性添加访问权限：**
 
其实这一步在每定义一个方法和属性的时候就应该做，最好刚开始都先添加 Privite 权限，这样后面如果调用需要再一个个修改成其他权限，这样影响比较小，也更安全，如果反过来，则会让很多已经调用该方法或者引用了该属性的其他对象瞬间报错。

可以通过如下的操作查看类的公共接口：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator009.png?imageView2/0/h/500/w/575" >
  </center>
</div>

<div >
<center>
    <img src="https://liangjinggege.com/Calculator010.png?imageView2/0/h/500/w/575" >
  </center>
</div>

默认是 internal 权限，表示对外是可访问的

而这里有些属性和方法是不应该暴露给外界的，所以应该设置为 private 访问权限，不让其他类访问。

<div >
<center>
    <img src="https://liangjinggege.com/Calculator011.png?imageView2/0/h/500/w/575" >
  </center>
</div>

对于 CalculatorBrain 类，只需要给外界暴露 setOperand：和 performOperation：方法还有 result 计算属性就可以了。

<div >
<center>
    <img src="https://liangjinggege.com/Calculator012.png?imageView2/0/h/500/w/575" >
  </center>
</div>

### 第十步
**布局 UI，适配横竖屏**

现在功能做完了，最后一步，需要把 UI 布局好，需要不管哪种屏幕，不管横竖屏，都要适配好。这里需要用到 iOS 推出的一个新的概念 UIStackView：

首先选中最下面一排四个按钮，如下图操作，插入一个 StackView：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator013.png?imageView2/0/h/500/w/575" >
  </center>
</div>

接下来到右边的属性观察器里设置一些属性，Distribution 选择 Fill Equally，Spaceing 选择 10，

<div >
<center>
    <img src="https://liangjinggege.com/Calculator014.png?imageView2/0/h/500/w/575" >
  </center>
</div>

同理，重复这样的操作选择后面四排按钮，同样的操作分别设置好 StackView：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator015.png?imageView2/0/h/500/w/575" >
  </center>
</div>

接下来选择这五个设置好了的 StackView, 在给这五个 StackView 设置一个 StackView：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator016.png?imageView2/0/h/500/w/575" >
  </center>
</div>

然后，同时选中最上面的标签以及最大的那个 StackView，再给他们设置一个 StackView 进来：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator017.png?imageView2/0/h/500/w/575" >
  </center>
</div>

最后设置约束，首先选中最后设置的那个最大的那个 StackView，按住 Ctrl 键，向上拖线，放手，在弹出的选择视图里面选择对顶部的垂直距离固定，然后选中弹出的那个线，到右边属性观察器里面修改约束值为 0：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator018.png?imageView2/0/h/500/w/575" >
  </center>
</div>

<div >
<center>
    <img src="https://liangjinggege.com/Calculator019.png?imageView2/0/h/500/w/575" >
  </center>
</div>

依次同样的操作设置好左，右，底部的约束，然后就会变成这样，这样整个 UI 不管在横竖屏或者各种尺寸的设备都保持对上下左右的距离都固定。

<div >
<center>
    <img src="https://liangjinggege.com/Calculator019.png?imageView2/0/h/500/w/575" >
  </center>
</div>

好了，看下运行效果：

<div >
<center>
    <img src="https://liangjinggege.com/calculatorgif.gif?imageView2/0/h/500/w/575" >
  </center>
</div>

好，做完了......

## 设计 / 思路分析
### 需要建哪些类？类的职能？
1. 视图控制器 ViewController， 类职能：控制视图的生命周期，管理视图，响应视图上的各种点击、触摸等事件；
2. CalculatorBrain，类职能：接收操作数和运算符，计算出结果，并返回出去；

### 类?
类里面需要定义哪些属性，方法, 数据结构，类型、职能是什么？哪些是私有的，哪些是公有的？

1. **ViewController**
* 属性：
	
属性           |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
display       | UILable!      |     显示文本    | private
userIsInTheMiddleOfTyping  | Bool |标识是否正在输入 | private
displayValue | Double | 计算型属性，将 display 显示的 String 类型文本返回为 Double，将输入的 Double 类型的操作数装换为 String 类型显示到 display 的文本 | private 
brain | CalculatorBrain 类  | 类实例，专门用来接收操作数和运算符，计算出结果，并返回出去 | private
		
* 方法	

方法          |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
touchDigit       | Method 事件方法     | 监听按钮的点击事件，用来输入操作数    | private
performOperation | Method 事件方法 | 监听按钮的点击事件，用来执行计算过程 | private 

2. **CalculatorBrain**
* 属性：

属性           |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
accumulator       | Double     |     存储操作数    | private
operations  | Dictionary<String, Operation> | 存储运算符以及运算符对应的实际运算操作 | private
pending | PendingBinaryOperationInfo Struct 结构体 | 存储二元操作的第一个操作数以及二元操作类型 | private 
result | Double | 只读属性，返回计算结果 | public
		
* 方法
	
方法          |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
setOperand    |   实例方法   | 接收操作数 | public
performOperation | 实例方法  | 执行运算操作 | public 
executePendingBinaryOperation | 实例方法  | 执行二元运算操作，并将运算结果赋值给 accumulator | private 
		
* 结构体
	
结构体          |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
PendingBinaryOperationInfo | Strcut | 保存二元操作的相关信息，包括是什么二元操作，和第一个操作数 | private
		
* 枚举
	
枚举          |  类型         | 职能          | 访问权限
------------- | ------------- | ------------- | -------------
Operation |Enum | 带关联值的枚举，存储运算的操作类型 | private

### 调用关系

<div >
<center>
    <img src="https://liangjinggege.com/classCall.001.png?imageView2/0/h/700/w/775" >
  </center>
</div>

# 测试
1. 是否适配好了横竖屏？
2. 所有的功能需求是否都已实现？
3. 边际值和异常情况是否考虑完全？
4. 是否编写单元函数测试？
 
# 优化？
## 现在的代码有什么 bug ?

## 是否存在代码冗余？

## 是否能重构？

# 总结？
## 语法知识点
### 隐式解析可选类型(implicitly unwrapped optionals)
#### 概念
如果一个可选类型第一次被赋值之后,可以确定以后总会有值。就可以使用`隐式解析可选类型`。

一个`隐式解析可选类型`其实就是一个普通的`可选类型`,但是可以被当做`非可选类型`来使用,并不需要每次都使用 ! 解析来获取可选值。

可以把`隐式解析可选类型`当做一个可以自动解析的可选类型。

>注意：同样，在`隐式解析可选类型`没有值的时候尝试取值,会触发运行时错误。所以，如果一个变量之后可能变成 nil 的话请不要使用`隐式解析可选类型`。如果需要在变量的生命周期中判断是否是 nil 的话，请使用普通可选类型。

#### 扩展
1. 可选是一种枚举：

	```
	enumOptional<T>{ 
		case None
    	case Some(T)
  	}
	```

2. 可选可以成链式（chained）：

	```
	var display: UILabel? // 假设 display 没有被定义成隐式解析可选的 UILabel 类型  
	
	if let label = display {
    	if let text = label.text {
        	let x = text.hashValue
			... 
		}
	}
	```
	可以简化为：
	
	```
	if let x = display?.text?.hashValue { ... }
	```

3. 可选的默认运算符 "??"(空合运算符)
	假设需求：给一个 UIlable 赋值一个 String 类型的文本，如果这个 String 为 nil, 则赋值为“ ”空格。一般需要这样做：

	```
	let s: String? = ... // might be nil
	if s != nil {
    	display.text = s
	} else {
    	display.text = “ “
	}
	```

	但是有更简单的方式实现：

	```
	display.text = s ?? " " 
	```

	>使用空合运算符 ?? 需要满足两个条件： 
	- s 是可选类型；
	- 默认值的数据类型需要和可选类型的数据类型一致；

### 关联值枚举
[关联值枚举](http://chenliangjing.me/2016/10/08/Swift%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0%EF%BC%88%E8%AF%AD%E8%A8%80%E5%9F%BA%E7%A1%80-Enumerations%EF%BC%89/#关联值-Associated-Values)

### Switch 值绑定
[Switch 值绑定](http://chenliangjing.me/2016/09/27/Swift%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0-%E8%AF%AD%E8%A8%80%E5%9F%BA%E7%A1%80-Control-Flow/#值绑定（Value-Bindings）)

### 闭包简写
[闭包简写](http://chenliangjing.me/2016/09/29/Swift%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0%EF%BC%88%E8%AF%AD%E8%A8%80%E5%9F%BA%E7%A1%80-Closures%EF%BC%89/#单表达式闭包隐式返回-Implicit-Returns-From-Single-Expression-Closures)

### 访问控制
>属性，类，函数等能够进行版本控制的统称为实体。

* _open_：open 是 Swift 3 新增的访问控制符，相较于 public 更加开放。open 和 public 都是可以跨 Module 访问的，但在跨 Module 访问时， open 修饰的类可以继承，修饰的方法可以重写（此时，open 需同时修饰该方法以及所在类），而 public 不可以。至于 public final 与 public，前者在任何地方均不可重写，而后者可在本 Module 内重写。	
* _public_：可以访问自己模块或应用中源文件的任何实体，别人也可以访问引入该模块中源文件里的所有实体。通常情况下，某个接口或 Framework 是可以被任何人使用时，可以设置为 public 级别；

* _internal_：可以访问自己模块或应用中源文件里的任何实体，但是别人不能访问该模块中源文件里的实体，通常情况下，某个接口或 Framework 作为内部结构使用时，可以将其设为 internal 级别；

* _fileprivate_：可在当前源文件内访问所有类的实体； 

* _private_：只能在当前类中访问使用的实体，称为私有实体。使用 private 级别，可以用作隐藏某些功能的实现细节；

>访问优先级：open > public > internal(默认) > fileprivate > private
	
### UIStackView

Stack View 会自动为每个 subview 创建和添加 Auto Layout constraints。所以可以控制 subview 的大小和位置。可以通过选项配置 subview 的大小、排布以及彼此间的间距。

## tips

1. 使用 x-code 代码格式缩进对齐功能，选中一段代码，ctrl + I 组合键；
2. 使用 x-code 输入表情和特殊字符 Emoji & Symbols，Ctrl + Commond + Shift 组合键；
3. 查看源文件的开放接口，如下操作：

<div >
<center>
    <img src="https://liangjinggege.com/Calculator009.png?imageView2/0/h/500/w/575" >
  </center>
</div>
