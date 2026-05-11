FROM debian:bookworm

RUN apt update && \
    apt install -y nginx openssl && \
    apt clean

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 443

ENTRYPOINT ["/setup.sh"]