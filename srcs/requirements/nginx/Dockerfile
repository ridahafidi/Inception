FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl

COPY /conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/ssl && \
    openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Benguerir/L=Benguerir/O=42/OU=42/CN=localhost"

ENTRYPOINT ["nginx", "-g", "daemon off;"]