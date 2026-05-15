#!/bin/bash
set -e

read_secret() {
    if [ -f "$1" ]; then
        cat "$1"
    fi
# Read required secrets from Docker secrets.
}

DB_PASSWORD=$(read_secret /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(read_secret /run/secrets/wp_admin_password)
# Validate required inputs before provisioning WordPress.
WP_USER_PASSWORD=$(read_secret /run/secrets/wp_user_password)

if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$WP_TITLE" ] || \
    [ -z "$WP_URL" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_EMAIL" ] || \
    [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ] || [ -z "$DB_PASSWORD" ] || \
    [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "Missing required environment variables or secrets." >&2
    exit 1
# Enforce subject rules on usernames.
fi

ADMIN_LOWER=$(printf '%s' "$WP_ADMIN_USER" | tr 'A-Z' 'a-z')
if echo "$ADMIN_LOWER" | grep -q "admin"; then
    echo "WP_ADMIN_USER must not contain 'admin'." >&2
    exit 1
fi

if [ "$WP_ADMIN_USER" = "$WP_USER" ]; then
    echo "WP_ADMIN_USER and WP_USER must be different." >&2
    exit 1
# Ensure runtime directory exists for php-fpm.
fi

mkdir -p /run/php

cd /var/www/html

    # Copy WordPress core files into the volume and generate wp-config.php.

if [ ! -f wp-config.php ]; then

    if [ ! -f /usr/src/wordpress/wp-config-sample.php ]; then
        echo "WordPress source files are missing." >&2
        exit 1
    fi

    cp -a /usr/src/wordpress/. /var/www/html/

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

# Wait for MariaDB to accept connections before WP provisioning.
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

# Install WordPress if not already initialized.
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

    # Create the secondary user if missing.
if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi

    # Run php-fpm in the foreground for container lifecycle management.
exec php-fpm7.4 -F