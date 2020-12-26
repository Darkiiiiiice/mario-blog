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

  

