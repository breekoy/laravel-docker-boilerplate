FROM php:7.3-fpm-alpine AS php_base

RUN apk add --update libpng-dev libzip-dev htop

RUN docker-php-ext-install pdo pdo_mysql gd zip pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer self-update 1.10.20

FROM php_base AS php_cron

COPY crontab /etc/crontabs/root

CMD ["crond", "-f"]

FROM php_base AS php_supervisor

RUN apk add --update --no-cache supervisor

COPY ./supervisor/supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

FROM php_base AS php_redis

RUN apk add --update --no-cache redis

CMD ["redis-server", "--protected-mode", "no"]
