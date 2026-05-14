#!/bin/bash
set -e

read_secret() {
	if [ -f "$1" ]; then
		cat "$1"
	fi
}

DB_PASSWORD=$(read_secret /run/secrets/db_password)
DB_ROOT_PASSWORD=$(read_secret /run/secrets/db_root_password)

if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || \
	[ -z "$DB_PASSWORD" ] || [ -z "$DB_ROOT_PASSWORD" ]; then
	echo "Missing required environment variables or secrets." >&2
	exit 1
fi

install -d -o mysql -g mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysqld_safe --user=mysql &
	sleep 3

	mariadb -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

	mariadb -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

	mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

	mariadb -e "FLUSH PRIVILEGES;"

	mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
	sleep 2
fi

exec mysqld_safe --user=mysql --bind-address=0.0.0.0