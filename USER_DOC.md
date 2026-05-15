# User Documentation

## Services Provided
- Nginx: HTTPS entrypoint on port 443.
- WordPress: PHP application served by php-fpm.
- MariaDB: relational database for WordPress.

## Start and Stop
- Start: `make up`
- Stop: `make down`

## Host Data Directories
This project stores persistent data in Docker named volumes mapped to host directories:
- `/home/rida/data/mariadb`
- `/home/rida/data/wordpress`

Create them once before starting:
- `sudo mkdir -p /home/rida/data/mariadb /home/rida/data/wordpress`

## Access the Website and Admin Panel
1) Add a hosts entry pointing your local IP to your domain:
   - `127.0.0.1 rhafidi.42.fr`
2) Open `https://rhafidi.42.fr` in your browser.
3) Admin panel: `https://rhafidi.42.fr/wp-admin`

## Credentials and Secrets
Create the following files locally (these are ignored by git):
- `secrets/db_root_password.txt`
- `secrets/db_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`
- `secrets/credentials.txt`

Update non-secret settings in `srcs/.env`:
- Domain name, database name/user, and WordPress site/user metadata.

## Check Services
- List containers: `docker compose -f srcs/docker-compose.yml ps`
- Logs: `docker compose -f srcs/docker-compose.yml logs -f`
- Verify HTTPS: open the website and confirm TLS in the browser.
