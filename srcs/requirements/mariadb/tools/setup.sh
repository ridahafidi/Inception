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

mysqld_safe --user=mysql &

for i in $(seq 1 30); do
	if mariadb-admin ping --silent >/dev/null 2>&1; then
		break
	fi
	if [ "$i" -eq 30 ]; then
		echo "MariaDB did not start in time." >&2
		exit 1
	fi
	sleep 1
done

ROOT_AUTH_ARGS=(-u root -p"${DB_ROOT_PASSWORD}")
if ! mariadb "${ROOT_AUTH_ARGS[@]}" -e "SELECT 1;" >/dev/null 2>&1; then
	if mariadb -u root -e "SELECT 1;" >/dev/null 2>&1; then
		ROOT_AUTH_ARGS=(-u root)
	else
		echo "Unable to authenticate as MariaDB root user." >&2
		exit 1
	fi
fi

mariadb "${ROOT_AUTH_ARGS[@]}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

mariadb "${ROOT_AUTH_ARGS[@]}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

mariadb "${ROOT_AUTH_ARGS[@]}" -e "ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

mariadb "${ROOT_AUTH_ARGS[@]}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

mariadb "${ROOT_AUTH_ARGS[@]}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

mariadb "${ROOT_AUTH_ARGS[@]}" -e "FLUSH PRIVILEGES;"

mariadb-admin "${ROOT_AUTH_ARGS[@]}" shutdown
sleep 2

exec mysqld_safe --user=mysql --bind-address=0.0.0.0