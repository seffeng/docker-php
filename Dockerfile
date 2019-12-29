FROM    seffeng/alpine

MAINTAINER  seffeng "seffeng@sina.cn"

ARG BASE_DIR="/opt/websrv"

ENV VERSION=7.3.13\
 CONFIG_DIR="${BASE_DIR}/config/php"\
 INSTALL_DIR=${BASE_DIR}/program/php\
 EXTEND="gcc g++ make bzip2 autoconf file libc-dev pkgconf argon2-dev coreutils libedit-dev libsodium-dev perl openssl-dev patch gzip freetype libcurl libxml2-dev curl-dev libjpeg-turbo-dev libpng-dev libevent-dev sqlite-dev"
 
ARG CONFIGURE="./configure\
 --prefix=${INSTALL_DIR}\
 --enable-fpm\
 --with-fpm-user=www\
 --with-fpm-group=wwww\
 --with-config-file-path=${CONFIG_DIR}\
 --enable-option-checking=fatal\
 --with-mhash\
 --enable-ftp\
 --enable-mbstring\
 --enable-mysqlnd\
 --with-password-argon2\
 --with-sodium=shared\
 --with-curl\
 --with-libedit\
 --with-openssl\
 --with-zlib\
 --with-config-file-scan-dir=${CONFIG_DIR}/conf.d"

WORKDIR /tmp
ADD php-${VERSION}.tar.bz2 ./
COPY    conf ./conf

RUN apk update && apk add --no-cache ${EXTEND} &&\
 mkdir -p ${BASE_DIR}/logs ${BASE_DIR}/tmp ${CONFIG_DIR}/conf.d &&\
 addgroup wwww && adduser -H -D -G wwww www &&\
 cd php-${VERSION} &&\
 ${CONFIGURE} &&\
 make && make install &&\
 ln -s ${INSTALL_DIR}/bin/php /usr/bin/php &&\
 ln -s ${INSTALL_DIR}/bin/phpize /usr/bin/phpize &&\
 cp -Rf /tmp/conf/* ${CONFIG_DIR} &&\
 echo -e "#!/bin/sh\n${INSTALL_DIR}/sbin/php-fpm -y ${CONFIG_DIR}/php-fpm.conf \$1" > ${CONFIG_DIR}/start.sh &&\
 echo -e "#/bin/sh/\nkill -INT  \`cat ${CONFIG_DIR}/logs/php-fpm.pid\`" > ${CONFIG_DIR}/stop.sh &&\
 echo -e "#/bin/sh/\nkill -USR2  \`cat ${CONFIG_DIR}/logs/php-fpm.pid\`" > ${CONFIG_DIR}/reload.sh &&\
 chmod +x ${CONFIG_DIR}/start.sh ${CONFIG_DIR}/stop.sh ${CONFIG_DIR}/reload.sh &&\
 ln -s ${CONFIG_DIR}/start.sh /usr/bin/php-fpm &&\
 # apk del ${EXTEND} &&\
 rm -rf /var/cache/apk/* &&\
 rm -rf /tmp/*

VOLUME ["${BASE_DIR}/tmp"]

CMD ["php-fpm"]