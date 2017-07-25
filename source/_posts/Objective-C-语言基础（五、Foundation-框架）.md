---
title: Objective-C  语言基础（五、Foundation 框架）
date: 2017-04-26 23:46:47
tags:
- iOS
- Objective-C
categories:
- iOS
- Objective-C
---

## Foundation 简介
Foundation 框架是 Mac/iOS 中其他框架的基础，Foundation 框架包含了很多开发中常用的数据类型（结构体、枚举、类）

## 字符串
[源码地址一](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSString)
[源码地址二](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E5%AD%97%E7%AC%A6%E4%B8%B2)
### 1.NSString
#### #创建字符串

```
// 1. 通过字符串常量创建，存储在`常量区`中
NSString *str1 = @"张三";
    
// 2. 通过对象方法创建
NSString *str2 = [[NSString alloc] initWithFormat:@"李四"];
    
// 2. 通过类工厂方法创建
NSString *str3 = [NSString stringWithFormat:@"李四"];

```

通过不同的方式创建的字符串，字符串对象存储的位置不一样

1. 通过字符串常量创建：字符串对象存储在`常量区`中，并且如果多个字符串对象，多个字符串对象指向同一块存储空间。
	
	![](http://o6heygfyq.bkt.clouddn.com/Snip20170416_5.png)
	
2. 通过对象方法以及类工厂方法创建：字符串对象存储在`堆区`中。

>注意：不同平台存储的方式也不一样，如果是 MAC 平台，系统会对字符串对象进行优化，如果是 iOS 平台就是两个对象。

#### #字符串读写
##### 文件读
###### 直接读写文件中的字符

```
// 字符串读取
// 1. 从文件中读取字符串
/**
 file：文件路径，绝对路径
 encoding: 字符编码，一般写 UTF-8
 */
NSError *error = nil;
NSString *str = [NSString stringWithContentsOfFile:@"/Users/chenliangjing/Desktop/test.txt" encoding:NSUTF8StringEncoding error:&error];
if (error == nil)
{
    NSLog(@"str = %@",str);
}
else
{
    NSLog(@"error = %@", [error localizedDescription]);
}

// 2. 将字符串写入文件中
NSDate *now = [NSDate date];
NSString *str = [NSString stringWithFormat:@"%@", now];
    
// atomically:如果YES，字符串写入文件的过程如果没有写完，那么不会生成文件
//            如果NO，字符串写入文件的过程如果没有写完，会生成文件
[str writeToFile:@"/Users/chenliangjing/Desktop/test.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
if (error == nil)
{
    NSLog(@"str = %@",str);
}
else
{
    NSLog(@"error = %@", [error localizedDescription]);
}


```

###### 根据 URL 加载文件中的字符串

```
// 根据 URL 从文件中读取字符串
// 1. 创建 URL
// 协议头 + 主机地址 + 文件路径
NSString *path = @"file://192.168.0.100/Users/chenliangjing/Desktop/test.txt";
NSURL *url = [NSURL URLWithString:path];
    
// 2. 根据 URL 加载文件中的字符串
NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
if (error == nil)
{
    NSLog(@"str = %@", str);
}
else
{
    NSLog(@"error = %@", [error localizedDescription]);
}

```

如果资源是在`本机地址`获取的，那么 URL 的主机地址可以省略，上述的路径可以写为：

```
// 前面的 `/` 不能省略，代表根路径 
NSString *path = @"file:/Users/chenliangjing/Desktop/test.txt";

```

如果是通过 fileURLWithPath: 方法创建 URL，则协议头也不用写，系统会自动添加协议头（file://）

```
NSString *path = @"/Users/chenliangjing/Desktop/test.txt"; 
NSURL *url = [NSURL fileURLWithPath:path];
 
```
>注意：如果 URL 中含有中文，通过 fileURLWithPath: 方法创建 URL 会自动将中文进行百分号编码，而如果通过 UrlWithString: 方法，不会自动进行中文的处理，需手动进行中文百分号编码：

![](http://o6heygfyq.bkt.clouddn.com/Snip20170426_1.png)

##### 文件写

```
// 文件写入
NSString *str = @"chenliangjing";
NSString *path = @"/Users/chenliangjing/Desktop/test.txt";
NSError *error = nil;
[str writeToURL:[NSURL fileURLWithPath:path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
if (error) {
    NSLog(@"写入失败");
    NSLog(@"error = %@", error);
} else {
    NSLog(@"写入成功");
}

```

>注意：如果多次往同一个文件中写入内容，那么最后一次写入的内容会覆盖掉以前的内容。

#### #字符串比较
##### 比较两个字符串的“内容”是否相同
	
```
// 1. 比较两个字符串的“内容”是否相同
bool flag = [str1 isEqualToString:str2];
NSLog(@"flag = %i", flag);

```
	
##### 比较两个字符串的”地址“是否相同

```
// 2. 比较两个字符串的”地址“是否相同
flag = (str1 == str2);

```
	
##### 比较两个字符串大小，比较的 ACCIC 码值
 - NSOrderedAscending 升序，前面的小于后面的
 - NSOrderedSame, 相等
 - NSOrderedDescending 降序，前面的大于后面的

```
// 1. 不忽略大小写比较
switch ([str1 compare:str2]) {
    case NSOrderedAscending:
        NSLog(@"str1 小于 str2");
        break;
    case NSOrderedSame:
        NSLog(@"str1 等于 str2");
        break;
    case NSOrderedDescending:
        NSLog(@"str1 大于 str2");
        break;
    default:
        break;
};
	
// 2. 忽略大小写比较
NSString *str3 = @"zhangsan";
NSString *str4 = @"ZHANGSAN";

switch ([str3 caseInsensitiveCompare:str4]) {
    case NSOrderedAscending:
        NSLog(@"str3 小于 str4");
        break;
    case NSOrderedSame:
        NSLog(@"str3 等于 str4");
        break;
    case NSOrderedDescending:
        NSLog(@"str3 大于 str4");
        break;
    default:
        break;
};

```


#### #字符串搜索
##### 判断是否以什么开头
 
```
 NSString *str = @"http://www.baidu.com";
// 1. 判断是否以什么开头
if ([str hasPrefix:@"http://"])
{
    NSLog(@"是一个 url");
}
else
{
    NSLog(@"不是一个 url");
}

```
 
##### 判断以什么结尾

```
if ([str hasSuffix:@".gif"])
{
    NSLog(@"动态图片");
}
else
{
    NSLog(@"不是动态图片");
}
    
```

##### 判断字符串中是否包含“某个字符串”

```
// 只要 str 中包含“某个字符串”，就会返回该字符串在字符串中的起始位置和长度
NSRange range = [str rangeOfString:@"baidu"];
NSLog(@"range.location = %lu, range.length = %lu", range.location, range.length); // range.location = 11, range.length = 5
// 如果 str 中没有需要查找的字符串，那返回的 range 的length = 0，location = NSNotFound
NSRange range2 = [str rangeOfString:@"google"];
if (range2.location != NSNotFound)
{
    NSLog(@"在 str 中找到 “baidu”");
}
else
{
     NSLog(@"在 str 中没有找到 “baidu”");
     NSLog(@"range2.length = %lu", range2.length); // 0
}

```

#### #字符串截取

```
NSString *str = @"<hea>陈良静</hea>";
// 默认从第一个字符开始找
NSUInteger location = [str rangeOfString:@">"].location + 1;

// NSBackwardsSearch，从最后一个字符开始找
NSUInteger length = [str rangeOfString:@"<" options:NSBackwardsSearch].location - location;

NSRange range = NSMakeRange(location,length);

// 1. 在 range 范围内截取
NSString *newStr = [str substringWithRange:range];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = <hea>陈良静</hea>, newStr = 陈良静

// 2. 从什么位置开始截取，一直截取到最后
// 默认从第一个字符开始找
NSUInteger fromLocation = [str rangeOfString:@">"].location + 1;
NSString *newStr = [str substringFromIndex:fromLocation];
NSLog(@"str = %@, newStr = %@", str, newStr); // <hea>陈良静</hea>, newStr = 陈良静</hea>


// 3. 从开头开始截取，一直截取到什么位置
NSUInteger toLocation = [newStr rangeOfString:@"<"].location;
newStr = [newStr substringToIndex:toLocation];
NSLog(@"str = %@, newStr = %@", str, newStr); // <hea>陈良静</hea>, newStr = 陈良静

```

#### #字符串替换

##### 用制定字符串替换字符串中的子串

```
NSString *str = @"http://www.baidu.com";
// 将“baidu”替换为“sina”
NSString *newStr = [str stringByReplacingOccurrencesOfString:@"baidu" withString:@"sina"];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = http://www.baidu.com, newStr = http://www.sina.com
    
```

##### 去除空格

```
NSString *str = @" http://ww w.baidu.c  om ";
NSString *newStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
NSLog(@"str = %@, newStr = %@", str, newStr); // http://ww w.baidu.c  om , newStr = http://www.baidu.com

```

##### 替换首尾

```
NSString *str = @" ht tp://ww w.b ai du.com  ";
// 去除首尾的空格
NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
NSString *newStr = [str stringByTrimmingCharactersInSet:set];
NSLog(@"str = %@, newStr = %@", str, newStr); // str =  ht tp://ww w.b ai du.com  , newStr = ht tp://ww w.b ai du.com
    
// 将首尾的大写字符全部取出掉
str = @"HTTP://www.baidu.com";
NSCharacterSet *set2 = [NSCharacterSet uppercaseLetterCharacterSet];
newStr = [str stringByTrimmingCharactersInSet:set2];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = HTTP://www.baidu.com, newStr = ://www.baidu.com

```

#### #字符串和路径

##### 判断是否是一个绝对路径

```
// 本质是判断字符串是否以“/”开头
bool flag = [str isAbsolutePath];
if (flag)
{
    NSLog(@"str 是一个绝对路径"); // str 是一个绝对路径
}
else
{
    NSLog(@"str 不是一个绝对路径");
}

```

##### 获取文件路径中的最后一个目录

```
// 本质是获取路径中最后一个/后面的内容
NSString *lastDir = [str lastPathComponent];
NSLog(@"lastDir = %@", lastDir); // lastDir = test.txt

```

##### 删除文件路径中的最后一个目录

```

// 本质是删除最后一个"/"以及后面的内容
NSString *newStr = [str stringByDeletingLastPathComponent];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = /Users/chenliangjing/Desktop/test.txt, newStr = /Users/chenliangjing/Desktop

```

##### 给文件路径添加一个目录

```
// 如果原路径后面已经有了"/"，则不会在添加“/”，如果有没有，怎会添加“/”，如果有多个"/",则会删除多余的"/"，只保留一个"/"
NSString *addDir = @"chenliangjing.tex";
newStr = [str stringByAppendingPathComponent:addDir];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = /Users/chenliangjing/Desktop/test.txt, newStr = /Users/chenliangjing/Desktop/test.txt/chenliangjing.tex

```

##### 获取路径中的文件扩展名

```
// 本质是从字符串的末尾开始查找，截取第一个"."后面的内容
NSString *extName = [str pathExtension];
NSLog(@"extName = %@", extName); // extName = txt

```

##### 删除路径中的文件扩展名

```
// 本质是从字符串的末尾开始查找，删除第一个"."后面的内容
newStr = [str stringByDeletingPathExtension];
NSLog(@"str = %@, newStr = %@", str, newStr); // str = /Users/chenliangjing/Desktop/test.txt, newStr = /Users/chenliangjing/Desktop/test

```

##### 给文件路径天机一个扩展名

```
NSString *addExtName = @"gif";
newStr = [newStr stringByAppendingPathExtension:addExtName];
NSLog(@"newStr = %@", newStr); // newStr = /Users/chenliangjing/Desktop/test.gif

```

#### #字符串转换

##### 将字符串装换为大写

	NSString *str = @"chenLiangJing";
	NSString *newStr = [str uppercaseString];
	NSLog(@"str = %@, newStr = %@", str, newStr); // str = chenLiangJing, newStr = CHENLIANGJING   
 

##### 将字符串装换为小写


	newStr = [str lowercaseString];
	NSLog(@"str = %@, newStr = %@", str, newStr); // henLiangJing, newStr = chenliangjing 
  
 
##### 将字符串的首字符转换为大写


	newStr = [str capitalizedString];
	NSLog(@"str = %@, newStr = %@", str, newStr); // str = chenLiangJing, newStr = Chenliangjing


##### 字符串与基本数据类型的转换


	NSInteger a = 10;
	NSInteger b = 10;
	newStr = [NSString stringWithFormat:@"%ld", a + b]; // newStr = 20
	NSLog(@"newStr = %@", newStr);
	    
	NSString *str1 = @"30"; // 要确保装换的字符串确实可以转成想要的基本数据类型，否则会结果错误
	NSString *str2 = @"50";
	NSInteger result = [str1 integerValue] + [str2 integerValue];
	NSLog(@"result = %ld", result); // result = 80  
 
    
##### C 语言字符创和 Objective-C 字符串之间的转换

```
// C 转 OC
char *cStr = "clj";
NSString *ocStr = [NSString stringWithUTF8String:cStr];
NSLog(@"cStr = %s, ocStr = %@", cStr, ocStr); // cStr = clj, ocStr = clj
    
// OC 转 C
ocStr = @"chenliangjing";
const char *newcStr = [ocStr UTF8String];
NSLog(@"ocStr = %@, newcStr = %s", ocStr, newcStr); // ocStr = chenliangjing, newcStr = chenliangjing

```


### 2.NSMutableString
#### #NSMutableString 基本概念
1. NSMutableString 是 NSString 类的子类，NSString 类中提供的所有方法在  NSMutableString 类中都可以使用，NSMutableString 类似一个字符串链表，可以任意的在字符串中添加、删除字符串，在指定位置插入字符串，用来操作字符串更加灵活。

2. 可变和不可变
- 不可变
指的是字符串在内存中占用的存储空间固定，并且存储的内容不能发生变化

- 可变 
指的是字符串在内存中占用的存储空间可以不固定，并且存储的内容可以被修改

#### #NSMutableString 常用方法
##### 在字符串后面添加字符串

	[mStr appendString:@"liangjing"];
	NSLog(@"mStr = %@", mStr); // mStr = chenliangjing
	[mStr appendFormat:@"'s age is %i", 25];
	NSLog(@"mStr = %@", mStr); // mStr = chenliangjing's age is 25
  

##### 删除字符串

	NSRange delRange = [mStr rangeOfString:@"'s age is 25"];
	[mStr deleteCharactersInRange:delRange];
	NSLog(@"mStr = %@", mStr); // chenliangjing

    
##### 插入字符串

	NSRange insRange = [mStr rangeOfString:@"liangjing"];
	[mStr insertString:@"_" atIndex:insRange.location];
	NSLog(@"mStr = %@", mStr); // mStr = chen_liangjing

    
##### 替换字符串

```
// 调用父类 NSString 的替换字符串方法，返回一个新的字符串，不修改原来的字符串
NSString *newStr = [mStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
NSLog(@"mStr = %@, newStr = %@", mStr, newStr); // chen_liangjing, newStr = chenliangjing
    
// 调用 NSMutableString 的替换方法
NSRange repRange = [mStr rangeOfString:@"_liangjing"];
    
// OccurrencesOfString: 需要替换的字符串
// withString: 用什么字符串替换
// options: 替换是的搜索方式
// range: 搜索的范围
// 返回值: 表示替换了多少个字符串
NSUInteger count = [mStr replaceOccurrencesOfString:@"_" withString:@"" options:0 range:repRange];
NSLog(@"mStr = %@", mStr); // mStr = chenliangjing
NSLog(@"count = %ld", count); // count = 1
    
```


## 数组
[源码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E6%95%B0%E7%BB%84)
### 1. NSArray
#### NSArray 基本概念
- 能存放任意 OC 对象，而且是有序的
- 不能存储非 OC 对象，比如 int\float\char\stuct 等
- 不可变。一旦初始化完毕，他里面的内容就永远是固定的，不能添加，删除里面的元素

##### 创建方式

	+ (instancetype)array;
	+ (instancetype)arrayWithObject:(ObjectType)anObject;
	+ (instancetype)arrayWithObjects:(const ObjectType [])objects count:(NSUInteger)cnt;
	+ (instancetype)arrayWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
	// 通过一个数组来创建
	+ (instancetype)arrayWithArray:(NSArray<ObjectType> *)array;
	
	- (instancetype)initWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
	- (instancetype)initWithArray:(NSArray<ObjectType> *)array;
	- (instancetype)initWithArray:(NSArray<ObjectType> *)array copyItems:(BOOL)flag;
	
	+ (nullable NSArray<ObjectType> *)arrayWithContentsOfFile:(NSString *)path;
	+ (nullable NSArray<ObjectType> *)arrayWithContentsOfURL:(NSURL *)url;
	- (nullable NSArray<ObjectType> *)initWithContentsOfFile:(NSString *)path;
	- (nullable NSArray<ObjectType> *)initWithContentsOfURL:(NSURL *)url;
	
	
	// 常用创建方式，字面量语法
	NSArray *arr = @[@"obj1", @"obj2"];


##### 常用方法

```
NSArray *arr = @[@"obj1", @"obj2"];
    
// 1. 获取数组中元素的个数
NSUInteger arrCount = [arr count];
NSLog(@"arrCount = %lu", arrCount); //  arrCount = 2
    
// 2. 获取最后一个元素
NSString *lastObj = [arr lastObject];
NSLog(@"lastObj = %@", lastObj); // lastObj = obj2
    
// 3. 获取第一个元素
NSString *firstObj = [arr firstObject];
NSLog(@"firstObj = %@", firstObj); // firstObj = obj1
    
// 4. 获取数组中指定位置的元素
NSString *obj = [arr objectAtIndex:1];
NSLog(@"obj[1] = %@", obj); // obj[1] = obj2

// 5. 数组中是否包含某一个元素
NSString *obj3 = @"obj3";
BOOL flag = [arr containsObject:obj3];
if (flag)
{
    NSLog(@"arr 中包含 %@", obj3);
}
else
{
    NSLog(@"arr 中不包含 %@", obj3); // arr 中不包含 obj3
}

```

#####  简写(推荐方式)

	// 1. 数组简写
	NSArray *simpleArr = @[@"zhangsan", @"lisi", @"wangwu", @15, @"30"];
	    
	// 2. 获取指定位置的数组中元素
	id o = simpleArr[3];
	NSLog(@"o = %@", o); // o = 15
 

#### NSArray 遍历

```
    NSArray *arr = @[@"zhangsan", @"lisi", @"wangwu"];
    
// 1. 常规遍历
for (int i = 0; i < arr.count; i ++ )
{
    NSLog(@"arr[%i] = %@", i, arr[i]);
}
    
// 2. 增强 for 循环
// 逐个取出 arr 中的元素，将元素赋值给 obj
for (NSString *str in arr)
{
    NSLog(@"str = %@", str);
}
    
// 3. 使用数组迭代器遍历(推荐使用)
// 每取出一个元素就会调用一次block
// 每次调用 block 都会将当前取出的元素和元素对应的索引传递出来
// obj 就是当前取出的元素，idx 就是当前元素的对应索引
// stop 用于控制什么时候停止遍历
[arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (idx == 1)
    {
        // 停止遍历
        *stop = YES;
    }
    NSLog(@"idx = %lu, obj = %@", idx, obj);
}];

```

#### 给 NSArray 中所有对象发消息

	Person *p1 = [Person new];
	p1.food = @"food1";
	Person *p2 = [Person new];
	p2.food = @"food2";
	Person *p3 = [Person new];
	p3.food = @"food3";
	Person *p4 = [Person new];
	p4.food = @"food4";
	    
	NSArray *arr = @[p1, p2, p3, p4];
	// 如果使用 OC 数组存储对象，可以调用数组的方法给数组中所有的元素都执行指定的方法
	// selector: 要执行的方法
	// withObject:方法的参数
	[arr makeObjectsPerformSelector:@selector(eatWithFood:) withObject:@"food"];


> 注意：如果数组中保存的不是相同类型的元素，并且没有相同的方法，那么程序运行会报错。


#### 数组排序
##### 方法一：只能用于 OC 对象

	// compare: 排序方法只能用在数组中所有元素是 OC 对象时才能使用，如果数组中的对象时非 OC 对象，那么程序会运行报错
	NSArray *newArr = [arr sortedArrayUsingSelector:@selector(compare:)];
	NSLog(@"newArr = %@", newArr); // newArr = (2, 3, 5, 10, 20, 100)


##### 方法二：可用于自定义对象

```
Person *p1 = [Person new];
p1.age = 35;
Person *p2 = [Person new];
p2.age = 15;
Person *p3 = [Person new];
p3.age = 45;
Person *p4 = [Person new];
p4.age = 5;
    
NSArray *arr2 = @[p1, p2, p3, p4];
NSLog(@"arr2.age = %@", arr2);
    
// 该排序方法默认会按照升序排序
NSArray *newArr2 = [arr2 sortedArrayUsingComparator:^NSComparisonResult(Person *obj1, Person *obj2) {
    // 每次调用该 block 都会取出数组中的两个元素出来
    // 二分排序
    return obj1.age > obj2.age;
}];
NSLog(@"newArr2 = %@", newArr2);

```

#### NSArray 和 NSString 转换

	// 1. 将 NSArray 中的元素按照某个连接符拼接成一个字符串
	NSArray *arr = @[@"zhangsan", @"lisi", @"wangwu"];
	NSString *result = [arr componentsJoinedByString:@"_"];
	NSLog(@"result = %@", result); // result = zhangsan_lisi_wangwu
	    
	// 2. 通过字符串中的某一个连接符截取出一个字符串数组，字符串切割
	NSArray *newArr = [result componentsSeparatedByString:@"_"];
	NSLog(@"newArr = %@", newArr); // ewArr = (zhangsan, lisi, wangwu)

#### NSArray 文件读写

```
// 1. 将数组写入到文件中
NSArray *arr = @[@"zhangsan", @"lisi", @"wangwu"];
    
// 如果将一个数组写入文件中，本质是写入了一个 XML 文件，一般情况下，会将 XML 文件的扩展名保存为 plist，因为比较方便查看
bool flag = [arr writeToFile:@"/Users/chenliangjing/Desktop/temp.plist" atomically:YES];
NSLog(@"flag = %i", flag);
    
// 2. 从文件中读取一个数组
NSArray *getArr = [NSArray arrayWithContentsOfFile:@"/Users/chenliangjing/Desktop/temp.plist"];
NSLog(@"getArr = %@", getArr); // getArr = (zhangsan, lisi, wangwu)

```

>注意：writeToFile:只能写入数组中保存的元素都是 Foundation 框架中的类创建的对象，如果保存的是自定义对象，那么不能写入。


### 2. NSMutableArray
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSMutableArray)

#### NSMutableArray 介绍
- NSMutableArray 是 NSArray 的子类，是可变的数组，可以随时往里面增加，插入，删除，替换元素。

#### NSMutableArray 用法

```
// 1. 创建一个空数组
NSMutableArray *arrM = [NSMutableArray array];
NSLog(@"arrM = %@", arrM); // arrM = ( )
    
// 2. 添加元素
[arrM addObject:@"zhangsan"];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan)
// 从指定数组中取出元素添加到 arrM 中
[arrM addObjectsFromArray:@[@"lisi", @"wangwu"]];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, wangwu)
    
// 把指定数组当做 arrM 中的一个元素添加
[arrM addObject:@[@"lisi2", @"wangwu2"]];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, wangwu, (lisi2, wangwu2))
    
// 3. 插入元素
// 往指定位置插入新元素
[arrM insertObject:@"chenliangjing" atIndex:2];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, chenliangjing, wangwu, (lisi2, wangwu2))
    
// 插入一组数据，指定数组需要插入的位置，和要插入多少个元素
NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
[arrM insertObjects:@[@"A", @"B"] atIndexes:set];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, A, B, chenliangjing, wangwu, (lisi2, wangwu2))
    
// 4. 删除元素
// 删除最后一个元素
[arrM removeLastObject];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, A, B, chenliangjing, wangwu)
    
// 从指定位置删除元素
[arrM removeObjectAtIndex:4];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, A, B, wangwu)
    
// 从指定的范围删除一个数组
NSIndexSet *remSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
[arrM removeObjectsAtIndexes:remSet];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi, wangwu)
    
// 删除指定的元素
[arrM removeObject:@"wangwu"];
NSLog(@"arrM = %@", arrM); // arrM = (zhangsan, lisi)
    
// 删除所有元素
[arrM removeAllObjects];
NSLog(@"arrM = %@", arrM); // arrM = ( )
    
// 5. 替换元素
[arrM addObject:@"A"];
[arrM replaceObjectAtIndex:0 withObject:@"B"];
NSLog(@"arrM = %@", arrM); // // arrM = ( B )
    
// 6. 获取元素
NSString *element = [arrM objectAtIndex:0];
NSLog(@"element = %@", element); // element = B
    
// 7. 简易用法
// 获取
NSString *element2 = arrM[0];
NSLog(@"element2 = %@", element2); // element2 = B
    
// 替换
arrM[0] = @"C";
NSLog(@"arrM[0] = %@", arrM[0]); // arrM[0] = C
    
```

## 字典
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E5%AD%97%E5%85%B8)

### 1. NSDictionary
- 通过一个 key，能找到对应的 value
- NSDictionary 是不可变的，一旦初始化完毕，里面的内容就无法改变

#### 字典创建

```
// 1. 创建字典
// key 和 value 是一一对应的
NSDictionary *dic = [NSDictionary dictionaryWithObjects: @[@"chenliangjing", @"25"] forKeys: @[@"name", @"age"]];
NSString *name = [dic objectForKey:@"name"];
NSString *age = [dic objectForKey:@"age"];
NSLog(@"name = %@, age = %@", name, age); // name = chenliangjing, age = 25
    
// 简易创建（推荐使用）
NSDictionary *dic2 = @{@"name" : @"chenliangjing", @"age" : @25};
NSLog(@"dic2 = %@", dic2); // dic2 = { age = 25; name = chenliangjing; }

```

#### 字典遍历

	NSDictionary *dic = @{@"name" : @"chenliangjing", @"age" : @25, @"height" : @1.70};
	
	// 迭代器
	[dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
	    NSLog(@"key = %@, obj = %@", key, obj);
	}];


#### 字典文件读取

```
NSDictionary *dic = @{@"name" : @"chenliangjing", @"age" : @25, @"height" : @1.70};
    
// 1. 写入文件
BOOL flag = [dic writeToFile:@"/Users/chenliangjing/Desktop/test.plist" atomically:YES];
if (flag)
{
    NSLog(@"写入成功");
}
else
{
    NSLog(@"写入失败");
}
    
// 2. 从文件中读取
NSDictionary *newDic = [NSDictionary dictionaryWithContentsOfFile:@"/Users/chenliangjing/Desktop/test.plist"];
NSLog(@"newDic = %@", newDic); // newDic = {
    age = 25;
    height = "1.7";
    name = chenliangjing;
}
    
```

> 注意：字典和数组不一样，字典中保存的数据是无序的。


### 2. NSMutableDictionary

[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSMutableDictionary)

```
// 1. 创建一个空的字典
NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
NSLog(@"mDic = %@", mDic); // mDic = { }
    
// 2. 添加
[mDic setObject:@"chenliangjing" forKey:@"name"];
NSLog(@"mDic = %@", mDic); // mDic = { name = chenliangjing; }
    
// 将字典中所有的键值对全部取出来添加到 mDic 中去
[mDic setValuesForKeysWithDictionary:@{@"age" :  @25, @"height" : @1.70}];
NSLog(@"mDic = %@", mDic); // mDic = { age = 25; height = "1.7"; name = chenliangjing;}
    
// 3. 获取
NSString *name = mDic[@"name"]; // 推荐使用
NSLog(@"name = %@", name); // name = chenliangjing
NSNumber *height = [mDic objectForKey:@"height"];
NSLog(@"height = %@", height); // height = 1.7
    
// 4. 删除
// 通过 key 删除
[mDic removeObjectForKey:@"name"];
NSLog(@"mDic = %@", mDic); // mDic = { age = 25; height = "1.7"; }
    
// 通过一个 key 的数组删除
[mDic removeObjectsForKeys:@[@"height", @"age"]];
NSLog(@"mDic = %@", mDic); // mDic = { }

// 5. 修改
[mDic setObject:@"zhangsan" forKey:@"name"];
NSLog(@"mDic = %@", mDic); // mDic = { name = zhangsan;}
    
// 通过 setObject: 给同名的 key 赋值，就可以覆盖掉以前的旧值
[mDic setObject:@"lisi" forKey:@"name"];
NSLog(@"mDic = %@", mDic); // mDic = { name = lisi;}
    
// 通过字面量语法赋值
mDic[@"name"] = @"wangwu";
NSLog(@"mDic = %@", mDic); // mDic = { name = wangwu;}

```

> 1. 注意事项：不能使用 @{} 来创建一个可变字典
> 2. 注意事项：如果是不可变字典，那么 key 不能相同。如果是不可变字典出现了同名 key，那么后面的 key 对应的值不会被保存，如果可变数组出现了同名的 key，那么后面的值会覆盖掉前面的。


## NSNumber
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSNumber)

```
int age = 25;
float height = 1.70;
BOOL isMale = YES;
    
// 1. 将基本数据类型转换成对象类型
NSNumber *ageN = [NSNumber numberWithInt:age];
NSNumber *heightN = [NSNumber numberWithFloat:height];
NSNumber *maleN = [NSNumber numberWithBool:isMale];
NSLog(@"ageN = %@, heightN = %@, maleN = %@", ageN, heightN, maleN); //  ageN = 25, heightN = 1.7, maleN = 1
    
// 2. 将对象类型转换成基本数据类型
int ageT = [ageN intValue];
float heightT = [heightN floatValue];
BOOL isMaleT = [maleN boolValue];
NSLog(@"ageT = %d, heightT = %f, isMaleT = %i", ageT, heightT, isMaleT); // ageT = 25, heightT = 1.700000, isMaleT = 1
    
// 3 .基本数据类型转成对象类型简写(推荐使用)
NSNumber *intN = @29;
NSNumber *doubleN = @29.897;
NSNumber *boolN = @NO;
    
// 注意：如果传入的是变量，需要将变量用 () 包装起来，如果传入的是常量， () 可以省略
float temp = 24.89;
NSNumber *floatN = @(temp);
NSLog(@"intN = %@, doubleN = %@, boolN = %@, floatN = %@", intN, doubleN, boolN, floatN); // intN = 29, doubleN = 29.897, boolN = 0, floatN = 24.89

```

## NSValue
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSValue)

- NSNumber 是 NSValue 的子类，但 NSNumber 只包装数值类型
- NSValue 可以包装任意值
	- 因此，可以将结构体包装成 NSValue 类型后，加入到 NSArray/NSDictionary 中去


```
// 1. 包装常用结构体
CGPoint point = CGPointMake(10.0, 20.0);
NSValue *valueP = [NSValue valueWithPoint:point];
NSArray *arr = @[valueP];
NSLog(@"arr = %@", arr); // arr = ("NSPoint: {10, 20}")

    
// 2. 包装自定义结构体
typedef struct{
    int age;
    char *name;
    double _height;
}Person;
    
Person p = {25, "chenliangjing", 17.0};
// valueWithBytes: 接收一个指针，需要传递需要包装的结构体的变量的地址
// objCType: 需要传递需要包装的数据类型
NSValue *value = [NSValue valueWithBytes:&p objCType:@encode(Person)];
NSArray *arrV = @[value];
NSLog(@"arrV = %@", arrV); // rrV = ("<19000000 00000000 740f0000 01000000 00000000 00003140>")

    
// 从 value 中取出自定义的结构体变量
Person result;
[value getValue:&result];
NSLog(@"age = %d, name = %s, _height = %f", result.age, result.name, result._height); // age = 25, name = chenliangjing, _height = 17.000000

```


## NSDate
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSDate)


```
// 1. 创建
// date 方法创建的时期对象，对象中就保存了当前时间
NSDate *now = [NSDate date];
NSLog(@"now = %@", now);
    
// 在 now 的时间基础上追加多少秒
//    NSDate *date = [now dateByAddingTimeInterval:8 * 60 * 60];
//    NSLog(@"date = %@", date);
    
    
// 1.1 获取当前所处的时区
NSTimeZone *zone = [NSTimeZone systemTimeZone];
// 1.2 获取当前时区和指定时间的时间差
NSInteger seconds = [zone secondsFromGMTForDate:now];
NSDate *newDate = [now dateByAddingTimeInterval:seconds];
NSLog(@"newDate = %@", newDate);
    
    
// 2. 时间格式化
// 创建时间格式化对象
NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
// 指定时间的格式
//yyyy : 年
//MM : 月
//dd : 日
//HH : 时
//mm : 分
//ss : 秒
// Z : 时区
fmt.dateFormat = @"yyyy年MM月dd日 HH时mm分ss秒";
    
// 利用时间格式对象对时间进行格式化
NSString *result = [fmt stringFromDate:[NSDate date]];
NSLog(@"result = %@", result); //  result = 2017年04月26日 21时43分14秒
    
    
// 3. 字符串转成时间对象
NSString *str = @"2017年04月26日 21时43分14秒";
NSDateFormatter *farmat = [[NSDateFormatter alloc] init];
    
// 注意：str 的时间格式要和指定的 dateFormat 保持一致
farmat.dateFormat = @"yyyy年MM月dd日 HH时mm分ss秒";
NSDate *date = [farmat dateFromString:str];
NSLog(@"date = %@", date); //  date = 2017-04-26 13:43:14 +0000

```

## NSCalendar
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSCalendar)

```
// 获取当前时间
NSDate *now = [NSDate date];
NSLog(@"now = %@", now);
    
// 1. 日历
NSCalendar *calendar = [NSCalendar currentCalendar];
NSCalendarUnit type = NSCalendarUnitYear |
                        NSCalendarUnitMonth |
                        NSCalendarUnitDay |
                        NSCalendarUnitHour |
                        NSCalendarUnitMinute |
                        NSCalendarUnitSecond;
    
// 利用日历类从当前时间中获取单独的年、月，日，时，分，秒
NSDateComponents *cmps = [calendar components:type fromDate:now];
NSLog(@"year = %ld", cmps.year);
NSLog(@"month = %ld", cmps.month);
NSLog(@"day = %ld", cmps.day);
NSLog(@"hour = %ld", cmps.hour);
NSLog(@"minute = %ld", cmps.minute);
NSLog(@"second = %ld", cmps.second);
    
    
// 2. 比较两个时间之间的差值，比较相差多少年多少月多少日多少时多少分多少秒
// 2.1 过去的一个时间
NSString *str = @"2017年04月26日 21时43分14秒";
NSDateFormatter *farmat = [[NSDateFormatter alloc] init];
    
// 注意：str 的时间格式要和指定的 dateFormat 保持一致
farmat.dateFormat = @"yyyy年MM月dd日 HH时mm分ss秒";
NSDate *date = [farmat dateFromString:str];
NSLog(@"date = %@", date); //  date = 2017-04-26 13:43:14 +0000
    
// 2.2 现在的一个时间
NSDate *nowN = [NSDate date];
    
// 2.3 比较两个时间
NSCalendar *calendarN = [NSCalendar currentCalendar];
NSDateComponents *cmpsN = [calendarN components:type fromDate:date toDate:nowN options:0];
NSLog(@"年：%ld, 月：%ld, 日：%ld, 时：%ld, 分：%ld, 秒：%ld", cmpsN.year, cmpsN.month, cmpsN.day, cmpsN.hour, cmpsN.minute, cmpsN.second); // 年：0, 月：0, 日：0, 时：0, 分：40, 秒：59
    
```

## NSFileManager
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/NSFileManager)

### 1. NSFileManager 类是单例

```
// 1. NSFileManager 类是一个单例
NSFileManager *manager1 = [NSFileManager defaultManager];
NSFileManager *manager2 = [NSFileManager defaultManager];
NSLog(@"manager1 = %p, manager2 = %p", manager1, manager2); // manager1 = 0x100205710, manager2 = 0x100205710 地址一样

```

### 2. 判断一个文件或者一个文件夹是否存在

```
BOOL dirExist = [manager1 fileExistsAtPath:@"/Users/chenliangjing"];
NSLog(@"dirExist = %i", dirExist); // dirExist = 1 ,文件夹存在
    
BOOL fileExist = [manager1 fileExistsAtPath:@"/Users/chenliangjing/Desktop/test.plist"];
NSLog(@"fileExist = %i", fileExist); // fileExist = 0 ,文件不存在

```

### 3. 判断一个文件是否存在，并且判断它是否是一个文件夹

```
    BOOL dir = NO;
    // 返回值表示为：传入路径对应的文件或者文件夹是否存在
    // isDirectory：由于保存判断结果，如果是一个目录，那么就会给 dir 赋值为 YES，如果不是就赋值 NO
    BOOL flag = [manager1 fileExistsAtPath:@"/Users/chenliangjing/Desktop/test.plist" isDirectory:&dir];
    NSLog(@"flag = %i, dir = %i", flag, dir); // flag = 1, dir = 0，文件存在，但不是一个文件夹

```

### 4. 获取文件或者文件夹的属性

```
// 获取文件或者文件夹的属性
NSFileManager *manager = [NSFileManager defaultManager];
NSDictionary *info = [manager attributesOfItemAtPath:@"/Users/chenliangjing/Desktop/TempDir" error:nil];
NSLog(@"info = %@", info);

```


### 5. 获取文件夹下所有的文件

```
// 创建文件管理对象
NSFileManager *manager = [NSFileManager defaultManager];
    
// 1. 不包括子文件夹下面的文件
// 注意：contentsOfDirectoryAtPath:方法只能获取当前文件下面的资源，而不能获取子文件夹下面的资源
NSArray *contentArr = [manager contentsOfDirectoryAtPath:@"/Users/chenliangjing/Desktop/TempDir" error:nil];
NSLog(@"contentArr = %@", contentArr);
    
// 2. 包括子文件夹下面的所有文件
//    NSArray *contentAllArr = [manager1 subpathsAtPath: @"/Users/chenliangjing/Desktop/TempDir"];
NSError *error = nil;
NSArray *contentAllArr = [manager subpathsOfDirectoryAtPath: @"/Users/chenliangjing/Desktop/TempDir"error:&error];
if (error)
{
    NSLog(@"error = %@", error);
}
else
{
    NSLog(@"contentAllArr = %@", contentAllArr);
}

```

### 6. 创建文件夹

```
// 创建文件夹
NSFileManager *manager = [NSFileManager defaultManager];
    
// DirectoryAtPath: 文件夹创建的位置
// withIntermediateDirectories: 如果指定的文件夹中有一些文件夹不存在，是否自动创建不存在的文件夹
// attributes: 指定创建出来的文件夹的属性
// error: 是否创建成功，如果失败会给传入的参数赋值
// 注意：该方法只能创建文件夹，不能用来创建文件
[manager createDirectoryAtPath:@"/Users/chenliangjing/Desktop/chenlj" withIntermediateDirectories:YES attributes:nil error:nil];

```


### 7. 创建文件

```
// 创建文件
NSFileManager *manager = [NSFileManager defaultManager];
    
// 创建二进制数据
NSString *contentStr = @"chenliangjing";
NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    
// createFileAtPath: 指定文件创建出来的位置
// contents: 文件中的内容
// attributes: 创建处理文件的属性
// 该方法只能创建文件，不能用来创建文件夹
BOOL flag = [manager createFileAtPath:@"/Users/chenliangjing/Desktop/TempDir/chenlj.txt" contents:data attributes:nil];
if (flag)
{
    NSLog(@"创建成功");
    NSString *content = [NSString stringWithContentsOfFile: @"/Users/chenliangjing/Desktop/TempDir/chenlj.txt" encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"content = %@", content); // content = chenliangjing
}
else
{
    NSLog(@"创建失败");
}

```

## 常用结构体
[源代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E5%B8%B8%E7%94%A8%E7%BB%93%E6%9E%84%E4%BD%93)

```
typedef CGPoint NSPoint;

typedef CGSize NSSize;

typedef CGRect NSRect;

```

- NSPoint 等于 CGPoint
- NSSize 等于 CGSize
- NSRect 等于 CGRect


```
// 保存坐标
CGPoint point = CGPointMake(10.0, 20.0);
    
// 保存尺寸
CGSize size = CGSizeMake(100.0, 100.0);
    
// 保存坐标和尺寸
CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
NSLog(@"rect = %@", NSStringFromRect(rect)); // rect = {{10, 20}, {100, 100}}

```
