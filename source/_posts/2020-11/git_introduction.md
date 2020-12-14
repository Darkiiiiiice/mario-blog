---
title: Git 版本控制管理
date: '2020-11-30 23:00:00'
category: Git
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-14 23:00:00'
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


## 文件管理和索引
> Git 在工作目录和版本库之间增加了一层索引, 用来暂存, 收集或修改  
> Git 提交会分为两步 暂存变更 和 提交变更  

Git的索引不包含任何文件内容, 它仅仅追踪你想要提交的那些内容

### Git 中的文件分类
1. 已追踪的(Tracked)
	> 已追踪的文件是指已经在版本库中的文件, 或者是已经暂存到索引中的文件  
	> 如果想要将新文件添加为已追踪
	``` bash
	$ git add filename
	```

2. 被忽略的(Ignored)
	> 被忽略的文件必须在版本库中被声明为不可见或忽略

3. 未追踪的(Untracked) 
	> 未追踪的文件是指那些不再前两类中的文件

### 使用 git add 
git add 命令将暂存一个文件, 如果一个文件是未追踪状态, 那么 git add 就会将文件的状态转化为已追踪状态  

在 Git 对象模型中, git add会将每个文件的全部内容都复制到对象库中, 并按文件的SHA1来索引  

可以使用 git ls-files 查看隐藏在对象模型下的东西, 并且可以找到那些暂存文件的 SHA1 值
``` bash
$ git ls-files
```

### 使用 git commit 
git commit -a 会导致执行提交之前 自动暂存所有未暂存的和未追踪的文件变化, 包括从工作副本中删除的已追踪文件  

### 使用 git rm 
git rm 会在版本库和工作目录中同时删除文件  

从工作目录和索引中删除一个文件, 并不会删除该文件在版本库中的历史记录  

将一个文件从已暂存变化为未暂存状态
``` bash
$ git rm --cached filename
```
> 这是很危险的一件事, 因为你有可能忘记这个文件是不再被追踪的


### 使用 git mv
git mv 会删除旧文件在索引中的路径, 并添加新文件的路径, 然后将对象库中的旧文件内容与新文件的索引关联  

### .gitignore 文件
.gitignore 文件格式
* 空行会被省略, #开头的行被用于注释
* 文件名匹配目录中的同名文件
* 目录名由末尾的/标记, 匹配目录中的同名目录和子目录, 但不匹配文件或符号链接
* 包含shell通配符
* 起始!会对改行其余部分的模式进行取反

Git 允许在版本库中任何目录下有 .gitignore 文件, 每个文件只影响该目录和子目录  

Git .gitignore 目录优先级:
* 在命令中指定的模式
* 从相同目录的 .gitignore 中读取的模式
* 上层目录中的模式
* 来自 .git/info/exclude 中的模式
* 来自配置变量core.excludefile 指定的文件中的模式



## 提交

在Git中, 提交(commit)是用来记录版本库的变更的

当提交时, Git会记录索引的快照并把快照放进对象库, 这个快照不包含任该索引中任何文件或目录的副本

提交是将变更引入版本库中的唯一方法

### 原子变更集
每一个Git提交都代表一个相对于之前状态的单个原子变更, 对所有做过的改动要么全部应用, 要么全部拒绝

### 识别提交
在Git中, 可以通过显示或隐式引用来指代每一个提交  
显示引用 唯一的 40 位十六进制SHA1提交ID
隐式引用 始终指向最新提交的HEAD

1. 绝对提交值 每一个提交的散列ID都是全局唯一的
2. 符号引用 
	> 引用是一个SHA1散列值, 指向Git对象库中的对象  

	符号引用 间接指向Git对象  
	每一个符号引用都有一个以ref/开始的明确全称, 存储在.git/refs/目录中  
	* refs/heads/ref 代表本地分支  
	* refs/remotes/ref 代表远程分支  
	* refs/tags/ref 代表标签  

	Git自动维护几个用于特定目的的特殊符号引用, 这些引用可以在使用提交的任何地方使用  
	1. HEAD 
	始终指向当前分支的最近提交
	2. ORIG_HEAD
	某些操作, 会把调整之前的版本HEAD记录到ORIG_HEAD中
	3. FETCH_HEAD
	当使用远程库时, git fetch 会把所有抓取分支的头记录到FETCH_HEAD中, 所以FETCH_HEAD记录的是最近抓取的分支HEAD
	4. MERGE_HEAD
	当一个合并操作正在进行时, 其他分支的头暂时记录在MERGE_HEAD中
	
### 提交历史记录
1. 查看旧提交
``` bash 
$ git log
```
变更从HEAD提交开始显示, 并从提交图中回溯

``` bash
$ git log master
```
如果你提供一个提交名, 那么这个日志将从该提交开始回溯输出

``` bash
$ git log --abbrev-commit master~12..master~10
```
显示在 master\~12 到 master~10 之间的所有提交

``` bash
$ git log -p commit
```
引入-p选项输出提交引进的补丁或变更

``` bash
$ git log --stat master~12 master~10
```
--stat 列举了提交中锁更改的文件以及每个更改的文件中有多少做了改动

### 查找提交
1. 使用 git bisect
git bisec 是一个功能强大的工具, 他一般基于任意搜索条件查找特定的错误提交
``` bash
$ git bisect start
```
启动二分搜索后, git 将进入二分模式  
一旦启动后 你要告诉Git哪个是坏提交
``` bash
$ git bisect bad
```
同样你要告诉Git 哪个是好提交
``` bash
$ git bisect good
```
在二分搜索过程中, Git维护一个日志来记录你的回答及提交ID
``` bash
$ git bisect log
```
不断通过 git bisect bad 或者 git bisect good 来确定当前版本是好版本还是坏版本, 最后完成二分查找
回到原来的状态
``` bash
$ git bisect reset
```

2. 使用 git blame
该命令可以告诉你一个文件中的每一行最后是谁修改的和哪次提交做出了变更
``` bash
$ git blame -L 23, version.c
```

## 分支

### 分支名
版本库中默认的分支命名为master  
为了可扩展性和分类组织, 可以创建一个带有层次的分支名, 类似于 UNIX 路径名, 例如: bug/pr-192或 bug/pr-2994

分支命名中的简单规则 
1. 可以使用斜杠创建一个分层的命名方案, 但是该分支名不能以斜线结尾
2. 分支名不能以减号开头
3. 以斜杠分割的组件不能以 (.) 开头
4. 分支名的任何地方都不能包含两个连续的点 (..)
5. 此外分支名不能包含以下内容
	* 任何空格或其他空白字符
	* Git 中的关键字 ~/^/:/?/*/[
	* ASCII码控制字符

这些规则是由 git check-ref-format 底层命令强制检测的, 而且分支名在 .git 目录中作为一个文件名是可用的

### 使用分支
版本库中可能存在多个分支, 但是最多只有一个分支是处于活动状态的

分支允许版本库中每一个分支的内容向许多不同的方向发散, 每次提交应用到某个分支时, 取决于当前的活动分支

Git 不会保存分支的起源信息, 相反, 分支名随着分支上新的提交而增量的向前移动

#### 创建分支
``` bash
$ git branch bug/pr-1238
$ git branch branch-name [starting-commit]
```
git branch 只是把分支名引入版本库, 并没有改变工作目录去使用新的分支

#### 列出分支名
``` bash
$ git branch
```
git branch 命令列出版本库中的分支名, 可以使用 -r 列出所有远程分支, 也可以使用 -a 列出所有分支

#### 查看分支
``` bash
$ git show-branch
```
git show-branch 提供比 git branch 更详细的输出, 按时间以倒序列出对分支有贡献的提交
1. 加号表示提交在一个分支中
2. 星号突出显示在活动分支的提交
3. 减号表示一个合并提交

#### 检出分支
检出 master 分支
``` bash
$ git checkout master
```

改变分支的影响: 
* 被检出的分支中存在, 但是当前分支中不存在的文件, 会从对象库中检出并放置在目录中
* 在当前分支中但不在被检出的分支中的文件, 会从工作目录中删除
* 这两个分支中都有的文件, 会被修改为被检出分支中的内容

强制检出分支
``` bash
$ git checkout -f dev
```

合并并检出
``` bash
$ git checkout -m dev
```
该操作会在你的本地修改和目标分支之间进行一次合并操作

创建并检出新分支
``` bash 
$ git checkout -b new-branch
```
与 git branch new-branch start-point 命令是相同的

分离HEAD分支
在下面情况下, Git 会自动创建一个匿名分支, 称为一个分离的HEAD(detached HEAD)
1. 检出的提交不是分支的头部
2. 检出一个追踪分支
3. 检出标签引用的提交
4. 启动一个 git bisect 操作
5. 使用 git submodule update 命令

#### 删除分支
``` bash
$ git branch -d dev
```
从版本库中删除分支, 但是 Git 会阻止你删除当前分支  
Git 不允许删除一个包含不存在与当前分支中的提交的分支

## diff
diff 是 differences 的缩写, 指的是两个事物的不同  
diff 命令会比较两个文件的差异然后显示出来

Git diff 可以遍历两个树对象, 同时显示他们间的差异

以下是三种可供树对象或类树对象使用 git diff 命令的基本来源:
1. 整个提交图中的任意树对象
2. 工作目录
3. 索引

git diff 命令可以使用上述三种来源的组合来进行如下几种比较
1. git diff
	> git diff 会显示工作目录和索引之间的差异, 同时会显示工作目录中什么是脏的, 并把这个脏文件作为下个提交暂存
2. git diff commit 
	> 这个形式会显示工作目录和给定提交间的差异
3. git diff --cached commit 
	> 这个形式会显示索引中的变更中和给定提交中的变更差异, 如果省略 commit, 则会默认使用 HEAD
4. git diff commit1 commit2 
	> 这个形式会显示两个提交之间的差异, 会忽略索引和工作目录
5. git diff -M 
	> 这个选项可以用来查找重命名并且生成一个简化的输出
6. -w 或 --ignore-space
	> 这个选项会在比较时忽略空白字符
7. --stat
	> 这个选项会显示针对两个树状态之间差异的统计数据
8. --color
	> 这个选项会使结果使用多种颜色显示

## 合并
当一个分支中的修改与另一个分支中的修改不发生冲突时, Git会计算合并结果, 并创建一个新提交来代表新的统一状态  
但是当分支冲突时, Git 并不解决冲突, Git会在修改索引中标记为 未合并, 留给开发人员处理, 当 Git 无法自动合并时, 你需要在所有冲突都解决后做一次最终提交

### 合并两个分支
``` bash
$ git merge dev
```
当出现冲突合并时, 应当使用 git diff 命令来调查冲突的程度, 改变的内容显示在<<<<<<<和=======之间, 替代的内容在 >>>>>>> 和=======之间

### 处理合并冲突
1. 定位冲突文件
``` bash
$ git status
$ git ls-file -u 
```
用以上命令来显示工作树中仍然未合并的一组文件

2. 检查冲突
通过检查冲突文件副本, 找到冲突处, 解决冲突, 移除冲突标记
	* 使用 git diff 命令
		> Git有一个特殊的, 特定的用于合并的 git diff 变体, 来同时显示两个父版本做的修改, 可以拿HEAD和MERGE_HEAD版本跟工作目录版本进行比较
	* 使用 git log 命令
		> 可以使用一些特殊的 git log 选项来帮助你找出变更的确切来源
		``` bash
		$ git log --merge --left-right -p
		```
		git log 选项如下: 
		1. --merge 只显示跟产生冲突的文件相关的提交
		2. --left-merge 如果提交来自合并的左边则显示<, 如果冲突来自合并的右边则显示>
		3. -p 显示提交消息和每个提交相关联的补丁

3. Git 是如何追踪冲突的
	* .git/MERGE_HEAD 包含合并进来的提交的SHA1值
	* .git/MERGE_MSG 包含当解决冲突后执行 git commit 命令时用到的默认合并消息
	* Git的索引包含每个冲突文件的三个副本: 合并基础, 我们的版本和他们的版本
	* 冲突的版本不存储在索引中, 他存储在工作目录中的文件里

4. 结束解决冲突	
必须解决索引中记录的所有冲突文件, 只要有未解决的冲突, 就不能提交

当查看一个合并提交时, 应该注意
1. 在开头第二行新写着 Merge:
2. 自动生成的提交日志消息有助于标注冲突的文件列表
3. 合并提交的差异不是一般的差异, 它始终处于组合差异或者 冲突合并 模式

5. 终止或重新合并
``` bash
$ git reset --hard HEAD
```
将工作目录和索引重置到git merge 之前

如果要终止合并或在他已经结束后放弃
``` bash
$ git reset --hard ORIG_HEAD
```

### 合并策略
有两种倒置合并的常见退化情况
1. 已经是最新的
	> 当来自其他分支(HEAD)的所有提交都存在于目标分支上时, 即使它已经在自己的分支上前进了, 目标分支还是已经更新到最新的
2. 快进的
	> 当分支 HEAD 已经在其他分支中完全存在或表示时, 就会发生快进合并

(未完待续...)


