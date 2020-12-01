---
title: 设计模式 (五)
date: '2020-12-01 22:00:00'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-01 22:00:00'
---

# 设计模式 （五)

## 模板方法模式
> 模板方法模式(Template Method Pattern): 一个操作中的算法框架, 而将一些步骤延迟到子类中, 使得子类可以不改变一个算法的结构即可重定义该算法的某些特定步骤

抽象模板中的方法: 
1. 基本方法: 
    基本方法也叫做基本操作, 是由子类实现的方法, 并且在模板方法被调用
2. 模板方法: 
    可以有一个或者几个, 实现对基本方法的调度, 完成固定逻辑

``` Golang
// 抽象模板类接口
type IPerson interface {
	Talk()
	Jump()
	Move()
}
```

``` Golang
// 抽象模板类实现
type Person struct {
	Object IPerson
	Name   string
}

func (p *Person) Talk() {
	fmt.Println("name = ", p.Name)
}

func (p *Person) Jump() {
	fmt.Println(p.Name + " jump")
}

func (p *Person) Move() {
	if p.Object != nil {
		p.Object.Jump()
		p.Object.Talk()
	}
}
```
``` Golang
// 具体模板类实现
type Boy struct {
	Person
}

func (b *Boy) Talk() {
	fmt.Printf("boy[%s] talk\n", b.Person.Name)
}

func (b *Boy) Jump() {
	fmt.Printf("boy[%s] jump\n", b.Person.Name)
}

type Girl struct {
	Person
}

func (g *Girl) Talk() {
	fmt.Printf("girl[%s] talk\n", g.Person.Name)
}

func (g *Girl) Jump() {
	fmt.Printf("girl[%s] jump\n", g.Person.Name)
}
```
``` Golang
// 场景类
func main() {

	p1 := &template.Person{}
	p2 := &template.Person{}
	p1.Object = &template.Boy{}
	p2.Object = &template.Girl{}

	p1.Move()
	p2.Move()
}
```


### 模板方法模式的应用

#### 优点
1. 封装不变部分, 扩展可变部分
> 把认为不变部分的算法封装到父类实现, 而可变部分的则可以通过继承来继续扩展
2. 提取公共部分代码, 便于维护
3. 行为由父类控制, 子类实现
> 基本方法是由子类实现的, 因此子类可以通过扩展的方式增加相应的功能, 符合开闭原则

#### 缺点
1. 多个子类有公有的方法, 并且逻辑基本相同
2. 重要复杂的算法, 可以把核心算法设计为模板方法
3. 重构时, 模板方法模式是一个经常使用的模式, 把相同的代码抽取到父类中, 然后通过钩子函数约束其行为

