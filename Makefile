NAME = inception

all: up

up:
	@echo "Building and starting containers..."
	@cd srcs && docker-compose up -d --build
	@echo "Waiting for containers to start..."
	@sleep 10
	@echo "Setting up database..."
	@$(MAKE) fix-database
	@echo "Setting up WordPress..."
	@$(MAKE) fix-wordpress
	@echo "🎉 Setup completed! Access: https://mfukui.42.fr"

fix-database:
	@docker exec mariadb mysql -u root -pSuperStrong123! -e "\
		CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; \
		CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'UserStrong456!'; \
		GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%'; \
		FLUSH PRIVILEGES;" 2>/dev/null || echo "Database setup may have failed"

fix-wordpress:
	@docker exec wordpress bash -c "\
		pkill -f setup_wordpress.sh || true; \
		sleep 3; \
		cd /var/www/html; \
		rm -rf *; \
		wp core download --allow-root; \
		wp config create --dbname=wordpress --dbuser=wp_user --dbpass=UserStrong456! --dbhost=mariadb:3306 --allow-root; \
		wp core install --url=https://mfukui.42.fr --title='My WordPress Site' --admin_user=site_admin --admin_password=AdminStrong789! --admin_email=admin@mfukui.42.fr --allow-root; \
		wp user create regular_user user@mfukui.42.fr --user_pass=UserStrong012! --role=author --allow-root 2>/dev/null || true; \
		chown -R www-data:www-data /var/www/html; \
		php-fpm7.4 -F &" 2>/dev/null || echo "WordPress setup may have failed"

down:
	@cd srcs && docker-compose down

clean: down
	@docker system prune -af
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

fclean: clean
	@docker system prune -af --volumes

re: fclean all

test:
	@echo "Testing website..."
	@curl -k https://mfukui.42.fr/ 2>/dev/null | head -5 || echo "Website not accessible"

logs:
	@cd srcs && docker-compose logs -f

ps:
	@cd srcs && docker-compose ps

.PHONY: all up down clean fclean re test logs ps fix-database fix-wordpress
