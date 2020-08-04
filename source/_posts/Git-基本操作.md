---
title: Git 基本操作
date: 2016-11-09 16:00:30
tags: Git
categories: Git
---

## #GitHub 上传代码
### 安装 git
如果没有安装 git，得先安装 git，mac 系统自带 git，不用安装，可以在命令行里查看下 git 的版本：

```bash
git version
```
<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161109_3.png?imageView2/0/h/300/w/475" >
  </center>
</div>

### git 配置
安装完 git，首要任务是配置我们的信息，最重要的是用户名及邮箱，在终端中以下命令：
<!-- more -->
```bash
git config --global user.name "用户名" 
git config --global user.email "用户邮箱"
```
### 新建一个代码仓库
登录到个人 GitHub 主页，点击头像左边附近 + 号按钮，选择 New repository 新建代码仓库：

<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161109_1.png?imageView2/0/h/300/w/375" >
  </center>
</div>

给仓库取个名字，可以添加描述，也可以不添加，点击下面创建按钮，一个个人仓库就创建好了

### 克隆仓库到本地

复制刚刚创建好的仓库的地址，在终端中克隆下来：

```bash
git clone https://github.com/github用户名/“仓库名”.git
```

### 添加内容到暂存区
克隆仓库到本地后，本地就会出现一个被版本管理的和代码仓库同名的目录文件夹，将写好的代码工程文件拖入到这个目录文件夹，终端 cd 到这个被版本控制的文件夹，然后提交添加到暂存区：

添加单个文件：

```bash
git add "文件名.后缀名"
```

添加目录下所有的文件：

```bash
git add -A
```

### 提交到暂存区
将添加的文件进行提交，填写这次提交的描述，通过下面的命令：

```bash
git commit -m "这次提交的描述"
```

### 提交到远程仓库
之前的操作都是在本地进行的，要想把暂存区的提交同步到 github 上的远程仓库，还需要执行下面的命令：

```bash
git push origin master
```
<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161109_5.png?imageView2/0/h/300/w/575" >
  </center>
</div>

执行成功完这个命令，就可以去 github 上查看这个仓库就已经多了刚刚提交的文件。

### 查看仓库当前状态
可以查看当前仓库的状态：是否为最新代码，有什么更新等等，执行 git status 命令：

```bash
git status
```
<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161109_4.png?imageView2/0/h/300/w/575" >
  </center>
</div>

### 其他命令
#### git show 查看某一次提交更新了什么：

```bash
git show
```

## 版本回退
### 没有将错误的版本提交到远程仓库

#### #情况一
`本地工作区修改后还没有被放到暂存区`：

```
git checkout -- file # `file` 指那个需要回退的文件
```

#### #情况二
`本地工作区修改后还添加到了暂存区`：

```
git reset HEAD file  # `file` 指那个需要回退的文件
```

再回到情况一，执行，此操作相当于让之前的 `git add` 失效：

```
git checkout -- file # `file` 指那个需要回退的文件
```

#### #情况三
`已提交了不合适的修改到版本库，但还没有推送到远程库`:

```
git reset --hard HEAD^
```

此操作相当于让之前的 `git commit -m "修改说明"` 失效。

### 已经将错误的版本提交到远程仓库
如果已经将错误的版本提交到远程仓库，想要回退到之前的版本的话，可以有一下几种方式：
#### #方法一(不推荐)
**本地仓库：** 先回退到某一个版本，比如上一个版本

```
git reset --hard HEAD^
```
`HEAD^`表示上一个版本，`HEAD^^`则表示上上个版本，再往上 100 个版本可以写成`HEAD~100`

然后删除远程的 master 分支：

```
git push origin:master
```

最后重新创建远程 master 分支，并将本地仓库中的最新修改提交到远程 master 仓库：

```
git push origin master
```
#### #方法二（慎用）

同样先在本地仓库回退到你想回退的版本，然后强制 push 到远程仓库：

```
git push --force
```

> 注意：这个暴力强制的方式，如果在团队开发的时候，容易造成覆盖掉其他同事的提交的代码的风险，`慎用`！

#### #方法三（推荐）

采取 `revert` 的方法，相当于重新生成一个提交，来撤销前一次错误的`commit`:

```
git revert HEAD
```
然后再把从工作区提交到暂存区，最后推送到远程分支：

```
git add .
git commit -m "撤销上次提交的修改"
git push origin master
```

## #分支
### 查看分支
使用 `git branch` 命令列举出工程下面所有的分支列表，用`*`号标记的分支为当前所在的分支，master 叫做主干分支，是每个在 git 管理下的工程都默认有的。 

```bash
git branch 
```

<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161124_1.png?imageView2/0/h/300/w/575" >
  </center>
</div>

### 新建分支
使用 `git branch [branch-name]` 命令新建一个分支，如用如下命令新建一个 develop 分支：

```bash
git branch develop
```
使用 `git branch` 命令查看一下，现在就建好了 develop 分支：

<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161124_2.png?imageView2/0/h/300/w/575" >
  </center>
</div>

### 切换分支
使用 `git checkout [branch-name]` 切换到指定的分支，如使用如下命令切换到 develop 分支：

```bash
git checkout develop
```
查看一下，当前所在分支已经切换到了 develop 分支：

<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161124_3.png?imageView2/0/h/300/w/575" >
  </center>
</div>

另外如果使用 `git checkout -b [branch-name]` 带 `-b` 标识新建分支，则表示新建一个分支并同时切换到这个新建的分支下面，如再新建一个 develop2 分支并同时切换到这个分支下就可以用如下一行命令搞定：

```bash
git checkout -b develop2
```
<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161124_5.png?imageView2/0/h/300/w/575" >
  </center>
</div>

### 删除分支
如果要删除一个分支，使用 `git branch -d [branch-name]` 命令，如把 develop2 分支删除，就可以使用如下命令：

```bash
git branch -d develop2
```

<div >
<center>
    <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20161124_6.png?imageView2/0/h/300/w/575" >
  </center>
</div>

>注意：如果要删除的分支正是当前所在的分支，则会报错，需要切换到另一个分支，再可以执行删除命令。
>强制删除分支：`git branch -D [branch-name]` 命令。
 
### 合并分支

**Fast forward 模式（删除分支后，会丢掉分支信息）**

如果在 develop 分支里做了修改，想要把修改合并到 master 分支里面，就要用到合并分支命令 `git merge [branch]`，如在 develop 添加一个 test.txt 文件，然后合并到 master 分支里去：

```bash
touch test.txt // 添加一个 test.txt 文件 
git checkout master // 切换到 master 分支
git merge develop // 把 develop 分支中的修改合并到 master 分支
```
 
>注意：如果在 develop 分支和 master 对同一个文件做了不同的修改的话，则合并的时候会产生冲突，这个时候，需要打开那个冲突的文件，`<<<<<<< HEAD` 到 `=======` 线包裹的内容是来自 master 分支，`=======` 到 `>>>>>>> develop` 线包裹的内容是 develop 分支中的，需要删除其中一个分支中冲突的内容的包括所有包裹内容的线，然后再进行合并。 

**禁用Fast forward 模式（Git就会在merge时生成一个新的commit， 从分支历史上就可以看出分支信息。）**

```bash
git merge --no-ff -m "合并说明" branch-name
```


### 在本地创建和远程分支对应的分支

```bash
git checkout -b branch-name origin/branch-name
```

### 建立本地分支和远程分支的关联

```bash
git branch --set-upstream branch-name origin/branch-name
```

### 合并远程不是对应分支的代码

有时候如果远程有一条分支更新了一些代码，如newFetrue，fixBug，需要合并到本地，由于和本地不是对应关系，不能直接 pull 拉取合并，可以先在本地新建一个和远程对应的临时分支，然后再去合并这条临时分支上的代码

```
# develop:远程分支，temp 本地临时分支
git fetch origin develop:temp

# 合并 temp 分支
git merge temp

# 合并指定 commitId 的代码
git cherry-pick commitId

```

## #标签
在开发过程中，当发布了一个稳定的版本后，都会给代码带一个标签。主要的 git 命令如下：

### 新建标签

```bash
# 1. 当前 HEAD 打标签
git tag <name>

# 2. 给某个 commit 打标签
git tag <name> <commit id>

# 3. 创建带有说明的标签， 用 `-a` 指定标签名，`-m` 指定说明文字：
git tag -a <name> -m <说明> <commit id>

# 4. 当前 HEAD 打标签
git tag -a <name> -m <说明>

```

### 查看标签

```bash
# 1. 查看某一个标签的详情
git show <tagname>

# 2. 查看所有标签
git tag
```

### 推送标签到远程

```bash
# 1. 推送标签到远程
git push origin <tagname>

# 2. 一次性推送所有本地未推送到远程的标签到远程
git push origin --tags
```

### 删除标签
```bash
# 1. 删除本地标签
git tag -d <tagname>

# 2. 删除远程标签
git push origin :refs/tags/<tagname>

```

## #查看历史记录


## 采坑记录

### 1. 仓库太大，clone 太慢

碰到一个仓库，仓库代码 500 多兆，通过 http 的方式 git clone 出现报错，报错信息是：

`error: RPC failed; curl 18 transfer closed with outstanding read data remaining
fatal: The remote end hung up unexpectedly`

找了找网上的解决方案，主要有两个：

1. 增大 http postBuffer 的空间大小

```
# 全局设置 http postBuffer 的空间大小
git config --global http.postBuffer 524288000 // 大概 500 M，不够再自己加

# 查看是否设置成功
git config -l  
```

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180626_1.png)

>但这个方法对我无效。

2. 只 clone 最近的一次提交

```

# clone 最近的一次提交
git clone --depth=1 <仓库地址>

# 下载该分支下的所有提交记录信息
git fetch --unshallow

```

> 这样可以很快很轻量的把代码 clone 下来，但这中方式同样会有一个问题，就是只会默认 clone 默认分支下的代码，通常是 master 分支下的代码。接下来就需要用到下面的命令，比如下载日常开发分支 develop 下的代码：

```
# 设置和远程 develop 分支的连接
git remote set-branches origin 'develop'
# 下载远程 develop 分支下最近的一次提交 
git fetch --depth 1 origin develop
# 从远处 develop 分支新建一个 develop 的本地分支
git checkout -b develop origin/develop

```

![](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/Snip20180626_3.png)
