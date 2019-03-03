FROM drupal:8.2

RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/themes

RUN git clone --branch 8.x-3.x https://git.drupal.org/project/bootstrap.git \
    && chown -R www-data:www-data bootstrap

# Let apache know we're behind a SSL reverse proxy
RUN sed -i '/Drupal settings:/a\SetEnvIf X-Forwarded-Proto "https" HTTPS=on' /var/www/html/.htaccess 

WORKDIR /var/www/html
    
