#!/bin/sh

set -e

: "${DOMAIN_NAME:?DOMAIN_NAME が未定義}"
: "${WP_SITE_TITLE:?WP_SITE_TITLE が未定義}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER が未定義}"
: "${WP_ADMIN_PASS:?WP_ADMIN_PASS が未定義}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL が未定義}"

export DOMAIN_NAME WP_SITE_TITLE WP_ADMIN_USER WP_ADMIN_PASS WP_ADMIN_EMAIL

# 所有者設定
chown -R www-data:www-data /var/www/html

# wp-config.php 存在チェック
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "❌ wp-config.php が存在しません。セットアップ失敗"
    exit 1
fi

# WordPress セットアップ（初回のみ）
if ! wp core is-installed --allow-root; then
    wp core install --url="https://${DOMAIN_NAME}" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

# FPM起動
exec php-fpm8.2
