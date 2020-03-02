# Docker Alpine PHP

## 环境

```
alpine: ^3.11
php: 7.1.33
```

## 常用命令：

```sh
# 拉取镜像
$ docker pull seffeng/php

# 运行；若配合 nginx 使用，注意 <html-dir> 和 <tmp-dir> 与 nginx 一致
$ docker run --name php-test -d -v <html-dir>:/opt/websrv/data/wwwroot -v <tmp-dir>:/opt/websrv/tmp -v <log-dir>:/opt/websrv/logs seffeng/php

# 完整示例，--link 用于通过别名链接对应的 redis 和 mysql ：
$ docker run --name php-71-alias1 --link redis-alias1 --link mysql-alias1 -d -v /srv/websrv/data/wwwroot:/opt/websrv/data/wwwroot -v /srv/websrv/tmp:/opt/websrv/tmp -v /srv/websrv/logs/php/7.1:/opt/websrv/logs seffeng/php:7.1

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
```
