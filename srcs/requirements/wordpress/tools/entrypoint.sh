#!/bin/sh

set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE 未定義}"
: "${MYSQL_USER:?MYSQL_USER 未定義}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD 未定義}"
: "${MYSQL_HOST:?MYSQL_HOST 未定義}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER 未定義}"
: "${WP_ADMIN_PASS:?WP_ADMIN_PASS 未定義}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL 未定義}"
: "${WP_SITE_TITLE:?WP_SITE_TITLE 未定義}"

cd /var/www/html

# 所有権
chown -R www-data:www-data /var/www/html

# WordPressダウンロード
if [ ! -f wp-load.php ]; then
    echo "📦 WordPress をダウンロード中..."
    wp core download --allow-root
fi

# wp-config作成
if [ ! -f wp-config.php ]; then
    echo "📝 wp-config.php を作成中..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
fi

# DBが使えるようになるまで待つ
echo "⌛ MariaDB に接続確認中..."
for i in $(seq 1 20); do
    if wp db check --allow-root; then
        echo "✅ MariaDB に接続成功"
        break
    fi
    echo "🔁 接続再試行中 ($i)"
    sleep 1
done

# WordPress 初期化
if ! wp core is-installed --allow-root; then
    echo "⚙️ WordPress 初期セットアップ..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

echo "🚀 php-fpm 起動"
exec php-fpm8 --nodaemonize
