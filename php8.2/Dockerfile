FROM docker.io/library/php:8.2-fpm@sha256:bb3965026f2e2ae2e59f9c80848d3d1343b12c5c71120876a2ef04ebbff31deb
ARG NODE_VERSION=18
ENV LC_ALL C.UTF-8

COPY --from=ghcr.io/shyim/supervisord:latest@sha256:1531279d119ffb0e4411f1d769026f10dd52916c3078056e81068e4d8586d296 --link /usr/local/bin/supervisord /usr/bin/supervisord
COPY --from=docker.io/library/caddy:2.8@sha256:60199fbf2046892e0aa4b19c7d3adf71f530c36abc65728627422148a75b3475 --link /usr/bin/caddy /usr/bin/caddy

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
    build-essential \
    ca-certificates \
    gnupg \
    unzip \
    libsodium-dev \
    rsync \
    supervisor \
    git \
    wget \
    xz-utils \
    make \
    gcc \
    gosu \
    g++ \
    jq \
    curl \
    netcat-openbsd \
    traceroute \
    vim \
    nano \
    less \
    procps \
    zip \
    libzip-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libmcrypt-dev \
    libonig-dev

# installing mlocati/docker-php-extension-installer to ease up php-extension installation:
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions  \
    bcmath \
    gd \
    intl \
    mysqli \
    pdo \
    pdo_mysql \
    pcntl \
    sockets \
    bz2 \
    gmp \
    soap \
    zip \
    ffi \
    redis \
    opcache \
    apcu  \
    amqp  \
    curl  \
    mbstring \
    ftp \
    sodium && \
    mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini" && \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf && \
    rm -f /usr/local/etc/php-fpm.d/www.conf && \
    rm -f /usr/local/etc/php-fpm.d/www.conf.default

ENV FPM_PM=dynamic \
    FPM_PM_MAX_CHILDREN=5 \
    FPM_PM_START_SERVERS=2 \
    FPM_PM_MIN_SPARE_SERVERS=1 \
    FPM_PM_MAX_SPARE_SERVERS=3 \
    FPM_PM_MAX_REQUESTS=100 \
    PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING & ~E_NOTICE & ~E_CORE_WARNING & ~E_COMPILE_WARNING & ~E_USER_DEPRECATED" \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_EXECUTION_TIME=120 \
    PHP_UPLOAD_MAX_FILESIZE=256M \
    PHP_POST_MAX_SIZE=256M

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer

#BEGINN OF NODEJS BLOCK#
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN echo "Package: nodejs" >> /etc/apt/preferences.d/nodejs \
    && echo "Pin: origin deb.nodesource.com" >> /etc/apt/preferences.d/nodejs \
    && echo "Pin-Priority: 600" >> /etc/apt/preferences.d/nodejs
RUN apt-get update; apt-get install -y nodejs
#END OF NODEJS BLOCK#

RUN set -eux; \
    mkdir -p \
      /app/public \
      /var/www  \
      /config/caddy \
      /data/caddy; \
    chown -R www-data:www-data \
      /app/public \
      /var/www  \
      /config/caddy \
      /data/caddy \
      /usr/local/etc/php/php.ini; \
    usermod -d /app www-data

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

COPY --link rootfs /

RUN set -eux; \
    chown -R www-data:www-data \
    /etc/caddy

# Copy the entrypoint script into the image
COPY entrypoint.sh /usr/local/bin/

# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
WORKDIR /app

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
