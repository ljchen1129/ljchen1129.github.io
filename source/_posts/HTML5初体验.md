---
title: HTML5 初体验
date: 2016-06-02 14:10:22
tags: 
- html5
- css
categories: html5

---
<img src="HTML5初体验/html5.jpg" width="400px" height="300px
">
## 前言
>随着移动互联网的火热，html5技术的成熟，越来越多的APP都采用了混合编程的模式，这是一个趋势。既在原生APP里面嵌入大量的HTML5网页，综合了原生和html5各自的优势。所以作为一个APP开发从业人员，掌握html5开发已成为了职业发展的必备技能。
<!-- more -->
## 效果
<center><img src="https://blogimages-1254431338.cos.ap-shenzhen-fsi.myqcloud.com/aboutUS.png" width="375px" height="675px">
</center>

## 开发工具
[WebStorm](https://www.jetbrains.com/webstorm/)
>The smartest JavaScript IDE

>Lightweight yet powerful IDE, perfectly equipped for complex client-side development and server-side development with Node.js

## 代码

```html
   <html lang="en">
<head>
    <meta charset="UTF-8">
    <title>关于我们</title>
    <link hre/Users/chenliangjing/Desktop/未命名文件夹f="css/aboutUs.css" rel="stylesheet">
</head>
<body style="background-color: #f0f0f0; position: relative">
	
<!--vstlogo图片-->
<div style="height: 130px;text-align: center">
    <img src="images/vst_aboutUs.png" style="margin-top: 40px;width: 90px">
</div>
	
<!--vst简介-->
<div id="main">
    <div>伟仕佳杰，为全球超过一百二十几个顶尖ICT品牌创建增值服务，
        打造由企业级系统、T服务和分销三大核心部分组成的完整业务体系，
        产品覆盖智能终端、移动互联、数码外设、基础网络、存储方案、软件与服务、
        信息安全、物联应用、云计算、大数据等领域，以优秀的企业信誉和雄厚的资金实力
        服务于超过27000个合作伙伴平台。
    </div>
</div>
	
<!--vst官网-->
<div id="footer">
        <div>伟仕佳杰</div>
        <a href="http://ecschina.com" target="_blank">ecschina.com</a>
	
</div>
	
</body>
</html>
```

## CSS

```css
html,body{
    margin: 0;
    padding:0;
    height: 100%;
}
	
#main{
    margin: 0 auto;
    padding-bottom: 40px;/*等于footer的高度*/
}
	
#main div{
    margin-right: 12px;
    margin-top: 20px;
    margin-left: 12px;
    font-size: 12px;
    color: #646464
}
	
#footer {
    text-align: center;
    position: absolute;
    bottom: 20px;
    width: 100%;
    height: 40px;/*尾部的高度*/
}
	
#footer div{
    /*margin-bottom: 8px;*/
    font-size: 15px;
}
	
#footer a{
    color: #646464;
    font-size: 11px;
    text-decoration: none; /*去除下划线*/
}    
```

## 总结
这是一个最简单的一个html5页面，只有网页和层叠样式，没有JS交互，嵌在原生APP中，跨平台，真正地write once,run everywhere！接下来想学习[JavaScript](http://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000)，开发复杂一点的网页出来，go!