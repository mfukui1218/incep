#!/bin/bash
set -e

until mysqladmin ping -h mariadb --silent; do
  echo "Waiting for mariadb to be ready..."
  sleep 2
done

if ! wp core is-installed --allow-root; then
  wp core install --url="https://${DOMAIN_NAME}" --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root
fi

if ! wp user get "${WP_ADMIN_USER}" --allow-root >/dev/null 2>&1; then
  wp user create "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" --role=administrator --user_pass="${WP_ADMIN_PASS}" --allow-root
fi

exec "$@"
