# Developer Documentation

## Prerequisites
- Docker and Docker Compose installed.
- A Linux VM environment (required by the subject).

## Setup From Scratch
1) Create secrets in `srcs/secrets/` (see USER_DOC.md).
2) Update `srcs/.env` with the site configuration.
3) Ensure the host directories exist:
   - `/home/rhafidi/data/mariadb`
   - `/home/rhafidi/data/wordpress`

## Build and Launch
- Build and start: `make up`
- Stop: `make down`

## Managing Containers and Volumes
- Show container status: `docker compose -f srcs/docker-compose.yml ps`
- View logs: `docker compose -f srcs/docker-compose.yml logs --tail=200`
- Recreate with fresh volumes: `docker compose -f srcs/docker-compose.yml down -v`

## Data Persistence
- MariaDB data: `/home/rhafidi/data/mariadb`
- WordPress files: `/home/rhafidi/data/wordpress`

## Project Layout
- `srcs/`: compose file and environment configuration.
- `srcs/requirements/`: Dockerfiles and setup scripts per service.
- `srcs/secrets/`: local secret files (ignored by git).
