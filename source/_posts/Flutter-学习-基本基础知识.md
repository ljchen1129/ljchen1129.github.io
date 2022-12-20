---
title: Flutter 学习-基本基础知识
date: 2022-10-1 11:39:23
tags:
- Flutter
categories:
- Flutter
---

### Flutter 工程模式

1. App：就是一个以 Flutter 为容器的 App 工程项目，里面可包含各种平台（iOS、Android、Mac OS、Windows、Linux、Web），`统一管理模式`
2. Module：创建一个 Flutter 模块，以模块的形式分别嵌入各自的原生平台项目，`三端分离模式`
3. Package：纯 Dart 插件工程，不依赖 Flutter，仅包含 Dart 层的实现，`通常用来定义一些公共库`
4. Plugin：Flutter 平台插件，包含 Dart 和 Native 平台层的实现，是一种`特殊的 Flutter Package`
5. Skeleton（骨架）：flutter 2.5 之后新增的，自动生成 Flutter 模版，提供常用框架

![Untitled](/Users/chenliangjing/Desktop/Futter 学习-基础知识 2/Flutter 学习-基础知识 e6440b73b13b4778acd60310c88194ed/Untitled.png)

### 基本结构

```dart
// 入口主函数
void main() {
  runApp(const MyApp());
}

// 无状态组件
class MyApp extends StatelessWidget {
  // 构造方法
  const MyApp({super.key});

  // build 描述如何根据其他较低级别的 widgets 来显示自己
  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    // 一种移动端和网页端通用的视觉设计语言， Flutter 提供了丰富的 Material 风格的 widgets
    return MaterialApp(
      title: 'Welcome to Flutter',
      // Scaffold 是 Material 库中提供的一个 widget，它提供了默认的导航栏、标题和包含主屏幕 widget 树的 body 属性。 widget 树可以很复杂。
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text(wordPair.asPascalCase),
        ),
      ),
    );
  }
}
```

### widget

`StatelessWidget`：无状态的 widgets 是不可变的，这意味着它们的属性不能改变 —— 所有的值都是 final

`StatefulWidget`：有状态的 widgets 也是不可变的，但其持有的状态可能在 widget 生命周期中发生变化

实现一个有状态的 widget 至少需要两个类： 

1）一个 `StatefulWidget` 类；

2）一个 `State` 类；

`StatefulWidget` 类本身是不变的，但是 `State` 类在 widget 生命周期中始终存在。

IDE 直接输入 `stful`，直接会生成样板代码

```dart
// 自动更新 RandomWords 其对应的 State 类 _RandomWordsState
class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 列表组件

使用 `ListView` 实现列表组件

```dart
ListView _bulidSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          // 对于每个建议的单词对都会调用一次 itemBuilder，
          // 然后将单词对添加到 ListTile 行中。在偶数行，
          // 该函数会为单词对添加一个 ListTile row，在奇数行，
          // 该函数会添加一个分割线的 widget，来分隔相邻的词对。
          // 注意，在小屏幕上，分割线可能较难辨别。
          if (i.isOdd)
            return const Divider(); // 在 ListView 里的每一行之前，添加一个 1 像素高的分隔线 widget。

          final index = i ~/ 2; // 语法 i ~/ 2 表示 i 除以 2，但返回值是整型（向下取整），
          // 比如 i 为：1, 2, 3, 4, 5 时，结果为 0, 1, 1, 2, 2，
          // 这个可以计算出 ListView 中减去分隔线后的实际单词对数量。
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs()
                .take(10)); // 如果是建议列表中最后一个单词对，接着再生成 10 个单词对，然后添加到建议列表。
          }

          return _bulidRow(_suggestions[index]);
        });
  }

Widget _bulidRow(WordPair pair) {
    final alerdySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alerdySaved ? Icons.favorite : Icons.favorite_border,
        color: alerdySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          alerdySaved ? _saved.remove(pair) : _saved.add(pair);
        });
      },
    );
  }
```

![Untitled](/Users/chenliangjing/Desktop/Futter 学习-基础知识 2/Flutter 学习-基础知识 e6440b73b13b4778acd60310c88194ed/Untitled 1.png)

### 交互事件

给组件添加事件

```dart
onTap: () {
// 触发页面重新布局渲染
        setState(() {
          alerdySaved ? _saved.remove(pair) : _saved.add(pair);
        });
      },
```

### 路由导航

页面跳转，导航路由组件 `Navigator` 组件

```dart
// 路由到新的页面
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );

          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            // 新增 6 行代码开始 ...
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          ); // ... 新增代码段结束.
        },
      ),
    );
  }
```

### 主题样式

使用 `ThemeData` 切换主题样式

```dart
// build 描述如何根据其他较低级别的 widgets 来显示自己
  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    // 一种移动端和网页端通用的视觉设计语言， Flutter 提供了丰富的 Material 风格的 widgets
    return MaterialApp(
      title: 'Startup Name Generator',
      // 切换样式
      theme: ThemeData(
        primaryColor: Colors.red,
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.light().copyWith(primary: Colors.yellow),
      ),
      // Scaffold 是 Material 库中提供的一个 widget，它提供了默认的导航栏、标题和包含主屏幕 widget 树的 body 属性。 widget 树可以很复杂。
      home: const RandomWords(),
      debugShowCheckedModeBanner: false,
      // Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Startup Name Generator'),
      //   ),
      //   body: const Center(
      //     child: RandomWords(),
      //   ),
      // ),
    );
  }
```

> ****[解决Flutter中ThemeData.primaryColor在AppBar等组件中不生效](https://www.cnblogs.com/huangzs/p/16305693.html)****

### 最后效果

![Untitled](/Users/chenliangjing/Desktop/Futter 学习-基础知识 2/Flutter 学习-基础知识 e6440b73b13b4778acd60310c88194ed/Untitled.gif)

### 布局

基础 **`widgets`**

1. Text
2. Row，column：相对应 web 中的 flexbox 布局模型
3. Stack: 相对应 web 中的绝对位置布局模型
4. Container：容器 **`widgets`** 
   1. 设置外边距、内边距和尺寸的约束条件
   2. 使用 `[BoxDecoration](https://api.flutter-io.cn/flutter/painting/BoxDecoration-class.html)`来进行装饰，如背景，边框，或阴影等
   3. 使用矩阵在三维空间进行转换

> Flutter App 就是由各个 **`widgets`** 组合嵌套而成

### **Flutter 的构建模式**

- Debug
  - 包含所有调试信息，日志，devTools，热重载工具等，包体积大，代码未优化，实际性能受影响
- Release
  - 没有断点等调试信息，只支持真机
- Profile
  - 用来测试 App 性能，关闭各种日志，devTools，包体积小，接近真实使用场景





<!--more-->

---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「by在水一方」。

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/qrcode_for_gh_0be790c1f754_258.jpg" alt="by在水一方" style="zoom:50%;" />

