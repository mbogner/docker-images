FROM php:8.2-apache
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip ca-certificates curl \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libicu-dev libzip-dev libxml2-dev libpq-dev libmagickwand-dev libgmp-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j"$(nproc)" bcmath exif gd intl opcache pdo pdo_pgsql gmp zip pcntl \
  && pecl install imagick apcu redis \
  && docker-php-ext-enable imagick apcu opcache redis \
  && a2enmod rewrite headers env dir mime setenvif \
  && rm -rf /var/lib/apt/lists/*

RUN { \
      echo "memory_limit=512M"; \
      echo "upload_max_filesize=1024M"; \
      echo "post_max_size=1024M"; \
      echo "max_execution_time=3600"; \
      echo "opcache.enable=1"; \
      echo "opcache.interned_strings_buffer=16"; \
      echo "opcache.max_accelerated_files=10000"; \
      echo "opcache.memory_consumption=128"; \
      echo "opcache.save_comments=1"; \
      echo "disable_functions="; \
    } > /usr/local/etc/php/conf.d/99-nextcloud.ini

# Unpack Nextcloud into Apache web root
COPY ./tmp/nextcloud.zip /opt/nextcloud.zip
RUN rm -rf /var/www/html \
 && unzip -q /opt/nextcloud.zip -d /var/www \
 && rm -f /opt/nextcloud.zip \
 && ln -s /var/www/nextcloud /var/www/html \
 && mkdir -p /var/www/nextcloud/data \
 && chown -R www-data:www-data /var/www

# Apache vhost for Nextcloud at /
RUN cat > /etc/apache2/sites-available/000-default.conf <<'APACHE'
<VirtualHost *:80>
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
APACHE

# Persistent volumes (recommended)
VOLUME ["/var/www/nextcloud/data", "/var/www/nextcloud/config", "/var/www/nextcloud/apps"]

EXPOSE 80