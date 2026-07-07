#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

DB_PASSWORD=$(cat /run/secrets/db_password)
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mariadbd --user=mysql --skip-networking &

until mariadb-admin ping >/dev/null 2>&1
do
	sleep 1
done

if mariadb -u root -e "SELECT 1" >/dev/null 2>&1; then
	mariadb -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};

CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF
else
	mariadb -u root -p"${ROOT_PASSWORD}" << EOF
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};

CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF
fi

mariadb-admin -u root -p"${ROOT_PASSWORD}" shutdown

exec mariadbd --user=mysql