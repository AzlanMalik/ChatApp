FROM php:apache
RUN docker-php-ext-install mysqli
COPY . /var/www/html
VOLUME /var/www/html/php/images
RUN chmod -R 777 /var/www/html/php/images
EXPOSE 80
