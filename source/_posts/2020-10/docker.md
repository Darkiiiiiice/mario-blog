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






