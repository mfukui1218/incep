#!/bin/bash

# SSL証明書とキーのディレクトリを作成
mkdir -p /etc/nginx/ssl

# より適切な自己署名SSL証明書を生成
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42School/OU=Inception/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.42.fr,DNS:mfukui.42.fr,IP:127.0.0.1"

# 証明書ファイルの権限を設定
chmod 600 /etc/nginx/ssl/nginx.key
chmod 644 /etc/nginx/ssl/nginx.crt

echo "SSL certificate generated with SAN for localhost and 127.0.0.1"
