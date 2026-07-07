#!/bin/bash

set -e

mkdir -p /run/php

DB_PASSWORD=$(cat /run/secrets/db_password)

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

#copy wp files if wp-confing.php dosen't exist
if [ ! -f wp-config.php ]; then
    cp -r /tmp/wordpress/* /var/www/html/ &&
    rm -rf /tmp/wordpress 
fi

cd /var/www/html

#if wp-confing.php dosen't exist
#create wp-config.php that has the database infos
#to reach out to db when needed
if [ ! -f wp-config.php ]; then
wp config create \
    --dbname="${MARIADB_DATABASE}" \
    --dbuser="${MARIADB_USER}" \
    --dbpass="${DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --allow-root
fi

#check if mariadb is ready and test a real TCP connection to database and a query test
until mariadb \
    -h"${WORDPRESS_DB_HOST}" \
    -u"${MARIADB_USER}" \
    -p"${DB_PASSWORD}" \
    -e "SELECT 1" >/dev/null 2>&1
do
    sleep 2
done

#check if wp tables re configured in database using wp-cli
#if not wp core install creates all the necessary db tables and insert admin
#instead of reaching to install.php wp-cli handles it
if ! wp core is-installed --allow-root; then
wp core install \
    --url="${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --allow-root
fi

#check if user42 exists in database
# if not create it
if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
wp user create \
    "${WP_USER}" \
    "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=author \
    --allow-root
fi

#set www-data as owner and group of /var/ww/html
#to avoid access conflict with nginx during upload requests
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F