#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

DB_PASSWORD=$(cat /run/secrets/db_password)
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d /var/lib/mysql/wp_db ];
then

mariadbd --user=mysql --skip-networking &

until mariadb-admin ping >/dev/null 2>&1
do
	sleep 1
done

	mariadb -u root << EOF
	CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};

	CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%'
	IDENTIFIED BY '${DB_PASSWORD}';

	GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';

	ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

	FLUSH PRIVILEGES;
EOF

mariadb-admin -u root -p"${ROOT_PASSWORD}" shutdown

fi

exec mariadbd --user=mysql
