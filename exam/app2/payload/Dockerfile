FROM php:7.2-apache

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
LABEL app=ex_py_hlwd

COPY src/ /var/www/html/

