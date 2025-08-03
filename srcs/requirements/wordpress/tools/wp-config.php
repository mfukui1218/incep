<?php
define('DB_NAME', getenv('MYSQL_DATABASE'));
define('DB_USER', getenv('MYSQL_USER'));
define('DB_PASSWORD', getenv('MYSQL_PASSWORD'));
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY', 'dummy');
define('SECURE_AUTH_KEY', 'dummy');
define('LOGGED_IN_KEY', 'dummy');
define('NONCE_KEY', 'dummy');
define('AUTH_SALT', 'dummy');
define('SECURE_AUTH_SALT', 'dummy');
define('LOGGED_IN_SALT', 'dummy');
define('NONCE_SALT', 'dummy');

$table_prefix = 'wp_';
define('WP_DEBUG', false);

if (!defined('ABSPATH')) define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
