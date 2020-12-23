---
title: Redis(一)
date: '2020-12-23 20:00:00'
category: Redis
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-23 20:00:00'
---

# Redis(一)

    Redis(Remote Dictionary Service)是互联网技术领域使用最为广泛的存储中间件

## 基础

### 数据结构

1. string(字符串)  
    字符串是Redis最简单的数据结构, Redis所有的数据结构都以唯一的key字符串作为名称, 然后通过这个唯一的key值来获取相应的value数据

    Redis的字符串是动态字符串, 是可以修改的字符串, 内部结构的实现采用预分配冗余空间的方式来减少内存的频繁分配  
    当字符串长度小于1MB时, 扩容大都是加倍现有空间, 如果字符串长度超过1MB, 扩容时一次指回多扩1MB空间
    > 字符串的最大长度为512MB  

    字符串操作:  
    1. 键值对  
        ``` redis
        set key value   ;设置k-v
        get key value   ;读取k-v
        exist key value ;判断key是否存在
        del key         ;删除key
        ```

    2. 批量键值对  
        ``` redis
        mset k1 v1 k2 v2 k3 v3  ;批量设置
        mget k1 k2 k3           ;批量读取k, 返回一个列表
        ```

	3. 扩展  
		``` redis
		expire key 5 		;设置key的过期时间
		setex key 5 value   ;等价于 set + expired
		setnx key value		;如果key不存在则设置key
		```

	4. 计数  
		自增的范围是 signed long 的最大值和最小值
		``` redis
		incr key 		;key对应的value+1
		incrby key 5	;key对应的value+5
		```

2. list(列表)  
	列表是使用链表实现的, 这意味着list的插入和删除操作非常快, 时间复杂度为o(1), 但是索引的时间复杂度为O(n), 当最后一个元素被弹出之后, 该数据结构被删除, 内存被回收

	Redis采用快速链表实现, 在元素较少的情况下, 会使用一块连续的内存存储, 这个结构是ziplist, 即压缩列表  
	当数据量比较多的时候才会使用quicklist

	列表操作:
	1. 右边进左边出: 队列  
		``` redis
		rpush k1 v1 v2 v3 	;从右边向k1中添加元素
		llen k1				;获取队列长度
		lpop k1 			;从左边弹出队列中的值
		```
	2. 右边进右边出: 栈
		``` redis
		rpush k1 v1 v2 v3  	;从右边向k1中添加元素
		rpop k1				;从右边弹出队列中的值
		```
	3. 慢操作
		``` redis
		lindex k1 1 		;获取队列中index=1的值, O(n)
		lrange k1 0 -1		;获取所有元素, O(n)
		ltrim k1 1 -1 		;保留指定区间的值, O(n)
		```

3. hash(字典)
	Redis的字典, 是无序字典, 内部存储了很多键值对, Redis的字典只能存储字符串

	字典操作:
		``` redis
		hset d1 k1 v1 		;向d1字典, 保存k1-v1键值对
		hsetall d1			;获取所有的key和value, key和value间隔出现
		hlen d1				;获取字典长度
		hget d1 k1 			;获取d1字典中保存的k1指向的value
		hmset d1 k1 v1 k2 v2;批量设置字典	
		hincrby d1 k1 1		;增加字典中key值+1
		```

4. set(集合)
	Redis的集合, 是无序, 唯一的键值对

	集合操作:
		``` redis
		sadd s1 k1			;设置set集合
		smembers s1			;获取集合值
		sismember s1 k1		;查询集合中是否存在某个值
		scard s1			;获取集合长度
		spop s1				;从集合中弹出一个值
		```

5. zset(有序列表)
	Redis的有序列表, 采用跳跃列表实现

	有序列表操作:
		``` redis
		zadd z1 k1 v1 			;设置zset
		zrange z1 0 -1 			;按key顺序列出区间内的值
		zrevrange z1 0 -1		;按key逆序列出区间内的值
		zcard z1				;获取zset长度
		zscore	z1 v1			;获取指定value的score
		zrank z1 v1				;获取指定value的排名
		zrangebyscore z1 0 8.91 ;根据分值区间遍历
		zrem z1 v1 				;删除value
		```


6 容器型数据结构的通用规则  
> * create if not exist: 如果容器不存在, 则创建一个, 再进行操作
> * drop if no elements: 如果容器中没有元素, 则立即删除容器, 释放内放

7 过期时间
	Redis所有的数据结构都可以设置过期时间, 过期后, Redis会自动删除相应的对象

	``` redis
    expire key 500 	;设置key的过期时间
    ttl key			;获取key剩余的时间
    ```

### 分布式锁

    分布式锁 一般使用setnx指令, 只允许被一个客户端加锁, 调用完成后使用del指令释放锁

* 超时问题  
    > Redis的分布式锁不能解决超时问题, 如果加锁和解锁之间的执行时间超过了锁的时间, 那么其他线程就会抢占锁, 出现并发安全问题

* 可重入性  
    > 可重入性是指线程在持有锁的情况下, 再次请求加锁, 如果一个锁支持同一个线程多次加锁, 那么这个锁就是可重入的

### 延时队列

    Redis的list数据结构常用来作为异步消息队列使用, 用rpush和lpush操作入列, 用lpop和rpop操作出列  

* 空队列  
    如果队列空了, 客户端就会陷入pop的死循环
* 阻塞读  
    使用blpop或者brpop操作, 在队列没有数据的时候, 会立即进入休眠状态, 一旦存在数据后, 则立刻醒来
* 空闲连接自动断开  
    如果线程一直阻塞, Redis的客户端连接就变成了闲置连接, 如果闲置连接太久, 服务器会主动断开连接, 减少闲置资源占用

### 位图

    Redis提供了位图数据结构, 其实际就是字符串, byte数组  
    Redis的位数组是自动扩展的, 如果设置了某个偏移位置超出了现有的内容范围, 就会自动将位数组进行扩充


    1. 基础操作
        ``` redis
        setbit s 1          ;设置位图
        getbit s 1          ;获取位图          
        ```
    2. 统计和查找
        ``` redis 
        bitcount s          ;获取位数
        bitcount s 0 0      ;获取前一个字符中, 1的位数
        bitcount s 0 1      ;获取前两个字符中, 1的位数
        bitpos  s 0         ;获取第一个0位
        bitpos  s 1         ;获取第一个1位
        bitpos  s 1 1 1     ;获取从第二个字符算起, 第一个1位
        bitpos  s 1 2 2     ;获取从第三个字符算起, 第一个1位
        ```
    3. 魔术指令bitfield
        bitfield有三个子指令, 分别是get, set, incr

