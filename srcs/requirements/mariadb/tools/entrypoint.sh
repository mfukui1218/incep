#!/bin/sh

set -e  # エラー時即終了

# --- 環境変数の存在確認 ---
: "${MYSQL_DATABASE:?環境変数 MYSQL_DATABASE が未定義です}"
: "${MYSQL_USER:?環境変数 MYSQL_USER が未定義です}"
: "${MYSQL_PASSWORD:?環境変数 MYSQL_PASSWORD が未定義です}"
: "${MYSQL_ROOT_PASSWORD:?環境変数 MYSQL_ROOT_PASSWORD が未定義です}"

# --- MariaDB データベースが未初期化なら初期化 ---
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 MariaDB 初期化中..."

    # mysql データベースの基本テーブルを作成
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    # 初期化SQLを一時ファイルに出力
    INIT_SQL_FILE="/tmp/init.sql"
    cat > "$INIT_SQL_FILE" <<EOF
-- rootユーザーのパスワード設定
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- 任意のDB作成とユーザー作成
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "🚀 初期化SQLを実行中..."
    mysqld --user=mysql --bootstrap < "$INIT_SQL_FILE"
    rm -f "$INIT_SQL_FILE"

    echo "✅ MariaDB 初期化完了"
else
    echo "🛠 既存の MariaDB データを検出。初期化スキップ。"
fi

# --- MariaDB 起動 ---
echo "🚀 MariaDB 起動中..."
exec mysqld --user=mysql
