FROM prestashop/prestashop:latest

ENV PS_DEV_MODE=0

RUN apt-get update && apt-get install -y \
    nano \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R www-data:www-data /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
