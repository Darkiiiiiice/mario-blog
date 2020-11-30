---
title: Git 版本控制管理
date: '2020-11-30 23:00:00'
category: Git
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-11-30 23:00:00'
---

# Git 版本控制管理

## Git 关键特性

1. 有助于分布式开发
2. 能够胜任上千开发人员的规模
3. 性能优异
4. 保持完整性和可靠性
5. 强化责任
6. 不可变性
7. 原子事务
8. 支持并且鼓励基于分支的开发
9. 完整的版本库
10. 自由免费(Be free, as in freedom)

## 安装 Git

> 目前主流发行版都默认会安装 git
1. Debian/Ubuntu
``` Bash
$ sudo apt-get install git 
```
2. CentOS/Fedora
``` Bash
$ sudo yum install git
```
3. Arch/Manjaro
``` Bash
$ sudo pacman -S git
```
4. Mac OS X
``` Bash
brew install git
```


## Git 简易命令

* 显示版本号
``` Bash 
$ git --version
```

* 配置提交作者
``` Bash
$ git config user.name "MarioMang"
$ git config user.email "zbackdoor@qq.com"
```
> 也可以设置 GIT_AUTHOR_NAME 和 GIT_AUTHOR_EMAIL

* 创建初始版本库
``` Bash
$ git init
```
> git 不关心你初始化的仓库是空的还是有文件的, git init 创建了一个隐藏目录 名为 .git

* 将文件添加到版本库
``` Bash
$ git add index.html
```
> git add . 会将当前目录以及子目录中的文件都添加到版本库中, 因为 . 代表了当前目录路径  
> git add 相当于只是暂存(staged)了这个文件, 并没有提交

* 显示当前版本库状态
``` Bash
$ git status
```

* 提交更新
``` Bash
$ git commit -m 'Initial content'
```
> 如果环境变量中设置了 GIT_EDITOR, 在 git commit 时, 会打开 GIT_EDITOR 设置的编辑器, 用来编辑提交信息

* 查看提交记录
``` Bash
$ git log
```
> 显示版本库中所有单独的提交  
> 根据提交的拓扑顺序展示
``` Bash
$ git show dfc132f823c24a027ec17eba2dcac0f1fcf44664
```
> 显示 git log 展示的特定的提交信息, 如果不加 uuid 参数, 则会展示最近一次提交的详细信息
``` Bash
$ git show-branch --more=10
```
> 提供当前分支提交记录的单行摘要

* 查看提交差异
``` Bash 
$ git diff dfc132f823c24a027ec17eba2dcac0f1fcf44664 ffb85896fc111ecda9aa34cc1d43513d9888c30f
```
> 显示两个提交版本之间的差异

* 版本库内删除文件和重命名
``` Bash
$ git rm index.html
```
> 从版本库中删除一个你不需要的文件
``` Bash
$ git mv foo.html bar.html
```
> 为版本库中的文件重命名

* 创建版本库的副本
``` Bash
$ git clone public_html clone_html
```


### 配置文件

* .git/config
	> 版本库特定的配置 可用 --file 参数修改, 默认选择, 优先级最高  
	> 可以使用 --unset 移除设置
	``` Bash
	$ git --unset --file user.email
	```

* ~/.gitconfig
	> 用户特定的配置 可用 --global 参数修改  
	> 可以使用 --unset 移除设置
	``` Bash
	$ git --unset --global user.email
	```

* /etc/gitconfig
	> 系统范围的设置 可用 --system 参数修改, 需要系统权限  
	> 可以使用 --unset 移除设置
	``` Bash
	$ git --unset --system user.email
	```


## 基本概念

1. 版本库  
	Git版本库(repository) 是一个简单数据库, 其中包含所有用来维护于管理项目的修订版本和历史信息  
	Git在每个版本库中维护一组配置元数据, 这些配置不会跟随clone或者复制转移  
	Git版本库中维护两个重要的数据结构 *对象库(object store)* 和 *索引(index)*

2. Git 对象类型
	Git 有4种对象类型: *块(blob)* *目录树(tree)* *提交(commit)* *标签(tag)*  
	1. 块(blob)
		文件的每一个版本表示为一个块, 一个blob保存一个文件的数据, 但不包含这个文件的元数据
	2. 目录树(tree) 
		一个目录树对象代表一层目录信息, 它记录 blob 标识符 路径名和一个目录中所有文件的元数据  
		它也可以递归引用其他目录树或子树对象, 从而建立一个包含文件和子目录完整层次结构
	3. 提交(commit) 
		一个提交对象保存版本库中每一次变化的元数据, 包括作者, 提交者, 提交日期和日志消息  
		每一个提交指向一个目录树对象, 这个目录树对象在一张完整的快照中捕获提交时版本库的状态
	4. 标签(tag)
		一个标签对象分配一个任意的且人类可读的名字给一个特定对象, 通常是一个提交对象

3. 索引
	索引是一个临时的, 动态的二进制文件, 他描述整个版本库的目录结构

4. 可寻址内容名称
	Git 对象库被组织及实现一个内容寻址的存储系统  
	对象库中的每个对象都有一个唯一的名称, 这个名称时向对象的内容应用SHA1的到的SHA1散列值

5. Git 追踪内容
	1. Git 对象库时基于对象内容的散列计算的值, Git追踪的是文件的内容, 而不是文件名
	2. 如果两个文件的内容完全一样, 无论是否在相同的目录中, Git 在对象库中只保存一份 blob 形式的内容副本
	3. 如果文件发生变化, Git 会重新为该文件计算一个 SHA1 散列值, 识别它现在是一个不同的对象
	4. 当一个文件从一个版本变化到另一个版本时, Git 内部可以有效的存储每个文件的每个版本, 而不是他们的差异

6. 路径名于内容
	Git 把文件名视为一段区别于文件内容的数据  
	数据库对比
	| 系统 | 索引机制 | 数据存储 |
	|:---:|:---:|:---:|
	| 传统数据库 | 索引顺序存取方法 | 数据记录 |
	| Unix 文件系统 | 目录 | 数据块 |
	| Git | .git/objects/hash 树对象内容 | blob对象 树对象|

7. 打包文件
	Git 首先定位内容非常相似的全部文件, 然后为他们之一存储整个内容, 之后计算相似文件之间的差异并且值存储差异
