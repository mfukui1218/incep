FROM alpine:3.22

RUN apk update && apk add --no-cache \
    mariadb mariadb-client

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
	
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
