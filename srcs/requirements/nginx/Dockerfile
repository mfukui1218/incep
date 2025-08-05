FROM alpine:3.22

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    bash

RUN mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout /etc/ssl/private/nginx.key \
      -out /etc/ssl/certs/nginx.crt \
      -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=Dev/CN=localhost"

# config ファイルを追加
COPY conf/nginx.cnf /etc/nginx/nginx.cnf
COPY conf/default.cnf /etc/nginx/conf.d/default.cnf

# フォルダ作成
RUN mkdir -p /run/nginx

# 所有権変更
RUN chown -R nginx:nginx /var/lib/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
