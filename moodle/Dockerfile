FROM php:8.3-apache
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

# Moodle
# https://download.moodle.org/releases/latest/
RUN curl -fsSL https://download.moodle.org/download.php/direct/stable501/moodle-latest-501.tgz -o /tmp/moodle.tgz \
 && tar -xzf /tmp/moodle.tgz -C /var/www \
 && rm /tmp/moodle.tgz

# ---- OS deps for PHP extensions + tools ----
RUN apt update && apt install -y --no-install-recommends \
      curl ca-certificates unzip \
      libpq5 libpq-dev \
      libzip-dev \
      libicu-dev \
      libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
      libxml2-dev \
 && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \
      pdo_pgsql pgsql \
      zip intl gd \
      soap exif \
 && apt purge -y libpq-dev \
 && apt autoremove -y && apt clean  && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/moodle

# ---- Composer: create vendor/ ----
RUN curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm /tmp/composer-setup.php \
 && composer install --no-dev --classmap-authoritative --prefer-dist --no-interaction --no-progress

# ---- PHP recommended settings for Moodle ----
RUN { \
    echo "max_input_vars=5000"; \
    echo "zend.exception_ignore_args=1"; \
  } > /usr/local/etc/php/conf.d/99-moodle.ini

COPY config.php /var/www/moodle/config.php
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN mkdir /data && \
    chown -R www-data:www-data /data /var/www/html

VOLUME /data
EXPOSE 80