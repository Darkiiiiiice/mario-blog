---
title: 设计模式 (七)
date: '2020-12-07 22:00:00'
category: 设计模式
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-07 22:00:00'
---

# 设计模式 （七)

## 代理模式
> 代理模式(Proxy Pattern): 未其他对象提供一种代理以控制这个对象的访问, 也被称为委托模式

<div class="gallery-group-main">
{% galleryGroup '代理模式' '代理模式类图' '/resources/images/proxy.svg' /resources/images/proxy.svg %}
</div>

代理模式角色: 
1. Subject抽象主题角色
	> 抽象主题类定义最普通的业务类型
2. RealSubject 具体主题角色
	> 被委托角色, 被代理角色, 业务逻辑的具体执行者
3. Proxy 代理主题角色
	> 委托角色, 代理角色

###  优点
1. 职责清晰
	> 真实角色就是实现实际的业务逻辑, 不用关心其他非本职业务, 通过后期的代理角色完成事务
2. 高扩展性
	> 具体角色都是会随时变化的, 只要他实现了接口, 代理类就可以在完全不做任何修改的情况下使用
3. 智能化


### 使用场景	
1. 普通代理
> 客户端只能访问代理角色, 而不能访问真实角色 

``` golang
// 抽象角色
type Player interface {
	Login(username string)

	KillBoss()

	Upgrade()
}
```

``` golang
// 真实角色
type GamePlayer1 struct {
	Name  string
	Level int
}

func (g *GamePlayer1) Login(username string) {
	fmt.Printf("用户名: %s\n", username)
	g.Name = username
}

func (g *GamePlayer1) KillBoss() {
	fmt.Printf("%s 消灭了BOSS\n", g.Name)
}

func (g *GamePlayer1) Upgrade() {
	g.Level++
	fmt.Printf("%s 升级了, 当前等级为: %d\n", g.Name, g.Level)
}
```

``` golang
// 代理角色
type GameProxy struct {
	GamePlayer Player
}

func (g *GameProxy) Login(username string) {
	g.GamePlayer.Login(username)
}

func (g *GameProxy) KillBoss() {
	g.GamePlayer.KillBoss()
}

func (g *GameProxy) Upgrade() {
	g.GamePlayer.Upgrade()
}
```

``` golang
// 场景类
func main() {
	player := &proxy.GamePlayer1{}

	gameProxy := &proxy.GameProxy{GamePlayer: player}

	gameProxy.Login("Mario")
	gameProxy.KillBoss()
	gameProxy.Upgrade()
}
```
