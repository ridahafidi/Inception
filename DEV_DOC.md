# DEVELOPER DOCUMENTATION

## Prerequisites

Required software:

* Linux Virtual Machine
* Docker
* Docker Compose

Verify installation:

```bash
docker --version
docker compose version
```

---

## Repository Structure

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
```

The srcs directory contains all Docker-related configuration.

---

## Environment Configuration

The `.env` file contains non-sensitive configuration:

```env
DOMAIN_NAME=
MARIADB_DATABASE=
MARIADB_USER=
WP_ADMIN_USER=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_EMAIL=
DB_VOLUME_PATH=
WP_VOLUME_PATH=
```

Sensitive information is stored inside Docker secrets.

Expected local secret files:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Create them locally before starting the stack; they are ignored by git and must exist for Docker Compose to mount them.

---

## Building The Project

Build and start:

```bash
make
```

---

## Stopping Containers

```bash
make down
```

---

## Removing Containers And Volumes

```bash
make fclean
```

---

## Useful Docker Commands

List containers:

```bash
docker ps
```

List volumes:

```bash
docker volume ls
```

List networks:

```bash
docker network ls
```

Inspect logs:

```bash
docker logs <container>
```

Open a shell inside a container:

```bash
docker exec -it <container> sh
```

---

## Persistent Data

MariaDB stores database data inside:

```text
db_data
```

WordPress stores website files inside:

```text
wp_data
```

Both volumes persist independently from container lifecycles.

---

## Container Communication

Containers communicate through the dedicated Docker network:

```text
inception
```

Service discovery relies on Docker DNS:

```text
wordpress -> mariadb
nginx -> wordpress
```

No host networking is used.