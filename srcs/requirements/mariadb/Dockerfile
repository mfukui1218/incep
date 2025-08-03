FROM alpine:3.20

RUN apk update && apk add --no-cache mariadb mariadb-client openrc gettext

# データベース起動用ディレクトリ
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# MariaDB のデータディレクトリの所有権（重要）
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# MariaDB設定ファイル
COPY conf/my.conf /etc/my.cnf

# 初期化SQLテンプレートとエントリースクリプト
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

# MariaDBのデータを永続化
VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/entrypoint.sh"]
