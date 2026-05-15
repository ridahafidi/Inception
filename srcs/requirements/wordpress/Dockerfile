FROM debian:bullseye

RUN apt update && \
    apt install -y \
    php-fpm \
    php-mysql \
    php-cli \
    curl \
    mariadb-client && \
    apt clean

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

RUN curl -fsSL https://wordpress.org/latest.tar.gz \
    -o /tmp/wordpress.tar.gz && \
    mkdir -p /usr/src/wordpress && \
    tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 && \
    rm -f /tmp/wordpress.tar.gz

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/setup.sh ./setup.sh

RUN chmod +x setup.sh

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]