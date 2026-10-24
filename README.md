# Docker Alpine PHP

# 版本

* [8.5 , 8.5.12 , latest](https://github.com/seffeng/docker-php/tree/8.5)
* [8.4 , 8.4.27](https://github.com/seffeng/docker-php/tree/8.4)
* [8.3 , 8.3.36](https://github.com/seffeng/docker-php/tree/8.3)
* [8.2 , 8.2.35](https://github.com/seffeng/docker-php/tree/8.2)
* [8.1 , 8.1.34](https://github.com/seffeng/docker-php/tree/8.1)
* [8.0 , 8.0.30](https://github.com/seffeng/docker-php/tree/8.0)
* [7.4 , 7.4.33](https://github.com/seffeng/docker-php/tree/7.4)
* [7.3 , 7.3.33](https://github.com/seffeng/docker-php/tree/7.3)
* [7.2 , 7.2.34](https://github.com/seffeng/docker-php/tree/7.2)
* [7.1 , 7.1.33](https://github.com/seffeng/docker-php/tree/7.1)
* [5.6 , 5.6.40](https://github.com/seffeng/docker-php/tree/5.6)

## Dockerfile 说明

```shell
# Dockerfile.Extension
## 增加扩展，在 php:8.5 镜像基础上生成 php:8.5-ext 镜像

# Dockerfile.Slim
## 精简镜像，在 php:8.5-ext 镜像基础上生成 php:8.5-ext-slim 镜像

# Dockerfile.Supervisor
## 增加 supervisor，在 php:8.5-ext-slim 镜像基础上生成 php-supervisor:8.5-ext-slim 镜像

# Dockerfile.Nginx
## 增加 nginx，在 nginx:1.30 和 php-supervisor:8.5-ext-slim 镜像基础上生成 nginx-php:1.30-8.5 镜像

# 注意，仓库推送时报错（error from registry: unknown manifest class for application/vnd.oci.empty.v1+json）
## 原因1：Registry 版本过旧或不支持 OCI Artifacts；
## 原因2：客户端工具与 Registry 的兼容性问题
## 修改参数，以非 OCI 方式进行构建
$ set DOCKER_BUILDKIT=1
$ set BUILDX_NO_DEFAULT_ATTESTATIONS=1
$ docker build --output type=image,name=myimage,oci-mediatypes=false -t [IMAGE NAME] .
```

## 常用命令：

```sh
# 拉取镜像
$ docker pull seffeng/php

# 运行；若配合 nginx 使用，注意 <html-dir> 和 <tmp-dir> 与 nginx 一致
$ docker run --name php-test -d -v <html-dir>:/opt/websrv/data/wwwroot -v <tmp-dir>:/opt/websrv/tmp -v <log-dir>:/opt/websrv/logs seffeng/php

# 完整示例，可参考备注
$ docker run --name php-alias1 -d -v /opt/websrv/data/wwwroot:/opt/websrv/data/wwwroot -v /opt/websrv/tmp:/opt/websrv/tmp -v /opt/websrv/logs/php:/opt/websrv/logs seffeng/php

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
#### 备注

```shell
# 建议容器之间使用网络互通
## 1、添加网络[已存在则跳过此步骤]
$ docker network create network-01

## 运行容器增加 --network network-01 --network-alias [name-net-alias]
$ docker run --name php-alias1 --network network-01 --network-alias php-net1 -d -v /opt/websrv/data/wwwroot:/opt/websrv/data/wwwroot -v /opt/websrv/tmp:/opt/websrv/tmp -v /opt/websrv/logs/php:/opt/websrv/logs seffeng/php
```