#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld #/var/lib/mysql

DB_PASSWORD=$(cat /run/secrets/db_password)

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

FLUSH PRIVILEGES;
EOF

mariadb-admin -u root shutdown

exec mariadbd --user=mysql