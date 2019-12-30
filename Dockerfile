FROM seffeng/alpine:latest

MAINTAINER  seffeng "seffeng@sina.cn"

ARG BASE_DIR="/opt/websrv"

ENV PHP_VERSION=php-7.3.13\
 CONFIG_DIR="${BASE_DIR}/config/php"\
 INSTALL_DIR=${BASE_DIR}/program/php\
 BASE_PACKAGE="gcc g++ make file"\
 EXTEND="patch gzip freetype-dev bzip2 libcurl libxml2-dev curl-dev libjpeg-turbo-dev libpng-dev libevent-dev openssl-dev"
 
ENV PHP_URL="https://www.php.net/distributions/${PHP_VERSION}.tar.bz2"\
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
 --with-gd\
 --with-jpeg-dir\
 --with-png-dir\
 --with-curl\
 --with-openssl\
 --with-zlib"

WORKDIR /tmp
COPY    conf ./conf

RUN apk update && apk add --no-cache ${BASE_PACKAGE} ${EXTEND} &&\
 wget ${PHP_URL} &&\
 tar -jxf ${PHP_VERSION}.tar.bz2 &&\
 mkdir -p ${BASE_DIR}/logs ${BASE_DIR}/tmp ${CONFIG_DIR}/conf.d ${CONFIG_DIR}/log &&\
 addgroup wwww && adduser -H -D -G wwww www &&\
 cd ${PHP_VERSION} &&\
 ${CONFIGURE} &&\
 make && make install &&\
 ln -s ${INSTALL_DIR}/bin/php /usr/bin/php &&\
 ln -s ${INSTALL_DIR}/bin/phpize /usr/bin/phpize &&\
 cp -Rf /tmp/conf/* ${CONFIG_DIR} &&\
 echo -e "#!/bin/sh\n${INSTALL_DIR}/sbin/php-fpm -F -y ${CONFIG_DIR}/php-fpm.conf \$1" > ${CONFIG_DIR}/start.sh &&\
 echo -e "#/bin/sh/\nkill -INT  \`cat ${CONFIG_DIR}/logs/php-fpm.pid\`" > ${CONFIG_DIR}/stop.sh &&\
 echo -e "#/bin/sh/\nkill -USR2  \`cat ${CONFIG_DIR}/logs/php-fpm.pid\`" > ${CONFIG_DIR}/reload.sh &&\
 chmod +x ${CONFIG_DIR}/start.sh ${CONFIG_DIR}/stop.sh ${CONFIG_DIR}/reload.sh &&\
 ln -s ${CONFIG_DIR}/start.sh /usr/bin/php-fpm &&\
 apk del ${BASE_PACKAGE} &&\
 rm -rf /var/cache/apk/* &&\
 rm -rf /tmp/*

VOLUME ["${BASE_DIR}/tmp", "${BASE_DIR}/data/wwwroot"]

CMD ["php-fpm", "-F"]