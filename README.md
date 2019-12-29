# Docker Alpine Nginx

常用命令：

```sh
# 拉取镜像
$ docker pull seffeng/nginx

# 运行
$ docker run --name nginx-test -d -p 80:80 -p 443:443 -v <html-dir>:/opt/websrv/data/wwwroot -v <conf-dir>:/opt/websrv/config/nginx/conf.d -v <cert-dir>:/opt/websrv/config/nginx/certs.d -v <log-dir>:/opt/websrv/logs <tmp-dir>:/opt/websrv/tmp seffeng/nginx

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

