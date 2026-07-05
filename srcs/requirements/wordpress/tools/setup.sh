#!/bin/bash

set -e

mkdir -p /run/php

DB_PASSWORD=$(cat /run/secrets/db_password)

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

#copy wp files if needed
if [ ! -f wp-config.php ]; then
    cp -r /usr/src/wordpress/* /var/www/html/
fi

cd /var/www/html

#create wp-confing.php
#wp config create generates wp-config.php and stores the
#database connection information.
if [ ! -f wp-config.php ]; then
wp config create \
    --dbname="${MARIADB_DATABASE}" \
    --dbuser="${MARIADB_USER}" \
    --dbpass="${DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --allow-root
fi

#wait for mariadb
until mariadb \
    -h"${WORDPRESS_DB_HOST}" \
    -u"${MARIADB_USER}" \
    -p"${DB_PASSWORD}" \
    -e "SELECT 1" >/dev/null 2>&1
do
    sleep 2
done

#wp core install uses those credentials to connect to
#MariaDB, create all WordPress tables, initialize the site,
#and create the administrator account.
if ! wp core is-installed --allow-root; then
wp core install \
    --url="${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --allow-root
fi

#create wp_user if it does not already exist
if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
wp user create \
    "${WP_USER}" \
    "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=author \
    --allow-root
fi

#set www-data as owner and group of /var/ww/html
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F