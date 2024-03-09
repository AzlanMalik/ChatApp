FROM php:apache
RUN docker-php-ext-install mysqli
COPY . /var/www/html
VOLUME /var/www/html/php/images
RUN chown -R www-data:www-data /var/www/html 
EXPOSE 80
