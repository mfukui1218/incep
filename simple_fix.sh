#!/bin/bash

echo "=== シンプルで確実なアプローチ ==="

# MariaDBスクリプトを超シンプルに
cat > srcs/requirements/mariadb/tools/init_db.sh << 'MARIADB_EOF'
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
MARIADB_EOF

# WordPressスクリプトを超シンプルに
cat > srcs/requirements/wordpress/tools/setup_wordpress.sh << 'WP_EOF'
#!/bin/bash

cd /var/www/html

echo "Waiting for database..."
for i in {1..30}; do
    if mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1" >/dev/null 2>&1; then
        echo "Connected!"
        break
    fi
    sleep 1
done

if [ ! -f "index.php" ]; then
    wp core download --allow-root
    wp config create --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost="mariadb" --allow-root
    wp core install --url="https://${DOMAIN_NAME}" --title="WordPress" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --allow-root
fi

chown -R www-data:www-data /var/www/html
exec "$@"
WP_EOF

chmod +x srcs/requirements/mariadb/tools/init_db.sh
chmod +x srcs/requirements/wordpress/tools/setup_wordpress.sh

echo "シンプル設定完了"
