---
title: runtime 学习
date: 2017-05-10 07:59:00
tags:
- iOS
- runtime
categories: iOS
---

## runtime 简介


## 消息机制
OC 方法的底层实现就是`消息机制`。

**方法调用流程：**

1. 通过 `isa` 指针找到对应的`类对象`或者`元类对象`（`实例方法`保存在`类对象`中，`类方法`保存在`元类对象`中）
2. 通过方法名注册`方法编号`
3. 根据`方法编号`查找对应的方法
4. 找到最终函数实现地址，根据地址去`内存方法区`找到对应的函数

**内存 5 大区**
<!-- more -->
1. 栈
2. 堆
3. 静态区
4. 常量区
5. 方法区

**消息机制原理**:对象根据方法编号 `SEL` 去`映射表`查找对应的`方法实现`


```
// 1. 获取一个类对象
id cls = objc_getClass("Person");
    
// 2. 注册方法编号
SEL alloc = sel_registerName("alloc");
    
// 3. 给类对象发送消息
// 参数一：消息接受者
// 参数二：消息的实现方法
// 参数三：方法的参数
Person *p = objc_msgSend(cls, alloc);
    
// 4. 给实例对象发送消息
// 4.1. 注册方法编号
SEL init = sel_registerName("init");
p = objc_msgSend(p, init);

```

![](http://liangjinggege.com/Snip20170510_2.png)

>注意：1. 导入头文件 `<objc/message.h>`
>
>注意：2. ![](http://liangjinggege.com/Snip20170510_1.png)

## 获取方法

```
// 1. 获取实例方法
// 参数一：类对象
// 参数二：方法名
//    class_getInstanceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>)
    
// 2. 获取类方法
Method oldMethod = class_getClassMethod([NSURL class], sel_registerName("URLWithString:"));

Method currentMethod = class_getClassMethod([NSURL class], @selector(clj_urlWithString:));

```

## 交换方法实现
系统自带的方法功能不够，给系统自带的方法扩展一些功能，并且保持原有的功能。

通过交换方法的实现，去拦截监系统方法。比如拦截 NSURL 类的 `URLWithString：`类方法，判断 url 是否存在。只需要添加一个分类，在类的 `load` 中和自己写的自定义方法交换。

```
// 1. 获取类方法
Method oldMethod = class_getClassMethod([NSURL class], sel_registerName("URLWithString:"));
Method currentMethod = class_getClassMethod([NSURL class], @selector(clj_urlWithString:));
    
// 2. 交换两个方法的实现
method_exchangeImplementations(oldMethod, currentMethod);

```

![](http://liangjinggege.com/Snip20170510_3.png)

## 动态添加方法
如果一个给一个对象发送一条没有实现的消息，那么应用程序将会崩溃，利用 runtime 可以给对象`动态的添加方法`。

如果一个类方法非常多，加载类到内存的时候也比较耗费资源，需要给每个方法生成映射表，可以使用 runtime 动态给某个类，添加方法解决。

![](http://liangjinggege.com/Snip20170510_4.png)


>注意：`class_addMethod(Class cls, SEL name, IMP imp, const char *types)` 方法最后一个参数 types 的字符对应可参照[这里](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100)。

## 给类添加关联对象

```
// 1. 存
// 参数一：要关联的源对象
// 参数二：key 键值
// 参数三：关联对象
// 参数四：关联对象值得内存管理策略
objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)

// 2. 取
objc_getAssociatedObject(id object, const void *key)

```

**应用场景：**给系统类动态添加属性

```
- (void)setButtonClickBlock:(void (^)(UIBarButtonItem *))buttonClickBlock
{
    objc_setAssociatedObject(self, @selector(buttonClickBlock), buttonClickBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIBarButtonItem *))buttonClickBlock
{
    return objc_getAssociatedObject(self, @selector(buttonClickBlock));
}

```

## 获取类中的所有成员属性

```
// 参数一：从哪个类中获取
// 参数二：这个类有多少成员属性，传入一个无符号 int，会自动给这个变量赋值
// 返回值：Ivar *，表示一个 Ivar 数组，会把所有成员属性放在一个数组中，通过返回的数组就能全部获取到
unsigned int count;
Ivar *ivarList = class_copyIvarList([obj class], &count);
    
for (int i = 0; i < count; i++)
{
    // 根据下标获取对应的成员属性
    Ivar ivar = ivarList[i];
    
    // 获取成员属性名
    NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
    // 获取成员属性类型
    NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
}

```

## 定义一个类

```
// 定义一个类
// 第一个参数：继承自哪个类
// 第二个参数：类的名称
// 第三个参数：
Class cls = objc_allocateClassPair([self class], newClassName, 0);

// 注册新类
objc_registerClassPair(cls);

```

## 修改 isa 指针

```
// 
object_setClass(self, cls);

```


## 自动生成属性代码

```
+ (void)resolveDict:(NSDictionary *)dict
{
    // 拼接属性定义
    NSMutableString *strM = [NSMutableString string];
    
    // 遍历字典
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 记录数据类型
        NSString *type;
        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")])
        {
            type = @"NSString";
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")])
        {
            type = @"NSArray";
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")])
        {
            type = @"BOOL";
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")])
        {
            type = @"NSNumber";
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionary")])
        {
            type = @"NSDictionary";
        }
        
        // 属性字符串
        NSString *property;
        if ([type containsString:@"NS"])
        {
            if ([type isEqualToString:@"NSString"])
            {
                property = [NSString stringWithFormat:@"@property(nonatomic, copy) %@ *%@;", type, key];
            }
            else
            {
                property = [NSString stringWithFormat:@"@property(nonatomic, strong) %@ *%@;", type, key];
            }
        }
        else
        {
            property = [NSString stringWithFormat:@"@property(nonatomic, assign) %@ %@;", type, key];
        }
        
        [strM appendFormat:@"\n%@\n", property];
    }];
    
    NSLog(@"%@", strM);
}

```

**调用:**

```
NSString *path = [[NSBundle mainBundle] pathForResource:@"status.plist" ofType:nil];
NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
NSDictionary *dic = [dict[@"statuses"] firstObject];
    
[StatusModel resolveDict:dic];

```

**打印：**

![](http://liangjinggege.com/Snip20170510_7.png)

>扩展：进一步的话，可以考虑写一个自动生成模型属性的小工具，通过后台返回的 JSON 等数据格式转化为模型属性，并直接写入到模型 .h 文件中，自动对应数据类型，内存管理策略，以及添加注释。

## KVO 底层实现
KVO 监听对象属性的变化其实是监听对象属性的 `Setter` 方法。

内部是通过 runtime 动态的添加一个一个类，继承自监听的对象，然后通过 runtime 重写了属性的 setter 方法，通过监听对象属性的 setter 方法实现。

```
#import "NSObject+KVO.h"
#import <objc/message.h>

static NSString *const kObserver = @"kObserver";

@implementation NSObject (KVO)


- (void)clj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    // 1. 自定义一个继承自观察对象的子类CLJ_KVO_Object
    // 1.1. 动态生成一个类
    NSString *oldClassName = NSStringFromClass([self class]);
    const char *newClassName = [[@"CLJ_KVO_" stringByAppendingString:oldClassName] UTF8String];
    
    // 定义一个类
    // 第一个参数：继承自那个类
    // 第二个参数：类的名称
    // 第三个参数：
    Class cls = objc_allocateClassPair([self class], newClassName, 0);
    
    // 注册新类
    objc_registerClassPair(cls);
    
    
    // 2. 重写被观察属性的 setter 方法，在内部恢复父类的做法，通知观察者
    // 添加setter方法
    class_addMethod(cls, @selector(setName:), (IMP)setName, "v@:@");
    
    // 3. 修改 self 的 isa 指针，指向子类对象
    object_setClass(self, cls);
    
    // 4. 将观察者保存到当前对象
    // 参数一：要关联的源对象
    // 参数二：key 键值
    // 参数三：关联对象
    // 参数四：关联对象值得内存管理策略
    objc_setAssociatedObject(self, &kObserver, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void setName(id self, SEL _cmd, NSString *newName)
{
    NSLog(@"newName = %@", newName);
    
    // 保存当前类型
    id class = [self class];
    
    // 改变 isa 指针
    object_setClass(self, class_getSuperclass(class));
    
    // 调用父类的 set 方法，设置新值
    objc_msgSend(self, @selector(setName:), newName);
    
    
    // 取出观察者对象
    id observer = objc_getAssociatedObject(self, &kObserver);
    
    // 通知观察者
    objc_msgSend(observer, @selector(observeValueForKeyPath:ofObject:change:context:), @"name", self, nil, nil);
    
    // 返回子类类型
    object_setClass(self, class);
}

```

调用

```
#import "ViewController.h"
#import "Person.h"
#import "NSObject+KVO.h"

@interface ViewController ()

@property(nonatomic, strong) Person *p;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    Person *p = [[Person alloc] init];
    
//    [p addObserver:self forKeyPath:@"_name" options:NSKeyValueObservingOptionNew context:nil];
    
    [p clj_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    
    _p = p;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"对象%@的%@被改变为%@", object, keyPath, change);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _p.name = @"chenliangjing";
}

```

打印：

![](http://liangjinggege.com/Snip20170510_7.png)


## 字典转模型

### 1. KVC 实现
* KVC 字典转模型弊端：
	* 必须保证，模型中的属性和字典中的key一一对应。
	* 如果不一致，就会调用`[<Status 0x7fa74b545d60> setValue:forUndefinedKey:]`
报`key`找不到的错。	
	*  解决:重写对象的`setValue:forUndefinedKey:`,把系统的方法覆盖，
就能继续使用KVC，字典转模型了。

```

+ (instancetype)statusWithDict:(NSDictionary *)dict
{
    StatusModel *model = [[StatusModel alloc] init];
    
    [model setValuesForKeysWithDictionary:dict];
    
    return model;
}

// 重写该方法，如果找不到 key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // 让 “idstr” 这个 key 的 value 设置给 “idst” 属性
    if ([key isEqualToString:@"idstr"])
    {
        [self setValue:value forKey:@"idst"];
    }
}

```

**调用和打印：**

![](http://liangjinggege.com/Snip20170510_8.png)


### 2.runtime 实现
* **思路：**利用`运行时`，遍历模型中`所有属性`，根据模型的属性名，去字典中查找 key，取出对应的值，给模型的属性赋值。

* **步骤：**提供一个 NSObject 分类，专门字典转模型，以后所有模型都可以通过这个分类转。 

**.h 文件**

```
#import <Foundation/Foundation.h>

@protocol ModelDelegate <NSObject>

@optional
// 提供一个协议，只要遵守这个协议的类，都能把数组中的字典转模型
// 用在三级数组转换
+ (NSDictionary *)arrayContainModelClass;

@end

@interface NSObject (PropertyRuntime)

/// 字典转模型
+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

```

**.m 文件**

```
#import "NSObject+PropertyRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyRuntime)

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    // 1. 遍历model所有的属性列表
    
    // 1.1. 创建对应的对象
    id obj = [[self alloc] init];
    
    // 获取类中的所有成员属性
    // 参数一：从哪个类中获取
    // 参数二：这个类有多少成员属性，传入一个无符号 int，会自动给这个变量赋值
    // 返回值：Ivar *，表示一个 Ivar 数组，会把所有成员属性放在一个数组中，通过返回的数组就能全部获取到
    unsigned int count;
    Ivar *ivarList = class_copyIvarList([obj class], &count);
    
    for (int i = 0; i < count; i++)
    {
        // 根据下标获取对应的成员属性
        Ivar ivar = ivarList[i];
        
        // 获取成员属性名
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 从第 1 个下标开始截取
        NSString *key = [ivarName substringFromIndex:1];
        
        // 根据成员属性名去字典中查找对应的value
        id value = dict[key];
        
        // 获取成员属性类型
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        // 去掉转义字符。生成的是这种@"@\"User\"" 类型 -》 @"User"  在OC字符串中 \" -> "，\是转义的意思，不占用字符
        type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        type = [type stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        // 二级转换：如果字典中还有字典，也需要把对应的字典转换成模型
        // 数据是字典类型以及是自定义数据类型才需要再做一层字典转模型
        if ([value isKindOfClass: [NSDictionary class]] && ![type hasPrefix:@"NS"])
        {
            // 继续字典转模型
            // 根据字符串类名生成类对象
            Class modelCalss = NSClassFromString(type);
            
            // 有对应模型才需要转
            if (modelCalss)
            {
                value = [modelCalss modelWithDict:value];
            }
        }
        
        // 三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        if ([value isKindOfClass:[NSArray class]])
        {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)])
            {
                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;
                
                // 获取数组中对应字典的模型
                NSString *modelType = [idSelf arrayContainModelClass][key];
                
                // 生成模型
                Class modelClass = NSClassFromString(modelType);
                
                if (modelClass)
                {
                    NSMutableArray *arrM = [NSMutableArray array];
                    for (NSDictionary *dict in value)
                    {
                        id model = [modelClass modelWithDict:dict];
                        [arrM addObject:model];
                    }
                    
                    value = arrM;
                }
            }
        }
        
        // 给模型中的属性赋值
        if (value)
        {
            [obj setValue:value forKey:key];
        }
        
    }
    
    return obj;
}

```

**带有数组字典的模型中实现`字典数组转模型数组`的协议**

```
+ (NSDictionary *)arrayContainModelClass
{
    return @{@"pic_urls" : @"PictureModel"};
}

```

**调用：**

![](http://liangjinggege.com/Snip20170510_9.png)