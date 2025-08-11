#!/bin/bash

set -e

echo "=== WordPress Auto Setup Starting ==="

cd ${WP_PATH:-/var/www/html}

# 権限設定
chown -R www-data:www-data /var/www/html

# データベース接続を待つ（最大90秒）
echo "Waiting for database connection..."
for i in {1..90}; do
    if mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1" >/dev/null 2>&1; then
        echo "✅ Database connected after $i seconds!"
        break
    fi
    if [ $i -eq 90 ]; then
        echo "❌ Database connection timeout after 90 seconds!"
        exit 1
    fi
    sleep 1
done

# WordPress コアファイルをダウンロード
if [ ! -f "wp-load.php" ]; then
    echo "📦 Downloading WordPress core files..."
    wp core download --allow-root
    chown -R www-data:www-data /var/www/html
    echo "✅ WordPress downloaded successfully!"
else
    echo "✅ WordPress files already exist!"
fi

# wp-config.phpを作成
if [ ! -f "wp-config.php" ]; then
    echo "⚙️  Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    chown www-data:www-data wp-config.php
    chmod 644 wp-config.php
    echo "✅ wp-config.php created successfully!"
else
    echo "✅ wp-config.php already exists!"
fi

# WordPressをインストール
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "🚀 Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE:-My WordPress Site}" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-password123}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --allow-root
    
    echo "✅ WordPress installed successfully!"
    
    # 一般ユーザーを作成
    if [ -n "${WP_USER}" ] && [ -n "${WP_USER_EMAIL}" ]; then
        echo "👤 Creating regular user..."
        wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
            --user_pass="${WP_USER_PASSWORD:-password123}" \
            --role=author \
            --allow-root 2>/dev/null || echo "ℹ️  User creation skipped (may already exist)"
    fi
else
    echo "✅ WordPress already installed!"
fi

# 最終的な権限設定
echo "🔧 Setting final permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;
find /var/www/html -type d -exec chmod 755 {} \;

echo "🎉 WordPress setup completed successfully!"
echo "📋 Final status:"
echo "   - WordPress files: $(ls -1 /var/www/html/ | wc -l) files"
echo "   - wp-config.php: $(test -f wp-config.php && echo "✅ EXISTS" || echo "❌ MISSING")"
echo "   - Installation: $(wp core is-installed --allow-root 2>/dev/null && echo "✅ COMPLETE" || echo "❌ INCOMPLETE")"

# PHP-FPMを起動
echo "🚀 Starting PHP-FPM..."
exec "$@"
