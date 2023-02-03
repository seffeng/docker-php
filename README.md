# Docker Alpine PHP

## 版本

* [8.1 , 8.1.15](https://github.com/seffeng/docker-php/tree/8.1)

## 常用命令：

```sh
# 拉取镜像
$ docker pull seffeng/php:8.1

# 运行；若配合 nginx 使用，注意 <html-dir> 和 <tmp-dir> 与 nginx 一致
$ docker run --name php-test -d -v <html-dir>:/opt/websrv/data/wwwroot -v <tmp-dir>:/opt/websrv/tmp -v <log-dir>:/opt/websrv/logs seffeng/php

# 完整示例，可参考备注 ：
$ docker run --name php-81-alias1 -d -v /opt/websrv/data/wwwroot:/opt/websrv/data/wwwroot -v /opt/websrv/tmp:/opt/websrv/tmp -v /opt/websrv/logs/php/8.1:/opt/websrv/logs seffeng/php:8.1

# 查看正在运行的容器
$ docker ps

# 停止
$ docker stop [CONTAINER ID | NAMES]

# 启动
$ docker start [CONTAINER ID | NAMES]

# 进入终端
$ docker exec -it [CONTAINER ID | NAMES] sh

# 删除容器
$ docker rm [CONTAINER ID | NAMES]

# 镜像列表查看
$ docker images

# 删除镜像
$ docker rmi [IMAGE ID]

# 复制本机文件到容器
$ docker cp /root/file [CONTAINER ID]:/root/file

# 复制容器文件到本机
$ docker cp [CONTAINER ID]:/root/file /root/file
```

#### 网络

```shell
# 查看网络
$ docker network ls

# 创建网络
$ docker network create [NAME]
```

#### 备注

```shell
# 建议容器之间使用网络互通
## 1、添加网络[已存在则跳过此步骤]
$ docker network create network-01

## 运行容器增加 --network network-01 --network-alias [name-net-alias]
$ docker run --name php-81-alias1 --network network-01 --network-alias php-81-net1 -d -v /opt/websrv/data/wwwroot:/opt/websrv/data/wwwroot -v /opt/websrv/tmp:/opt/websrv/tmp -v /opt/websrv/logs/php/8.1:/opt/websrv/logs seffeng/php:8.1
```

