*This project has been created as part of the 42 curriculum by rhafidi.*

# Inception

## Description

Inception is a system administration project whose goal is to build a complete web infrastructure using Docker and Docker Compose.

The infrastructure is composed of three isolated services:

* NGINX (TLS termination and reverse proxy)
* WordPress with PHP-FPM
* MariaDB

Each service runs in its own container and communicates through a dedicated Docker network.

Persistent data is stored using Docker named volumes.

---

## Project Architecture

Browser (HTTPS:443)

↓

NGINX

↓

FastCGI (wordpress:9000)

↓

WordPress (PHP-FPM)

↓

TCP (mariadb:3306)

↓

MariaDB

---

## Instructions

Build and start the infrastructure:

```bash
make
```

Stop containers:

```bash
make down
```

Remove containers and volumes:

```bash
make fclean
```

Rebuild everything:

```bash
make re
```

---

## Main Design Choices

### Virtual Machines vs Docker

Virtual Machines virtualize an entire operating system including its own kernel.

Docker containers share the host kernel and isolate processes through namespaces and cgroups.

Containers start faster, consume fewer resources, and are easier to deploy.

### Secrets vs Environment Variables

Environment variables are suitable for non-sensitive configuration such as usernames and domain names.

Docker Secrets are used for sensitive information such as passwords because they are mounted separately and avoid exposing credentials directly in configuration files.

### Docker Network vs Host Network

Docker networks isolate container communication and provide internal DNS resolution.

Host networking removes this isolation and is forbidden by the project subject.

### Docker Volumes vs Bind Mounts

Docker named volumes are managed by Docker and are portable across environments.

Bind mounts directly expose host directories and are not allowed for WordPress and MariaDB persistent storage in this project.

---

## Resources

Official Docker Documentation:
https://docs.docker.com

Official Docker Compose Documentation:
https://docs.docker.com/compose

NGINX Documentation:
https://nginx.org/en/docs/

MariaDB Documentation:
https://mariadb.com/kb/en/documentation/

WordPress Documentation:
https://wordpress.org/documentation/

### AI Usage

AI was used as a learning assistant to:

* Understand Docker concepts.
* Review configuration choices.
* Explain networking, volumes, and FastCGI.
* Validate architectural decisions.

All generated content was manually reviewed, tested, and understood before being integrated into the project.