FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    wget \
    curl

RUN wget https://wordpress.org/wordpress-6.8.2.tar.gz -O /tmp/wp.tar.gz && \
    tar -xzf /tmp/wp.tar.gz -C /tmp && \
    rm -rf /tmp/wp.tar.gz

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]