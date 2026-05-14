*This project has been created as part of the 42 curriculum by rhafidi.*

## Description
Inception is a small infrastructure composed of Nginx, WordPress (php-fpm), and MariaDB, all running in separate Docker containers and connected through a dedicated Docker network. The stack uses TLS on port 443 only and persists data using named volumes mapped to /home/rhafidi/data.

## Instructions
1) Create secrets (see USER_DOC.md) and ensure /etc/hosts contains your domain.
2) Start: `make up`
3) Stop: `make down`

## Project Description
This project builds custom images from Debian bullseye and runs each service in its own container:
- Nginx serves HTTPS traffic and forwards PHP requests to WordPress.
- WordPress runs with php-fpm and installs the site plus two users via wp-cli.
- MariaDB provides the database using a persistent named volume.

### Design comparisons
- Virtual Machines vs Docker: VMs virtualize an entire OS; Docker isolates processes with shared kernel and lower overhead.
- Secrets vs Environment Variables: secrets avoid committing sensitive data; env vars are convenient for non-sensitive config.
- Docker Network vs Host Network: a bridge network isolates services while allowing container name resolution.
- Docker Volumes vs Bind Mounts: named volumes are managed by Docker and portable; bind mounts are host-path specific.

## Resources
- Docker documentation: https://docs.docker.com/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress documentation: https://developer.wordpress.org/
- Nginx documentation: https://nginx.org/en/docs/
- AI usage: used to review the subject requirements and draft documentation and scripts; all changes were reviewed and validated.
