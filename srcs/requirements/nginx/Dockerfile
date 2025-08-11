FROM debian:bullseye

# NGINXと必要なツールをインストール
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# SSL証明書を作成するスクリプトをコピー
COPY tools/setup_ssl.sh /usr/local/bin/setup_ssl.sh
RUN chmod +x /usr/local/bin/setup_ssl.sh

# SSL証明書を生成
RUN /usr/local/bin/setup_ssl.sh

# NGINX設定ファイルをコピー
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/sites-available/default

# デフォルトのNGINX設定を削除してカスタム設定をリンク
RUN rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# ログディレクトリを作成
RUN mkdir -p /var/log/nginx && \
    chown -R www-data:www-data /var/log/nginx

# ポート443を公開
EXPOSE 443

# NGINXをフォアグラウンドで実行
CMD ["nginx", "-g", "daemon off;"]
