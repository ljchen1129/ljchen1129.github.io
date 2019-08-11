---
title: 团队 git-flow 开发流程
date: 2018-10-20 14:50:06
tags:
- 软件工程
categories:
- 软件工程
---

## 前言
之前做项目的时候，出现过一些因为代码提交管理出现的问题。问题如下：

1. 分支过多，每个做马甲一个分支，每次混淆完又一个备份分支，每次企业包发版一个分支、每个新特性又是一个分支，大量的分支，又没有及时的删除，一方面容易造成 git 服务器的存储压力，另一方面，大量的提交记录造成工程体积庞大，全部 clone 下来好几个 G，费时费力，http 方式 clone 也容易报 `RPC failed; curl 18 transfer closed with outstanding read data remaining` 错。
<!-- more -->
2. 有些文件和资源没有必要纳入到版本管理中去。如 pod 的库，只保存 podfile 文件在远程就可以了，需要的时候本地 podfile install/update 就行，可以添加到 git 忽略文件里去。github 上专门有个仓库收纳了各个语言开发时的 [gitignore](https://github.com/github/gitignore) 模板，可以参考下。
3. 修改 bug 或者开发完新特性后没有及时全部同步到所有分支。同样是因为分支过多以及没有一个规范，造成有些 bug 或者新特性在某个分支修复和开发完了，另外的分支却没有及时同步。
4. 打包管理，应该要保证发包前测试通过后的项目代码是不能有任何修改的，最好能够自动化打包，避免开发人员人为修改代码后打包上传，造成测试人员测试通过的代码和真正发包的代码不一致问题。

## git 规范
参考 [git flow](https://nvie.com/posts/a-successful-git-branching-model/)，一图胜千言

![](https://liangjinggege.com/git-flow.png)

### 中心分支
生命周期长，一直存在。

#### Master（主分支）
顾名思义，既然名字叫 Master，那么该分支就是主分支的意思。在 git repo下主分支的职责主要就是负责记录 stable版本的迭代，当在 beta 版本的项目或是开发版本的项目得到了充分的验证之后，才能将分支并入 master 分支。master 分支永远是 production-ready 的状态，即稳定可产品化发布的状态。每发布一个版本则打上对应的 tag 标签。

#### Develop（开发分支）
这个分支是平常开发的一个主要分支，不管是要做新的 feature 还是需要做 bug fix，都是从这个分支分出来做。在这个分支下主要负责记录开发状态下相对稳定的版本，即完成了某个 feature 或者修复了某 个bug 后的开发稳定版本。从 develop 分支总能够获得最新开发进展的代码。

##### 1. 从 master 分支迁出

```shell
git checkout -b develop master
```

##### 2. 拉取远程最新代码

```shell
git fetch origin develop
```

##### 3. 合并本地

```shell
git merge origin/develop
// 或者
git rebase origin/develop
```

##### 4. 推送到远程

```shell
git push origin develop
```


### 辅助分支
生命周期短，完成使命后删除。

#### Feature branches（功能分支）

这是由许多分别负责不同 feature 开发的分支组成的一个分支系列。new feature 主要就在这个分支系列下进行开发。当在一个大的 develop 的迭代之下，往往会把每一个迭代分成很多个功能点，并将功能点分派给不同人的人员去开发。每一个人员开发的功能点就会形成一个 feature 分支，当功能点开发测试完毕之后，就会合并到 develop 分支去。

##### 1. 从 develop 分支新建一条特性分支并切到这条分支上

```shell
git checkout -b feature-xxx develop
```

##### 2. 做完了新特性切回到 develop 分支

```shell
git checkout develop
```

##### 3. 合并新特性分支

```shell
git merge --no-ff -m "合并说明" feature-xxx
```

##### 4. 删除分支

```shell
git branch -d feature-xxx
```

##### 5. 提交代码到远程

```shell
git push origin develop
```

#### Release branches（发布辅助分支）
Relase branch 通常负责短期的发布前准备工作、小 bug 的修复工作、版本号等元信息的准备工作。与此同时，develop 分支又可以承接下一个新功能的开发工作了。

在一段短时间内，在 Release branches 上，我们可以继续修复 bug。在此阶段，严禁新功能的并入，新功能应该是被合并到 develop 分支的。

经过若干 bug 修复后，Release branches 上的代码已经达到可发布状态，此时，需要完成三个动作：第一是将 Release branches 合并到 master 分支，第二是一定要为 master 上的这个新提交打 Tag（记录里程碑），第三是要将 Release branches 合并回 develop 分支。

##### 1. 当一个迭代测试的差不多的时候，从 develop 分支切出来

```shell
git checkout -b release-0.1 develop
```

​
##### 2. 一旦准备好了发版，合并修改到 master 分支和 develop 分支上，删除发布分支
​
​```shell
​#合并修改到 master 分支
git checkout master 
git merge --no-ff -m "合并说明" release-0.1 
git push origin master
​```

​
##### 3. 打标签

```shell
git tag -a v0.1 -m "version 0.1 released"

// 推送标签到远程
git push origin v1.0
```
​
##### 4. 合并修改到 develope 分支

```shell
git checkout develop 
git merge --no-ff -m "合并说明" release-0.1 
git push origin develop
```

​
##### 5. 删除发布分支

```shell
git branch -d release-0.1
```

#### Hotfix branches（热修复分支）
这个分支系列是紧急线上修复，当线上出现 bug 且特别紧急的时候，就可以从 master 拉出分支到这里进行修复，修复完成后分别并入 master 和 develop 分支。

##### 1. 从 master 主分支上切出来

```shell
git checkout -b hotfix-#001 master
```

##### 2. 修复bug完成

```shell
#切回主分支
git checkout master  
#合并到主分支
git merge --no-ff -m "合并说明" hotfix-#001 
#推送到远程
git push origin master

# 合并到 develop 分支
git checkout develop
git merge --no-ff -m "合并说明" hotfix-#001
​
#删除 bug 修复分支
git branch -d bugfix-#001
```


## pull request & codeReview

需要执行 codeReview 的时候可以引入一些工具，在完成代码推送到远程后，将提交合并到 mater 分支之前，设置 codeReview。

## 解决冲突

还未提交到本地暂存区

```shell

# `file` 指那个需要回退的文件
git checkout -- file 
已经提交到本地暂存区，没有提交到本地
# `file` 指那个需要回退的文件
git reset HEAD file  
​
# 此操作相当于让之前的 git add 失效：
git checkout -- file 
```

已经提交到本地，没有提交到远程

```shell
# 此操作相当于让之前的 git commit -m "修改说明" 失效。
# HEAD^表示上一个版本，HEAD^^则表示上上个版本，再往上 100 个版本可以写成HEAD~100
git reset --hard HEAD^
```

已经提交到远程

```shell
# 采取 revert 的方法，相当于重新生成一个提交，来撤销前一次错误的commit:
git revert HEAD
​
# 然后再把从工作区提交到暂存区，最后推送到远程分支：
git add .
git commit -m "撤销上次提交的修改"
git push origin master
```

## 草稿箱

有时候，需要切换到其他分支去，而当前分支开发任务还未完成提交，可以暂存到草稿箱中去。

```shell

# 存入草稿箱
git stash
​
# 取出草稿
git stash pop
git stash apply
​
#查看草稿箱
git stash list
​
#显示某次草稿的具体文件
git stash show [stash序号]
```

## 注意点

待补充...