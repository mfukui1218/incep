#!/bin/bash

# SSL証明書とキーのディレクトリを作成
mkdir -p /etc/nginx/ssl

# 自己署名SSL証明書を生成
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42School/OU=Student/CN=*.42.fr"

# 証明書ファイルの権限を設定
chmod 600 /etc/nginx/ssl/nginx.key
chmod 644 /etc/nginx/ssl/nginx.crt
