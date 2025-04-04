FROM prestashop/prestashop:latest

ENV PS_DEV_MODE=0 \
    PS_COUNTRY=FR \
    PS_LANGUAGE=fr \
    PS_INSTALL_AUTO=1 \
    DB_NAME=prestashop \
    DB_USER=prestashop \
    DB_PASSWD=psswrd \
    DB_SERVER=db

RUN apt-get update && apt-get install -y \
    nano \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
