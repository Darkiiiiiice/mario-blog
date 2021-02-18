---
title: HTTP
date: '2021-02-18 20:00:00'
category: HTTP
author: MarioMang
cover: /resources/images/default_cover.gif
updated: '2021-02-18 20:00:00'
---

## HTTP协议

HTTP(HyperText Transfer Protocol)超文本传输协议, HTTP正式作为标准被公布是于1996年5月, 版本被命名为HTTP/1.0, 并记载于RFC1945中.  
HTTP/1.0于1997年1月公布, 是目前主流的HTTP协议版本

### URI(统一资源标识符)

URI(Uniform Resource Identifier), RFC2396对该协议进行了定义

* Uniform
  规定统一的格式可方便处理多种不同类型的资源, 而不用根据上下文环境来识别资源制定的访问方式. 
* Resource
  资源的定义是可标识的任何东西
* Identifier
  表示可标识的对象, 也称为标识符

所以, URI就是某个协议方案表示的资源定位标识符, 协议方案是指访问资源所使用的协议类型名称  
采用HTTP协议时, 协议方案就是 http, 除此之外, 还有ftp\mailto\telnet\file等
标准的URI协议方案有30种左右, 由ICANN的IANA管理颁布

RFC3986: 统一资源标识符通用语法

``` URI
ftp://ftp.is.co.za/rfc/rfc1808.txt
http://www.ietf.org/rfc/rfc2396.txt
ldap://[2001:db8::7]/c=GB?objectClass?one
mailto:John.Doe@example.com
news:comp.infosystems.www.servers.unix
tel:+1-816-555-2222
telnet://192.168.0.1:80/
urn:oasis:names:specification:docbook:dtd:xml:4.1.2
```

URI格式

http://user:pass@www.example.com:80/dir/index.html?uid=1#ch1
协议方案名://用户名:密钥@服务器地址:服务器端口号/带层次的文件路径?查询字符串#片段标识符

* 登录信息(认证)
  指定用户名和密码作为从服务器段获取资源时必要的登录信息, 可选项
* 服务器地址
  使用绝对URI必须制定待访问的服务器地址, 地址可以使DNS可解析域名, 或者IPv4,IPv6地址
* 服务器端口号
  制定服务器连接的网络端口号, 若用户省略则自动使用默认端口号
* 带层次的文件路径
  制定服务器上的文件路径来定位特指的资源, 这与UNIX系统的文件目录结构相似
* 查询字符串
  针对已指定的文件路径内的资源, 可以使用查询字符串传入任意参数
* 片段标识符
  使用片段标识符通常可标记出已获取资源中的字资源, RFC并没有规定其使用方法

### 请求报文

``` http
POST /form/query HTTP/1.1
HOST: example.org
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 16

name=ueno&age=37
```

### 响应报文

``` http
HTTP/1.1 200 OK
Date: Tue, 10 Jul 2012 06:50:15 GMT
Content-Length: 362
Content-Type: text/html

<html>...
```

### HTTP Method

* GET: 获取资源
  GET方法用来请求访问已被URI识别的资源, 制定的资源经服务端解析后返回响应内容. 
* POST: 传输实体主体
  POST 方法用来传输实体的主体, POST 的目的并不是获取响应的主体内容
* PUT: 传输文件
  PUT 方法用来传输文件, 就像FTP协议的文件上传一样, 要求在请求报文的主体中包含文件内容, 然后保存到请求URI指定的位置
* HEAD: 获取报文首部
  HEAD 方法和 GET方法一样, 只是不返回报文主体部分, 用于确认URI的有效性及资源更新的日期时间等
* DELETE: 删除文件
  DELETE方法用来删除文件, 是与PUT相反的方法, DELETE 方法按请求URI删除指定的资源
* OPTIONS: 询问支持的方法
  OPTIONS 方法用来查询针对请求URI制定的资源支持的方法
* TRACE: 追踪路径
  TRACE 方法是让Web服务器端将之前请求通信回环给客户端的方法, 发送请求时, 在Max-Forwards首部字段中填入数值, 每经过一个服务器端就将该数字减一, 当数值刚好减到0时, 就停止继续传输, 最后接受到请求的服务器端则返回状态码200OK的响应
  客户端通过TRACE方法可以查询发送出去的请求是怎样被加工修改的
* CONNECT: 要求用隧道协议连接代理
  CONNECT 方法要求在与代理服务器通信时建立隧道, 实现用隧道协议进行TCP通信, 主要使用SSL和TLS协议把通信内容加密后经网络隧道传输

### HTTP 持久连接

为了解决每次请求都会造成无用的TCP连接建立和断开的开销, HTTP/1.1实现了持久连接(HTTP Persistent Connections, 也称为HTTP keep-alive)
持久连接的特点是, 只要任意一端没有明确提出断开连接, 则保持TCP连接状态, 这样减少了TCP连接的重复建立和断开所造成的额外开销, 减轻了服务器端的负载
HTTP/1.1中, 所有连接默认都是持久连接

### HTTP 管线化

管线化技术使得多个请求可以并行操作, 而不用一个一个的等待响应

### HTTP Cookies

Cookies技术通过在请求和响应报文中写入Cookies信息来控制客户端的状态

### HTTP 报文

用于HTTP协议交互的信息被称为HTTP报文, 请求端的HTTP报文叫做请求报文, 响应端的HTTP报文叫做响应报文
报文本身是由多行数据构成的字符串文本, 由CR+LF做换行符

HTTP报文大致可分为报文首部和报文主体两块, 两者由首次出现的空行来划分, 通常来说, 并不一定要有报文主体

#### 请求报文及响应报文的结构

请求报文

``` http
报文首部:
  请求行
  请求首部字段
  通用首部字段
  实体首部字段
  其他
CR+LF
报文主体
```

响应报文

``` http
报文首部:
  状态行
  响应首部字段
  通用首部字段
  实体首部字段
  其他
CR+LF
报文主体
```

* 请求行
  包含用于请求的方法, 请求URI和HTTP版本
* 状态行
  包含表明响应结果的状态码, 原因短语和HTTP版本
* 首部字段
  包含标识请求和响应的各种条件和属性的各类首部
* 其他
  可能包含HTTP的RFC里未定义的首部(Cookies等)

### HTTP 内容编码

内容编码指明应用在实体内容上的编码格式, 并保持实体信息原样压缩

* gzip( GNU zip )
* compress( UNIX 系统的标准压缩 )
* deflate( zlib )
* identity( 不进行编码 )

在HTTP通信过程中, 请求的编码实体资源尚未全部传输完成之前, 浏览器无法显示请求页面,  在传输大容量数据时, 通过把数据分割成多块, 能够让浏览器逐步显示页面

HTTP/1.1中存在一种称为传输编码的机制, 可以在通信时按某种编码方式传输, 但指定义作用于分块传输编码中
HTTP协议中也采纳了多部分对象集合, 发送的一份报文主体内可含有多类型实体, 通常在图片或文本文件等上传时使用

多部分对象集合包含的对象如下
* multipart/form-data
  在Web表单文件上传时使用
* mutilpart/byteranges
  状态码206(Partial Content, 部分内容)响应报文包含了多个范围的内容时使用


### HTTP 内容协商

内容协商机制是指客户端和服务器端就响应的资源内容进行交涉, 然后提供给客户端最为适合的资源

内容协商类型

* 服务器驱动协商(Server-driven Negotiation)
  由服务器端进行内容协商, 以请求的首付字段为参考, 在服务端自动处理
* 客户端驱动协商(Agent-driven Negotiation)
  由客户端进行内容协商的方式, 用户从浏览器显示的可选项列表中手动选择
* 透明协商(Transparent Negotiation)
  时服务器驱动和客户端驱动的结合体, 是由服务器端和客户端各自进行内容协商的一种方法

### HTTP 状态码

状态码的职责是当客户端向服务器端发送请求时, 描述返回的请求结果

|状态码|类别|原因短语|
|:---:|:---:|:---:|
|1xx| Informational(信息性状态码) | 接收的请求正在处理 |
|2xx| Success(成功状态码)         | 请求正常处理完毕 |
|3xx| Redirection (重定向状态码)  | 需要进行附加操作以完成请求 |
|4xx| Client Error (客户端错误状态码) | 服务器无法处理请求 |
|5xx| Server Error (服务器错误状态码) | 服务器处理请求出错 |

| 状态码 | 原因短语 | 解释 |
|:---:|:---:|:---:|
|200| OK | 表示从客户端发来的请求在服务器端被正常处理 |
|204| No Content| 该状态码代表服务器接收的请求已成功处理, 但在返回的响应报文中不含实体的主体部分 |
|206| Partial Content| 该状态码表示客户端进行了范围请求, 而服务器成功指行了这部分的GET请求 |
|301| Moved Permanently| 永久重定向, 该状态码表示请求的资源已被分配成了新的URI, 以后使用资源限制所指的URI |
|302| Found | 临时重定向, 该状态码表示请求的资源已被分配了新的URI, 希望用户本次能使用新的URI访问 |
|303| See Other | 该状态码表示由于请求对应的资源存在着另一个URI, 应该使用GET方法定向获取请求的资源 |
|304| Not Modified | 该状态码表示客户端发送附带条件的请求时, 服务器端允许请求访问资源, 但因发生请求条件未满足条件的情况后, 直接返回304 |
|307| Temporary Redirection | 临时重定向, 该状态码与302有着相同的含义 |
|400| Bad Request | 该状态码表示请求报文中存在语法错误 |
|401| Unauthorized | 该状态码表示发送请求需要有通过HTTP认证的认证信息 |
|403| Forbidden | 该状态码表明对请求资源的访问被服务器拒绝了 |
|404| Not Found | 该状态码表明服务器上无法找到请求的资源 |
|500| Internal Server Error | 该状态码表明服务器端在执行请求时发生了错误 |
|503| Service Unavailable | 该状态码表明服务器暂时处于超负载或正在进行停机维护, 现在无法处理请求 |

### 代理

代理服务器的基本行为就是接收客户端发送的请求后转发给其他服务器, 代理不改变请求URI, 会直接发送给前方持有资源的目标服务器

* 缓存代理
  代理转发响应时, 缓存代理会预先将资源的副本保存在代理服务器上
* 透明代理
  转发请求或响应时, 不对报文做任何加工的代理类型被称为透明代理, 反之, 对报文内容进行加工的代理被称为非透明代理

### 网关

网关的工作机制和代理十分相似, 而网关能使通信线路上的服务器提供非HTTP协议服务

### 隧道

隧道可按照要求建立起一条与其他服务器的通信线路, 届时使用SSL等加密手段进行通信, 隧道的目的时确保客户端能与服务器进行安全的通信
隧道本身不会解析HTTP请求, 请求会保持原样转发给之后的服务器, 隧道会在通信双方断开连接时结束

### HTTP 首部字段

HTTP首部字段是构成HTTP报文的要素之一

HTTP首部字段类型

* 通用首部字段(General Header Fields)
  请求报文和响应报文两方都会使用的首部
* 请求首部字段(Request Header Fields)
  从客户端向服务器发送请求报文时使用的首部
* 响应首部字段(Response Header Fields)
  从服务器向客户端放回响应报文时使用的首部
* 实体首部字段(Entity Header Fields)
  针对请求报文和响应报文的实体部分使用的首部

通用首部字段

| 首部字段名 | 说明 |
|:---:|:---:|
| Cache-Control | 控制缓存的行为 |
| Connection | 逐跳首部, 连接的管理 |
| Date | 创建报文的日期时间 |
| Pragma | 报文指令 | 
| Trailer | 报文末端的首部一览 |
| Transfer-Encoding | 指定报文主体的传输编码方式 |
| Upgrade | 升级为其他协议 |
| Via | 代理服务器相关信息 |
| Warning | 错误通知 |

请求首部字段

| 首部字段名 | 说明 |
|:---:|:---:|
| Accept | 用户代理可处理的媒体类型 |
| Accept-Charset | 优先的字符集 |
| Accept-Encoding | 优先的内容编码 |
| Accept-Language | 优先的语言 |
| Authorization | Web认证信息 |
| Expect | 期待服务器的特定行为 |
| From | 用户的电子邮箱地址 |
| Host | 请求资源所在的服务器 |
| If-Match | 比较实体标记 |
| If-Modified-Since | 比较资源的更新时间 |
| If-None-Match | 比较实体标记(与If-Match相反) |
| If-Range | 资源未更新时发送实体Byte的范围请求 |
| If-Unmodified-Since | 比较资源的更新时间 |
| Max-Forwards | 最大传输逐跳数 |
| Proxy-Authorization | 代理服务器要求客户端的认证信息 |
| Range | 实体的字节范围请求 |
| Referer | 对请求中URI的原始获取方法 |
| TE | 传输编码的优先级 |
| User-Agent | HTTP客户端的信息 |

响应首部字段 

| 首部字段名 | 说明 |
|:---:|:---:|
| Accept-Ranges | 是否接收字节范围请求 |
| Age | 推算资源创建经过时间 |
| ETag | 资源的匹配信息 |
| Location | 令客户端重定向至指定URI |
| Proxy-Authenticate | 代理服务器对客户端的认证信息 |
| Retry-After | 对再次发起请求的时机要求 |
| Server | HTTP服务器的安装信息 |
| Vary | 代理服务器缓存的管理信息 |
| WWW-Authenticate | 服务器对客户端的认证信息 |

实体首部字段 

| 首部字段名 | 说明 |
|:---:|:---:|
| Allow | 资源可支持HTTP方法 |
| Content-Encoding | 实体主体适用的编码方式 |
| Content-Language | 实体主体的自然语言 |
| Content-Length | 实体主体的大小 |
| Content-Location | 替代对应资源的URI |
| Content-MD5 | 实体主体的报文摘要 |
| Content-Range | 实体主体的位置范围 |
| Content-Type | 实体主体的媒体类型 |
| Expires | 实体主体过期的日期时间 |
| Last-Modified | 资源的最后修改日期时间 |

### HTTP通用首部字段

#### Cache-Control

缓存请求指令

| 指令 | 参数 | 说明 |
|:---:|:---:|:---:|
| no-cache | 无 | 强制向源服务器再次验证 |
| no-store | 无 | 不缓存请求或响应的任何内容 |
| max-age=[second] | 必需 | 响应的最大Age值 |
| max-stale=[second] | 可省略 | 接收已过期的响应 |
| min-fresh=[second] | 必需 | 期望在指定时间内的响应仍有效 |
| no-trasform | 无 | 代理不可更改媒体类型 |
| only-if-cached | 无 | 从缓存获取资源 |
| cache-extension | - | 新指令标记 |

缓存响应指令

| 指令 | 参数 | 说明 |
|:---:|:---:|:---:|
| public | 无 | 可向任意方提供响应的缓存 |
| private | 可省略 | 仅向特定用户返回响应 |
| no-cache | 可省略 | 缓存前必需先确认其有效性 |
| no-store | 无 | 不缓存请求或响应的任何内容 |
| no-transform | 无 | 代理不可更改媒体类型 |
| must-revalidate | 无 | 可缓存但必须再向源服务器进行确认 |
| proxy-revalidate | 无 | 要求中间缓存服务器对缓存的响应有效性再进行确认 |
| max-age=[second] | 必需 | 响应的最大Age值 |
| s-maxage=[second] | 必需 | 公共缓存服务器响应的最大Age值 |
| cache-extension | - | 新指令标记 |

#### Connection

Connection首部字段具备如下两个作用

* 控制不再转发给代理的首部字段
* 管理持久连接

#### Date

首部字段Date表明创建HTTP报文的日期和时间
HTTP/1.1协议使用在RFC1123中规定的日期时间格式

#### Pragma

Pragma是HTTP/1.1之前版本的历史遗留字段, 仅做兼容性处理

#### Trailer

首部字段Trailer会事先说明在报文主体后记录了哪些首部字段, 该首部字段可应用在HTTP/1.1版本分块传输编码时

#### Transfer-Encoding

首部字段Transfer-Encoding规定了传输报文主体时采用的编码方式

#### Upgrade

首部字段Upgrade用于检测HTTP协议以及其他协议是否可使用更高的版本进行通信, 其参数值可以用来指定一个完全不同的通信协议

#### Via

首部字段Via是为了追踪客户端与服务器之间的请求和响应报文传输路径
报文经过代理或者网关时, 会先在首部字段Via中附加该服务器的信息, 然后再进行转发

#### Warning

首部字段会告知用户一些与缓存相关的问题的警告

| 警告码 | 警告内容 | 说明 |
|:---:|:---:|:---:|
| 110 | Response is stale(响应已过期) | 代理返回已过期的资源 |
| 111 | Revalidation failed(再验证失败) | 代理再验证资源有效性时失败 |
| 112 | Disconnection operation(断开连接操作) | 代理与互联网连接被故意切断 |
| 113 | Heuristic expiration(试探性过期) | 响应的使用期超过24小时 |
| 199 | Miscellaneous warning(杂项警告) | 任意的警告内容 |
| 214 | Transformation applied(使用了转换) | 代理对内容编码或媒体类型等执行了某些处理时 |
| 299 | Miscellaneous warning(持久杂项警告) | 任意的警告内容 |

### 请求首部字段

#### Accept 

Accept首部字段可通知服务器, 用户代理能够处理得媒体类型及媒体类型的相对优先级

#### Accept-Charset

Accept-Charset首部字段可用来通知服务器用户代理支持的字符集以及字符集的相对优先顺序

#### Accept-Encoding

Accept-Encoding首部字段用来告知服务器用户代理支持的内容编码以及内容编码的优先级顺序

* gzip
  由文件压缩程序gzip生成的编码格式, 采用Lempel-Ziv算法以及32位循环冗余校验(Cyclic Redundancy Check, CRC)
* compress
  由Unix文件压缩程序compress生成的编码格式, 采用Lempel-Ziv-Welch算法
* deflate
  组合使用zlib格式及由defalte压缩算法生成的编码格式
* identity
  不执行压缩或不会变化的默认编码格式

#### Accept-Language

Accept-Language首部字段用来告知服务器用户代理能够处理的自然语言集, 以及自然语言集的相对优先级

#### Authorization

Authorization首部字段用来告知服务器, 用户代理的认证信息, 通常, 想要通过服务器认证的用户代理会在接受到返回的401状态后, 把首部字段Authorization加入请求中

#### Expect 

Expect字段告知服务器, 期望出现的某种特定行为

#### From

From字段告知服务器使用用户代理的用户的电子邮件地址

#### Host

首部字段Host会告知服务器, 请求的资源所处的灰暗往主机名和端口号

#### Max-Forwards

通过TRACE或OPTIONS方法, 发送包含首部字段Max-Forwards的请求时, 该字段以十进制整数形式指定可经过的服务器最大化数目

#### Proxy-Authorization

接收到从代理服务器发来的认证质询时, 客户端会发送包含首部字段 Proxy-Authorization的请求, 以告知服务器认证所需要的信息

#### Range

对于只需获取部分资源的范围请求, 包含首部字段Range即可告知服务器资源的指定范围

#### Referer

Referer 字段会告知服务器请求的原始资源的URI

#### TE

TE字段会告知服务器客户端能够处理响应的传输编码方式及相对优先级

#### User-Agent

User-Agent首部字段将创建请求的浏览器和用户代理名称等信息传达给服务器

### 响应首部字段

#### Accept-Ranges

首部字段Accept-Ranges 是用来告知客户端服务器是否能处理范围请求, 以指定获取服务器端某个部分的资源

#### Age

首部字段Age能告知客户端, 源服务器再多久前创建了响应

#### ETag

首部字段ETag能告知客户端实体标识, 它是一种可将资源以字符串形式做唯一性标识的方式

#### Location

Location 可以将响应接收方引导至某个与请求URI位置不同的资源
该字段会配合3XX: Redirection 的响应, 提供重定向的URI

#### Proxy-Authenticate 

Proxy-Authenticate字段会把由代理服务器所要求的认证信息发送给客户端

#### Retry-After

首部字段 Retry-After告知客户端应该在多久之后再次发送请求, 主要配合状态码 503 Service Unavailable 响应, 或 3xx Redirect响应一起使用

#### Server

首部字段 Server 告知客户端当前服务器上安装的HTTP服务器应用程序的信息

#### Vary

首部字段Vary客队缓存进行控制, 源服务器会向代理服务器传达关于本地缓存使用方法的命令

#### WWW-Authenticate

首部字段 WWW-Authenticate 用于HTTP访问认证, 他会告知客户端适用于访问请求URI所指定资源的认证方案和带参数提示的质询

### 实体首部字段

#### Allow

Allow用于通知客户端能够支持Request-URI指定资源的所有HTTP方法

#### Content-Encoding

Content-Encoding 会告知客户端服务器对实体的主体部分选用的内容编码方式

#### Content-Language

Content-Language会告知客户端, 实体主体使用的自然语言

#### Content-Length

Content-Length表明了实体主体部分的大小

#### Content-Location

Content-Location 给出与报文主体部分相对应的URI

#### Content-MD5

客户端会对接收的报文主体执行相同的MD5算法, 然后与首部字段Content-MD5进行比较, 用来检查报文传输过程中是否完整

#### Content-Range

针对范围请求, 返回响应时使用首部字段 Content-Range, 能告知客户端作为响应返回的实体在哪个部分符合范围请求

#### Content-Type

首部字段Content-Type说明了实体主体内对象的媒体类型

#### Expires

Expires会将资源失效的日期告知客户端

#### Last-Modified

Last-Modified指明资源最终修改的时间

### Cookies首部字段

#### Set-Cookie

Set-Cookie字段的属性值

| 属性 | 说明 |
|:---:|:---:|
| NAME=VALUE | 赋予Cookies的名称和值 |
| expires=DATE | Cookie的有效期 |
| path=PATH | 将服务器上的文件目录作为Cookie的适用对象 |
| domain=域名 | 作为Cookie适用对象的域名 |
| Secure | 仅在HTTPS安全通信时才会发送Cookies |
| HttpOnly | 加以限制, 使Cookie不能被javascript脚本访问 |

#### Cookie

Cookie会告知服务器, 当客户端想获得HTTP状态管理支持时, 就会在请求中包含从服务器接收道德Cookie

