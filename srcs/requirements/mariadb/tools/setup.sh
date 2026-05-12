#!/bin/bash
if [ ! -d "/var/lib/mysql/mysql" ]; then
	service mariadb start

	mariadb -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

	mariadb -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

	mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

	mariadb -e "FLUSH PRIVILEGES;"

	mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

install -d -o mysql -g mysql /run/mysqld

exec mysqld --user=mysql