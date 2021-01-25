---
title: 设计模式 (三)
date: '2020-11-30'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-11-30 21:00'
---

# 设计模式 （三)

## 工厂方法模式
> 工厂方式模式: 定义一个用户创建对象的接口, 让子类决定实例化哪一个类, 工厂方法使一个类实例化延迟到子类

<div class="gallery-group-main">
{% raw %}
{% galleryGroup '工厂模式' '工厂模式类图' '/resources/images/factory.png' /resources/images/factory.png %}
{% endraw %}
</div>

``` Golang
/* product.go */
// 定义产品接口,
type Product interface {
	Method()
}

type ConcreteProduct struct {
	// 定义具象化的产品类, 实现 Product 接口
}

func (p *ConcreteProduct) Method() {
	// 业务逻辑
}
```

``` Golang
/* factory.go */
// 定义工厂接口
type Factory interface {
	CreateProduct() Product
}

// 定义具象化的工厂, 实现 Factory 接口
type ConcreteFactory struct {
}

func (c ConcreteFactory) CreateProduct() Product {
	// 根据不同条件生产不同的具象化 Product
	return new(ConcreteProduct)
}

```


### 工厂方法模式的应用

#### 优点

1. 良好的封装性
	> 创建对象进行约束, 降低模块间的耦合
2. 扩展性优秀
	> 在增加产品品类的时候, 只需要修改具体的工厂类或者扩展一个工厂类即可
3. 屏蔽产品类
	> 产品类的变化, 不需要调用这关心 

#### 使用场景	

1. 工厂方法用来替代 new 的方式创建对象
2. 需要灵活扩展框架的情况下, 可以考虑采用工厂模式
3. 一个类不需要知道他的创建过程

### 工厂模式扩展

#### 简单工厂模式
> 当一个模块仅需要一个工厂类时, 可以使用静态方法实现工厂类
``` Golang
// factory.go
package factory

func CreateProduct() Product {
	return new(Product)
}

```
``` Golang
// main.go
func main() {
	var product = factory.CreateProduct()
}
```

#### 多个工厂模式
> 当一个工厂类无法生产众多的产品的对象时, 一个产品具有多个具体实现时, 每个产品初始化方式都不相同时, 就需要对工厂类进行拆分
``` Golang
// product_1.go
type Prod1Factory struct {
	// 实现 Factory 接口
}

func (f Prod1Factory) CreateProduct() Product {
	// 根据不同条件生产不同的具象化 Product
	return new(Prod1Factory)
}
```
``` Golang
// product_2.go
type Prod2Factory struct {
	// 实现 Factory 接口
}

func (f Prod2Factory) CreateProduct() Product {
	// 根据不同条件生产不同的具象化 Product
	return new(Prod2Factory)
}
```


#### 代替单例模式
> 通过工厂模式 在内存中 只生产一个对象, 就完成了单例模式
