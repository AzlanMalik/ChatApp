FROM php:7.3.26-apache
WORKDIR /var/www/html/
COPY . .
RUN docker-php-ext-install mysqli
RUN mkdir -p /var/www/html/php/images
RUN chown -R www-data:www-data /var/www/html/php/images
RUN chmod -R 755 /var/www/html/php/images
EXPOSE 80

