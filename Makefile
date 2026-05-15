prepare:
	mkdir -p /home/rhafidi/data

up: prepare
	docker compose -f srcs/docker-compose.yml up --build

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v --remove-orphans