#!/bin/bash

echo "=== Auto-fixing WordPress after make ==="

echo "1. Setting up MariaDB database and user..."
docker exec mariadb mysql -u root -pSuperStrong123! -e "
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'UserStrong456!';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
"

echo "2. Setting up WordPress manually..."
docker exec wordpress bash -c "
pkill -f setup_wordpress.sh || true
pkill php-fpm || true
sleep 3

cd /var/www/html
rm -rf *

wp core download --allow-root
wp config create --dbname=wordpress --dbuser=wp_user --dbpass=UserStrong456! --dbhost=mariadb:3306 --allow-root
wp core install --path=/var/www/html --url=https://mfukui.42.fr --title='My WordPress Site' --admin_user=site_admin --admin_password=AdminStrong789! --admin_email=admin@mfukui.42.fr --allow-root

chown -R www-data:www-data /var/www/html
php-fpm7.4 -F &
"

echo "3. Testing..."
sleep 5
curl -k https://mfukui.42.fr/ 2>/dev/null | head -5
