FROM node:latest AS node

FROM composer AS composer

RUN composer require "phpunit/phpunit:^8" \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

FROM php:7.4-fpm

COPY --from=composer /app/vendor /vendor

ARG APCU_VERSION=5.1.20
ARG MEMCACHE_VERSION=4.0.5.2

ARG CONTAINER_GID
ARG CONTAINER_UID
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG BX_XDEBUG_IP
ARG BX_XDEBUG_PORT
ARG BX_DEFAULT_CHARSET

ARG BX_SMTP_PORT
ARG BX_SMTP_FROM

COPY ./conf.d /usr/local/etc/php/conf.d/
COPY ./php-fpm.d /usr/local/etc/php-fpm.d/
COPY ./msmtp /usr/local/etc/msmtp/

RUN apt-get update \
    && apt-get install -y vim msmtp \
    && echo "syntax on" > ~/.vimrc \
    && apt-get -y install \
        libmagickwand-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libmemcached-dev \
        libicu-dev \
        libzip-dev \
        zlib1g-dev \
        libpng-dev \
        libxml2-dev \
        --no-install-recommends \
    && pecl install imagick apcu-${APCU_VERSION} memcached \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable memcached \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo_mysql opcache exif intl sockets bz2 zip \
    && docker-php-ext-configure opcache --enable-opcache \
#    && pecl install -o -f redis \
#    && docker-php-ext-enable redis \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug \
    && pecl install memcache-${MEMCACHE_VERSION} && docker-php-ext-enable memcache

RUN groupadd -g ${CONTAINER_GID} ${CONTAINER_GROUP} \
    && useradd -u ${CONTAINER_UID} -g ${CONTAINER_GID} ${CONTAINER_USER}

RUN chmod -R 777 /usr/local/etc/php/ \
    && chown -R ${CONTAINER_USER} /usr/local/etc/php/ \
    && curl -sS https://getcomposer.org/installer | php ; mv composer.phar /usr/bin/composer

RUN sed -i "$ a xdebug.client_host="${BX_XDEBUG_IP} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a xdebug.client_port="${BX_XDEBUG_PORT} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a default_charset="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/php.ini \
    && sed -i "$ a mbstring.internal_encoding="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/mbstring.ini \
    && sed -i "$ a port "${BX_SMTP_PORT} /usr/local/etc/msmtp/msmtp.conf \
    && sed -i "$ a from "${BX_SMTP_FROM} /usr/local/etc/msmtp/msmtp.conf

# COPY ./phpunit.local.xml /phpunit.xml
# COPY ./bootstrap.local.php /.bootstrap.php

# COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
# COPY --from=node /usr/local/bin/node /usr/local/bin/node
# RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
# RUN npm install -g @bitrix/cli
# RUN npm install -g eslint-plugin-flowtype
# RUN mkdir -p /home/${CONTAINER_USER} && chown -R ${CONTAINER_USER}:$(id -gn ${CONTAINER_USER}) /home/${CONTAINER_USER}

# # mailhog
# RUN apt-get update && apt-get install -y --no-install-recommends curl git
# RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
# ENV PATH /usr/local/go/bin:$PATH
# RUN go get github.com/mailhog/mhsendmail
# RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
# RUN echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' > /usr/local/etc/php/conf.d/mailhog.ini

ENTRYPOINT php-fpm -F
