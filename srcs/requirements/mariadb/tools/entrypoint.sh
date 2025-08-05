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
-- root パスワード設定
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- ユーザー削除（念のため）
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
DROP USER IF EXISTS '${MYSQL_USER}'@'localhost';

-- DB作成
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- ユーザー作成
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- 必須
FLUSH PRIVILEGES;
EOF

    echo "⚙️ SQLを実行しています..."
    mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm /tmp/init.sql
fi

echo "🚀 MariaDB 起動中..."
exec mariadbd --user=mysql --port=3306 --bind-address=0.0.0.0 --skip-networking=0
