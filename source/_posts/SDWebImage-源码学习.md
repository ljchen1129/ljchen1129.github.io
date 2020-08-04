---
title: SDWebImage 源码学习
date: 2017-05-03 09:23:26
tags:
- iOS
- 源码学习
categories:
- iOS
- 源码学习
---

## 前言
SDWebImage 是用来做图片异步加载以及图片缓存的第三方库，用一行代码就能集成图片的多级缓存以及异步下载，功能强大，好用方便。之前学习多线程 NSOperation 时，实现过一个简单的图片异步下载，代码在[这里](http://chenliangjing.me/2017/03/17/iOS-%E5%A4%9A%E7%BA%BF%E7%A8%8B-NSOperation/#NSOperation-实现多图下载)。现在想了解一下 SDWebImage 的实现机制和工作原理，通过过阅读他的源代码。我这里的版本是 SDWebImage 4.0.0。




## 使用方法
<!-- more -->
1.通过 `UIImageView+WebCache` 分类，给一个 UIImageView 视图下载并设置图片。

```
// 方法：根据一个 url 给一个 UIImageView 视图下载并设置图片
// URL：图片资源地址
// placeholderImage：占位图片
[cell.imageView sd_setImageWithURL:[NSURL URLWithString:a.icon] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
    
```

2.通过 `UIImageView+WebCache` 分类，获取下载过程回调，下载完成回调

```	
// 给 UIImageView 视图下载并设置图片
// 参数一 URL：图片资源路径
// 参数二 placeholderImage ：占位图片
// 参数三 options ：选择枚举，图片下载选项操作
// 参数四 progress： 图片下载过程进度回调（receivedSize ： 已下载的图片数据大小，expectedSize：图片真实的数据大小，targetURL：图片资源目标路径）
// 参数五 completed：图片下载完毕回调（image ：图片，error：错误信息，cacheType：枚举，缓存类型，imageURL：图片目标路径）
[cell.imageView sd_setImageWithURL:[NSURL URLWithString:a.icon] placeholderImage:[UIImage imageNamed:@"placeHolder"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    
} completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
	
}];
	
```

**说明1：**`SDWebImageOptions` 选项

```
/// 下载图片操作选项枚举
typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {

	/// 下载失败后重新下载。默认情况下,如果一个 url 在下载的时候失败了,那么这个url 会被加入黑名单并且 library 不会尝试再次下载。如果设置这个选项，那么即使某个 url 下载失败了，还是会尝试再次下载
	SDWebImageRetryFailed = 1 << 0,
		
	/// 低优先级下载。默认情况下，图片会在发生交互时下载，比如 tableView 滑动时。如果设置了这个选项，那么在应用发生交互的情况下会停止下载，交互结束后又重新下载
	SDWebImageLowPriority = 1 << 1,

	/// 禁止磁盘缓存,只有内存缓存	
	SDWebImageCacheMemoryOnly = 1 << 2,
		
	/// 显示图片下载进度	
	SDWebImageProgressiveDownload = 1 << 3,

	/// 刷新缓存。如果选择这个选项，一个图片即使被缓存了，还是会去重新下载，并重新缓存	
	SDWebImageRefreshCached = 1 << 4,

	/// 继续在后台下载。如果图片正在下载中，程序进入后台，设置这个选项会在后台继续下载图片
	SDWebImageContinueInBackground = 1 << 5,

	/// 可以控制存在NSHTTPCookieStore的cookies
	SDWebImageHandleCookies = 1 << 6,
	
	/// 允许不安全的SSL证书,在正式环境中慎用
	SDWebImageAllowInvalidSSLCertificates = 1 << 7,
	
	/// 高优先级，优先下载图片。默认情况下,image 在下载的时候是按照他们在队列中的顺序下载的(就是先进先出).设置这个选项会把他们移动到队列的前端,并且立刻下载,而不是等到当前队列装载的时候再装载.
	SDWebImageHighPriority = 1 << 8,
	
	/// 默认情况下,占位图片会在图片下载的时候显示.设置这个选项会延迟占位图显示的时间,等到图片下载完成之后才会显示占位图   
	SDWebImageDelayPlaceholder = 1 << 9,
		
	SDWebImageTransformAnimatedImage = 1 << 10,
	    
	SDWebImageAvoidAutoSetImage = 1 << 11,
	
	SDWebImageScaleDownLargeImages = 1 << 12
};
	
```


**说明2**：`SDImageCacheType` 枚举

```
/// 图片缓存类型
typedef NS_ENUM(NSInteger, SDImageCacheType) {

	/// 没有缓存，图片来自下载 
    SDImageCacheTypeNone,

	/// 图片来自磁盘缓存
    SDImageCacheTypeDisk,

	/// 图片来自内存缓存
    SDImageCacheTypeMemory
};

```

3.通过 `SDWebImageManager` 类单例，获取下载的图片，不进行设置（依然有内存&磁盘缓存）
	
```
[[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:@"http://image.tianjimedia.com/uploadImages/2015/162/22/4GU4301NQGWW.jpg"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    
} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
    self.imageView.image = image;
}];
	
```

4.通过 `SDWebImageDownloader` 类单例，直接下载，不做内存以及磁盘缓存。

	[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:@"http://p.3761.com/pic/20131413167658.jpg"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
	    
	} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
	    // 注意：这里是在子线程
	    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
	        self.imageView.image = image;
	    }];
	}];


## 设置 gif 图片
设置动态 GIF 图片。SDWebImage 4.0.0 以后设置 gif 图片的方式就改了，需要额外 pod 'SDWebImage/GIF' ，并且显示图片的 UIImageView 要改成 `FLAnimatedImageView` 类。

```
// 设置动态 gif 图片
- (void)setupGifImage
{
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/chenliangjing/Downloads/23b8c47499b23d19c7129085b9e2aca7.gif"];
    self.imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
}

```

>注意：需要导入头文件 `#import <FLAnimatedImage.h>`


## 处理内存警告

```
// 内存警告
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    // 1. 清空缓存
    // 直接删除，然后重新创建
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:^{
        
    }];
    
    // 清除过期缓存，计算当前缓存的大小，和设置的最大缓存数量作比较，如果超出，继续删除（根据文件创建的时间先后顺序）
    // kDefaultCacheMaxCacheAge : 1 week
    [[SDWebImageManager sharedManager].imageCache deleteOldFilesWithCompletionBlock:^{
        
    }];
    
    // 2. 取消当前所有操作
    [[SDWebImageManager sharedManager].imageDownloader cancelAllDownloads];
}

```

## 最大并发数量
在 `SDWebImageDownloader` 类的 `initWithSessionConfiguration:` 初始化方法里面设置为 6

```
- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration {
    if ((self = [super init])) {
        // 队里里面任务执行顺序，默认先进先出
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        // 队列最大并发数 = 6
        _downloadQueue.maxConcurrentOperationCount = 6;
    }
    return self;
}

```

## 缓存文件的保存名称处理方式
拿到图片的 URL 路径，对路径进行 MD5 加密存储。

```
- (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [key.pathExtension isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension]];

    return filename;
}

```

## 对内存警告的处理方式
通过接收应用活动状态的通知，进行内存警告的处理，如果应用出现内存警告，就清除内存缓存。

```
// Subscribe to app events
/// 应用出现内存警告时调用
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(clearMemory)
                                             name:UIApplicationDidReceiveMemoryWarningNotification
                                           object:nil];

/// 应用被终止时调用
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(deleteOldFiles)
                                             name:UIApplicationWillTerminateNotification
                                           object:nil];

/// 应用进入后台时调用
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(backgroundDeleteOldFiles)
                                             name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

```

## 缓存处理的方式
使用 NSCache 类处理内存缓存
使用沙盒 cache 处理磁盘缓存

```
@property (strong, nonatomic, nonnull) NSCache *memCache;

```

## 判断图片的类型
使用了一个 `NSData+ImageContentType` 分类，根据图片的`二进制数据`的`第一个字节`码来判断。

```

+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return SDImageFormatUndefined;
    }
    
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return SDImageFormatJPEG; // JPEG 类型
        case 0x89:
            return SDImageFormatPNG; // PNG 类型
        case 0x47:
            return SDImageFormatGIF; // GIF 类型
        case 0x49:
        case 0x4D:
            return SDImageFormatTIFF; // TIFF 类型
        case 0x52:
            // R as RIFF for WEBP
            if (data.length < 12) {
                return SDImageFormatUndefined;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return SDImageFormatWebP; // WebP 类型
            }
    }
    return SDImageFormatUndefined;
}

```

## 队列中任务的处理方式
默认是：FIFO

```
/// 队列中任务执行顺序
typedef NS_ENUM(NSInteger, SDWebImageDownloaderExecutionOrder) {
  	
  	/// 默认是先进先出
    SDWebImageDownloaderFIFOExecutionOrder,

	/// 后进先出
    SDWebImageDownloaderLIFOExecutionOrder
};

```

## 如何下载图片
通过发送网络请求来下载图片，使用 NSURLSession 

## 请求超时的时间
默认是 15 秒。

```
/// 网络请求超时时间
_downloadTimeout = 15.0;

sessionConfiguration.timeoutIntervalForRequest = _downloadTimeout;

/**
 *  Create the session for this task
 *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
 *  method calls and completion handler calls.
 */
self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                             delegate:self
                                        delegateQueue:nil];

```

## 调用顺序

UIImageView+WebCache 的分类方法，给一个 UIImageView 下载设置图片:

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170509_1.png)

然后调用：

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170509_4.png)

接着调用 `UIView+WebCache` 类中方法：

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170509_6.png)

其实就是单例类 `SDWebImageManager` 中的下载方法：

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170509_7.png)

最终调用 `SDWebImageDownloader` 类中的下载方法，通过 `NSUrlSeesion` 类进行网络下载： 

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20170509_8.png)


## 源码

[源码地址](https://github.com/ljchen1129/Objective-C-Practice-Code/tree/master/SDWebImage%20%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0)