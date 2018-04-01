---
title: iOS 开发小 tips 收集
date: 2016-10-21 11:06:04
tags:
- iOS
categories: iOS
---
# 前言
先开个坑，记录整理下 iOS 开发中的小 tips...

# 工具效率
### 1. 查看工程代码行数
1. cd 到工程文件夹，如果要避免统计到`第三方库`的代码，应该再 cd 到存放我们自己写的项目文件夹：

<div >
<center>
    <img src="http://o6heygfyq.bkt.clouddn.com/4C26F715-EADD-4C10-AA6F-8953C0726C60.png?imageView2/0/h/350" width="500px" >
    </center>
</div>

2. 打开终端，输入如下命令：
<!-- more -->
	```
	find . -name "*.m" -or -name "*.h" -or -name "*.xib" -or -name "*.c" |xargs grep -v "^$"|wc -l 
	```
	![](http://o6heygfyq.bkt.clouddn.com/97C15843-4298-4916-9E96-A6F4FC512232.png?imageView2/0/h/350/w/500)
	
	>注意：这个统计会去掉`空行`，但是包括`注释`。
	
	如果需要列出每个文件的行数，则输入这句命令：
	
	```
	find . -name "*.m" -or -name "*.h" -or -name "*.xib" -or -name "*.c" |xargs wc -l   
	```
	![](http://o6heygfyq.bkt.clouddn.com/622C80FA-38BA-4A8F-992E-0EFA8F05EDE7.png?imageView2/0/h/350/w/500)
	
>但是发现一个问题：如果用这句命令，总行数和上一句命令的总行数对不上，可能是没有忽略掉空行吧，不知道那个命令才是表示去掉空行的，困惑？
	

### 2. pod install/update 更新慢
- 原因：执行以上两个命令的时候会升级 CocoaPods 的 spec 仓库，加一个参数可以省略这一步，然后速度就会提升不少。加参数的命令如下：

```
# 安装
pod install --verbose --no-repo-update
# 更新
pod update --verbose --no-repo-update

```

# 语言语法






# 踩过的坑
### 1. 特定页面导航栏的隐藏
开发者经常碰见这样的需求，总有某些页面需要隐藏导航栏，但是又不能影响到整体项目，如个人中心页面，一般最容易想到的做法是在 viewWillAppear 设置 navigationBar 隐藏，然后在 viewWillDisappear 方法里设置 navigationBar 不隐藏，像这样：

```
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}
```

这样似乎可以解决问题，但是如果这个时候要使用模态视图，prestent 出一个视图，比如常见的弹出登录界面，这个时候就会出现如下的一个不好看的闪动的动画效果，而这并不是我们想要的：  

<div >
<center>
    <img src="http://o6heygfyq.bkt.clouddn.com/0914271803292uou.gif?imageView2/0/h/650" width="300px" >
    </center>
</div>

### **#解决方案**

导航控制器有一个代理方法，可以设置导航控制器的代理为当前控制器，然后在 willShowViewController 代理方法里面隐藏导航栏就可以解决问题了：

```
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
```

### 2. 设置 tableViewCell 分割线占满整个 cell 的宽度
* 先在 cell 的实例化方法中添加如下方法

```
if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
{
    cell.preservesSuperviewLayoutMargins = NO;
}
if ([cell respondsToSelector:@selector(setLayoutMargins:)])
{
    [cell setLayoutMargins:UIEdgeInsetsZero];
}
```

* tableView 的 SeparatorStyle 为 UITableViewCellSeparatorStyleSingleLine，separatorInset 为 UIEdgeInsetsZero：

```
tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
tableView.separatorInset = UIEdgeInsetsZero;
tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // 隐藏模拟器上多余的cell分割线
```


### Assertion failure in -[UICollectionViewData validateLayoutInRect:], /SourceCache/UIKit/UIKit-3347.44/UICollectionViewData.m:426

iOS 8 系统下 UICollectionView 自定义布局后，刷新 reloadData 方法，当前一个布局还没有结束的时候，就有开始刷新布局，会崩溃，搞了好久，解决方案如下：

- 重写布局类 UICollectionViewLayout 的 `prepareLayout` 布局方法，在每一次开始布局前，是原有的布局失效

```
- (void)prepareLayout
{
  [super prepareLayout];
  [self invalidateLayout];
}
```


# 其他
