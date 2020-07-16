FROM php:7.1-cli-alpine

LABEL maintainer="adityarahman032@gmail.com"

ENV PHP_USER php-app
ENV PHP_GROUP php-app
ENV PHP_UID 1001
ENV PHP_GID 1002

RUN set -xe \
  && curl https://getcomposer.org/installer -o /tmp/composer-setup.php \
  && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && apk add --no-cache \
      git \
      openldap \
      libpng \
      libjpeg-turbo \
      libstdc++ \
      freetds \
      unixodbc \
      gnupg \
      libzip \
      imap-dev \
      imagemagick \
      krb5 \
  && curl -o /tmp/msodbcsql17_17.5.2.2-1_amd64.apk https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.2-1_amd64.apk \
  && curl -o /tmp/mssql-tools_17.5.2.1-1_amd64.apk https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.apk \
  && curl -o /tmp/msodbcsql17_17.5.2.2-1_amd64.sig https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.2-1_amd64.sig \
  && curl -o /tmp/mssql-tools_17.5.2.1-1_amd64.sig https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.sig \
  && curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - \
  && gpg --verify /tmp/msodbcsql17_17.5.2.2-1_amd64.sig /tmp/msodbcsql17_17.5.2.2-1_amd64.apk \
  && gpg --verify /tmp/mssql-tools_17.5.2.1-1_amd64.sig /tmp/mssql-tools_17.5.2.1-1_amd64.apk \
  && apk add --allow-untrusted /tmp/msodbcsql17_17.5.2.2-1_amd64.apk \
  && apk add --allow-untrusted /tmp/mssql-tools_17.5.2.1-1_amd64.apk \
  && apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      openldap-dev \
      libpng-dev \
      libjpeg-turbo-dev \
      freetds-dev \
      unixodbc-dev \
      libzip-dev \
      imagemagick-dev \ 
      krb5-dev \
      openssl-dev \
  && docker-php-source extract \
  && pecl install \
      sqlsrv-5.6.1 \
      pdo_sqlsrv-5.6.1 \
      redis \
      imagick \
  && docker-php-ext-configure gd --with-jpeg-dir=/usr/include \
  && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
  && docker-php-ext-install \
      ldap \
      gd \
      pdo_mysql \
      mysqli \
      zip \
      pdo_dblib \
      imap \
      bcmath \
  && docker-php-ext-enable \
      sqlsrv \
      pdo_sqlsrv \
      redis \
      imagick \
  && addgroup -g $PHP_GID $PHP_GROUP \
  && adduser -D -u $PHP_UID -G $PHP_GROUP $PHP_USER \
  && docker-php-source delete \
  && apk del .build-deps && rm -rf /tmp/*

USER $PHP_USER
WORKDIR /app
ENTRYPOINT ["/bin/sh"]
