NAME = inception
COMPOSE = docker compose
YAML = srcs/docker-compose.yml
ENV_FILE := $(if $(wildcard srcs/.env.local),srcs/.env.local,srcs/.env)

.PHONY: all up down re clean fclean build-mariadb build-wordpress build-nginx

all: up

up:
	$(COMPOSE) -f $(YAML) --env-file $(ENV_FILE) up -d --build

down:
	$(COMPOSE) -f $(YAML) down

re:
	$(COMPOSE) -f $(YAML) --env-file $(ENV_FILE) down -v
	$(COMPOSE) -f $(YAML) --env-file $(ENV_FILE) up -d --build

clean:
	$(COMPOSE) -f $(YAML) down --volumes

fclean:
	$(COMPOSE) -f $(YAML) --env-file $(ENV_FILE) down -v
	docker volume prune -f

build-mariadb:
	docker build --no-cache -t mariadb-image ./srcs/requirements/mariadb

build-wordpress:
	docker build --no-cache -t wordpress-image ./srcs/requirements/wordpress

build-nginx:
	docker build --no-cache -t nginx-image ./srcs/requirements/nginx
