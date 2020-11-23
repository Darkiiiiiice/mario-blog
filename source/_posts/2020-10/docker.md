---
title: Docker 总结
date: '2020-10-12'
category: Docker
author: MarioMang
cover: /resources/images/default_cover.gif
---

# Docker 学习总结

## 简介

容器与管理程序虚拟化(Hypervisor Virtualization, HV)不同  
**管理程序虚拟化** 通过中间层将一台或多台独立的机器虚拟运行与物理硬件之上  
**容器** 则是直接运行在操作系统内核之上的用户空间

**Docker** 是一个能够把开发的应用程序自动部署到容器的开源引擎。由 [Docker](https://www.docker.com) 公司的团队编写， 基于 Apache2.0 开源授权协议发行。

### Docker 组件
* Docker 客户端和服务器(Docker Engine)
    > Docker 是一个客户端/服务器(C/S)架构的程序。 Docker 提供了一个命令行工具 docker 以及一整套 RESTful API 与守护进程通信
* Docker 镜像
    > 镜像是基于联合文件系统的一种层式结构，由一系列指令一步一步构建出来
* Registry
    > Docker 用 Registry 来保存用户构建的镜像。Registry分为公共和私有两种
    > Docker 公司运营的公共 Registry 叫做 Docker Hub
* Docker 容器
    > 容器基于镜像启动，容器中可以运行一个或多个进程.

### Docker 技术组件
* 一个原生的 Linux 容器格式， Docker 中成为 libcontainer
* Linux 内核的命名空间，用于隔离文件系统、进程和网络
* 文件系统隔离，每个容器都有自己的root文件系统
* 进程隔离 每个容器都运行在自己的进程环境中
* 网络隔离 容器间的虚拟网络接口和IP地址都是分开的
* 资源隔离和分组 使用 cgroups 将CPU和内存之类的资源独立分配给每个 Docker 容器
* 写时复制 文件系统都是通过写时复制创建的，这就意味着文件系统是分层的、快速的，而且占用磁盘空间更小
* 日志 容器产生的 STDOUT、STDERR 和 STDIN 这些IO流都会被收集并记入日志，用来进行日志分析和故障排错
* 交互式 Shell 用户可以创建一个伪 tty 终端，将其链接到 STDIN， 为容器提供一个交互式的 Shell


### Docker 守护进程
* 修改守护进程的网络
    > 将 Docker 守护进程绑定到宿主机上的所有网络接口
    ``` Bash
    $ sudo docker daemon -H tcp://0.0.0.0:2375
    ```
    > 可以通过设置环境变量避免每次运行客户端都执行上步命令
    ``` Bash
    $ export DOCKER_HOST="tcp://0.0.0.0:2375"
    ```
    > 将 Docker 守护进程绑定到非默认套接字
    ``` Bash
    $ sudo docker daemon -H unix://home/docker/docker.sock
    ```
    > 将 Docker 守护进程绑定到多个地址
    ``` Bash
    $ sudo docker daemon -H tcp://0.0.0.0:2375 -H unix://home/docker/docker.sock
    ```
    > 开启 Docker 守护进程的调试模式
    ``` Bash
    $ sudo docker daemon -D
    ```
* 检查 Docker 守护进程状态
    > 检查 Docker 守护进程的状态
    ``` Bash
    $ sudo systemctl status docker
    ```
    > 启动 Docker 守护进程
    ``` Bash
    $ sudo systemctl start docker
    ```
    > 停止 Docker 守护进程
    ``` Bash
    $ sudo systemctl stop docker
    ```

### Docker 基础操作
* 查询 Docker 信息
    ``` Bash
    $ sudo docker info
    ```

* 启动 Docker 镜像
    ``` Bash
    $ sudo docker run -i -t ubuntu /bin/bash
    ```

* 停止 Docker 镜像
    ``` Bash
    $ sudo docker stop container_name/container_id
    ```

* 重新启动已经停止的容器
    ``` Bash
    $ sudo docker start container_name/container_id
    ```

* 附着到正在运行的容器上
    ``` Bash
    $ sudo docker attach container_name/container_id
    ```

* 创建守护式容器
    ``` Bash
    $ sudo docker run -d ubuntu /bin/bash
    ```

* 获取容器日志
    ``` Bash
    $ sudo docker logs container_name/container_id
    ```

* 查看守护式容器进程
    ``` Bash
    $ sudo docker top container_name
    ```

* 自动重启容器
    ``` Bash
    $ sudo docker run --restart=always -d ubuntu
    ```

* 查看容器信息
    ``` Bash
    $ sudo docker inspect daemon_container
    ```

* 删除容器
    ``` Bash
    $ sudo docker rm container
    ```

### Docker 镜像和仓库

Docker 镜像是由文件系统叠加而成。最底端是一个引导文件系统，即bootfs，这很像典型的 Linux/Unix 的引导文件系统  

* 列出 Docker 镜像
    ``` Bash
    $ sudo docker images
    ```
    > 本地镜像都保存在 Docker 宿主机的 /var/lib/docker 目录下

* 拉取 Docker 镜像
    ``` Bash
    $ sudo docker pull ubuntu:20.04
    ```

* 查找镜像
    ``` Bash
    $ sudo docker search nginx
    ```

* 提交定制容器
    ``` Bash
    $ sudo docker commit container_id mariomang/ubuntu
    ```

#### 用 Dockerfile 构建镜像

1. 创建示例仓库
    ``` Bash
    $ mkdir static_web
    $ cd !$
    $ touch Dockerfile
    ```

2. 编写 Dockerfile 
    ``` Dockerfile
    # Version: 0.0.1
    FROM ubuntu:20.04
    MAINTAINER MarioMang "mariomang@exmaple.com"
    RUN apt-get update && apt-get install -y nginx
    RUN echo 'Hi, I am in your container' \
        > /usr/share/nginx/html/index.html
    EXPOSE 80
    ```

3. 基于 Dockerfile 构建镜像
    ``` Bash
    $ sudo docker build -t="mariomang/static_web" .
    ```
4. 忽略 Dockerfile 的构建缓存
    ``` Bash
    $ sudo docker build --no-cache -t="mariomang/static_web"
    ```

#### Dockerfile 指令

1. CMD 
    > CMD 指令用于指定容器启动时要运行的指令  
    > 使用 docker run 命令可以覆盖 CMD 指令
    > 在 Dockerfile 中只能指定一条指令
    > 如果有多条CMD指令，只有最后一条CMD指令会被使用
    1. 使用CMD指令
    ``` Dockerfile
    CMD ["/bin/bash"]
    ```

    2. 给CMD指令传递参数
    ``` Dockerfile
    CMD ["/bin/bash", "-l"]
    ```

2. ENTRYPOINT
    > 在启动容器时不容易被覆盖
    > 用户可以在运行时通过 docker run 的 --entrypoint 标志覆盖 ENTRYPOINT
    1. 使用 ENTRYPOINT 指令
    ``` Dockerfile
    ENTRYPOINT ["/usr/sbin/nginx"]
    ```

    2. 为ENTRYPOINT指令指定参数
    ``` Dockerfile
    ENTRYPOINY ["/usr/sbin/nginx","-g","daemon off;"]
    ```

3. WORKDIR
    > WORKDIR 指令用来在从镜像创建一个新容器时，在容器内部设置一个工作目录， ENTRYPOINT和CMD指定的程序会在这个目录下执行
    1. 使用 WORKDIR 指令
    ``` Dockerfile
    WORKDIR /opt/webapp/db
    ```
    2. 覆盖工作目录
    ``` Dockerfile
    $ sudo docker run -it -w /var/log ubuntu pwd
    ```

4. ENV
    > ENV 指令用来在镜像构建过程中设置环境变量
    1. 在 Dockerfile 文件中设置环境变量
    ``` Dockerfile
    ENV RVM_PATH /home/rvm
    ```
    2. 使用 ENV 设置多个环境变量
    ``` Dockerfile
    ENV RVM_PATH=/home/rvm RVM_ARCHFLAGS="-arch i386"
    ```
    3. 在 Dockerfile 中使用环境变量
    ``` Dockerfile
    ENV TARGET_DIR /opt/app
    WORKDIR $TARGET_DIR
    ```

5. USER
    > USER 指令用来指定该镜像会以什么样的用户去运行
    1. 使用 USER 指令
    ``` Dockerfile
    USER nginx
    ```
    2. 指定 USER 和 GROUP 的各种组合
    ``` Dockerfile
    USER user
    USER user:group
    USER uid
    USER uid:gid
    USER user:gid
    USER uid:group
    ```

6. VOLUME
    > VOLUME 指令用来向基于镜像创建的容器添加卷
    > 一个卷可以存在于一个或者多个容器内的特定目录
    * 卷可以在容器间共享和重用
    * 一个容器可以不是必须和其他容器共享卷
    * 对卷的修改是立即生效的
    * 对卷的修改不会更新镜像产生影响
    * 卷会一直存在直到没有任何容器再使用它

    1. 使用 VOLUME 指令
    ``` Dockerfile
    VOLUME ["/opt/project"]
    ```
    2. 使用 VOLUME 指令指定多个卷
    ``` Dockerfile
    VOLUME ["/opt/project", "/data"]
    ```

7. ADD
    > ADD 指令用来将构建环境下的文件和目录复制到镜像中

    1. 使用 ADD 指令
    ``` Dockerfile
    ADD software.so /opt/application/software.so
    ```
    2. 在 ADD 指令中使用 URL 作为文件源
    ``` Dockerfile
    ADD http://xxxx.com/latest.zip /opt/latest.zip
    ```
    3. 将归档文件作为 ADD 指令中的源文件
    > Docker 会将归档文件解开到目录下
    > Docker 解开归档文件 = tar -x
    ``` Dockerfile
    ADD latest.tar.gz /opt/latest/
    ```

8. COPY 
    > COPY 非常类似 ADD, 区别在于 COPY 不会提取文件和解压文件

    1. 使用 COPY 指令
    ``` Dockerfile
    COPY conf.d/ /etc/conf.d/
    ```

9. LABEL
    > LABEL 指令用于为Docker 镜像添加元数据
    > 元数据以键值对的形式展现

    1. 添加 LABEL指令
    ``` Dockerfile
    LABEL version="1.0"
    LABEL location="Beijing" type="Data Center" role="Web Server"
    ```

10. STOPSIGNAL
    > STOPSIGNAL 指令用来设置停止容器时发送什么系统调用信号给容器

11. ARG
    > ARG 指令用来定义可以在 docker build 命令运行时传递给构建运行时的变量
    > 只需要在构建时使用 --build-arg 标志即可
    
    1. 添加 ARG指令
    ``` Dockerfile
    ARG build
    ARG webapp_user=user
    ```
    2. 使用 ARG 指令
    ``` Bash
    $ sudo docker build --build-arg build=1234 -t webapp .
    ```
    3. 预定义 ARG 变量
    ``` Txt
    HTTP_PROXY
    http_proxy
    HTTPS_PROXY
    https_proxy
    FTP_PROXY
    ftp_proxy
    NO_PROXY
    no_proxy
    ```

12. ONBUILD
    > ONBUILD 指令能为镜像添加触发器

    1. 添加 ONBUILD 指令
    ``` Dockerfile
    ONBUILD ADD . /app/src
    ONBUILD RUN cd /app/src && make
    ```

#### Docker Networking

> Docker Networking 允许用户创建自己的网络，容器可以通过这个网上互相通信

1. 创建 Docker 网络
``` Bash
$ sudo docker network create app
```
> 这里用 docker network 创建了一个桥接网络

2. 在 Docker 网络中使用容器
``` Bash
$ sudo docker run -d --net=app redis
```

3. 将已有网络添加到容器
``` Bash
$ sudo docker network connect app redis
```

4. 从网络中断开一个容器
``` Bash
$ sudo docker network disconnect app redis
```

5. 链接另一个容器
``` Bash
$ sudo docker run --link redis:redis-name ubuntu
```

6. 在容器内添加 /etc/hosts 记录
``` Bash
$ sudo docker run --add-host=docker:172.18.0.2 redis
```

