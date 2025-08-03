#!/bin/sh

# 秘密鍵と証明書を生成
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /run/secrets/ssl_key.pem \
  -out /run/secrets/ssl_cert.pem \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=Inception/CN=${DOMAIN_NAME}"

# 生成後の確認（オプション）
ls -l /run/secrets/
