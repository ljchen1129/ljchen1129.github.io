---
title: iOS 架构模式之 MVP 模式
date: 2017-04-27 19:15:39
tags:
- iOS
- 架构模式
categories:
- iOS
- 架构模式
---

## 前言
在 iOS 项目开发中，有很中架构模式，最经典的是 MVC 模式，M 代表数据层，V 代表视图 UI 层，C 代表控制器层，主管业务逻辑，负责把 M 层的数据显示到 V 视图层上，还有其他的一些架构模式，如 MVVM，还有今天介绍的 MVP。由于是第一次接触 MVP，只记录学到的一个案例。

## 源码
- [Objective-C 版本](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/%E6%9E%B6%E6%9E%84%E6%A8%A1%E5%BC%8F-MVP)
- [Swift 版本](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/iOS%E6%9E%B6%E6%9E%84%E6%A8%A1%E5%BC%8F%E2%80%94MVP%EF%BC%88Swift%EF%BC%89)

## MVP 简介
- MVP 架构模式
	- M：数据层（网络、数据库、文件等）数据相关
	- V：UIView 以及子类 + UIViewController 及子类
	- P：中介（用于关联 M 和 V）
 
>特点：将数据层和 UI 层完全隔离。V 层：只负责创建 UI 和显示 UI，刷新 UI。
<!-- more -->
## 模拟场景
通常一个业务开发的流程是这样的，进入一个页面 --> 请求数据 --> 网络加载 --> 渲染 UI。下面就模拟一下这样一个业务场景，请求数据渲染一个列表视图，通过 MVP 架构模式来编写代码，看看会发生什么？

![](http://o6heygfyq.bkt.clouddn.com/Snip20170427_3.png?imageView/0/w/375)

## 第一步
编写一个网络请求工具类，通过传递请求路径，请求参数，请求方式能够从网上请求数据并回调出去。

```
// get 请求
+ (void)getRequsetWithUrl:(NSString *)urlString callBack:(callBack)callBack
{
    // 1. 创建请求 URL
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2. 创建请求参数集合
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // 3. 设置请求方式
    request.HTTPMethod = @"GET";
    
    // 4. 创建请求会话
    NSURLSession *seesion = [NSURLSession sharedSession];
    
    // 5. 创建一个请求任务
    [SVProgressHUD show];
    NSURLSessionDataTask *task = [seesion dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 7. 处理请求结果
        if (error != nil)
        {
            [SVProgressHUD setStatus:@"请求失败"];
            NSLog(@"请求失败 --- error = %@", error);
        }
        else
        {
            [SVProgressHUD dismiss];
            NSLog(@"请求成功");
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error)
            {
                NSLog(@"error = %@", error);
                NSLog(@"json 解析失败！");
            }
            else
            {
                // 8. 回调请求结果
                callBack(jsonDict);
            }
        }
    }];
    
    // 6. 执行请求
    [task resume];
}

```

## 第二步

新建一个列表数据的 Model，用来装载数据，在里面做一些数据转换的操作，把字典数组转成模型数组，并回调出去。

```
// 请求分类列表数据
- (void)requestCategoryDataWithName:(NSString *)name pwd:(NSString *)pwd callBack:(void(^)(id response))callBack
{
    NSLog(@"name = %@, pwd = %@", name, pwd);
    [HttpUtils getRequsetWithUrl:@"http://api.budejie.com/api/api_open.php?a=category&c=subscribe" callBack:^(NSDictionary *dict) {
        NSDictionary *dic = dict[@"list"];
        // 将字典数组转成模型数组
        id response = [NSArray yy_modelArrayWithClass:[self class] json:dic];
        callBack(response);
    }];
}

```

## 第三步
新建一个协议，让 V 层遵守这个协议，一旦业务逻辑发起网络请求并回调，就响应这个协议。

```
@protocol CategroyTableViewDelegate <NSObject>

- (void)onCategroyTableViewResult:(id)result;

@end

```

## 第四步
新建 P 层，关联 V 层和 M 层，并提供绑定 View 以及解除绑定 View 的方法。

```
#import "CategoryPresenter.h"
#import "CategoryModel.h"

@interface CategoryPresenter ()

@property(nonatomic, strong) CategoryModel *categoryM;
@property(nonatomic, weak) id<CategroyTableViewDelegate> categoryT;

@end

@implementation CategoryPresenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _categoryM = [[CategoryModel alloc] init];
    }
    
    return self;
}

// 绑定view
- (void)attachView:(id<CategroyTableViewDelegate>)categoryTableView
{
    _categoryT = categoryTableView;
}

// 解除绑定View
- (void)detachView
{
    _categoryT = nil;
}

- (void)categoryTableViewRequestDataWithName:(NSString *)name pwd:(NSString *)pwd
{
    [_categoryM requestCategoryDataWithName:name pwd:pwd callBack:^(id response) {
        if (_categoryT != nil && [_categoryT respondsToSelector:@selector(onCategroyTableViewResult:)])
        {
        	  // 响应这个协议方法
            [_categoryT onCategroyTableViewResult:response];
        }
    }];
}

```

## 第五步
在控制器里面遵守并实现这个协议，并发起数据请求。

```
@interface ViewController () <CategroyTableViewDelegate>

@property (nonatomic, strong) CategoryPresenter *catePresenter;
@property (weak, nonatomic) IBOutlet CategroyTableView *categoryTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _catePresenter = [[CategoryPresenter alloc] init];
    
    // 绑定 P
    [_catePresenter attachView:self];
    
    // 发起数据请求
    [_catePresenter categoryTableViewRequestDataWithName:@"chenlaingjing" pwd:@"123456"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 解除绑定
    [_catePresenter detachView];
}

#pragma mark - CategroyTableViewDelegate

- (void)onCategroyTableViewResult:(id)result
{
    NSLog(@"result = %@", result);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.categoryTableView.dataArray = (NSArray *)result;
    });
}

```

## 第六步
最后一步，数据请求成功后去刷新表格视图

```
#pragma mark - setter

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    [self reloadData];
}

```

## 总结
方法调用顺序：一进入到这个控制器的视图，先会创建 P 层，并绑定控制器，然后调用 P 层的发起网络请求方法 categoryTableViewRequestDataWithName:，将请求参数传递进去，然后来到 P 层方法实现，调用 M 层的数据请求方法，M 层给网络请求工具类传递请求路径，请求方式，请求参数， HttpUtils 网络请求层请求完成后回调给 M 层，M 层做一个数据处理的工作，这里讲字典数据转成模型数据传递到 P 层，P 层拿到数据后先判断是否有绑定 V 层，并且是否代理响应了协议方法，如果是，就响应协议方法，并把 P 层拿到的模型数据数据传递出去，由于 V 层遵守了代理，实现了协议方法，所以一旦网络请求完成回调，就会执行协议方法，并传递模型数组数据，V 层一拿到数据，就去刷新表格视图。
