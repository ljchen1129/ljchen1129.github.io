---
title: C 语言拾遗
date: 2019-03-09 19:29:09
tags:
- C
- 指针
categories: C

---

## 前言

最近学习[数据结构和算法](https://chenliangjing.me/2019/02/13/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B8%8E%E7%AE%97%E6%B3%95%E5%AD%A6%E4%B9%A0-%E5%BC%80%E7%AF%87/)，使用 C 语言实现一些算法和练习题的时候，容易卡壳在 C 语言里面的一些指针、结构体、内存分配等相关语法知识点上，这次复习了一下，下面是一些记录。


## 指针

指针：就是`保存地址的变量`，变量的值是所指像的`内存地址`。

<!--more-->

```C

int i;
int *p = &i;
int *p, q;
int *p,q;
```

![](http://liangjinggege.com/Xnip2019-03-09_20-38-52.png)

### 指针应用场景

#### 场景一，函数返回多个值，某些值只能通过指针返回

如 iOS 里面常见的一些这样的代码：

```Objective-C

NSError *error = nil;
[[NSFileManager defaultManager] removeItemAtPath:@"xxx/path" error:&error];
if (error) {
    NSLog(@"操作失败！\n");
    NSLog(@"error = %@", error);
} else {
    NSLog(@"操作成功！");
}
```

这段代码在给定路径下删除资源，通过外界传递的 error 来接收错误值，用来判断操作是否成功。这个方法里面的 error 只能通过参数返回。

再看一段 C 代码：

```C
// 求整型数组中元素的最大值和最小值
void minmax(int a[], int len, int *max, int *min)
{
    int i;
    *min = *max = a[0];
    for (i = 1; i < len; i++)
    {
        if (a[i] < *min) 
        {
            *min = a[i];
        }
        
        if (a[i] > *max) 
        {
            *max = a[i];
        }
    }
}

int main(int argc, const char * argv[]) {
    
    int a[] = {1, 3, 4, 10, 66, 78, 34, 99};
    int min, max;
    minmax(a, sizeof(a)/sizeof(a[0]), &max, &min);
    printf("min = %d, max = %d\n", min, max);
    
    return 0;
}

// 日志输出
min = 1, max = 99
Program ended with exit code: 0
```

> 这种场景下，指针的作用就是作为函数参数把函数需要返回的值带出来。


#### 场景二，函数返回运算状态，常用 -1 和 0 表示，函数结果通过指针返回

举例，除法运算有可能不成功，当除数为 0 时，就不成功，这个时候函数既需要告诉外界函数的运算状态，又要将结果返回，这样可以把`运算结果通过指针来返回`


```C
// 如果除法成功，返回1；否则返回0
int divide(int a, int b, int *resutlt)
{
    int ret = 1;
    if (b == 0) ret = 0;
    else {
        *resutlt = a/b;
    }
    return ret;
}

int main(int argc, const char * argv[]) {
    
    int a = 5;
    int b = 2;
    int c;
    
    if (divide(a, b, &c)) {
        printf("%d/%d=%d\n", a,b,c);
    }
    
    return 0;
}

// 执行结果
5/2=2
Program ended with exit code: 0
```

#### 指针使用常见错误场景

定义了指针变量，但还没有指向任何变量，就开始使用指针。

![](http://liangjinggege.com/Xnip2019-03-09_20-46-33.png)

### 指针数组

#### 1. 函数参数中的数组其实就是指针。看段代码：

![](http://liangjinggege.com/Xnip2019-03-09_21-06-45.png)

在sum函数里面修改数组参数a[0]的值，影响到了原数组。其实在函数中，数组参数就是指针，所以下面这几种写法是等价的。

```C
int sum(int a[], int length)
int sum(int *, int);
int sum(int *a, int length)
int sum(int [], int length)
```

#### 2. 数组是特殊的指针

- 数组变量本身表达地址，赋值给指针`不需要用&取地址`。
- 数组的单元表达的是变量，赋值给指针`需要用&取地址`。
- [] 可以对数组做，也可以对指针做。
- `* 运算符`可以对指针做，也可以对数组做。
- 数组变量是` const 的指针`，不能被赋值。

![](http://liangjinggege.com/Xnip2019-03-09_21-49-17.png)


### 指针与const

#### 1. 指针是const

```C

int a = 1;
int *const p = &a;
*p = 2;
// 指针指向的变量可以改变
printf("*p=%d\n", *p);
    
// 指针不能改
//    *p++;

// 打印日志
*p=2
Program ended with exit code: 0
```


#### 2. 所指是const

```C

int a = 1;
// 两个等价
// const int *p = &a;
int const *p = &a;
// 指针可以改
printf("*p = %d\n", *p);
*p++;
// 指针指向的变量不能改
//    *p = 2;
printf("*p = %d\n", *p);

// 打印日志
*p = 1
*p = -272632560
Program ended with exit code: 0
```

#### 3. 应用场景

当要传递的参数类型比地址大的时候，如结构体类型，使用`const类型修饰所指变量`，既能用`比较小的字节数`传递值给参数，又能`防止函数内部对外面变量的修改`。

#### 4. const 数组

![](http://liangjinggege.com/Xnip2019-03-09_22-25-32.png)

上面说到，数组在函数参数中其实是指针，在函数内部可以修改原数组的值，为了保护数组不被函数破坏，可以设置函数参数为const

![](http://liangjinggege.com/Xnip2019-03-09_22-28-47.png)


### 指针运算

#### 1. 指针加减
指针`加减运算`是将指针指向的`内存单元下移或者上移`，移动的单位是sizeof(内存单元)。

- 指针加减常数（p+1、p-1, p += 1; p -= 1）
- 指针自增自减（p++、p--）
- 指针之间相减 : 指`两个指针之间`相差`多少个内存单元`，即地址之差/sizeof(内存单元)

```C

printf("指针加减运算-----\n");
printf("p = %p\n", p);
// p 加运算，指向数组下一个内存单元
p += 1;
printf("p = %p\n", p);
// p 减运算，指向数组上一个内存单元
p = p - 1;
printf("p = %p\n", p);
    
// p 自增自减
printf("指针自增自减-----\n");
p++;
printf("p = %p\n", p);
p--;
printf("p = %p\n", p);
    
// 指针相减
int *q = &a[8];
printf("指针相减-----\n");
printf("q = %p, p = %p,q - p = %ld\n", q,p, q - p);
    

// 打印日志，地址之间相差16进制正好sizeof(int)，*(p+1) -> 相当于a[1]
// 指针相减，地址相差 32，正好是8 * sizeof(int)
指针加减运算-----
p = 0x7ffeefbff4c0
p = 0x7ffeefbff4c4
p = 0x7ffeefbff4c0
指针自增自减-----
p = 0x7ffeefbff4c4
p = 0x7ffeefbff4c0
指针相减-----
q = 0x7ffeefbff4e0, p = 0x7ffeefbff4c0,q - p = 8
Program ended with exit code: 0
```

>注意：指针能够进行这些运算的前提是指针指向的是`一片连续的内存空间地址`，如数组这样。如果指针不是指向一片连续的内存空间，则这种运算是没有意义的。

#### 2. *p++

- 取出p所指内存的那个数据，然后再把p移到下一个位置去，即p+1。
- ++ 的优先级大于*
- 常用语数组类的连续空间操作，如数组遍历
- 在一些CPU上，可以直接被翻译成一条汇编指令，所以运行效率高

```C

int a[] = {0,1,2,3,4,5,6,7,8,9, -1};
int *p = &a[0];
while (*p != -1) {
    printf("%d\n", *p++);
}

// 打印日志
0
1
2
3
4
5
6
7
8
9
Program ended with exit code: 0
```

#### 3. 指针比较

指针的比较其实就是对指针所指内存地址大小的比较

- <、<=、==、>、>=、！= 这些运算符都可以来对指针操作

### 0 地址
每个用用程序都有 0 地址，0 地址可以用来表示不能随便访问的地址，所以指针不应该具有 0 值，但可以用来表示特殊的事情

- 返回的`指针无效的`
- 指针没有被`真正初始化`（先初始化为NULL、0）
- NULL 表示 0 地址

```C
// 表示q没有被真正初始化，不能使用
int *q = NULL;
// 错误
// *q = 15;
```

### 指针类型

- 指针的类型主要是指`所指向的内存变量的类型`，不同指向类型的指针是`不能直接相互赋值`的
- 指针类型转换
	- void * 表示不知道指向指向什么类型的指针

![](http://liangjinggege.com/Xnip2019-03-10_15-16-52.png)


### 动态内存分配

C 语言中动态内存分配要引入 #include <stdlib.h> 系统库。


```C
// 内存分配函数，传入一个需要申请的内存空间大小，单位是字节，返回一个 void * 指针指向这片内存空间
void *malloc(size_t __size)

// 释放空间，传入是指向要释放内存的指针
void free(void *);
```

![](http://liangjinggege.com/Xnip2019-03-10_15-39-48.png)

#### 常见问题

1. 申请了空间忘记free
2. free过了在free
3. 地址变过了，直接去free

## 结构体
结构体常用来表达复杂一些的数据结构。

### 声明

```C

// 1. 有名结构体
struct point {
    int x;
    int y;
};

// p1，p2都是结构体 point 类型
struct point p1, p2;


// 2. 无名结构体，没有定义结构体类型，只是声明了两个结构体的变量p3，p4
struct {
    int x;
    int y;
} p3, p4;

// 3. 既定义了结构体类型point，有声明了两个变量 p5，p6
struct point {
    int x;
    int y;
} p5, p6;
```

### 访问

![](http://liangjinggege.com/Xnip2019-03-10_16-16-28.png)

### 作为函数参数

结构体直接当做函数参数和数组不一样，`数组是传递的指针`，而`结构传递的是值`，需要赋值一遍原结构到函数参数中，如果结构很大的话，这样的操作就需要消耗挺大的资源。可以选择使用`指针传递`。


#### 指向结构的指针

```
struct point *getNewPoint(struct point *point)
{
    point->x = 2;
    point->y = 2;
    
    return point;
}

int main(int argc, const char * argv[]) {

    // p2 指向结构体的指针变量
    struct point *p2 = &p1;
    // 赋值
    (*p2).x = 1;
    // 用 -> 表示指针所指结构体变量的成员变量
    p2->y = 1;
    
    printf("x = %d, y = %d\n", p2->x, p2->y);
    // 将结构体指针传入函数参数
    p2 = getNewPoint(p2);
    printf("x = %d, y = %d\n", p2->x, p2->y);
}

// 打印日志
x = 1, y = 1
x = 2, y = 2
Program ended with exit code: 0
```

### 结构数组

```
// 结构数组，数组里面的元素是一个个结构体
struct point points[] = {
    {0,0},{1,1}, {2,2}
};
    
// 访问
int x = points[0].x;
int y = points[1].y;
```

### typedef

```C

// 取别名，相当于Point就是结构体体类型。
typedef struct {
    int x;
    int y;
}Point;


// 使用
Point p1;
Point *p2 = &p1;
    
p1.x = 1;
p1.y = 1;
p2->x = 2;
p2->y = 2;
```



***

分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「青争哥哥」。

![](http://liangjinggege.com/qrcode_for_gh_0be790c1f754_258.jpg)