FROM alpine:3.8

MAINTAINER  seffeng "seffeng@sina.cn"

ARG BASE_DIR="/opt/websrv"

ENV PHP_VERSION=php-5.6.40\
 REDIS_EXT_VERSION=redis-4.3.0\
 LIBICONV_VERSION=libiconv-1.16\
 CONFIG_DIR="${BASE_DIR}/config/php"\
 INSTALL_DIR=${BASE_DIR}/program/php\
 BASE_PACKAGE="wget tzdata gcc g++ make file autoconf patch gzip bzip2 curl libevent-dev bison re2c perl openssl-dev"\
 EXTEND="libcurl libxml2-dev libjpeg-turbo-dev libpng-dev libzip-dev freetype-dev"
 
ENV PHP_URL="https://www.php.net/distributions/${PHP_VERSION}.tar.bz2"\
 REDIS_EXT_URL="https://pecl.php.net/get/${REDIS_EXT_VERSION}.tgz"\
 LIBICONV_URL="https://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV_VERSION}.tar.gz"\
 CONFIGURE="./configure\
 --prefix=${INSTALL_DIR}\
 --enable-fpm\
 --with-fpm-user=www\
 --with-fpm-group=wwww\
 --with-config-file-path=${CONFIG_DIR}\
 --with-config-file-scan-dir=${CONFIG_DIR}/conf.d\
 --enable-bcmath\
 --enable-exif\
 --enable-ftp\
 --enable-mbstring\
 --enable-mysqlnd\
 --enable-pcntl\
 --enable-sockets\
 --enable-zip\
 --with-curl\
 --with-freetype-dir\
 --with-gd\
 --with-iconv=/usr/local\
 --with-jpeg-dir\
 --with-mysql=mysqlnd\
 --with-mysqli=mysqlnd\
 --with-openssl\
 --with-pdo-mysql=mysqlnd\
 --with-pear\
 --with-png-dir\
 --with-zlib"

WORKDIR /tmp
COPY    conf ./conf

RUN \
 ############################################################
 # apk add
 ############################################################
 sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories &&\
 apk update && apk add --no-cache ${BASE_PACKAGE} ${EXTEND} &&\
 cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
 echo 'Asia/Shanghai' > /etc/timezone &&\
 mkdir -p ${BASE_DIR}/data/wwwroot ${BASE_DIR}/logs ${BASE_DIR}/tmp ${CONFIG_DIR}/conf.d &&\
 addgroup wwww && adduser -H -D -s /sbin/nologin -G wwww www &&\
 ############################################################
 # download files
 ############################################################
 wget ${PHP_URL} &&\
 wget ${REDIS_EXT_URL} &&\
 wget ${LIBICONV_URL} &&\
 tar -jxf ${PHP_VERSION}.tar.bz2 &&\
 tar -zxf ${REDIS_EXT_VERSION}.tgz &&\
 tar -zxf ${LIBICONV_VERSION}.tar.gz &&\
 ############################################################
 # install libiconv
 ############################################################
 cd /tmp/${LIBICONV_VERSION} &&\
 ./configure --prefix=/usr/local &&\
 make && make install &&\
 if [ -f /usr/bin/iconv ] ; then (rm -rf /usr/bin/iconv) fi &&\
 ln -s /usr/local/bin/iconv /usr/bin/iconv &&\
 ############################################################
 # install php
 ############################################################
 cd /tmp/${PHP_VERSION} &&\
 ${CONFIGURE} &&\
 make && make install &&\
 ln -s ${INSTALL_DIR}/bin/php /usr/bin/php &&\
 ln -s ${INSTALL_DIR}/bin/phpize /usr/bin/phpize &&\
 cp -Rf /tmp/conf/* ${CONFIG_DIR} &&\
 echo -e "#!/bin/sh\n${INSTALL_DIR}/sbin/php-fpm -y ${CONFIG_DIR}/php-fpm.conf \$1" > ${CONFIG_DIR}/start.sh &&\
 echo -e "#/bin/sh/\nkill -INT  \`cat ${BASE_DIR}/tmp/php-fpm.pid\`" > ${CONFIG_DIR}/stop.sh &&\
 echo -e "#/bin/sh/\nkill -USR2  \`cat ${BASE_DIR}/tmp/php-fpm.pid\`" > ${CONFIG_DIR}/reload.sh &&\
 chmod +x ${CONFIG_DIR}/start.sh ${CONFIG_DIR}/stop.sh ${CONFIG_DIR}/reload.sh &&\
 ln -s ${CONFIG_DIR}/start.sh /usr/bin/php-fpm &&\
 ############################################################
 # install redis ext
 ############################################################
 cd /tmp/${REDIS_EXT_VERSION} &&\
 ${INSTALL_DIR}/bin/phpize &&\
 ./configure --with-php-config=${INSTALL_DIR}/bin/php-config &&\
 make && make install &&\
 echo -e "; redis extension ;\nextension=redis.so" > ${CONFIG_DIR}/conf.d/redis.ini &&\
 ############################################################
 cd /tmp && apk del ${BASE_PACKAGE} &&\
 rm -rf /var/cache/apk/* &&\
 rm -rf /tmp/*

VOLUME ["${BASE_DIR}/tmp", "${BASE_DIR}/data/wwwroot", "${BASE_DIR}/logs"]

CMD ["php-fpm", "-F"]
