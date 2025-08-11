FROM debian:bullseye

# MariaDBサーバーとクライアントをインストール
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# 設定ファイルをコピー
COPY conf/server.conf /etc/mysql/mariadb.conf.d/50-server.cnf

# 初期化スクリプトをコピー
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# ログディレクトリを作成
RUN mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql

# ポート3306を公開
EXPOSE 3306

# 初期化スクリプトを実行してMariaDBを起動
ENTRYPOINT ["/usr/local/bin/init_db.sh"]

# MariaDBサーバーをフォアグラウンドで実行
CMD ["mysqld_safe", "--bind-address=0.0.0.0"]
