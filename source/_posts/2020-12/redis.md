---
title: Redis
date: '2020-12-23 20:00:00'
category: Redis
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-24 20:00:00'
---

## Redis

Redis(Remote Dictionary Service)是互联网技术领域使用最为广泛的存储中间件
Redis is an open source (BSD licensed), in-memory data structure store, used as
a database cache and message broker

Redis特点

* Redis是一个高性能key/value内存型数据库
* Redis支持丰富的数据类型
* Redis支持持久化
* Redis单进程, 单线程

## 基础

### 数据结构

1. string(字符串)  
  字符串是Redis最简单的数据结构, Redis所有的数据结构都以唯一的key字符串作为名称, 然后通过这个唯一的key值来获取相应的value数据

  Redis的字符串是动态字符串, 是可以修改的字符串, 内部结构的实现采用预分配冗余空间的方式来减少内存的频繁分配  
  当字符串长度小于1MB时, 扩容大都是加倍现有空间, 如果字符串长度超过1MB, 扩容时一次指回多扩1MB空间
  > 字符串的最大长度为512MB  

1. list(列表)  

  列表是使用链表实现的, 这意味着list的插入和删除操作非常快, 时间复杂度为o(1), 但是索引的时间复杂度为O(n)
  当最后一个元素被弹出之后, 该数据结构被删除, 内存被回收

  采用快速链表实现, 在元素较少的情况下, 会使用一块连续的内存存储, 这个结构是ziplist, 即压缩列表  
  当数据量比较多的时候才会使用quicklist

  元素有序且可以重复

1. hash(字典)
Redis的字典, 是无序字典, 内部存储了很多键值对, Redis的字典只能存储字符串

1. set(集合)
Redis的集合, 是无序, 唯一的键值对

1. zset(有序列表)
Redis的有序列表, 采用跳跃列表实现, 不可重复

1. 容器型数据结构的通用规则  

  > * create if not exist: 如果容器不存在, 则创建一个, 再进行操作
  > * drop if no elements: 如果容器中没有元素, 则立即删除容器, 释放内放

1. 过期时间
  Redis所有的数据结构都可以设置过期时间, 过期后, Redis会自动删除相应的对象

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

### Reids相关操作指令

* 数据库操作指令

|指令|说明|
|:---:|:---:|
|SELECT db|选择数据库|
|FLUSHDB| 清空当前数据库 |
|FLUSHALL| 清空全部数据库|

* Key操作指令

|指令|说明|
|:---|:---:|
|DEL key|删除KEY|
|EXISTS key|判断KEY是否存在|
|EXPIRE key seconds|为KEY设置生存时间|
|KEYS pattern| 根据通配符规则查询key|
|MOVE key db| 移动key到对应数据库|
|PEXPIRE key milliseconds| 为key设置毫秒级生存时间|
|PEXPIREAT key timestamp| 为key设置过期时间戳|
|TTL key| 返回当前key的生存时间|
|PTTL key| 返回当前key的毫秒级生存时间|
|RANDOMKEY|随机返回一个key|
|RENAME key newkey| 重命名key为newkey|
|TYPE key| 返回key所存储的值的类型|

* String类型操作指令

|指令|说明|
|:---|:---:|
|SET key value| 设置key/value|
|GET key      | 根据key获取value|
|GETSET key value| 获取原始值的同时, 设置新key/value|
|SETEX key value [EX seconds]| 设置key/value的同时,设置生存时间|
|PSETEX key value [PX milliseconds]| 设置key/value的同时,设置生存时间|
|SETNX key value| 设置key/value|
|STRLEN key | 获取key对应value的长度|
|APPEND key value| 为key对应的值追加内容|
|GETRANGE key start end| 获取key对应[start,end]区间的值|
|MSET key value ...| 批量设置key/value|
|MSETNX key value ...| 批量设置key/value|
|INCR key| 对key对应的值进行自增 |
|INCRBY key increment| 对key对应的值增加指定值|
|DECR key| 对key对应的值进行自减|
|DECTBY key decrement| 对key对应的值减少指定值|
|INCREBYFLOAT key increment| 对key对应的值增加指定浮点数|

* List类型操作指令

|指令|说明|
|:---|:---:|
|LPUSH key element...| 向头部插入值|
|RPUSH key element...| 向尾部插入值|
|LPUSHX key element...| 向头部插入值, 但是要保证key存在|
|RPUSHX key element...| 向尾部插入值, 但是要保证key存在|
|LPOP key| 从头部弹出一个值 |
|RPOP key| 从尾部弹出一个值 |
|LRANGE key start stop| 遍历[start,stop]区间的值 |
|LLEN key | 获取列表长度 |
|LSET key index element| 设置索引位置的元素|
|LINDEX key index | 获取索引位置的元素|
|LREM key count element | 从列表中移除重复元素|
|LTRIM key start stop | 截取[start,stop]区间的值|
|LINSERT key BEFORE\|AFTER pivot element | 向列表中插入元素|

* Set类型操作指令

|指令|说明|
|:---|:---:|
| SADD key merber... | 向Set中添加元素 |
| SMEMBERS key| 获取Set元素 |
| SCARD key | 获取Set长度 |
| SPOP key count | 随机从Set中弹出一个元素 |
| SMOVE src dst member| 从一个Set中向另一个Set移动元素 |
| SREM key member... | 删除集合中的元素|
| SISMEMBER key member | 判断Set中是否存在元素 |
| SRANDMEMBER key count | 随机返回一个元素|
| SDIFF key ...| 去除第一个集合中其他集合含有的相同元素 |
| SINTER key ...| 多个集合求交集|
| SUNION key ...| 多个集合求并集|

* ZSet类型操作指令

|指令|说明|
|:---|:---:|
| ZADD score member| 向ZSet中添加元素|
| ZCARD key| 获取ZSet长度|
| ZRANGE key start stop [withscore]| 根据分数排序返回区间值|
| ZREVRANGE key start stop [withscore]| 根据分数倒序返回区间值|
| ZRANGEBYSCORE key min max [withscore]| 根据分数查询|
| ZRANK key member| 返回元素排名|
| ZREVRANK key member | 返回元素倒序排名 |
| ZSCORE key member| 返回元素的分数|
| ZREM key member...| 删除一个指定元素|
| ZINCRBY key increment member| 给指定元素增加分数|

* Hash类型操作指令

|指令|说明|
|:---|:---:|
| HSET key field value| 向Hash中添加元素|
| HGET key field| 获取Hash中保存的元素|
| HGETALL key | 获取Hash的所有元素|
| HDEL key field | 删除Hash中的元素|
| HEXISTS key field | 判断Hash中是否存在元素|
| HKEYS key| 获取Hash中所有Key|
| HVALS key| 获取Hash中所有Value|
| HMSET key field value ...| 批量设置Hash元素 |
| HMGET key field ...| 批量获取Hash元素|
| HSETNX key field value| 设置一个不存在的值|
| HINCRBY key field increment | 对Hash中的数值元素自增|
| HINCRBYFLOAT key field increment | 对Hash中的数值元素自增浮点值|

### 持久化
