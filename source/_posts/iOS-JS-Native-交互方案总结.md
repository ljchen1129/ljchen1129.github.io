---
title: iOS JS-Native 交互方案总结
date: 2018-12-28 10:31:27
tags:
- iOS
categories:
- iOS
---

## 前言
随着移动互联网的发展，一些跨平台技术层出不穷，如 Facebook 的 [ReactNative](https://facebook.github.io/react-native/)、阿里的[Weex](https://weex.apache.org/)、国内各大互联网大厂的小程序、[PWA](https://en.wikipedia.org/wiki/Progressive_web_applications)、Google 的 [Flutter](https://flutter.dev/) 等，各种前端技术和原生混合形式开发方式正在成为一个大的趋势，所以在日常 iOS 开发中，经常会有原生 App 嵌入网页的业务需求，因此常常会有网页和原生页面交互的场景出现，希望能够结合网页和原生的各自优势，打造更极致的用户体验。本文就是总结日常开发中常见的几种 JS-Native 交互方案。

![开发方式演变](http://liangjinggege.com/1431555559512_.pic.jpg)

本文结合具体代码示例，尝试从使用、原理浅析、方案对比这几个角度来介绍各种方案的优缺点，希望能够说清楚在不同的业务场景下开发者该如何选择最合适自己的方案，最后，还会尝试自己实现一套满足基本业务需求的轻量级 hybrid 方案并展望未来。

## 使用
一般情况下，一个原生和网页的交互需求需要满足一下几点：

1. 网页能够获取原生特有的一些能力，如调用原生的方法，获取原生的数据，监听原生的事件。
2. 原生能够执行 JS 的代码，并将数据传递给网页。


### 一、JS 调用原生

#### 1. 假链接跳转拦截

#### 2. JavaScriptCore 系统库

#### 3. WebViewJavaScriptBridge 第三方库

#### 4. WKWebView 的 scriptMessageHandle 

#### 5. 跨平台框架

### 二、原生调用 JS

#### 1. UIWebView

#### 2. JavaScriptCore 系统库

#### 3. WebViewJavaScriptBridge 第三方库

#### 4. WKWebView 的 scriptMessageHandle 

#### 5. 跨平台框架





## UIWebView 时代

在 iOS 8 以前，可以使用 UIWebView 控件来做。



## WKWebView

<!--### JS 与 OC 通信

### 1. 通过 JavaScriptCore 中的 block



### 2. 通过 JavaScriptCore 中的 JSExprot



### OC 与 JS 通信-->

##


## 跨平台框架
### ReactNative





### Weex



### phoneGap-cordova



## 原理浅析



## 各种方案对比



