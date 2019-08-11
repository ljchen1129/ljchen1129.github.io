---
title: KVC & KVO 学习
date: 2017-05-11 11:11:09
tags:
- iOS
- KVC
- KVO
categories: iOS
---

## KVC
KVC：Key-value coding）键值编码。通过 key 值，来获取对象的属性，而不是通过明确地存取方法来获取。（通过一系列的方法和规则）

苹果系统通过给 NSObject 类添加一个 NSKeyValueCoding 分类来实现了 KVC，所以对于所有继承了 NSObject 的类都能使用 KVC，KVC 的使用主要是下面四个方法：

```
// 通过 key 来取值
- (nullable id)valueForKey:(NSString *)key;
// 通过 key 来设置
- (void)setValue:(nullable id)value forKey:(NSString *)key;

// 通过 keyPath 来取值
- (nullable id)valueForKeyPath:(NSString *)keyPath;
// 通过 keyPath 来设置
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;

```

**其他的一些方法：**
<!-- more -->
```
// 默认返回 YES，表示如果没有找到 Set<Key> 方法的话，会按照 _key，_iskey，key，iskey 的顺序搜索成员变量，设置成 NO 就不这样搜索
+ (BOOL)accessInstanceVariablesDirectly;

// KVC 提供属性值确认的 API，它可以用来检查 set 的值是否正确、为不正确的值做一个替换值或者拒绝设置新值并返回错误原因。
- (BOOL)validateValue:(inout id __nullable * __nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;

// 这是集合操作的 API，里面还有一系列这样的 API，如果属性是一个 NSMutableArray，那么可以用这个方法来返回
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;

// 如果 Key 不存在，且没有 KVC 无法搜索到任何和 Key 有关的字段或者属性，则会调用这个方法，默认是抛出异常
- (nullable id)valueForUndefinedKey:(NSString *)key;

// 和上一个方法一样，只不过是设值
- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;

// 如果在 SetValue 方法时面给 Value 传 nil，则会调用这个方法
- (void)setNilValueForKey:(NSString *)key;

// 输入一组 key,返回该组 key 对应的 Value，再转成字典返回，用于将 Model 转到字典。
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;

```

### valueForKey:

* 第一，判断是否有无 getter 方法，如果有，依次按照（NSString 类型查找方式）找 getKey> -> key -> isKey 的 getter 方法查找（属性也是通过存取方法来查找的，属性在编译时默认生成了 getter 方法和 setter 方法的代码）。其中，如果是 BOOL 或者 int 等值类型， 会做 NSNumber 类型转换。

	![](https://liangjinggege.com/Snip20170512_4.png?imageView/0/h/250)
	
* 第二，如果没有找到，继续按照`数组类型`规则查找方式，查找 countOf<Key>、objectIn<Key>Atindex、<Key>AtIndexes 格式的方法。如果 countOf<Key> 和另外两个方法中的一个找到，那么就会返回一个可以响应 NSArray 所有方法的代理集合的 NSArray 消息方法。

	```
	// countOf<Key> 方法
	- (NSUInteger)countOfName
	{
	    return 2;
	}
	
	//// objectIn<Key>AtIndex 方法
	//- (id)objectInNameAtIndex:(NSUInteger)index
	//{
	//    if (0 == index)
	//    {
	//        return @"zhangsan";
	//    }
	//    else
	//    {
	//        return @"lisi";
	//    }
	//}
	
	// <Key>AtIndexes 方法
	- (NSArray *)nameAtIndexes:(NSIndexSet *)indexes
	{
	    NSMutableArray *array = [NSMutableArray array];
	    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
	        if (idx == 0)
	        {
	            [array addObject:@"zhangsan"];
	        }
	        else
	        {
	            [array addObject:@"chenliangjing"];
	        }
	    }];
	    
	    return array;
	}
	
	```

**打印结果：**

![](https://liangjinggege.com/Snip20170514_1.png?imageView/0/h/250)
	
* 第三，还没找到，继续按照`集合类型`规则查找方式，查找 countOf<Key>、enumeratorOf<Key>、memberOf<Key> 格式的方法。如果这三个方法都找到，那么就返回一个可以响应 `NSSet` 所有方法的代理集合。
	
	
	
* 第四，判断是否实现了 `+ (BOOL)accessInstanceVariablesDirectly` 这个方法，这个方法默认是 YES，如果返回 YES，那么就按照 `_key -> _isKey -> key -> isKey` 的顺序查找`对应实例变量`的值并返回，如果该方法返回 NO，那么继续往下一个规则查找。
	
	![](https://liangjinggege.com/Snip20170512_7.png?imageView/0/h/140)
	
* 第五，如果以上都没有找到对应的 key，那么会调用 `- (id)valueForUndefinedKey:(NSString *)key` 方法，做`异常处理`.

	![](https://liangjinggege.com/Snip20170512_5.png?imageView/0/h/180)
	
* 第六，如果没有实现第四步中的方法，那么应用程序会崩溃。

	![](https://liangjinggege.com/Snip20170512_9.png?imageView/0/h/150)
	

### setValue:forKey:
* 第一，查找 `setter` 方法，判断有无相应的 `- (void)set<key>:(NSString *)<key>` setter 方法，如果有，则通过 setter 方法来设置值。（属性也是通过 setter 默认生成的 setter 方法来设置值的）。其中 `- (void)set<key>:(NSString *)<key>` 优先级大于 `- (void)set<isKey>:(NSString *)<iskey>`。
	
	![](https://liangjinggege.com/Snip20170512_10.png?imageView/0/h/270)
	
* 第二，如果没有找到相应的 setter 方法，那么再判断 `+ (BOOL)accessInstanceVariablesDirectly` 是否实现，默认返回 YES，如果返回 YES，那么去查找实例变量，依次按照 `_key -> _isKey -> key -> isKey` 的顺序查找设置值。如果返回 NO 或者实例对应的实例变量没有找到，那么继续走下一个步骤。
	
	![](https://liangjinggege.com/Snip20170512_11.png?imageView/0/h/200)
	
* 第三，如果以上步骤都没有设置值成功，那么会调用 `- (void)setValue:(id)value forUndefinedKey:(NSString *)key ` 方法，进行异常处理，

	![](https://liangjinggege.com/Snip20170512_12.png?imageView/0/h/300)
	
* 第四，如果没有实现第三步中的方法，那么应用程序将会崩溃.

	![](https://liangjinggege.com/Snip20170512_13.png?imageView/0/h/170)


### setValue:forKeyPath:

通过 keyPath 路径搜索值，当成员属性是自定义类型时，可以通过搜索 keyPath 路径的方法去查找自定义的成员属性的成员属性。

搜索机制：用过小数点来分离 key，然后再按照 KVC 搜索 key 方式的机制按顺序搜索下去。

```
_p = [Person new];
    
// 1. 人的名字
id name = [_p valueForKeyPath:@"name"];
    
// 2. 狗的生日，包括年月日
id dogBirthday = [_p valueForKeyPath:@"dog.birthday"];
NSValue *value = (NSValue *)dogBirthday;
    
// 从 value 中取出结构体变量
DogBirthday birthday;
[value getValue:&birthday];
    
// 3. 狗的身高
id dogHeight = [_p valueForKeyPath:@"dog.height"];
    
// 4. 狗要吃的食物名称
id dogFoodName = [_p valueForKeyPath:@"dog.food.foodName"];
    
// 打印人名/数据类型
NSLog(@"name = %@ %@", name, [name class]); // name = chenliangjing __NSCFConstantString
    
// 打印狗的生日/数据类型
NSLog(@"dogBirthday = %@ %@", dogBirthday, [dogBirthday class]); // dogBirthday = <e1070000 00000000 05000000 00000000 0f000000 00000000> NSConcreteValue
// 打印狗的生日(年、月、日)
NSLog(@"year = %lu mouth = %lu day = %lu", birthday.year, birthday.mouth, birthday.day); // year = 2017 mouth = 5 day = 15
// 打印狗的身高/数据类型
NSLog(@"dogHeight = %@ %@", dogHeight, [dogHeight class]); // dogHeight = 1.3 __NSCFNumber
// 打印狗的事物名称/数据类型
NSLog(@"dogFoodName = %@ %@", dogFoodName, [dogFoodName class]); // dogFoodName = 狗粮 __NSCFConstantString

```

* 对于结构体类型的属性，KVC 会包装成 NSValue 类型的。如果需要转为结构体，需要用到 NSValue 的对象方法 `getValue:`。
* 对于其他非 OC 对象类型，如：CGFloat/int/BOOL/double 等，KVC 会将这些类型转化为 NSNumber。
* keyPath 通过 `key.key.key...`这样的形式，可以读写更深层次的属性。

### KVC 对集合类型的操作
`集合运算符（Collection Operators）`是一个特殊的 `Key Path`，可以作为`参数`传递给 `valueForKeyPath：`方法。

运算符是一个以@开头的特殊字符串，格式如下图所示：

![](https://liangjinggege.com/keypath.jpg)

**集合操作符分为三种：**

1. 简单的集合操作: 返回 NSString(可以使用 @count，@max，@min，@sum 四种)、NSNumber（全部可以使用）、NSDate（可以使用 @count，@max，@min 三种）.
	- 简单集合运算符共有 @avg，@count，@max，@min，@sum 5 种。除了 `@count`，其他都需要有右边的 keyPath(一般为属性名)。
	
	**#如果数组或者集合的元素由 NSNumber 类型组成，可以使用 `@keyPath.self `的方式来操作集合**
	![](https://liangjinggege.com/Snip20170518_1.png)
	
	**#如果数组或者集合的元素由对象类型组成**
	![](https://liangjinggege.com/Snip20170518_2.png)
		
2. 对象操作符返回: NSArray.
	- @distinctUnionOfObjects: 返回一个由操作符右边的 `key path` 所指定的对象属性组成的数组，不对数组去重
	
	- @unionOfObjects: 返回一个由操作符右边的 `key path` 所指定的对象属性组成的数组，并对数组去重
	
	![](https://liangjinggege.com/Snip20170518_3.png)
	
3. 数组或集合操作符: 返回 NSArray、NSSet.
	- @distinctUnionOfArrays 和 @unionOfArrays: 返回 NSArray，distinct 版本会对数组取重。
	
	![](https://liangjinggege.com/Snip20170518_4.png)
	
	- @distinctUnionOfSets: 返回一个 NSSet 对象，因为 Sets 中的元素本身就是唯一的，所以没有对应的 @unionOfSets 运算符。

### 键值验证（Key-Value Validation）
KVC 提供了属性值，用来验证 key/keyPath 对应的 Value 是否可用的方法。

```
- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError;

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable __autoreleasing *)outError;

```

![](https://liangjinggege.com/Snip20170518_8.png)

**重写方法：**

```
- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError
{
    NSString *value = *ioValue;
    if ([inKey isEqualToString:@"name"] && [value isEqualToString:@"chenliangjing"])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

```

### KVC 异常处理
如果不小心使用了错误的 Key，或者在设值中不小心传递了 nil 的，就要进行异常处理，保证程序运行的稳定。

如果给一个`非对象属性`设置了一个 nil 值，会调用 `setNilValueForKey:` 这个方法，只需要重写这个方法即可

![](https://liangjinggege.com/Snip20170518_5.png)


### KVC 和字典

![](https://liangjinggege.com/Snip20170518_6.png)

### KVC 实现原理	
**实现代码:**

```
// .h 声明
#import <Foundation/Foundation.h>

@interface NSObject (KVCImplecation)

// 设置值
- (void)clj_setValue:(id)value forKey:(NSString *)key;
// 取值
- (id)clj_valueForKey:(NSString *)key;

// 是否从成员变量获取
+ (BOOL)clj_accessInstanceVariablesDirectly;

// 设置值异常处理：找不到key
- (void)clj_setValue:(id)value forUndefinedKey:(NSString *)key;
// 取值异常处理：找不到key
- (id)clj_valueForUndefinedKey:(NSString *)key;

// 处理value 为 nil 的情况
- (void)clj_setNilValueForKey:(NSString *)key;

@end


// .m 实现
#import "NSObject+KVCImplecation.h"
#import <objc/runtime.h>

@implementation NSObject (KVCImplecation)

- (void)clj_setValue:(id)value forKey:(NSString *)key
{
    // 1. 判断 key 是否异常
    if (key == nil || key.length == 0)
    {
        return;
    }
    
    // 2. 对非对象类型判断 value 是否为 nil
    if ([value isKindOfClass:[NSNull class]])
    {
        [self clj_setNilValueForKey:key]; //
        return;
    }

    // 3. 判断是否为对象类型
    if (![value isKindOfClass:[NSObject class]])
    {
        //
        @throw @"must be NSObject Type";
        return;
    }

    // 4. 判断是否实现了 setter (set<Key> -> setIs<key>)方法，如果有 setter 方法，那么直接执行 setter 方法
    NSString *funcName1 = [NSString stringWithFormat:@"set%@", key.capitalizedString];
    SEL sel1 = NSSelectorFromString(funcName1);
    if ([self respondsToSelector:sel1])
    {
        [self performSelector:sel1 withObject:value];
        return;
    }

    NSString *funcName2 = [NSString stringWithFormat:@"setIs%@", key.capitalizedString];
    SEL sel2 = NSSelectorFromString(funcName2);
    if ([self respondsToSelector:sel2])
    {
        [self performSelector:sel2 withObject:value];
        return;
    }
    
    // 5. 判断是否允许访问成员变量
    if ([[self class] clj_accessInstanceVariablesDirectly])
    {
        // 访问成员变量（_key -> _isKey -> key -> isKey）
        unsigned int count;
        Ivar* ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++)
        {
            Ivar ivar = ivars[i];
            NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            NSString *keyName = ivarName;
            BOOL findKeySuccessed = NO;
            
            // 5.1 先找 _key 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"_%@", key]])
            {   
                // 给成员变量设置值
                object_setIvar(self, ivar, value);
                findKeySuccessed = YES;
                break;
            }
            
            // 5.2. 找 _isKey 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"_is%@", key.capitalizedString]])
            {
                object_setIvar(self, ivar, value);
                findKeySuccessed = YES;
                break;
            }
            
            // 5.3 找 key 的成员变量
            if ([keyName isEqualToString:key])
            {
                object_setIvar(self, ivar, value);
                findKeySuccessed = YES;
                break;
            }
            
            // 5.4. 找 isKey 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"is%@", key.capitalizedString]])
            {
                NSLog(@"isKey = %@", [NSString stringWithFormat:@"is%@", key.capitalizedString]);
                findKeySuccessed = YES;
                break;
            }
            
            // 5.5. 如果还是没有找到相关的成员变量
            if (!findKeySuccessed)
            {
                [self clj_setValue:value forUndefinedKey:key];
            }

        }
    }
    else
    {
        [self clj_setValue:value forUndefinedKey:key];
    }
}

- (id)clj_valueForKey:(NSString *)key
{
    // 1. 判断 key 是否为空
    if (key == nil || key.length == 0)
    {
        return nil;
    }
    
    // 2. 判断是否存在相应的 getter 方法（getKey> -> key -> isKey）
    NSString *funcName1 = [NSString stringWithFormat:@"get%@", key.capitalizedString];
    SEL sel1 = NSSelectorFromString(funcName1);
    if ([self respondsToSelector:sel1])
    {
        return [self performSelector:sel1];
    }
    
    SEL sel2 = NSSelectorFromString(key);
    if ([self respondsToSelector:sel2])
    {
        return [self performSelector:sel2];
    }

    NSString *funcName3 = [NSString stringWithFormat:@"is%@", key.capitalizedString];
    SEL sel3 = NSSelectorFromString(funcName1);
    if ([self respondsToSelector:sel3])
    {
        return [self performSelector:sel3];
    }
    
    // 3. 判断是否允许访问成员变量
    if ([[self class] clj_accessInstanceVariablesDirectly])
    {
        // 4. 访问成员变量（_key -> _isKey -> key -> isKey）
        unsigned int count;
        Ivar* ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i ++)
        {
            Ivar ivar = ivars[i];
            NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            NSString *keyName = ivarName;
            BOOL findKeySuccessed = NO;
            
            // 4.1. 先找 _key 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"_%@", key]])
            {
                findKeySuccessed = YES;
                return object_getIvar(self, ivar);
                break;
            }
            
            // 4.2. 找 _isKey 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"_is%@", key.capitalizedString]])
            {
                findKeySuccessed = YES;
                return object_getIvar(self, ivar);
                break;
            }

            // 4.3. 找 key 成员变量
            if ([keyName isEqualToString:key])
            {
                findKeySuccessed = YES;
                return object_getIvar(self, ivar);
                break;
            }

            // 4.4. 找 isKey 成员变量
            if ([keyName isEqualToString:[NSString stringWithFormat:@"is%@", key.capitalizedString]])
            {
                findKeySuccessed = YES;
                return object_getIvar(self, ivar);
                break;
            }
            
            if (!findKeySuccessed)
            {
                [self clj_valueForUndefinedKey:key];
            }
        }
        
    }
    else
    {
        [self clj_valueForUndefinedKey:key];
    }

    return nil;
}

+ (BOOL)clj_accessInstanceVariablesDirectly
{
    NSLog(@"category");
    return YES;
}

@end

```

**调用：**

![](https://liangjinggege.com/Snip20170518_9.png)

### 应用场景
1. 动态地取值和设值
2. 访问和修改私有变量
3. 字典模型装换
4. 修改控件的内部属性
5. 操作集合
6. 高阶消息传递
7. KVO

### KVC Demo


## KVO
### 1. KVO 基本用法

**添加观察者：**

```
_p = [Person new];

// 第一个参数 Observer：观察者
// 第二个参数 KeyPath：观察的属性（字符串键）
// 第三个参数 options：观察的选项
// 第四个参数：context：上下文     
[_p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];

```

**监听回调方法：**

```
// 方法功能：监听回调
// 第一个参数 KeyPath：观察的属性（字符串键）
// 第二个参数 Object：观察的对象
// 第三个参数 change：<字典> 观察的属性值变化信息
// 第四个参数 context：上下文
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"object = %@ keyPath = %@ change = %@", object, keyPath, change);
}

```

**移除观察者：**

```
- (void)dealloc
{
    [_p removeObserver:self forKeyPath:@"name"];
}

```

### 2. 属性依赖

```
// 属性依赖。一旦监听到 lComponent 值发生变化，就相当于属性 redComponent 也发生变化，同样会发送通知出去
+ (NSSet *)keyPathsForValuesAffectingRedComponent
{
    return [NSSet setWithObject:@"lComponent"];
}

```

>意思就是：如果设置 A 属性依赖 B 属性，给 A 属性添加观察者后，一旦 B 属性的值发生变化， A 属性的观察者也能够监听到。

### 3. 自动通知和手动通知
默认 KVO 是自动通知的，如果需要关闭自动通知，改为手动通知，可以重写 `+ (BOOL)automaticallyNotifiesObserversOf<key>` 方法，并且在属性的 setter 方法赋值的前后手动调用 `willChangeValueForKey:` 和 `didChangeValueForKey:` 方法。

```
// 是否对观察的属性 name 自动接收通知。默认是 YES
+ (BOOL)automaticallyNotifiesObserversOfName;
{
    return NO;
}

// 手动开启。
// 注意：如果在其他地方修改了成员变量，也需要这样手动调用一下。
- (void)setName:(NSString *)name
{
    if (_name == name)
    {
        return;
    }
    
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

```

### 3. KVO 和 context
设置一个类唯一的 context，可以保证子类都是正确的，子类和父类都能安全的观察同样的键值而不会冲突。

**设置观察者为自己：**

```
static int const PrivateKVOContext;

@interface Student ()

@property(nonatomic, strong) id target;
@property(nonatomic, assign) SEL sel;
@property (nonatomic, copy) NSString *keyPath;

@end

@implementation Student

// 初始化方法
- (instancetype)initWithKeyPath:(NSString *)keyPath target:(id)target selector:(SEL)sel options:(NSKeyValueObservingOptions)options
{
    NSParameterAssert(target != nil);
    NSParameterAssert([target respondsToSelector:sel]);

    self = [super init];
    if (self) {
        self.target = target;
        self.sel = sel;
        self.keyPath = keyPath;
        
        // 将自己本身当做观察者
        [self addObserver:self forKeyPath:keyPath options:options context:&PrivateKVOContext];
    }
    return self;
}

// 移除观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:self.keyPath];
}

// 通知响应
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == &PrivateKVOContext) {
        [self didChange:change];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 将消息传递出去
- (void)didChange:(NSDictionary *)change
{
    id strongTarget = self.target;
    
    // 消除警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [strongTarget performSelector:self.sel withObject:change];
#pragma clang diagnostic pop
}

```

**调用**

![](https://liangjinggege.com/Snip20170514_2.png?imageView/0/h/350)


### 5. NSKeyValueObservingOptions 

* NSKeyValueObservingOptionInitial：设置 `NSKeyValueObservingOptionInitial` 选项，可以监听 `addObserver: forKeyPath:options:context:`方法调用时的通知以及属性值改变通知。

* NSKeyValueObservingOptionPrior：设置该观察选项，可以监听到属性值改变前以及改变后的两次通知。并通过字典 `change` 中的 `key` 值进行判断是设置属性值之前，还是之后。

	```
	if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue]) 
	{
	    // 改变之前
	} 
	else
	{
	    // 改变之后
	}
	
	```

* NSKeyValueObservingOptionOld：属性值被改变之前接收到监听通知。获取旧值：id oldValue = change[NSKeyValueChangeOldKey];

* NSKeyValueObservingOptionNew：属性值被改变之后接收到监听通知。获取新值：id newValue = change[NSKeyValueChangeNewKey];

### 5. 索引
如果属性是一个集合类，那么 KVO 会监听集合对象的增加，删除，替换等属性值改变操作，并在 change 字典里返回会包含键值变化的类型（添加、删除和替换）对于有序的集合，change 字典会包含受影响的 index。

```
-mutableArrayValueForKey:
-mutableSetValueForKey:
-mutableOrderedSetValueForKey:

```

![](https://liangjinggege.com/Snip20170514_3.png?imageView/0/h/350)

### 6. KVO 和线程
KVO 行为是`同步`的，并且发生与所观察的值发生变化的`同样的线程`上。手动或者自动调用 `- didChangeValueForKey:` 会触发 KVO 通知。

![](https://liangjinggege.com/Snip20170514_4.png?imageView/0/h/350)

>KVO 能够保证属性值在 setter 方法调用`之前`，该属性的观察者就就能够被通知到。

### 7. KVO Demo 
#### #画板
**效果如下：**

<img src="KVC-KVO-学习/drawBoard.gif" width="375px" height="750px
">

主要是通过 KVO 监听画板线条数组的变化，从而刷新撤销按钮、回退按钮、全部删除按钮的 UI 状态。

[示例代码](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/KVC%20%26%20%20KVO/KVO%20%E7%94%BB%E6%9D%BF)

#### #LAB 色彩空间

该 demo 主要是利用了 KVO 的对属性的监听，以及属性依赖，另外还有自定义一个观察者辅助类文件。
实现了属性值改变，UI 视图即时响应。

* LabColor：lab 颜色的生成，通过 RGB 的颜色的转换。
* KeyValueObserver：观察者辅助类，方便添加和移除观察者，以及通知监听。
* ViewController：视图控制器，控制视图和数据的交互逻辑。

**效果**

<img src="KVC-KVO-学习/labColorDemo.gif" width="375px" height="750px
">

[示例代码](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/KVC%20%26%20%20KVO/KVO%20and%20KVC%20Demo)

## 源代码
[代码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/KVC%20%26%20%20KVO)


## 参考资料
[KVC 和 KVO](https://objccn.io/issue-7-3/)
[iOS开发-KVO的奥秘](http://www.jianshu.com/p/742b4b248da9)
[KVC/KVO原理详解及编程指南](http://blog.csdn.net/wzzvictory/article/details/9674431)
[KVO与KVC](http://www.jianshu.com/p/d412ac1113a0)
[iOS开发技巧系列---详解KVC](http://www.jianshu.com/p/45cbd324ea65)
