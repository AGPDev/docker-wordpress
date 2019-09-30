FROM alpine:3.10

LABEL Maintainer="Anderson Guilherme Porto <hkrnew@gmail.com>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux."

ENV FTP_USER=wordpress \
    FTP_PASS=wordpress \
    FTP_UID=1001 \
    FTP_GID=1001 \
    PASV_ADDRESS=127.0.0.1 \
    PASV_MIN=21100 \
    PASV_MAX=21110 \
    TZ=America/Sao_Paulo \
    WORDPRESS_DB_HOST=mysql \
    WORDPRESS_DB_NAME=wordpress \
    WORDPRESS_DB_USER=root \
    WORDPRESS_DB_PASSWORD=root

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk --update --no-cache add \
        bash \
        # build-base \
        ca-certificates \
        curl \
        # linux-pam-dev \
        openssl \
        sed \
        shadow \
        supervisor \
        tzdata \
        unzip \
        # vim \
        vsftpd \
        imagemagick \
        graphicsmagick \
        ghostscript \
        jpegoptim \
        pngcrush \
        libjpeg-turbo-utils \
        optipng \
        pngquant \
        # Install nginx
        nginx \
        # Install php (cli/fpm)
        php7-fpm \
        php7-json \
        php7-intl \
        php7-curl \
        php7-mysqli \
        php7-mysqlnd \
        php7-pdo_mysql \
        # php7-pdo_pgsql \
        # php7-pdo_sqlite \
        php7-mcrypt \
        php7-gd \
        # disabled until Imagick was compiled against Image Magick version 1799 but version 1800 is loaded is fixed
        php7-imagick \
        php7-imap \
        php7-bcmath \
        #php7-soap \
        #php7-sqlite3 \
        php7-bz2 \
        php7-calendar \
        php7-ctype \
        #php7-mongodb \
        php7-pcntl \
        #php7-pgsql \
        php7-posix \
        php7-sockets \
        php7-sysvmsg \
        php7-sysvsem \
        php7-sysvshm \
        php7-xmlreader \
        php7-exif \
        php7-ftp \
        php7-gettext \
        php7-iconv \
        php7-zip \
        php7-zlib \
        php7-shmop \
        php7-wddx \
        sqlite \
        php7-xmlrpc \
        php7-xsl \
        geoip \
        php7-ldap \
        # php7-memcache \
        # php7-redis \
        php7-pear \
        php7-phar \
        php7-openssl \
        php7-session \
        php7-opcache \
        php7-mbstring \
        php7-iconv \
        # php7-apcu \
        php7-fileinfo \
        php7-simplexml \
        php7-tokenizer \
        php7-xmlwriter

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf.alter

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf.alter
COPY config/php.ini /etc/php7/conf.d/wordpress.ini

# Configure Wordpress
# COPY config/wordpress /home/www
RUN set -eux \
    && mkdir /home/www \
    && curl -o wordpress.tar.gz -fSL "https://br.wordpress.org/wordpress-latest-pt_BR.tar.gz" \
    && tar -xzf wordpress.tar.gz --strip 1 -C /home/www \
    && rm wordpress.tar.gz

COPY config/wp-config.php /home/www/wp-config.php
COPY config/wp-secrets.php /home/www/wp-secrets.php.alter

# Configure vsftpd
COPY config/vsftpd.conf /etc/vsftpd/vsftpd.conf

# Configure supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure entrypoint
COPY config/entrypoint.sh /usr/sbin/entrypoint.sh

RUN chmod +x /usr/sbin/entrypoint.sh

VOLUME /home/www

ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]

WORKDIR /home/www

EXPOSE 21 80 443 $PASV_MIN-$PASV_MAX

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]
