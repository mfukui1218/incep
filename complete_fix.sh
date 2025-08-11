#!/bin/bash

echo "=== 完全修正：make一発で動作するように設定 ==="

# 1. MariaDB初期化スクリプトを完全書き直し
echo "1. Fixing MariaDB init script..."
cat > srcs/requirements/mariadb/tools/init_db.sh << 'MARIADB_EOF'
#!/bin/bash

set -e

echo "MariaDB initialization starting..."

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB for the first time..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    echo "Setting up database and user..."
    
    mysql -u root << MYSQL_SCRIPT
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    mysqladmin shutdown -u root -p${MYSQL_ROOT_PASSWORD}
    echo "MariaDB initialization completed successfully."
else
    echo "MariaDB already initialized."
fi

exec "$@"
MARIADB_EOF

# 2. WordPress設定スクリプトを完全書き直し
echo "2. Fixing WordPress setup script..."
cat > srcs/requirements/wordpress/tools/setup_wordpress.sh << 'WP_EOF'
#!/bin/bash

set -e

echo "WordPress setup starting..."
cd ${WP_PATH:-/var/www/html}
chown -R www-data:www-data /var/www/html

echo "Waiting for database connection..."
for i in {1..120}; do
    if mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1" >/dev/null 2>&1; then
        echo "Database connection established after $i seconds."
        break
    fi
    if [ $i -eq 120 ]; then
        echo "ERROR: Database connection timeout!"
        exit 1
    fi
    sleep 1
done

if [ ! -f "wp-config-sample.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    chown -R www-data:www-data /var/www/html
fi

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
    chown www-data:www-data wp-config.php
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --path="/var/www/html" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE:-My WordPress Site}" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-admin123}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --allow-root
fi

chown -R www-data:www-data /var/www/html
echo "WordPress setup completed successfully."
exec "$@"
WP_EOF

# 3. 実行権限を設定
chmod +x srcs/requirements/mariadb/tools/init_db.sh
chmod +x srcs/requirements/wordpress/tools/setup_wordpress.sh

echo "=== 完全修正完了！ ==="
echo "テスト実行："
echo "  make fclean"
echo "  make"
