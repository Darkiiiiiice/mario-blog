---
title: Golang 并发
date: '2020-12-16 22:00:00'
category: Golang
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-17 22:00:00'
---

# Golang 并发

## 概述

* 竞争条件
当两个或多个操作必须按正确的顺序执行, 而程序并未保证这个顺序, 就会发生竞争条件
``` golang
func main() {
	var i = 0

	go func(){
		i++
	}()

	if i == 0 {
		fmt.Printf("i = %d\n",i)
	}
}
```
这段代码中, i++ 和 if i==0 {} 并无法保证他们两谁先执行, 谁后执行

* 原子性	
无法进一步分割的或者不可中断的操作, 被称为原子操作  
在考虑原子性时, 需要定义上下文或范围, 然后考虑在上下文环境中是否是原子性的

如果一个操作是原子的, 则认为他在并发环境中是安全的

* 内存访问同步
两个并发进程试图访问相同的内存区域, 他们访问内存的方式不是原子的
``` golang
func main() {
	var i = 0
	go func(){ i++ }()
	if i == 0 {
		fmt.Printf("i = 0")
	} else {
		fmt.Printf("i = %d\n",i)
	}
}
```
**临界区**: 程序中需要独占访问共享资源的部分  

	这段代码中有三个临界区: 
	1. goroutine 正在使变量递增
	2. if 语句, 检查数据值是否为0
	3. Printf, 检索并打印变量的值


* 死锁
如果所有进程彼此等待, 如果没有外界的干预, 这个程序将永远无法恢复, 这种状态称为死锁
``` golang
func main() {
	type value struct {
		mutex sync.Mutex
		value int
	}

	var wg sync.WaitGroup
	print := func(v1,v2 *value) {
		defer wg.Done()
		v1.mutex.Lock()
		defer v1.mutex.Unlock()

		time.Sleep(time.Second * 2)
		v2.mutex.Lock()
		defer v2.mutex.Unlock()

		fmt.Printf("v1 + v2 = %d\n", v1.value + v2.value)
	}

	var v1, v2 value
	wg.Add(2)
	go print(&v1, &v2)
	go print(&v2, &v1)
	wg.Wait()
}
```
第一次调用print锁定了v1, 然后试图锁定v2, 但在此期间, 第二次调用print已锁定了v2并试图锁定v1, 这导致两个goroutine都在等待彼此释放v1和v2

	出现死锁的必要条件(Coffman条件):
	* 相互排斥
		并发进程同时拥有资源的独占权
	* 等待条件
		并发进程必须同时拥有一个资源, 并等待额外的资源
	* 没有抢占
		并发进程拥有的资源只能被该进程释放, 即可满足这个条件
	* 循环等待
		一个并发进程(P1)必须等待一系列其他并发进程(P2), 这些并发进程同时也在等待进程(P1)
	如果确保至少有一个条件不成立, 我们便可以防止死锁


* 活锁	
活锁时正在主动执行并发操作的程序, 但这些操作无法向前推进程序的状态

* 饥饿
在任何情况下, 并发进程都无法获得执行工作所需的资源  
饥饿通常意味着有一个或多个贪婪的并发进程, 他们不公平的阻止一个或多个并发进程, 甚至阻止全部并发进程, 以尽可能有效的完成工作


## CSP
CSP(Communicating Sequential Processes)通信顺序进程

在sync包的文档描述中:  
sync包提供了基本的同步基元, 如互斥锁, 除了Once类型和WaitGroup类型, 大部分都是适用于低水平程序线程, 高水平的同步使用channel通信更好一些

Golang 的FAQ中:  
为了尊重mutex, sync包实现了mutex, 但是我们希望Golang语言的编程风格将会激励人们尝试更高等级技巧, 尤其时考虑构建你的程序, 以便一次只有一个goroutine负责某个特定的数据  

不要通过共享内存进行通信, 相反, 通过通信来共享内存, 有数不清的关于Golang核心团队的文章, 讲座和访谈, 相对于使用像sync.Mutex这样的原语, 他们更加拥护CSP


## goroutine
goroutine 是 Golang程序中最基本的组织单元之一, 每个程序至少有一个goroutine(main goroutine), 他在进程开始时自动创建并启动

Go中的goroutine时独一无二的, 它们不是OS线程, 也不是绿色线程, 而是一个更高级的抽象, 称为协程  
协程是一种非抢占式的简单并发子goroutine, 也就是说它们不能中断, 取而代之的是, 协程有多个point, 允许暂停或重新进入

goroutine没有定义自己的暂停方法或再运行点, 而是由 Golang runtime 观察运行时的状态和行为, 并在他们阻塞时自动挂起, 然后在不被阻塞时恢复它们  
协程和goroutine都是隐式并发结构, 但并发不是协程的属性: 必须同时托管多个协程, 并给每个协程一个执行的机会

Go的主机托管机制是一个名为 N:M 调度器实现, 这意味着它将M个绿色线程映射到N个OS线程, 然后将goroutine运行在绿色线程上

Go遵循这一个称为fork-join的并发模型, fork指在程序中的任意节点, 可以将子节点与父节点同时运行, join指在将来某个时候, 这些并发的执行分支将会合并在一起

goroutine的另一个好处是非常轻  
一个新创建的goroutine被赋予了几千字节, 这在大部分情况下都是足够的, 当他不运行时, runtime就会自动增长(缩小)存储堆栈的内存, 允许许多goroutine储存在适当的内存中, 每个函数调用CPU的开销平均为3个廉价指令, 在同一个地址空间中创建成千上万个goroutine是可行的, 如果goroutine只是线程, 系统的资源消耗会更小


##  sync包
sync包包含对低级别内存访问同步最有用的并发原语

### WaitGroup
当你不关心并发的操作结果, 或者你有其他方法来收集他们的结果时WaitGroup是等待一组并发操作完成的好方法

可以将WaitGroup视为一组并发安全的计数器: 调用通过传入的整数执行Add方法增加计数器的增量, 并调用Done方法对计数器进行递减, Wait方法阻塞, 直到计数器为0

### 互斥锁
sync.Mutex互斥锁, 是保护程序中临界区的一种方式  
Mutex通过开发人员的约定同步访问共享内存  

* Lock 方法对临界区上锁, 保证该线程独占临界区
* Unlock 方法释放互斥锁, 释放后该线程不再独占临界区, 其他线程可以抢占临界区

### 读写锁
sync.RWMutex读写锁, 在概念上和互斥锁是一样的  

可以有任意数量的线程持有读锁, 并且没有线程持有写锁  
同一时刻只有一个线程持有写锁, 此时其他线程不能持有读锁

### cond
一个goroutine的集合, 等待或发布一个event  
Cond可以让goroutine有效的等待, 直到它发出信号并检查它的状态, 并且不会有额外的资源消耗

* Wait 方法, 等待信号的发生
* Signal 方法, 发现等待最长时间的goroutine并通知它
* Broadcast 方法, 通知所有等待的goroutine

### once
sync.Once是一种类型, 它在内部使用一些sync原语, 以确保即使在不同的goroutine上, 也只会调用一次Do方法处理传递进来的函数

sync.Once指计算调用Do方法的次数, 而不是多少次唯一调用Do方法

### 池
Pool是Pool模式的并发安全实现, Pool模式是一种创建和提供可供使用的固定数量实例或Pool实例的方法, 它通常用于约束创建昂贵的场景(如数据库连接), 以便只创建固定数量的实例

对于Golang的sync.Pool可以被多个goroutine安全地使用

* Get方法将首先检查池中是否有可用的实例返回给调用者, 如果没有调用它的new方法创建一个新实例
* Put方法, 把工作的实例归还到池中, 以供其他进程使用

当使用 Pool 注意:
1. 当实例化sync.Pool, 使用new方法创建一个成员变量, 在调用时是线程安全的
2. 当你收到一个来自Get的实例时, 不要对所接收的对象状态做出任何假设
3. 当你用完了一个从Pool中取出来的对象时, 一定要调用Put, 否则, Pool就无法复用这个实例了
4. Pool内的分布必须大致均匀


### channel
channel 是由Hoare的CSP派生的同步原语, 一个channel充当信息传送的管道, 值可以沿着channel传递, 然后在下游读出

* 创建双向channel
	``` golang
	var channel = make(chan interface{})
	```

* 创建只读channel
	``` golang
	var channel = make(<-chan interface{})
	```

* 创建只写channel
	``` goland
	var channel = make(chan<- interface{})
	```
	> golang中的channel是阻塞的, 所以只有channel中的数据被消费后, 新的数据才能写入, 而任何试图从空channel读取数据的goroutine将等待至少一条数据被写入channel之后才能读到

* 创建buffered channel
	``` golang
	var channel = make(chan interface{}, 10)
	```
	> 缓冲channel 是一个内存中的FIFO队列, 用于并发进程进行通行

操作 channel 的状态
|操作|Channel 状态|结果|
|:---:|:---:|:---:|
|Read| nil | 阻塞 |
|    | 打开非空| 输出值 |
|    | 打开已空 | 阻塞 |
|    | 关闭 | <零值>, false |
|    | 只写   | 编译错误 |
|Write| nil | 阻塞 |
|     | 打开已满 | 阻塞 |
|     | 打开未满 | 输入值 |
|     | 关闭 | panic |
|     | 只读 | 编译错误 |
|close| nil | panic |
|     | 打开非空 | 关闭channel, 读取成功, 数据耗尽后, 读取零值 |
|     | 打开已空 | 关闭channel 读到零值 |
|     | 关闭 | panic |
|     | 只读 | 编译错误 |

* 单向的channel声明的是一种工具, 他将允许我们区分channel 的拥有者和 channel 的使用者
	> channel所有者对channel有一个写访问视图, 而channel 使用者只对channel 有一个只读视图

拥有channel的goroutine应该具备如下:
1. 实例化channel
2. 执行写操作, 或将所有权传递给另一个goroutine
3. 关闭channel
4. 执行前三件事, 并通过一个只读channel将他们暴露出来


### select
select 语句是将channel绑定在一起的粘合剂

``` golang
var c1,c2 <-chan interface{}
var c3 chan<- interface{}

select {
	case <-c1:
	case <-c2:
	case c3<-:
}
```
### GOMAXPROCS 控制
在runtime包中, GOMAXPROCS函数控制OS线程的数量

在 1.5版本之前这个值默认被设置为1, 之后被默认设置为主机上逻辑CPU的数量


## Go语言的并发模式

### 约束
* 用于共享内存的同步原语
* 通过通信共享内存来进行同步

### for-select 循环
``` golang
for {
	select {
	}
}
```

* 向 channel 发送常量
	``` golang 
	for _, s := range []string{"a","b","c"} {
		select {
			case <-done:
				return
			case stream<- s:
		}
	}
	```

* 循环等待停止
	```
	for {
		select {
			case <-done:
				return
			default:
		}
	}
	```

### 防止 goroutine 泄漏
goroutine会消耗资源, 并且goroutine不会被运行时垃圾回收, 所以要确保goroutine以正常的方式终止

goroutine的终止方式:                                           
* 当goroutine完成了任务
* 因为不可恢复的错误, 他不能继续工作
* 当它被告知需要终止工作

goroutine负责创建goroutine, 它也可以确保goroutine停止


### or-channel


