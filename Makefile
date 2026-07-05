NAME=inception
COMPOSE=docker compose -f srcs/docker-compose.yaml
DB_VLM_PATH=/home/rhafidi/data/mariadb
WP_VLM_PATH=/home/rhafidi/data/wordpress

all:
	mkdir -p $(DB_VLM_PATH)
	mkdir -p $(WP_VLM_PATH)
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v

re: fclean all

.PHONY: all down clean fclean re