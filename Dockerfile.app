FROM php:7.3.26-apache
COPY . /var/www/html
RUN docker-php-ext-install mysqli
RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 /var/www
EXPOSE 80

