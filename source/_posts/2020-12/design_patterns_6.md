---
title: 设计模式 (六)
date: '2020-12-02 22:00:00'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-02 22:00:00'
---

# 设计模式 （六)

## 建造者模式
> 建造者模式(Builder Pattern): 将一个复杂对象的构建与他的表示分离, 使得同样的构建过程可以创建不同的表示

在建造者模式下有如下4个角色:
1. Product 产品类
	通常是实现了模板方法模式
2. Builder 抽象建造者
	规范产品的组件
3. ConcreteBuilder 具体建造者
	实现抽象类定义的所有方法
4. Director 导演类
	负责安排已有模块的顺序

``` golang
// product
type Product struct {
	name string
}

func (p *Product) DoSomething() {
	fmt.Printf("name =[%s]\n", p.name)
}
```

``` golang
// 抽象建造者
type Builder interface {
	SetName(name string)

	Build() Product
}
```

``` golang
// 具体建造者
type ConcreteBuilder struct {
	product Product
}

func (c *ConcreteBuilder) SetName(name string) {
	c.product.name = name
}

func (c *ConcreteBuilder) Build() Product {
	return c.product
}
```

``` golang
// 导演类

type Director struct {
	builder Builder
}

func (d *Director) GetAdProduct() Product {
	d.builder.SetName("ad product")
	return d.builder.Build()
}

func NewDirector() *Director {
	d := new(Director)
	d.builder = new(ConcreteBuilder)
	return d
}
```

``` golang 
// 场景
func main() {
	director := builder.NewDirector()
	product := director.GetAdProduct()
	product.DoSomething()
}
```

### 优点
1. 封装性
2. 建造者独立, 容易扩展
3. 便于控制细节风险

### 使用场景
1. 相同的方法, 不同的执行顺序, 产生不同的顺序时
2. 多个部件或零件, 都可以装配到一个对象中, 但是产生的运行结果又不一样
3. 产品类非常复杂, 或者产品类中的调用顺序不同产生了不同的效能
4. 在对象创建过程中会使用到系统中的一些其他对象