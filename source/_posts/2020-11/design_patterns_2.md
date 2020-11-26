---
title: 设计模式 (二)
date: '2020-11-26'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
---

# 设计模式 （二)

## 单例模式
> 单例模式(Singleton Pattern)  
> 定义: 确保某一个类只有一个实例, 而且自行实例化并向整个系统提供这个实例

### 单例模式的应用

#### 优点
1. 减少创建对象或销毁对象时的内存开支
2. 当创建对象需要大量系统开支的时候, 可以减少系统开销
3. 避免软件对资源的重复占用
4. 在系统设置全局资源访问点, 优化和共享资源访问

#### 缺点
1. 没有接口, 扩展困难
    > 接口和抽象类是无法实例化的, 但是在特殊情况下可以实现接口, 被继承
2. 对测试不利
    > 在并行开发环境中, 如果单例模式没有完成, 不能进行测试
3. 单例模式于单一职责原则有冲突
    > 一个类应该只实现一个逻辑, 而不关心它是否是单例

#### 使用场景
1. 要求生成唯一序列号的环境
2. 整个项目需要一个共享访问点或共享数据
3. 创建一个对象需要消耗过多资源
4. 需要定义大量的静态常量和静态方法的环境

#### 注意事项

1. 懒汉模式
> 非线程安全, 当正在创建时, 有线程来访问时 singleton == nil, 就会再创建对象, 单例类就会有两个实例
``` golang
// singleton.go
var singleton *Singleton 

type Singleton struct {
	Tag   string
}

func GetSinglePointer() *Singleton {
	if singleton == nil {
		singleton = &Singleton{Tag: "default"}
	}
	return singleton
}
```

2. 饿汉模式
> 如果singleton创建初始化比较复杂耗时时, 加载时间会延长 
``` golang
// singleton.go
var singleton *Singleton = &Singleton{Tag: "default"}

type Singleton struct {
	Tag   string
}

func GetSingletonPointer() *Singleton {
	return singleton
}
```

3. 懒汉加锁
> 每次请求都会加锁, 消耗资源
``` golang 
// singletong.go
var singleton *Singleton
var mutex sync.Mutex

type Singleton struct {
	Tag string
}

func GetSingletonPointer() *Singleton {
	mutex.Lock()
	defer mutex.Unlock()
	if singleton == nil {
		singleton = &Singleton{Tag: "default"}
	}
	return singleton
}
```

4. 双重锁机制
> 避免了每次获取实例都加锁
``` golang 
// singleton.go
var singleton *Singleton
var mutex sync.Mutex

type Singleton struct {
	Tag string
}

func GetSingletonPointer() *Singleton {
	if singleton == nil {
		mutex.Lock()
		defer mutex.Unlock()
		if singleton == nil {
			singleton = &Singleton{Tag: "default"}
		}
	}
	return singleton
}
```

5. sync.Once
> go能保证这个函数中的代码仅仅执行一次
``` golang
// singleton.go
var singleton *Singleton
var once sync.Once

type Singleton struct {
	Tag string
}

func GetSingletonPointer() *Singleton {
	once.Do(func() {
		singleton = &Singleton{Tag: "default"}
	})
	return singleton
}
```