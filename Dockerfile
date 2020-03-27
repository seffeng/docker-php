FROM seffeng/alpine:latest

MAINTAINER  seffeng "seffeng@sina.cn"

ARG BASE_DIR="/opt/websrv"

ENV PHP_VERSION=php-7.4.4\
 REDIS_EXT_VERSION=redis-5.2.1\
 CONFIG_DIR="${BASE_DIR}/config/php"\
 INSTALL_DIR=${BASE_DIR}/program/php\
 BASE_PACKAGE="gcc g++ make file autoconf patch gzip freetype-dev curl-dev libevent-dev bison re2c openssl-dev"\
 EXTEND="libcurl libxml2-dev libjpeg-turbo-dev libpng-dev sqlite-dev oniguruma-dev bzip2-dev "
 
ENV PHP_URL="https://www.php.net/distributions/${PHP_VERSION}.tar.bz2"\
 REDIS_EXT_URL="http://pecl.php.net/get/${REDIS_EXT_VERSION}.tgz"\
 CONFIGURE="./configure\
 --prefix=${INSTALL_DIR}\
 --enable-fpm\
 --with-fpm-user=www\
 --with-fpm-group=wwww\
 --with-config-file-path=${CONFIG_DIR}\
 --with-config-file-scan-dir=${CONFIG_DIR}/conf.d\
 --enable-ftp\
 --enable-mbstring\
 --enable-mysqlnd\
 --enable-sockets\
 --enable-bcmath\
 --enable-exif\
 --enable-gd\
 --with-bz2\
 --with-jpeg\
 --with-curl\
 --with-openssl\
 --with-mysqli=mysqlnd\
 --with-pdo-mysql=mysqlnd\
 --with-zlib\
 --with-pear"

WORKDIR /tmp
COPY    conf ./conf

RUN \
 wget ${PHP_URL} &&\
 wget ${REDIS_EXT_URL} &&\
 tar -jxf ${PHP_VERSION}.tar.bz2 &&\
 tar -zxf ${REDIS_EXT_VERSION}.tgz &&\
 apk update && apk add --no-cache ${BASE_PACKAGE} ${EXTEND} &&\
 mkdir -p ${BASE_DIR}/data/wwwroot ${BASE_DIR}/logs ${BASE_DIR}/tmp ${CONFIG_DIR}/conf.d &&\
 addgroup wwww && adduser -H -D -G wwww www &&\
 cd ${PHP_VERSION} &&\
 ${CONFIGURE} &&\
 make && make install &&\
 ln -s ${INSTALL_DIR}/bin/php /usr/bin/php &&\
 ln -s ${INSTALL_DIR}/bin/phpize /usr/bin/phpize &&\
 cp -Rf /tmp/conf/* ${CONFIG_DIR} &&\
 echo -e "#!/bin/sh\n${INSTALL_DIR}/sbin/php-fpm -F -y ${CONFIG_DIR}/php-fpm.conf \$1" > ${CONFIG_DIR}/start.sh &&\
 echo -e "#/bin/sh/\nkill -INT  \`cat ${BASE_DIR}/tmp/php74-fpm.pid\`" > ${CONFIG_DIR}/stop.sh &&\
 echo -e "#/bin/sh/\nkill -USR2  \`cat ${BASE_DIR}/tmp/php74-fpm.pid\`" > ${CONFIG_DIR}/reload.sh &&\
 chmod +x ${CONFIG_DIR}/start.sh ${CONFIG_DIR}/stop.sh ${CONFIG_DIR}/reload.sh &&\
 ln -s ${CONFIG_DIR}/start.sh /usr/bin/php-fpm &&\
 cd /tmp/${REDIS_EXT_VERSION} &&\
 ${INSTALL_DIR}/bin/phpize &&\
 ./configure --with-php-config=${INSTALL_DIR}/bin/php-config &&\
 make && make install &&\
 echo -e "; redis extension ;\nextension=redis" > ${CONFIG_DIR}/conf.d/redis.ini &&\
 cd /tmp && apk del ${BASE_PACKAGE} &&\
 rm -rf /var/cache/apk/* &&\
 rm -rf /tmp/*

VOLUME ["${BASE_DIR}/tmp", "${BASE_DIR}/data/wwwroot", "${BASE_DIR}/logs"]

CMD ["php-fpm", "-F"]