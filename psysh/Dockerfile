FROM composer AS composer

RUN composer require psy/psysh

FROM bx-env_php-fpm

COPY --from=composer /app/vendor /vendor

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./config.php /config.php

# ENTRYPOINT ["/psysh"]
ENTRYPOINT ["/entrypoint.sh"]
