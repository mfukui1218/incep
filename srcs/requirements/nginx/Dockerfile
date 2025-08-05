FROM alpine:3.22

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    bash

# SSL証明書作成
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/localhost.key \
    -out /etc/nginx/ssl/localhost.crt \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=student/CN=localhost"

# config ファイルを追加
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

# フォルダ作成
RUN mkdir -p /run/nginx

# 所有権変更
RUN chown -R nginx:nginx /var/lib/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
