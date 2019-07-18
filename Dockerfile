FROM webdevops/base-app:alpine

LABEL Maintainer="Anderson Guilherme Porto <hkrnew@gmail.com>" \
      Description="Lightweight container with Nginx 1.14 & PHP-FPM 7.3 based on Alpine Linux."

ENV APPLICATION_PATH=/var/www/html \
    FTP_USER=application \
    FTP_PASSWORD=application \
    FTP_UID=1000 \
    FTP_GID=1000 \
    FTP_PATH=/var/www/html \
    WEB_DOCUMENT_ROOT=/var/www/html \
    WEB_DOCUMENT_INDEX=index.php \
    WEB_ALIAS_DOMAIN=*.vm \
    WEB_PHP_TIMEOUT=600 \
    WEB_PHP_SOCKET="127.0.0.1:9000" \ 
    #WEB_PHP_SOCKET="/var/run/php-fpm.socket" \    
    WORDPRESS_DB_HOST=mysql \
    WORDPRESS_DB_NAME=wordpress \
    WORDPRESS_DB_USER=root \
    WORDPRESS_DB_PASSWORD=root

COPY conf/ /opt/docker/
COPY docker/ /

RUN apk-install \
        # Install tools
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
        # Install vsftpd
        vsftpd \
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
        # php7-imagick \
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
        php7-xmlwriter \
    && ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
    && pecl channel-update pecl.php.net \
    # Temporarily disable pear due to https://twitter.com/pear/status/1086634389465956352
    # && pear channel-update pear.php.net \
    # && pear upgrade-all \
    && pear config-set auto_discover 1 \
    # && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    # PECL workaround, see webdevops/Dockerfile#78
    && sed -i "s/ -n / /" $(which pecl) \
    # Enable vsftpd services
    && ln -sf /opt/docker/etc/vsftpd/vsftpd.conf /etc/vsftpd.conf \
    && mkdir -p \
            /var/run/vsftpd/empty \
            /var/log/supervisor \
    # Enable php services
    && docker-service enable syslog \
    && docker-service enable cron \
    && docker-run-bootstrap \
    && docker-image-cleanup

RUN curl -o wordpress.tar.gz -fSL "https://br.wordpress.org/wordpress-latest-pt_BR.tar.gz" \
    && tar -xzf wordpress.tar.gz --strip 1 -C /var/www/html \
    && rm wordpress.tar.gz

VOLUME /var/www/html

EXPOSE 20 21 80 443 12020 12021 12022 12023 12024 12025