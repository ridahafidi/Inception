FROM debian:bullseye

RUN apt update && \
    apt install -y mariadb-server mariadb-client && \
    apt clean

COPY tools/setup.sh /setup.sh
COPY conf/99-inception.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]