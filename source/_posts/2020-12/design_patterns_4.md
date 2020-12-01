---
title: 设计模式 (四)
date: '2020-12-01'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-01 21:00'
---

# 设计模式 （四)

## 抽象工厂模式
> 抽象工厂模式(Abstract Factory Pattern): 为创建一组相关或相互依赖的对象提供一个接口, 而且无须指定他们的具体类

<div class="gallery-group-main">
{% galleryGroup '抽象工厂模式' '抽象工厂模式类图' '/resources/images/abstract_factory.jpg' /resources/images/abstract_factory.jpg %}
</div>

抽象工厂模式是工厂模式的升级, 在多个业务品种, 业务分类时, 通过抽象工厂模式产生需要的对象

### 抽象工厂模式的应用

#### 优点
1. 封装性, 只需要直到工厂类, 就可以创建出一个需要的对象
2. 产品族内的约束为非公开状态

#### 缺点
产品族扩展非常困难

#### 使用场景
一个对象族都有相同的约束, 则可以使用抽象工厂类