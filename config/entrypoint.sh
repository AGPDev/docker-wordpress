#!/bin/bash
set -e

if [ ! -f /etc/timezone ] && [ ! -z "$TZ" ]; then
  # At first startup, set timezone
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ >/etc/timezone
fi

if [ -z "$PASV_ADDRESS" ]; then
  echo "** This container will not run without setting for PASV_ADDRESS **"
  sleep 10
  exit 1
fi

if [ ! $(getent passwd $FTP_USER) ]; then
  addgroup -g $FTP_GID -S $FTP_USER

  adduser -u $FTP_UID -D -G $FTP_USER -h /home/www -s /bin/sh $FTP_USER  

  echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

  chown $FTP_USER:$FTP_USER /home/www -R
fi

if [ -f /etc/nginx/nginx.conf.alter ]; then
  sed -i "s/<NGINX_USER>/${FTP_USER}/" /etc/nginx/nginx.conf.alter
  rm /etc/nginx/nginx.conf
  mv /etc/nginx/nginx.conf.alter /etc/nginx/nginx.conf
fi

if [ -f /etc/php7/php-fpm.d/www.conf.alter ]; then
  sed -i "s/<FTP_USER>/${FTP_USER}/g" /etc/php7/php-fpm.d/www.conf.alter
  rm /etc/php7/php-fpm.d/www.conf
  mv /etc/php7/php-fpm.d/www.conf.alter /etc/php7/php-fpm.d/www.conf
fi

if [ -f /home/www/wp-secrets.php.alter ]; then
  curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /home/www/wp-secrets.php.alter
  mv /home/www/wp-secrets.php.alter /home/www/wp-secrets.php
fi

exec "$@"