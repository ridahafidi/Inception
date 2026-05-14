#!/bin/bash
set -e

read_secret() {
    if [ -f "$1" ]; then
        cat "$1"
    fi
}

DB_PASSWORD=$(read_secret /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(read_secret /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(read_secret /run/secrets/wp_user_password)

if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$WP_TITLE" ] || \
    [ -z "$WP_URL" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_EMAIL" ] || \
    [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ] || [ -z "$DB_PASSWORD" ] || \
    [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "Missing required environment variables or secrets." >&2
    exit 1
fi

ADMIN_LOWER=$(printf '%s' "$WP_ADMIN_USER" | tr 'A-Z' 'a-z')
if echo "$ADMIN_LOWER" | grep -q "admin"; then
    echo "WP_ADMIN_USER must not contain 'admin'." >&2
    exit 1
fi

if [ "$WP_ADMIN_USER" = "$WP_USER" ]; then
    echo "WP_ADMIN_USER and WP_USER must be different." >&2
    exit 1
fi

mkdir -p /run/php

cd /var/www/html

if [ ! -f wp-config.php ]; then

    curl -O https://wordpress.org/latest.tar.gz

    tar -xvf latest.tar.gz --strip-components=1

    rm -rf latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

for i in $(seq 1 30); do
    if mariadb-admin ping -h mariadb -u "$MYSQL_USER" -p"$DB_PASSWORD" >/dev/null 2>&1; then
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "MariaDB is not ready." >&2
        exit 1
    fi
    sleep 1
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi

exec php-fpm7.4 -F