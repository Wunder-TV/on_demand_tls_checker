FROM debian:bookworm-slim
ARG NODE_VERSION=18

COPY --from=docker.io/library/caddy:2.7@sha256:ca031cd33c788ebe467c94348400e5bf263178f9619f3993af8373f18681b8fd --link /usr/bin/caddy /usr/bin/caddy

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
    build-essential \
    ca-certificates \
    gnupg \
    unzip \
    libsodium-dev \
    rsync \
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
      /data/caddy; \
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
CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]