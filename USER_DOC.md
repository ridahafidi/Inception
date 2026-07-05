# USER DOCUMENTATION

## Services Provided

The infrastructure provides:

* HTTPS Web Server (NGINX)
* WordPress Website
* MariaDB Database

---

## Starting The Project

Run:

```bash
make
```

This builds images and starts all services.

---

## Stopping The Project

Run:

```bash
make down
```

---

## Rebuilding The Project

Run:

```bash
make re
```

---

## Accessing The Website

Open:

```text
https://<login>.42.fr
```

Example:

```text
https://rhafidi.42.fr
```

---

## Accessing WordPress Administration

Open:

```text
https://<login>.42.fr/wp-admin
```

Log in using the administrator account configured during installation.

---

## Credentials

Sensitive credentials are stored inside the repository secrets directory.

Examples:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Before running `make`, create those files locally under `secrets/` and put the matching password values inside each one.

---

## Checking Service Status

List running containers:

```bash
docker ps
```

View logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

## Checking Persistent Data

Database data:

```text
MariaDB Volume
```

Website data:

```text
WordPress Volume
```

Both persist after container recreation.
