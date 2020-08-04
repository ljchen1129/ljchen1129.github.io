---
title: iOS 源代码是怎样成为 App 的
date: 2019-10-28 10:24:52
tags:
- 编译
- 链接
categories:
- 编译
- 链接
---

## 前言

这篇文章想要探究一下在 iOS 开发中，iOS 源代码是怎样变成用户手机上的一个个 App 的，Xcode 里面 Command + B 具体发生了什么？

我想可以分为两个部分，第一个部分是 iOS 源代码是怎样打包上架市场并安装到到用户手机上的，第二部分是用户当点击 App Icon 到 App 启动经历了哪些过程？

<!--more-->

## 基础知识

### 编程语言分类

编程语言按照不同的角度可以有不同的分类。

#### 按`与硬件的距离`分：

- 机器语言：根据硬件指令集的 0101 
- 汇编语言：对机器语言做了简单的封装
- 高级语言：C/C++/Java/Python/JavaScript/Swift 等

#### 按`编程范式`分：

- 面向过程：
  - C
- 面向对象：
  - C++/Java
- 函数式

> 现在的很多高级语言都具备`多种编程范式`。

#### 按`是否需要编译`分：

- 编译型语言 Compiled Language，编译后可直接执行，执行效率高

  - C/C++/Objective-C/Swift（不依赖虚拟机）
  - Java (依赖虚拟机)，Java 源代码会先编译成为 .class（字节码）文件，再经过 JVM 一行一行的解释执行

- 解释型语言 Interpreted Language，也叫脚本语言 Scripting Language，运行在解释器上，解释一行代码，执行一行，执行效率相对编译型语言更低，但容易移植

  - Python/Ruby/JavaScript

  

Swift 是一门编译型语言，编译型语言的源代码要运行，首先是需要编译器（Complier）把源文件进行编译成目标文件，然后经过链接器（Linker）链接后才能够执行的。这篇主要记录的是 Swift 代码的编译过程。

### LLVM 编译器架构



![img](https://image-1254431338.cos.ap-guangzhou.myqcloud.com2019-10-28-101309.png)



- Frontend 前端
  - 词法分析、语法分析、语义分析、生成中间代码
- Optimizer 优化器
  - 中间代码优化
- Backend 后端
  - 生成不同硬件平台的机器码



![img](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-101312.png)



>LLVM 编译器三层式的架构，前后端依赖统一格式的中间代码(IR)，使得前后端可以独立的变化。新增一门语言只需要修改前端，而新增一个 CPU 架构只需要修改后端即可。



Objective C/C/C++使用的编译器前端是[clang](https://clang.llvm.org/docs/index.html)，swift是[swift](https://swift.org/compiler-stdlib/#compiler-architecture)，后端都是[LLVM](https://llvm.org/)。



## 第一部分：源代码 -> App 阶段

### Hello World 

先来看程序员都会写的第一行代码 hello world!，先看一下这行代码是如何变成可执行文件的，在终端打印出 `Hello, World`

```c
#include <stdio.h>

int main(int argc, const char * argv[]) {
    printf("Hello, World!\n");
    return 0;
}
```

#### 1. 预编译

```shell
# 使用 gcc 编译器编译这个文件，-E 表示只进行预编译
gcc -E main.c -o main.i
```

预编译阶段主要是处理源代码中以 `#` 号开始的预编译指令，如 `#include`、`#define`等，主要的规则有：

1. 删除所有`#define` ，展开所有宏定义
2. 处理条件编译，如 `#if`、`#ifdef`、`#elif`、 `#else`、`#endif` 等
3. 处理  `#include` 指令，`递归`地将被包含的文件插入到该预编译指令的位置
4. 删除所有的注释
5. 添加行号和文件名标识
6. 保留所有 `#pragma` 预编译指令

#### 2. 编译

```assembly
# 将预编译后的源代码编译成汇编代码
gcc -S main.i -o main.s
  
# 生成的汇编代码文件main.s
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 10, 15	sdk_version 10, 15
	.globl	_main                   ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	leaq	L_.str(%rip), %rdi
	movb	$0, %al
	callq	_printf
	xorl	%ecx, %ecx
	movl	%eax, -20(%rbp)         ## 4-byte Spill
	movl	%ecx, %eax
	addq	$32, %rsp
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"Hello, World!\n"


.subsections_via_symbols

```

#### 3. 汇编

这个阶段由汇编器将汇编代码 main.s 变成机器指令，即生成目标文件 main.o

```shell
# 生成目标文件 main.o
gcc -c main.s -o main.o
```

#### 4. 链接

```shell
# clang 编译器前端链接main.o，生成一个 a.out 可执行文件
clang main.o

➜  HelloWorld ls
a.out  main.c main.i main.o main.s

# 执行
➜  HelloWorld ./a.out 
Hello, World!
```

### 编译

上面只是简单的描述了一下程序员的第一行代码 Hello World 程序是怎样变成可执行文件的，其实在编译和链接阶段还有着更复杂更细致的操作，如在编译阶段就有词法分析、语法分析、语义分析、中间语言生成、目标代码生成和优化过程。

```shell
# 查看用 clang 编译源代码的过程
➜  HelloWorld clang -ccc-print-phases main.c 
0: input, "main.c", c # 输入
1: preprocessor, {0}, cpp-output # 预处理 -> 输出 cpp 文件 .cpp
2: compiler, {1}, ir # 编译 -> 输出中间代码 
3: backend, {2}, assembler # 编译器后端将中间代码转成汇编代码 -> 输出汇编代码 
4: assembler, {3}, object # 汇编器，将汇编代码转成机器代码 -> 输出目标文件代码 .o
5: linker, {4}, image # 链接器，生成机器无关的二进制代码 -> 输出机器无关二进制代码
6: bind-arch, "x86_64", {5}, image # 绑定机器架构，生成具体机器的二进制代码 -> 输出具体机型二进制代码
```



下面就写一段简单的两数求和的加法代码来分析一下：

```c
int sum(int a, int b) {
    return a + b;
}

int main(int argc, const char * argv[]) {
    int result = sum(1, 2);
    return 0;
}
```



#### 词法分析

词法分析就是将源代码的字符序列使用一个叫做 lex 的程序运用一种类似于有限状态机的算法（Finite Source Machine）分割成一系列的记号（token）的过程。

产生的 token 一般可以分为以下几类：关键字、标识符、字面量（数字、字符串）、特殊符号。在识别记号 token 的同时，也会将标识符放到符号表、将数字、字符串常量放到文字表等。

```shell
# 使用 clang 对 main.c 源代码只进行词法分析
xcrun clang -fmodules -fsyntax-only -Xclang -dump-tokens main.c

# 输出结果
annot_module_include '#include <stdio.h>

int sum(int a, int b) {
    return a + b;
}

int main(int argc, const char * argv[]) {
    int result = sum(1, 2);
'		Loc=<main.c:9:1> // 标识位于源文件的第 9 行，从第 1 个字符开始
int 'int'	 [StartOfLine]	Loc=<main.c:11:1> // 标识位于源文件的第 11 行，从第 1 个字符开始
identifier 'sum'	 [LeadingSpace]	Loc=<main.c:11:5>
l_paren '('		Loc=<main.c:11:8>
int 'int'		Loc=<main.c:11:9>
identifier 'a'	 [LeadingSpace]	Loc=<main.c:11:13>
comma ','		Loc=<main.c:11:14>
int 'int'	 [LeadingSpace]	Loc=<main.c:11:16>
identifier 'b'	 [LeadingSpace]	Loc=<main.c:11:20>
r_paren ')'		Loc=<main.c:11:21>
l_brace '{'	 [LeadingSpace]	Loc=<main.c:11:23>
return 'return'	 [StartOfLine] [LeadingSpace]	Loc=<main.c:12:5>
identifier 'a'	 [LeadingSpace]	Loc=<main.c:12:12>
plus '+'	 [LeadingSpace]	Loc=<main.c:12:14>
identifier 'b'	 [LeadingSpace]	Loc=<main.c:12:16>
semi ';'		Loc=<main.c:12:17>
r_brace '}'	 [StartOfLine]	Loc=<main.c:13:1>
int 'int'	 [StartOfLine]	Loc=<main.c:15:1>
identifier 'main'	 [LeadingSpace]	Loc=<main.c:15:5>
l_paren '('		Loc=<main.c:15:9>
int 'int'		Loc=<main.c:15:10>
identifier 'argc'	 [LeadingSpace]	Loc=<main.c:15:14>
comma ','		Loc=<main.c:15:18>
const 'const'	 [LeadingSpace]	Loc=<main.c:15:20>
char 'char'	 [LeadingSpace]	Loc=<main.c:15:26>
star '*'	 [LeadingSpace]	Loc=<main.c:15:31>
identifier 'argv'	 [LeadingSpace]	Loc=<main.c:15:33>
l_square '['		Loc=<main.c:15:37>
r_square ']'		Loc=<main.c:15:38>
r_paren ')'		Loc=<main.c:15:39>
l_brace '{'	 [LeadingSpace]	Loc=<main.c:15:41>
int 'int'	 [StartOfLine] [LeadingSpace]	Loc=<main.c:16:5>
identifier 'result'	 [LeadingSpace]	Loc=<main.c:16:9>
equal '='	 [LeadingSpace]	Loc=<main.c:16:16>
identifier 'sum'	 [LeadingSpace]	Loc=<main.c:16:18> // 标识位于源文件的第 16 行，从第 18 个字符开始
l_paren '('		Loc=<main.c:16:21>
numeric_constant '1'		Loc=<main.c:16:22>
comma ','		Loc=<main.c:16:23>
numeric_constant '2'	 [LeadingSpace]	Loc=<main.c:16:25>
r_paren ')'		Loc=<main.c:16:26>
semi ';'		Loc=<main.c:16:27>
return 'return'	 [StartOfLine] [LeadingSpace]	Loc=<main.c:17:5>
numeric_constant '0'	 [LeadingSpace]	Loc=<main.c:17:12>
semi ';'		Loc=<main.c:17:13>
r_brace '}'	 [StartOfLine]	Loc=<main.c:18:1>
eof ''		Loc=<main.c:18:2>
```

`identifier 'sum'	 [LeadingSpace]	Loc=<main.c:16:18`>   表示位于源文件的第 16 行，从第 18 个字符开始

![image-20191028130818220](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-050818.png)



经过词法分析后，源代码就变成了一个个记号 token，并且记录了每一个记号 token 的在源代码中的位置信息。

#### 语法分析

语法分析就是语法分析器对词法分析输出的记号 token 进行语法分析，输出一颗`以表达式为节点`的`抽象语法树(abstract syntax tree - AST)`。

```shell
# clang 语法分析生成抽象语法树
xcrun clang -fmodules -fsyntax-only -Xclang -dump-tokens main.c


# sum 函数
|-FunctionDecl 0x7fdd2a0126f0 <main.c:11:1, line:13:1> line:11:5 used sum 'int (int, int)'
| |-ParmVarDecl 0x7fdd2a010590 <col:9, col:13> col:13 used a 'int'
| |-ParmVarDecl 0x7fdd2a012618 <col:16, col:20> col:20 used b 'int'
| `-CompoundStmt 0x7fdd2a012838 <col:23, line:13:1>
|   `-ReturnStmt 0x7fdd2a012828 <line:12:5, col:16>
|     `-BinaryOperator 0x7fdd2a012808 <col:12, col:16> 'int' '+'
|       |-ImplicitCastExpr 0x7fdd2a0127d8 <col:12> 'int' <LValueToRValue>
|       | `-DeclRefExpr 0x7fdd2a012798 <col:12> 'int' lvalue ParmVar 0x7fdd2a010590 'a' 'int'
|       `-ImplicitCastExpr 0x7fdd2a0127f0 <col:16> 'int' <LValueToRValue>
|         `-DeclRefExpr 0x7fdd2a0127b8 <col:16> 'int' lvalue ParmVar 0x7fdd2a012618 'b' 'int'

# main 函数
`-FunctionDecl 0x7fdd2a012a60 <line:15:1, line:18:1> line:15:5 main 'int (int, const char **)'
  |-ParmVarDecl 0x7fdd2a012868 <col:10, col:14> col:14 argc 'int'
  |-ParmVarDecl 0x7fdd2a012950 <col:20, col:38> col:33 argv 'const char **':'const char **'
  `-CompoundStmt 0x7fdd2a012c98 <col:41, line:18:1>
    |-DeclStmt 0x7fdd2a012c50 <line:16:5, col:27>
    | `-VarDecl 0x7fdd2a012b20 <col:5, col:26> col:9 result 'int' cinit
    |   `-CallExpr 0x7fdd2a012c20 <col:18, col:26> 'int'
    |     |-ImplicitCastExpr 0x7fdd2a012c08 <col:18> 'int (*)(int, int)' <FunctionToPointerDecay>
    |     | `-DeclRefExpr 0x7fdd2a012b80 <col:18> 'int (int, int)' Function 0x7fdd2a0126f0 'sum' 'int (int, int)'
    |     |-IntegerLiteral 0x7fdd2a012ba0 <col:22> 'int' 1
    |     `-IntegerLiteral 0x7fdd2a012bc0 <col:25> 'int' 2
    `-ReturnStmt 0x7fdd2a012c88 <line:17:5, col:12>
      `-IntegerLiteral 0x7fdd2a012c68 <col:12> 'int' 0
```



sum 函数的语法树图形化为：

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-080347.png" alt="image-20191028160346857" style="zoom:80%;" />

有了 AST 抽象语法树，语法分析阶段就可以对代码进行分析检查，如检查括号是否匹配，是否缺少操作符，类型是否匹配等，一旦检查不通过，就会报告语法分析阶段的错误。

AST 也是用来编写 Clang 插件的主要交互的数据结构，程序员可以基于 AST 来编写自定义的语法规则，可以用来做代码静态检查。Clang 也提供了很多的 API 来对 AST 的节点做增删改查操作。

#### 语义分析

语法分析仅仅是完成对`表达式语法层面`的检查，要想检查语句是否真正有意义，还需要语义分析。

语义分析是由`语义分析器`来完成，语义分析检查的是表达式是否真的有意义，如类型的转换，声明和类型的匹配，如将一个浮点型赋值给一个指针类型，就会报语义分析阶段错误。

经过语义分析阶段后，整个语法树的表达式都被标识了类型，有些需要隐式转换的类型，也会在这个阶段插入相应的转换节点。

#### 中间语言生成

```shell
# clang 生成中间代码 .ll 是文本格式的中间代码，还有内存格式和二进制格式
clang -S -emit-llvm main.c -o main.ll

; ModuleID = 'main.c'
source_filename = "main.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @sum(i32, i32) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  store i32 %1, i32* %4, align 4
  %5 = load i32, i32* %3, align 4
  %6 = load i32, i32* %4, align 4
  %7 = add nsw i32 %5, %6
  ret i32 %7
}

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main(i32, i8**) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i32, align 4
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %7 = call i32 @sum(i32 1, i32 2)
  store i32 %7, i32* %6, align 4
  ret i32 0
}

attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "darwin-stkchk-strong-link" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "probe-stack"="___chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 15]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"Apple clang version 11.0.0 (clang-1100.0.33.8)"}
```

可以阅读以下 IR 中间代码中的 sum 函数：

```shell
# sum 函数
define i32 @sum(i32, i32) #0 {
  %3 = alloca i32, align 4 # 分配一个局部变量 %3
  %4 = alloca i32, align 4 # 分配一个局部变量 %4
  store i32 %0, i32* %3, align 4 # 将 %0 的值赋值给 %3，%0 就是 sum 函数的第一个参数 a
  store i32 %1, i32* %4, align 4 # 将 %1 的值赋值给 %4，%1 就是 sum 函数的第二个参数 b
  %5 = load i32, i32* %3, align 4 # 分配一个局部变量 %5， 并将 %3 的值赋值给 %5，即 a 的值
  %6 = load i32, i32* %4, align 4 # 分配一个局部变量 %6， 并将 %4 的值赋值给 %5，即 b 的值
  %7 = add nsw i32 %5, %6 a + b # 分配一个局部变量 %7，将局部变量 %5 和局部变量 %6 的值相加后赋值给 %7，即 a + b 的值
  ret i32 %7 # 返回局部变量 %7 的值，即 a + b 的值
}
```

至此，编译器前端的工作已经做完，生成了中间代码，中间代码是编译器前端的输出，也是编译器后端的输入。接下来就是编译器后端的工作了。

#### 目标代码生成和优化

编译器后端将中间代码转成汇编代码，输出汇编代码:

```assembly
# 使用 clang 生成汇编代码
clang -S main.c -o main.s
	
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 10, 15	sdk_version 10, 15
	.globl	_sum                    ## -- Begin function sum
	.p2align	4, 0x90
_sum:                                   ## @sum
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movl	-4(%rbp), %esi
	addl	-8(%rbp), %esi
	movl	%esi, %eax
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.globl	_main                   ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movl	$0, -4(%rbp)
	movl	%edi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	$1, %edi
	movl	$2, %esi
	callq	_sum
	xorl	%esi, %esi
	movl	%eax, -20(%rbp)
	movl	%esi, %eax
	addq	$32, %rsp
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function

.subsections_via_symbols
```

`汇编器`以汇编代码作为输入，将汇编代码转换为机器代码，最后输出目标文件(object file)：

```shell
clang -fmodules -c main.c -o main.o

// 使用 nm 可以查看 main.o 文件中的符号 Symbol
➜  HelloWorld nm -nm main.o
0000000000000000 (__TEXT,__text) external _sum
0000000000000020 (__TEXT,__text) external _main
```

`目标代码生成`阶段依赖具体的目标机器，不同的机器有不同的字长、寄存器、整数和浮点数数据类型。目标代码优化`会采取选择合适的寻址方式、使用位移代替乘法、删除多余的指令等方对代码进行优化。

> 符号 Symbol 表示一段代码或者是数据的起始地址。

#### 链接

每个文件或者模块独立编译后的目标文件组装的过程叫做`链接`，链接由`链接器`完成。链接过程主要包括了地址和空间的分配、符号决议、和重定位等步骤。

`链接器` 将不同的目标文件和库文件链接起来，处理好各个模块和文件中的相互引用，将符号绑定到地址上，最终形成`可执行文件`。

```shell
# 使用 clang 链接生目标文件生成可执行文件
clang main.o -o main
```



<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-094817.png" alt="image-20191028174816689" style="zoom:50%;" />



```shell
# 查看可执行文件中的符号表
➜  HelloWorld nm -nm main
                 (undefined) external  dyld_stub_binder (from libSystem) 
0000000100000000 (__TEXT,__text) [referenced dynamically] external __mh_execute_header
0000000100000f60 (__TEXT,__text) external _sum
0000000100000f80 (__TEXT,__text) external _main
```

> 表示符号 dyld_stub_binder 来自于 libSystem 库，undefined 表示在当前文件中找不到该符号，external 表示该符号可以支持外部访问

### iOS DEMO

上面我们通过一个 hello world 程序和一个加法函数的 C 语言来举例，基本覆盖了编译链接的整个大的流程，但毕竟是单文件的，涉及的场景有限，有很多细节没法展示。

下面写一个使用 Objective-C 和 Swift 的混编项目，使用 CocoaPods 来管理第三方库，包含了一个Objective-C .a 静态库 FooObjcStaticLibrary 和一个 Swift 的动态库 FooSwift.framework，尽量模拟真实的 iOS 项目场景，再来探究下。DEMO 项目结构如下：

![image-20191028232924657](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-152925.png)

运行效果：

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-28-153148.png" alt="image-20191028233148422" style="zoom: 50%;" />



#### 点击 Command + B

![image-20191029141549289](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-29-061550.png)

#### 构建过程

大多数任务在构建过程中由命令行工具运行，比如 Clang，LD，AC 工具，IB 工具，代码符号等。这些工具等执行，需要一组特定的实参，以特定的顺序，基于 Xcode 项目配置。

#### 构建系统 Bulid System

Xcode 10 开始，使用了新的 Bulid System，新构建系统使用 Swift Scratch 编写，提供了更好的性能，而且这个代码是开源的，地址在[这里](https://github.com/apple/swift-llbuild)。

#### 读取  project 文件

首先，构建系统会从 project 文件读取源代码的信息，决定构建过程的模型和流程，然后转换成一个树形结构叫做`定向图`，它显示了所有的`依赖关系`，项目中的输入和输出文件，以及处理他们的执行任务。构建系统就按照定向图的顺序执行一系列的构建任务。

![image-20191030120417315](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-30-040417.png)

>project 文件除了记录了 App 的一些相关信息和源代码文件的组织目录关系，还记录了 build settings、build phases、build rules、target 、target dependencies 等构建相关的信息。有关 project 文件更新详细的介绍可以看[这篇文章](http://yulingtianxia.com/blog/2016/09/28/Let-s-Talk-About-project-pbxproj/)。 

**构建顺序是由依赖关系决定的**，依赖关系的来源下面几种：

1. 构建系统自带的规则，如编译器、链接器、资源目录、storyboard 处理器，这些规则定义了哪些是输入文件，哪些是输出文件

2. target 依赖，build 当前的 target 之前，必须先对这里的依赖先进行 build

   ![image-20191030141806543](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-30-061806.png)

3. 隐式依赖（Implicit dependencies）

4. Bulid phases，代表着将代码转变为可执行文件的最高级别规则，里面描述了 build 过程中必须执行的不同类型规则，定义了构建处理的过程

   ​	![image-20191030142206876](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-30-062207.png)

   - CocoaPods 相关的脚本 script execution

   - Compile Sources  中规定了所有必须参与编译的文件，这里列出的所有文件将根据相关的 build rules 和 build settings 被处理

   - Link Binary with Libraries：列出了所有的静态库和动态库，编译结束后，这些库会参与上面编译阶段生成的目标文件进行链接
   - Copy Bundle Resources：将静态资源（例如图片、Storyboard 和字体）拷贝到 app bundle 中

5. Scheme 顺序依赖

   ![image-20191030192242047](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2019-10-30-112243.png)



该项目的构建定向图如下：**







#### 编译源代码





#### 链接





## 第二部分：点击 App Icon -> 看到页面









































---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「by在水一方」。

![by在水一方](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/qrcode_for_gh_0be790c1f754_258.jpg)