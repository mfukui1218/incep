#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    mysql -u root -e "
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
    CREATE DATABASE ${MYSQL_DATABASE};
    CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
    "
    
    mysqladmin shutdown -u root -p${MYSQL_ROOT_PASSWORD}
fi

exec "$@"
