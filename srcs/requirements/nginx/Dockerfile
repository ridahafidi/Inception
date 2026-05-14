FROM debian:bullseye

RUN apt update && \
    apt install -y nginx openssl gettext-base && \
    apt clean

COPY ./conf/nginx.conf /etc/nginx/nginx.conf.template
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 443

ENTRYPOINT ["/setup.sh"]