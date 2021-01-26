---
title: Algorithms(线性表)
date: '2021-01-22 20:10:00'
category: Algorithms
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2021-01-22 20:10:00'
---

## 线性表特点

由 n(n>=0) 个数据特性相同的元素构成的有限序列称为线性表  
当线性表中元素的个数n(n>=0)定义为线性表的长度, n = 0时称为空表

对于非空的线性表或线性结构, 其特点是:
1. 存在唯一的第一个元素
2. 存在唯一的最后一个元素
3. 除第一个元素外, 其余数据元素只有一个前驱元素
4. 除最后一个元素外, 其余数据元素只有一个后继元素

## 线性表类型

线性表是一个相当灵活的数据结构, 其长度可根据需要增长或缩短, 即对线性表的数据元素不仅可以进行访问, 而且可以进行插入和删除等操作

ADT:

``` ADT
List {
    数据对象: D={ai|i = 1,2,3,4,...,n, n>=0}
    数据关系: R={<ai-1, ai> | i = 2,...,n}
    基本操作: 

        // 构造一个空的线性表L
        InitList(&L) 

        // 如果线性表已存在, 则销毁线性表L
        DestroyList(&L) 

        // 将L重置为空表
        ClearList(&L)

        // 判断线性表是否为空
        IsEmpty(&L)

        // 返回线性表长度
        Length(&L)

        // 获取第i个元素
        Get(&L, i)

        // 返回第一个与e相同的元素位置
        IndexOf(&L, e)

        // 返回e的前一个元素
        Previous(&L, e)

        // 返回e的后一个元素
        Next(&L, e)

        // 在第i个位置之前插入新的数据元素
        Insert(&L, i, e)

        // 删除第i个元素
        Delete(&L, i)

        // 遍历线性表
        Traverse(&L)

        // 反转线性表
        Reverse(&L)
}
```

## 线性表顺序表示

线性表的顺序表示指的是用一组地址连续的存储单元依次存储线性表的数据元素, 这种表示也称作线性表的顺序存储结构或顺序映像, 通常这种存储结构的线性表为顺序表  
其特点是, 逻辑上相邻的数据元素, 其物理次序也是相邻的

假设线性表的每个元素需占用l个存储单元, 并以所占的第一个单元的存储地址作为数据元素的春初起始位置, 则线性表中第 i+1 个数据元素的存储位置 LOC(Ai+1) 和第i个数据元素的存储位置LOC(Ai)之间满足下列关系:  
LOC(Ai+1) = LOC(Ai) + l
一般来说线性表的第i个数据元素Ai的存储位置为:  
LOC(Ai) = LOC(Ai) + (i-1) * l

只要确定了存储线性表的起始位置, 线性表中任一数据元素都可随机存取, 所以线性表的顺序存储结构是一种随机存取的存储结构

### 数组顺序表

#### 存储结构

``` golang
type ArrayList {
    nodes []arrayListNode // 储存数据的节点数组

    length   int          // 数组长度
    capacity int          // 数组容量
}

type arrayListNode {
    value interface{}
}
```

#### 顺序表操作

1. 顺序表初始化

构造一个空的线性表,  动态分配线性表的存储区域可以有效的利用系统的资源, 不需要时, 可以释放回收资源

> golang 中可以使用切片实现, 其他语言需要手动实现底层数组的动态增长, golang中的切片在元素个数小于1024个时, 每次分配空间会增加一倍的容量, 当元素个数大于1024个时, 每次分配空间只会分配之前容量的四分之一

``` golang
func InitArrayList(capacity int) *ArrayList {
    var list = new(ArrayList)
    list.length = 0
    list.capacity = capacity
    list.nodes = make([]arrayListNode, 0, capacity)
    return list
}
 ```

2. 顺序表取值

由于顺序表随机取值的特点, 我们可以直接通过下标进行取值

``` golang
func (l *ArrayList) Get(index int) interface{} {
    if index < 0 || index >= l.length {
        return nil
    }
    return l.nodes[index].value
}
```

3. 顺序表查找

在顺序表中查找一个数据元素时, 其时间主要耗费在数据的比较上, 而比较的次数取决于被查元素的序号 i+1

``` golang
func (l *ArrayList) IndexOf(value interface{}) int {
    var index = -1
    for i, v := range l.nodes {
        if reflect.DeepEqual(v.value, value) {
            index = i
            break
        }
    }

    return index
}
```

4. 顺序表插入

顺序表的插入操作是指在表的第i个位置插入一个元素e, 使长度为n的线性表变为长度为n+1线性表

> 通过golang 的append内置函数, 动态增长空间, 然后将[i, len-1)部分的元素都向后移动一位, 然后将插入元素复制到i位置

``` golang
func (l *ArrayList) Insert(index int, value interface{}) {
    if index < 0 {
        index = 0
    }

    l.nodes = append(l.nodes, arrayListNode{value: value})
    for i := l.length; i > index; i-- {
        l.nodes[i] = l.nodes[i-1]
    }
    
    if index < l.length {
        l.nodes[index] = arrayListNode{value: value}
    }
    l.length = len(l.nodes)
    l.capacity = cap(l.nodes)
}
```

5. 顺序表删除

顺序表的删除和顺序表的插入操作正好相反, 指的是在表的第i个位置删除元素, 使长度为n的顺序表变为长度为n-1的顺序表

> 将[i+1,len)区间的所有元素都向前移动一位, 并释放最后位置的空间

``` golang
func (l *ArrayList) Delete(index int) {
    if index < 0 {
        return
    }
    
    for i := index; i < l.length-1; i++ {
        l.nodes[i] = l.nodes[i+1]
    }
    if index < l.length {
        l.nodes = l.nodes[:l.length-1]
    }
    
    l.length = len(l.nodes)
    l.capacity = cap(l.nodes)
}
```

## 线性表链式表示

线性表链式存储结构的特点是: 用一组任意的存储单元存储线性表的数据元素, 它包括两个域:
其中存储数据元素信息的域称为数据域, 存储直接后继存储位置的域称为指针域. 指针域中存储的信息称作指针或链, n个节点连接成一个链表, 即为线性表

根据链表节点所含指针个数, 指针指向和指针连接方式, 可将链表分为单链表, 循环链表, 双向链表, 二叉链表, 十字链表, 邻接表, 邻接多重表等

### 单链表

链表中每个节点中只包含一个指针域, 故称为线性链表或单链表

* 首元结点: 指链表中存储第一个数据元素a1的结点
* 头结点:   是在首元结点之前附设的一个结点, 其指针域指向首元结点
* 头指针:   指向链表中第一个结点的指针

链表增加头结点的作用:

1. 便于首元结点的处理, 首元结点的地址保存在头结点的指针域中, 则对链表的第一个数据元素的操作与其他数据元素相同, 无需进行特殊处理
2. 便于空表和非空表的统一处理, 当链表不设头结点时, 假设L为单链表的头指针, 它应该指向首元结点, 则当单链表长度为0时, L指针为空, 增加头结点后, 无论链表是否为空, 头指针都是指向头结点的非空指针

#### 单链表结构

``` golang
type LinkedList struct {
    length int
    root   *Element
}

type Element struct {
    Val  interface{}
    next *Element
}
```

#### 单链表的基本操作

1. 初始化

``` golang
func InitLinkedList() *LinkedList {
    var l = new(LinkedList)
    l.root = nil
    l.length = 0
    return l
}
```

2. 取值

和顺序表不同, 链表中逻辑相邻的结点并没有存储在物理相邻的单元中, 只能从链表的首元结点出发, 顺着链域next逐个结点向下访问

``` golang
func (l *LinkedList) Get(index int) interface{} {
    var cur = l.root

    for index > 0 && cur.next != nil {
        cur = cur.next
        index--
    }
    return cur.Val
}
```

3. 查找

链表中按值查找的过程和顺序表类似, 从链表的首元结点出发, 一次将结点值和给定值进行比较, 返回查找结果

``` golang
func (l *LinkedList) Search(elem interface{}) int {
    var cur = l.root

    for i:=0; cur.next != nil; i++ {
        if cur.Val == elem {
            return i
        }
        cur = cur.next
    }

    return -1
}
```

4. 插入

首先生成一个数据域为x的结点, 然后插入到单链表中, 将插入位置的指针域指向结点x, 将结点x的指针域指向插入位置之前指向的结点

``` golang
func (l *LinkedList) InsertOfIndex(elem interface{}, index int) {
    var n = &Element{
        Val:  elem,
        next: nil,
    }

    if index <= 0 {
        l.InsertOfHead(elem)
        return
    } else if index >= l.length {
        l.InsertOfTail(elem)
        return
    }

    var cur = l.root

    for index-1 > 0 && cur.next != nil {
        cur = cur.next
        index--
    }

    n.next = cur.next
    cur.next = n
    l.length++
}
```

5. 删除

要删除单链表中的制定位置的元素, 同插入元素一样, 首先应该找到该位置的前驱结点, 将前驱结点指向要删除元素指针域指向的位置

``` golang
func (l *LinkedList) Remove(index int) interface{} {
    var cur = l.root

    if index < 1 {
        var tmp = cur
        l.root = cur.next
        return tmp.Val
    }

    if index >= l.length {
        index = l.length - 1
    }

    for index-1 > 0 && cur.next != nil {
        cur = cur.next
        index--
    }

    var tmp = cur.next
    cur.next = cur.next.next
    l.length--

    return tmp.Val
}
```

6. 创建单链表

根据结点插入位置的不同, 链表的创建方式可分为
  
  1. 前插法
    前插法时通过将新结点逐个插入链表的头部来创建链表, 每次申请一个新结点, 读入相应的数据元素值, 然后将新结点插入到头结点之后

  ``` golang
  func (l *LinkedList) InsertOfHead(elem interface{}) {
     var n = &Element{
         Val:  elem,
         next: nil,
     }

     n.next = l.root
     l.root = n
     l.length++
  }   
  ```

  2. 后插法
    后插法时通过将新结点逐个插入到链表的尾部来创建链表

  ``` golang
  func (l *LinkedList) InsertOfTail(elem interface{}) {
      var n = &Element{
          Val:  elem,
          next: nil,
      }
  
      if l.root == nil {
          l.root = n
          l.length++
          return
      }
  
      var cur = l.root
  
      for cur.next != nil {
          cur = cur.next
      }
  
      cur.next = n
      l.length++
  }
  ```

### 循环链表

循环链表是另一种形式的链式存储结构, 其特点时表中最后一个结点的指针域指向头结点, 整个链表形成一个环, 从表中任意一个结点出发均可找到表中其他结点

循环单链表的操作和单链表基本一致, 差别仅在于: 当链表遍历时, 判别当前指针p是否指向表位结点的终止条件不同

### 双向链表

在双向链表的结点中有两个指针域, 一个指向直接后继, 另一个指向直接前驱

#### 存储结构

#### 基本操作  

1. 插入

2. 删除


### 顺序表和链表的比较

1. 空间性能的比较

  1. 存储空间的分配
    顺序标得存储空间必须预先分配, 元素个数扩充受一定限制, 易造成存储空间浪费或空间溢出现象, 而链表不需要为其预先分配空间, 只要内存空间允许, 链表中的元素个数就没有限制
  2. 存储密度的大小
    链表的每个结点除了设置数据域用来存储数据元素外, 还要额外设置指针域, 用来存储指示元素之间逻辑关系的指针, 从存储密度上来讲, 这是不经济的
    存储密度 = 数据元素本身占用的存储量 / 结点结构占用的存储量
    存储密度越大, 存储空间的利用率就越高, 显然, 顺序表的存储密度为1, 而链表的存储密度小于1

2. 时间性能的比较

  1. 存取元素的效率
    顺序表是由数组实现的, 他是一种随机存储结构, 制定任意一个位置序号i, 都可以在O(1)时间内直接存取该位置上的元素, 即取值操作的效率高; 而链表时一种顺序存取结构, 按位置访问链表中第i个元素时, 只能从表头开始一次向后遍历链表, 直到找到第i个位置上的元素,
    时间复杂度为O(n)
  2. 插入和删除操作的效率
    对于链表, 在确定插入或删除的位置后, 插入或删除操作无需移动数据, 只需要修改指针, 时间复杂度为O(1), 而对于顺序表, 进行插入或删除时, 平均要移动表中仅以办的结点, 时间复杂度为O(n)
