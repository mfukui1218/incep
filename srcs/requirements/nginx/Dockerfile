# srcs/requirements/nginx/Dockerfile
FROM alpine:3.20

RUN apk update && apk add --no-cache nginx openssl curl php82-fpm php82-mysqli php82-session php82-opcache php82-gd php82-curl php82-exif php82-zlib php82-xml php82-mbstring php82-phar php82-dom php82-tokenizer php82-fileinfo


# 起動スクリプトをコピー
COPY requirements/nginx/tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=Student/CN=mfukui.42.fr"

EXPOSE 443

CMD ["/entrypoint.sh"]
