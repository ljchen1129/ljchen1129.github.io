---
title: 基于 Pannellum 的全景图网页容器实现
date: 2019-10-02 12:22:17
tags:
- html
- 全景图
categories:
- html
- 全景图
---



### 前言

2017 年由于公司需要，做过一个支持全景图显示的网页，这篇文章主要回顾和记录一下当初开发这个功能时的一些情景。

### 先看效果

左边是在微信小程序中显示，右边是在 App 中显示

<img src="http://liangjinggege.com/2019-10-02-113357.gif" alt="ezgif.com-video-to-gif" style="zoom:67%;" /><img src="/Users/chenliangjing/Downloads/ezgif.com-video-to-gif (2).gif" alt="ezgif.com-video-to-gif (http://liangjinggege.com/2019-10-02-113443.gif)" style="zoom:67%;" />



### 实现了哪些功能

基于 [Pannellum](https://pannellum.org/) 实现

#### 1. 全景图的显示

```javascript
  viewer = pannellum.viewer('container', {
      // 默认参数
      "default": {
          "firstScene": "hotalScene", // 第一个场景
          "sceneFadeDuration": 1000, // 场景过度的动画时长
          "autoLoad": true, // 是否自动加载
          "compass":true, // 指南针是否显示
          "orientationOnByDefault": true,// 是否默认重力感应
      },

      // 场景数组
      "scenes": {
          "hotalScene": {
              "type": "equirectangular", // 全景图类型 equirectangular
              "panorama": path, // 全景图路径：可以本地，也可以是url
          }
      }
  });
```

#### 2. 场景切换

```javascript
// 动态添加场景，场景切换
viewer.addScene('roomScene',{ 
     "type": "equirectangular",  // 全景图类型 equirectangular
     "panorama": message.PanoramaUrl, // 全景图路径：可以本地，也可以是url
 });

 // 加载房间全景
 viewer.loadScene('roomScene');
```

#### 4. 和原生 App 的交互

#### 3. 和微信小程序的交互

```javascript
// 引入小程序 jsSdk
<script type="text/javascript" src="https://res.wx.qq.com/open/js/jweixin-1.3.1.js"></script>

// 小程序跳转，url 通过 & 拼接参数
wx.miniProgram.navigateTo({ url:'../roomBook/roomBookPage?model=' + JSON.stringify(currentRoomDict) + '&from=' + '3' });
```

### 4. 和 App 的交互

```objective-c
// 自定义拦截协议
var linkUrl = 'hjdykj://RoomID=';
window.location.href = linkUrl;

// 原生拦截到，做自定义的事情
NSString *message = (NSString *)param;
NSRange startR = [message rangeOfString:@"hjdykj://RoomID="];
// TODO:
```



### 参考资料

1. https://juejin.im/post/5b62b985e51d455d947196fc#heading-4
2. https://github.com/mpetroff/pannellum



---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「青争哥哥」。

![青争哥哥](http://liangjinggege.com/qrcode_for_gh_0be790c1f754_258.jpg)