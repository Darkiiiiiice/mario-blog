---
title: Python 学习笔记（一） 
date: '2022-01-11 22:00:00'
category: Python
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2022-01-11 22:00:00'
---

## Python 

### 变量和简单数据类型

#### 变量

* 变量的命名和使用

  * 变量名只能包含字母，数字和下划线。变量名可以字母或下划线打头，但不能以数字打头
  * 变量名不能包含空格，但可以使用下划线来分割其中的单词
  * 不要将Python的关键字和函数名用作变量名
  * 变量名应既简短又具有描述性
  * 慎用小写字母l和大写字母O

#### 字符串 

* 使用方法修改字符串的大小写

``` python
name="ada lovelace"
print(name.title())
```

* 拼接字符串

``` python
first_name = "ada"
last_name = "lovelace"
full_name = first_name + " " + last_name
```

* 使用制表符或换行符来添加空白

``` python
print("\tPython")
```

* 删除空白

``` python
favorite_language = "python"
favorite_language.rstrip() // 删除右侧空白
favorite_language.lstrip() // 删除左侧空白
favorite_language.strip()  // 删除两端空白
```




