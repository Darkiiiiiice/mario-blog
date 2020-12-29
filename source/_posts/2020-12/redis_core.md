---
title: Redis Core
date: '2020-12-26 20:00:00'
category: Redis
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2020-12-26 20:00:00'
---

## Redis Core

### 字符串

  Redis构建了一种简单动态字符串(Simple Dynamic String, SDS), 当Redis需要一个可以被修改的字符串值时, Redis就会使用SDS来表示字符串值
  SDS还被用作缓冲区: AOF模块中的AOF缓冲区, 以及客户端状态中的输入缓冲区

  SDS的定义:

  ``` C
  struct sdshdr{
     int len;    // 记录buf数组中已使用字节的数量
     int free;   // 记录buf数组中未使用字节的数量
     char buf[]; // 字节数组, 用于保存字符串
  }

  typedef char *sds;
  ```

  SDS遵循C字符串以空字符('\0')结尾, 空字符不计算在len中

  SDS与C字符串的区别

  1. O(1)获取字符串长度
    C字符串获取字符串长度 size_t strlen(const char *s) 计算, 程序需要遍历整个字符串, 直到遇到'\0'才能计算字符串长度
    SDS字符串只要访问SDS的len属性即可获取到字符串长度
  2. 杜绝缓冲区溢出
    C字符串不记录自身长度, 所以很容易造成缓冲区溢出
    SDS字符串的空间分配策略, 完全杜绝了缓冲区溢出的可能性
  3. 空间预分配
    对SDS进行修改时, 如果SDS的长度小于1MB, SDS会分配和len属性同样大小的未使用空间
    如果SDS的长度大于1MB, SDS会分配1MB的未使用空间
  4. 惰性空间释放
    当SDS需要缩短SDS保存的字符串时, 并不会立即使用内存分配回收缩短后多出来的字节, 而是使用free字段将这些字节数量记录起来

### 链表

  Redis构建了自己的链表

  ListNode定义:

  ``` C
  typedef struct listNode {
    struct listNode *prev; // 前置节点
    struct listNode *next; // 后置节点
    void *value;           // 节点值
  } listNode;
  ```

  List定义:
  
  ``` C
  typedef struct list {
      listNode *head;                       // 表头节点
      listNode *tail;                       // 表尾节点
      void *(*dup)(void *ptr);              // 节点值复制函数
      void (*free)(void *ptr);              // 节点值释放函数
      int (*match)(void *ptr, void *key);   // 节点值对比函数
      unsigned long len;                    // 链表所包含的节点数量
  } list;
  ```

  Redis链表实现的特性:

  * 双端:
    链表节点带有 prev 和 next 指针, 获取某个节点的前置节点和后置节点的复杂度都是O(1)
  * 无环:
    表头节点的 prev 指针和表尾节点 next 指针都指向 NULL, 对链表访问以 NULL 为终点
  * 带表头指针和表尾指针: 
    通过list结构的head指针和tail指针, 程序获取链表的表头节点和表尾节点的复杂度为O(1)
  * 带并链表长度计数器: 
    程序使用list结构的len属性来对list持有的链表节点进行计数, 程序获取链表中节点数量的复杂度O(1)
  * 多态: 
    链表节点使用 void* 指针来保存节点值, 并且通过list结构的dup\free\match三个属性为节点值设置类型特定函数, 所以链表可以用于保存不同类型值

### 字典

  字典, 又称为符号表(symbol table), 关联数组(associative array)或映射(map), 是一种用于保存键值对(key-value pair)的抽象数据结构

  Redis字典使用哈希表作为底层实现, 一个哈希表里面可以由多个哈希表节点, 而每个哈希表节点就保存了字典中的一个键值对

  哈希表定义:

  ``` C
  typedef struct dictht {
    dictEntry **table;      // 哈希表数组
    unsigned long size;     // 哈希表大小
    unsigned long sizemask; // 哈希表大小掩码, 用来计算索引值, 总是等于 size-1
    unsigned long used;     // 该哈希表已有节点的数量
  } dictht;
  ```

  哈希表节点:

  ``` C
  typedef struct dictEntry {
    void *key;   // 键

    // 值
    union {
      void *val;
      uint64_t u64;
      int64_t s64;
    } v;

    struct dictEntry *next; // 指向下个哈希表节点, 形成链表
  } dictEntry;
  ```

  字典定义:

  ``` C
  typedef struct dict {

    dictType *type; // 类型特定函数

    void *privdata; // 私有数据

    dictht ht(2);   // 哈希表

    int trehashidx; // rehash索引
  } dict;
  ```

  ``` C
  typedef struct dictType {

    unsigned int (*hashFunction) (const void *key);      // 计算哈希值的函数

    void *(*keyDup) (void *privdata, const void *key);   // 复制键的函数

    void *(*valDup) (void *privdata, const void *obj);   // 复制值的函数

    int (*keyCompare) (void *privdata, const void *key1, const void *key2); //对比键的函数

    void (*keyDestructor) (void *privdata, void *key);    // 销毁键的函数

    void (*valDestructor) (void *privdata, void *obj);    // 销毁值的函数
  } dictType;
  ```

  哈希算法
    当要将一个新的键值对添加到字典里面时, 程序需要先根据键值对的键计算出哈希值和索引值, 然后再根据索引值, 将包含新键值对的哈希表节点放到哈希表数组指定的索引上面 

  解决键冲突
    Redis的哈希表使用链地址法(separate chaining)来解决键冲突, 每个哈希表节点都有一个next指针, 多个哈希表节点可以用next指针构成一个单向链表, 被分配到同一个索引上的多个节点

  rehash
    Redis对字典的哈希表执行rehash的步骤如下

  1. 为字典的ht[1]哈希表分配空间, 这个哈希表的空间大小取决于要执行的操作, 以及ht[0]当前包含的键值对数量
  2. 将所有保存在ht[0]中的所有键值对rehash到ht[1]上面
  3. 当ht[0]包含的所有键值对都迁移到了ht[1]之后, 释放ht[0], 将ht[1]设置为ht[0], 并在ht[1]创建一个空白哈希表
  
### 跳跃表

  Redis 使用跳跃表作为有序集合键的底层实现之一, 如果有一个有序集合包含的元素数量比较多, 又或这有序集合中元素的成员是比较长的字符串时, Reids就会使用跳跃表来作为有序集合键的底层实现

  跳跃表实现

  ``` C
  typedef struct zskiplistNode {

    struct zskiplistNode *backward; // 后退指针

    double score;                   // 分值

    robj *obj;                      // 成员对象

    struct zskiplistLevel {
        struct zskiplistNode *forward; // 前进指针

        unsigned int span;             // 跨度
    } level[]; // 层
  } zskiplistNode;
  ```

  1. 层
    跳跃表节点的level数组可以包含多个元素, 每个元素都包含一个指向其他节点的指针

  2. 前进指针
    每个层都有一个指向表尾方向的前进指针, 用于从表头指向表尾方向访问节点

  3. 跨度
    层的跨度用于记录两个节点之间的距离
  
  4. 后退指针
    节点的后退指针用于从表尾向表头方向访问节点

  5. 分值和成员
    节点的分值和一个double类型的浮点数, 跳跃表中的所有节点都按照分支从小到大来排序
    节点的成员对象是一个指针, 它指向一个字符串对象, 而字符串对象则保存一个SDS值

  跳跃表
    
  ``` C
  typedef struct zskiplist {
    struct skiplistNode *header, *tail; // 表头节点, 表尾节点

    unsigned long length;               // 表中节点数量

    int level;                          // 表中层数最大的节点层数
  }
  ```

### 整数集合

  整数集合是集合键的底层实现, 当一个集合只包含整数值元素, 并且这个集合的元素数量不多时, Redis就会使用整数集合作为集合键的底层实现

  整数集合

  ``` C
  typedef struct intset {
      
      uint32_t encoding;  // 编码方式

      uint32_t length;    // 集合包含的元素数量

      int8_t contents[];  // 保存元素的数组
  } intset;
  ```

  * 如果encoding属性的值为INTSET_ENC_INT16, 那么contents就是一个int16_t[];
  * 如果encoding属性的值为INTSET_ENC_INT32, 那么contents就是一个int32_t[];
  * 如果encoding属性的值为INTSET_ENC_INT64, 那么contents就是一个int64_t[];

### 压缩列表
  
  压缩列表(ziplist)是列表键和哈希键的底层实现, 当一个列表键只包含少量列表项, 并且每个列表项要么就是小整数值, 要么就是长度比较短的字符串

  压缩列表构成:

  |属性|类型|长度| 用途 |
  |:---:|:---:|:---:|:---:|
  |zlbytes|uint32_t|4byte|记录整个压缩列表占用的内存字节数|
  |zltail|uint32_t|4byte|记录压缩列表表尾节点距离压缩列表的起始地址有多少字节|
  |zllen|uint16_t|2byte|记录了压缩列表包含的节点数量|
  |entryX|列表节点|不定|压缩列表包含的各个节点|
  |zlend|uint8_t|1byte|特殊值0xFF, 用于标记压缩列表的末端|

  压缩列表的节点的构成

  字节数组可以是以下3中长度:
  * 长度小于等于63字节的字节数组
  * 长度小于等于16383字节的字节数组
  * 长度小于等于4294967295字节的字节数组

  整数值可以是以下六种长度之一
  * 4位长, 介于0-12的无符号整数
  * 1字节长的有符号整数
  * 3字节长的有符号整数
  * int16_t类型整数
  * int32_t类型整数
  * int64_t类型整数

### 对象

  Redis使用对象来表示数据库中的键和值, 当Redis中创建一个键值对时, 至少会创建两个对象, 一个对象用作键值对的键, 另一个用作键值对的值对象

  | 类型常量 | 名称 |
  |:---:|:---:|
  |REDIS_STRING| 字符串对象 |
  |REDIS_LIST  | 列表对象   |
  |REDIS_HASH  | 哈希对象   |
  |REDIS_SET   | 集合对象   |
  |REDIS_ZSET  | 有序集合   |

  对象编码

  | 编码常量 | 编码对应的底层数据结构 |
  |:---:|:---:|
  |REDIS_ENCODING_INT           |  long类型整数 |
  |REDIS_ENCODING_EMBSTR        |  embstr编码的简单动态字符串 |
  |REDIS_ENCODING_RAW           |  简单动态字符串 |
  |REDIS_ENCODING_HT            |  字典 |
  |REDIS_ENCODING_LINKEDLIST    |  双向链表 |
  |REDIS_ENCODING_QUICKLIST     |  双向链表 |
  |REDIS_ENCODING_ZIPLIST       |  压缩列表 |
  |REDIS_ENCODING_INTSET        |  整数集合 |
  |REDIS_ENCODING_SKIPLIST      |  跳跃表和字典 |

  类型对象

  | 类型 |  编码 | 对象  |
  |:---:|:---:|:---:|
  |REDIS_STRING|REDIS_ENCODING_INT|使用整数值实现的字符串对象|
  |REDIS_STRING|REDIS_ENCODING_EMBSTR|使用embstr编码的SDS|
  |REDIS_STRING|REDIS_ENCODING_RAW | SDS实现字符串|
  |REDIS_LIST  |REDIS_ENCODING_QUICKLIST | 快速列表实现列表对象 |
  |REDIS_HASH  |REDIS_ENCODING_ZIPLIST | 压缩列表实现哈希对象 |
  |REDIS_HASH  |REDIS_ENCODING_HT   | 字典实现哈希对象 |
  |REDIS_SET   |REDIS_ENCODING_INTSET  | 整数集合实现集合对象 |
  |REDIS_SET   |REDIS_ENCODING_HT  | 字典实现集合对象 |
  |REDIS_ZSET  |REDIS_ENCODING_ZIPLIST | 压缩列表实现有序集合对象 |
  |REDIS_ZSET  |REDIS_ENCODING_SKIPLIST | 跳跃表和字典实现有序集合|

  | Redis对象格式 |
  |:---:|
  |redisObject |
  |type REDIS_STRING |
  |encoding REDIS_ENCODING_INT |
  |ptr |
  |...|

#### 字符串对象

  字符串对象的编码可以是int, raw, embstr

* 如果字符串对象保存的是整数值, 并且这个整数值可以用long类型表示, 那么字符串对象会将整数值保存在字符串对象结构的ptr属性里面, 并将字符串对象的编码设置为int
* 如果字符串保存的是字符串值, 并且这个字符串的长度大于44字节, 那么字符串对象将使用一个简单动态字符串来保存字符串值, 并将编码设置为raw格式
* 如果字符串保存的是字符串值, 并且字符串长度小于等于44字节, 那么字符串将编码设置为embstr
  > sds需要分配两次内存, 分别为redisObject和sdshdr 结构来表示字符串对象,
  > embstr则只需要分配一次内存, 空间中一次包含redisObject和sdshdr

#### 列表对象

##### *以下内容在3.2版本之前有效*

  列表对象的编码可以是ziplist或linkedlist

* ziplist编码的列表对象使用压缩列表作为底层实现, 每个压缩列表节点保存了一个列表元素
* linkedlist编码的列表对象使用双向链表作为底层实现, 每个双向链表节点都保存了一个字符串对象, 而每个字符串对象都保存了一个列表元素

当列表对象可以同时满足以下两个条件时, 列表对象使用ziplist编码:

* 列表对象保存的所有字符串元素的长度都小于64字节
* 列表对象保存的元素数量小于512个
不满足以上两个条件的列表对象使用linkedlist编码

##### *Redis3.2版本之后*

  使用quicklist代替原来的方式, quicklist: A doubly linked list of ziplists
  Quicklist是由ziplist组成的双向链表, 链表中的每个节点都以压缩列表ziplist的结构保存

#### 哈希对象

  哈希对象的编码可以是ziplist或者hashtable

* ziplist编码的哈希对象使用压缩列表作为底层实现
  * 保存键值对的两个节点总是在一起, 保存键的节点在前, 保存值的节点在后
  * 先添加的哈希对象会被放在压缩列表的表头方向, 后添加的会被放在表尾
* hashtable编码的哈希对象使用字典作为底层实现
  * 字典的每个键都是一个字符串对象
  * 字典的每个值都是一个字符串对象

当哈希对象同时满足以下两个条件时, 使用ziplist编码:

* 哈希对象保存的所有键值对的键和值的字符串长度都小于64字节
* 哈希对象保存的键值对数量小于512个

#### 集合对象

  集合对象的编码可以是intset和hashtable

当集合对象同时满足以下两个条件, 对象使用intset编码:

* 集合对象保存的所有元素都是整数
* 集合对象保存的元素数量不超过512个

#### 有序集合对象

  有序集合的编码可以是ziplist或者skiplist

当有序集合同时满足以下两个条件时, 对象使用ziplist:

* 有序集合保存的所有元素成员的长度都小于64字节
* 有序集合保存的元素数量小于128个

### 数据库

  Redis服务器将所有数据库都保存在redis.h/redisServer结构的数组中

#### 切换数据库
  
  每个Redis客户端都有自己的目标数据库, 每当客户端执行数据库写命令或者数据库读命令的时候, 目标数据库就会称为这些命令的操作对象
  默认情况下, Redis客户端的目标数据库为0号数据库, 可以通过select命令切换目标数据库

#### 数据键空间(key space)

  Redis是一个键值对数据库服务器, 服务器中的每个数据库都由一个redis/redisDb结构表示, 其中dict字段保存了数据库中的所有键值对, 我们将这个字典称为键空间

* 键空间的键也就是数据库的键, 每个键都是一个字符串对象
* 键空间的值也就是数据库的值, 每个值可以是字符串对象, 列表对象, 哈希对象, 集合对象或有序集合对象

键空间操作

* 添加新键
* 删除键
* 更新键
* 对键取值

读写键空间时的维护操作

* 在读取一个键之后, 服务器会根据键是否存在来更新服务器中键空间命中次数或键空间不命中次数
  > 通过INFO stats 中, keyspace_hits和keysapce_misses属性查看
* 在读取一个键之后, 服务器会更新键的LRU(最后一次使用)时间, 这个值可以用于计算键的空闲时间
  > 通过OBJECT idletime key可以查看键的空闲时间
* 如果服务器在读取一个键时发现该键已经过期, 那么服务器会先删除这个过期键, 然后才执行余下的其他操作
* 如果有客户端使用WATCH命令监视了某个键, 那么服务器在对被监视的键进行修改之后, 会将这个键标记为dirty，从而让事务程序注意到这个键已经被修改
* 服务器每次修改一个键之后, 都会对dirty键计数器的值增1, 这个计数器会触发服务器的持久化以及复制操作
* 如果服务器开启了数据库通知功能, 那么在对键进行修改之后, 服务器将按配置发送相应的事件通知

设置键的生存时间或过期时间

* 设置过期时间
  EXPIRE, PEXPIRE, EXPIREAT, PEXPIREAT都是使用PEXPIREAT命令来实现
* 保存过期时间
  redisDb结构的expires字典保存了数据库中所有键的过期时间, 被称为过期字典
  * 过期字典的键是一个指针, 这个指针指向键空间中的某个对象
  * 过期字典的值是一个long long类型的整数, 这个整数保存了键锁指向的数据库键的过期时间--毫秒精度的UNIX时间戳
* 移除过期时间
  PERSIST命令可以移除一个键的过期时间
* 计算并返回剩余时间
  TTL命令以秒为单位返回键的剩余生存时间, PTTL则以毫秒为单位返回键的剩余生存时间
* 过期键的判定
  1. 检查给定键是否存在于过期字典中, 如果存在则取得键的过期时间
  2. 检查当前UNIX时间戳是否大于键的过期时间, 如果是的化, 那么键已经过期, 否则的话, 键未过期

过期键的删除策略

* 定时删除
  定时删除策略对内存友好, 通过定时器, 定时删除策略可以保证过期键会尽快的被删除, 并释放内存
  如果过期键较多的情况下, 会占用相当一部分的CPU时间

* 惰性删除
  惰性删除只会在取出键时才对键进行过期检查, 保证删除操作只会在非做不可的情况下进行
  但是如果一直不访问这个键, 那么这个键就会一直存在于内存空间中

* 定期删除
  定期删除策略每隔一段时间执行一次删除过期键操作, 并通过限制删除操作执行的时长和频率减少占用CPU时间

Redis的过期删除策略

* 惰性删除策略
  所有读写数据库的命令, 判断是否过期, 如果过期则删除
* 定期删除策略
  定期并且在规定时间内, 分多次遍历服务器的各个数据库, 从数据库中的过期字典中随机检查一部分键的过期时间, 并删除其中的过期的键

生成RDB文件
  在执行save或bgsave命令创建RDB命令时, 程序会对数据库中的键进行检查, 已过期的键不会被保存到新创建的RDB文件中
载入RDB文件
  主服务器在载入RDB文件时, 程序会对保存的键进行检查, 未过期的键会被载入到数据库中, 过期的键会被忽略
  从服务器在载入RDB文件时, 不会检查键是否过期

AOF文件写入
  如果某个键过期, Redis会向文件中追加一条删除指令, 显示的记录该键被删除
AOF重写
  AOF重写的过程中, Redis会对数据库中的键进行检查, 已过期的键不会被重写到AOF文件中

复制
  当服务器运行在复制模式下, 从服务器的过期键删除动作由主服务器控制

* 主服务器删除一个过期键之后, 会显示的向所有从服务器发送删除指令, 通知从服务器删除这个过期键
* 从服务器在执行客户端发送的读命令时, 即使碰到过期键也不会删除, 而是继续像未过期的键一样处理
* 从服务器只有在接收到主服务器的删除指令才会将键删除




