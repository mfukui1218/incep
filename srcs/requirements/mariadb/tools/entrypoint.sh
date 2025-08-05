#!/bin/sh

set -e

: "${MYSQL_DATABASE:?未定義}"
: "${MYSQL_USER:?未定義}"
: "${MYSQL_PASSWORD:?未定義}"
: "${MYSQL_ROOT_PASSWORD:?未定義}"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 MariaDB 初期化中..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

    cat > /tmp/init.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm /tmp/init.sql
fi

echo "🚀 MariaDB 起動..."
exec mysqld --user=mysql
