#!/bin/bash

DOMAIN_NAME=${DOMAIN_NAME:-localhost}

# Render the Nginx config with the current domain name.
envsubst '$DOMAIN_NAME' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Prepare SSL directory and generate a self-signed certificate.
mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Morocco/L=Benguerir/O=1337/OU=42/CN=${DOMAIN_NAME}"

# Run Nginx in the foreground for container lifecycle management.
exec nginx -g "daemon off;"