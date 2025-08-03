COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

up:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

re:
	$(MAKE) down
	$(MAKE) up

prepare:
	mkdir -p /Users/${USER}/data/mariadb
	mkdir -p /Users/${USER}/data/wordpress

logs:
	$(COMPOSE) logs -f

.PHONY: up down re logs prepare
