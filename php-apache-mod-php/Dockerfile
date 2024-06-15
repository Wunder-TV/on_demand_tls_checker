FROM debian:latest
ARG NODE_VERSION
ARG PHP_VERSION
ENV LC_ALL C.UTF-8
ENV PHP_VERSION ${PHP_VERSION}
ENV NODE_VERSION ${NODE_VERSION}

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    build-essential \
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
    libonig-dev \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
    && apt-get update \
    && apt-get -y install \
    apache2 \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-ffi \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-apcu  \
    php${PHP_VERSION}-amqp  \
    php${PHP_VERSION}-curl  \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-ftp

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

RUN a2enmod rewrite

COPY site.conf /etc/apache2/sites-enabled/000-default.conf
COPY site.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir /var/www/html/public
WORKDIR /var/www/html
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]

STOPSIGNAL SIGINT
