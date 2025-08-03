FROM debian:bullseye

# 必要パッケージのインストール
RUN apt-get update && \
    apt-get install -y lsb-release apt-transport-https ca-certificates curl gnupg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && \
    apt-get update && \
    apt-get install -y \
        php8.4 \
        php8.4-fpm \
        php8.4-mysql \
        php8.4-curl \
        php8.4-mbstring \
        php8.4-xml \
        unzip \
        vim \
        curl \
        mariadb-client

# wp-cli インストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# WordPress インストール
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# php-fpm の listen を 9000 に変更
RUN mkdir -p /run/php && \
    sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.4/fpm/pool.d/www.conf

# entrypoint.sh をコピー
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY tools/wp-config.php /var/www/html/wp-config.php
COPY conf/php-fpm.conf /etc/php/8.4/fpm/php-fpm.conf

# ↓あとでこの debug.txt を出力してログに残す
RUN chmod +x /usr/local/bin/entrypoint.sh

# 起動
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.4", "-F"]
