FROM php:7.4-apache

ARG S9Y_VERSION=2.3.5

RUN apt-get update && \
	apt-get install -y \
	unzip \
    libicu-dev \
	libcurl4-openssl-dev \
	libmcrypt-dev \
	libmemcached11 \
	libmemcached-dev \
	imagemagick \
	vim-tiny \
	libonig-dev \
	libxml2-dev \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install gd intl opcache mysqli \
	&& rm -rf /var/lib/apt/lists/* /var/www/html/index.html

# RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# RUN	docker-php-ext-install gd intl mbstring mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Enable mod_rewrite    
RUN a2enmod rewrite

RUN mkdir -p /src /var/www/html/shared/uploads

ADD https://github.com/s9y/Serendipity/releases/download/${S9Y_VERSION}/serendipity-${S9Y_VERSION}.zip /src/serendipity-${S9Y_VERSION}.zip

RUN cd /src && unzip serendipity-${S9Y_VERSION}.zip && \
    mv /src/serendipity /var/www/html/

RUN chown -Rh root:www-data /var/www/html && \
	chown www-data:www-data /var/www/html/serendipity && \
	chown -Rh www-data:www-data /var/www/html/serendipity/uploads && \
	chown -Rh www-data:www-data /var/www/html/serendipity/plugins && \
	chown -Rh www-data:www-data /var/www/html/serendipity/templates && \
    chown -Rh www-data:www-data /var/www/html/serendipity/templates_c && \
	chmod 777 /var/www/html/serendipity/templates_c

COPY serendipity_config_local.inc.php.template /var/www/html/serendipity/serendipity_config_local.inc.php
RUN chown root:www-data /var/www/html/serendipity/serendipity_config_local.inc.php && \
	chmod 660  /var/www/html/serendipity/serendipity_config_local.inc.php

COPY apache2.conf.template /src/apache2.conf.template
RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.original && \
	cp /src/apache2.conf.template /etc/apache2/apache2.conf && \
	chown root:root /etc/apache2/apache2.conf && \
	chmod 644 /etc/apache2/apache2.conf

# Install Deco
ARG DECO_VERSION=1.4.0
ARG DECO_OS=linux
ARG DECO_ARCH=amd64
ADD https://github.com/YaleUniversity/deco/releases/download/v${DECO_VERSION}/deco_${DECO_VERSION}_${DECO_OS}_${DECO_ARCH}.tar.gz /usr/local/bin/deco.tar.gz
RUN cd /usr/local/bin && tar -zxvf deco.tar.gz && rm -f deco.tar.gz && chmod 555 deco && /usr/local/bin/deco version

COPY default_deco.json /var/run/secrets/deco.json
COPY entrypoint.sh /src
RUN chown root:root /src/entrypoint.sh && chmod 555 /src/entrypoint.sh

CMD ["/src/entrypoint.sh"]
