FROM php:7.4-fpm-alpine3.15

# ARGs will only be available at build time (pass them from env, for both local docker-compose, and Jenkins)
ARG DB_PASSWORD=$DB_PASSWORD
ARG DB_DATABASE=$DB_DATABASE
ARG DB_HOST=$DB_HOST
ARG DB_USERNAME=$DB_USERNAME
ARG SMTPSERVER=$SMTPSERVER
ARG SMTP_PASS=$SMTP_PASS
ARG SMTP_USER=$SMTP_USER
ARG SMTP_PORT=$SMTP_PORT
ARG SMTP_FROM=$SMTP_FROM

# default ENV values, left here just for Documentation
ENV PHP_INI_FILE="/etc/php7/php.ini" \
    PHP_FPM_CONF="/etc/php7/php-fpm.d/www.conf" \
    TZ="Etc/UTC" \
    COMPOSER_ALLOW_SUPERUSER="1" \
    COMPOSER_HOME="/root/.composer" \
    DB_PASSWORD=$DB_PASSWORD \
    DB_DATABASE=$DB_DATABASE \
    DB_HOST=$DB_HOST \
    DB_USERNAME=$DB_USERNAME \
    LOCALHOST="localhost" \
    MAIL_DRIVER="smtp" \
    MEMCACHED_SERVER="memcached" \
    MEMCACHED_PORT="11211" \
    REDIS_SERVER="redis" \
    REDIS_PORT="6379" \
    SMTPSERVER=$SMTPSERVER \
    SMTP_FROM=$SMTP_FROM \
    SMTP_PASS=$SMTP_PASS \
    SMTP_PORT=$SMTP_PORT \
    SMTP_USER=$SMTP_USER

# --------------------------------------------------------- Install dependancies
RUN apk add --update --no-cache \
        # Dependancy for intl \
        icu-libs \
        libintl \
        # Dependancy for zip \
        libzip \
        # Misc tools \
        git \
        imagemagick \
        patch

# --------------------------------------------------- Install build dependancies
RUN apk add --update --no-cache --virtual .docker-php-global-depS \
        # Build dependencies for gd \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        # gmp
        gmp-dev \
        # Build dependency for gettext \
        gettext-dev \
        # Build dependency for intl \
        icu-dev \
        # Build dependencies for XML part \
        libxml2-dev \
        ldb-dev \
        # Build dependencies for Zip \
        libzip-dev oniguruma-dev \
        # Build dependancies for Pecl \
        autoconf \
        g++ \
        make \
        # Build dependancy for APCu \
        pcre-dev

# Install packages and remove cache
# email testing: echo -e "Subject: Test Mail\r\n\r\nThis is a test mail, please let me know if it works..!" | msmtp --debug --from noreply@domain.com -t user@mail.com
RUN set -ex; \
    apk update ; \
    apk add --no-cache \
    wget tzdata zip unzip openssl ca-certificates nginx tar mysql-client supervisor haveged rng-tools msmtp gmp \
    php7 php7-fpm php7-cli php7-common php7-opcache \
    php7-bcmath php7-ctype php7-curl php7-dom php7-fileinfo php7-gd php7-gmp php7-iconv php7-intl php7-exif php7-json php7-mbstring php7-mysqli php7-openssl php7-pdo php7-pdo_mysql php7-phar php7-posix php7-session php7-memcached php7-redis php7-shmop php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter php7-zip php7-zlib ; \
    update-ca-certificates ; \
    echo -e "* * * * * /var/www/html/autorun.sh\n" >> /etc/crontabs/root ; \
    rm -rf /var/cache/apk/* ; \
    rm -rf /tmp/* \
    ;

# ------------------------------------------------------- Install php xdebug
#RUN apk add --update --no-cache autoconf g++ make && \
#   apk add --update --no-cache --virtual .docker-php-xdebug-depS \
#   autoconf g++ make && \
#   pecl install xdebug && \
#   docker-php-ext-enable xdebug && \
#   apk del .docker-php-xdebug-depS

# ------------------------------------------------------- Install php memcached
RUN apk add --update --no-cache libmemcached-libs && \
    apk add --update --no-cache --virtual .docker-php-memcached-depS cyrus-sasl-dev libmemcached-dev && \
    pecl install memcached && \
    docker-php-ext-enable memcached && \
    apk del .docker-php-memcached-depS

# ------------------------------------------------------- Install php mysql
RUN apk add --update --no-cache --virtual .docker-php-mysql-depS mysql-client && \
    docker-php-ext-configure mysqli && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-install mysqli pdo_mysql && \
    apk del .docker-php-mysql-depS

# ------------------------------------------------------- The End
RUN docker-php-ext-configure bcmath --enable-bcmath && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp && \
    docker-php-ext-configure gmp && \
    docker-php-ext-configure gettext && \
    docker-php-ext-configure intl --enable-intl && \
    docker-php-ext-configure mbstring --enable-mbstring && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-configure zip && \
    docker-php-ext-install bcmath gd gmp exif gettext intl mbstring opcache pcntl zip && \
    apk del .docker-php-global-depS && \
    rm -rf /var/cache/apk/* && \
    docker-php-source delete && \
    rm -rf /tmp/*

# Configure nginx
COPY devops/nginx-alpine.conf /etc/nginx/nginx.conf
COPY devops/default-alpine.conf /etc/nginx/conf.d/default.conf

# Configure supervisord
COPY devops/supervisord-alpine.conf /etc/supervisor/conf.d/supervisord.conf

# Tweak settings
RUN sed -i -e 's~.*expose_php = .*~expose_php = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*date.timezone =.*~date.timezone = "UTC"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*allow_url_fopen = .*~allow_url_fopen = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.cookie_httponly =.*~session.cookie_httponly = 1~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.use_trans_sid =.*~session.use_trans_sid = 0~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.use_strict_mode =.*~session.use_strict_mode = 1~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.use_cookies =.*~session.use_cookies = 1~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.use_only_cookies =.*~session.use_only_cookies = 1~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.cookie_samesite =.*~session.cookie_samesite = "Lax"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*default_charset = .*~default_charset = "UTF-8"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*display_errors = .*~display_errors = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*display_startup_errors = .*~display_startup_errors = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_WARNING \& ~E_DEPRECATED \& ~E_STRICT/' ${PHP_INI_FILE} && \
    sed -i -e 's~upload_max_filesize = .*~upload_max_filesize = 32M~' ${PHP_INI_FILE} && \
    sed -i -e 's~post_max_size = .*~post_max_size = 32M~' ${PHP_INI_FILE} && \
    sed -i -e 's~max_execution_time = .*~max_execution_time = 120~' ${PHP_INI_FILE} && \
    sed -i -e 's~memory_limit = .*~memory_limit = 128M~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*sendmail_path =.*~sendmail_path = "/usr/bin/msmtp -t"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*mail.add_x_header =.*~mail.add_x_header = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*open_basedir =.*~open_basedir = "/var/lib/php:/var/www:/root:/usr/local/bin:/tmp"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*cgi.fix_pathinfo=.*~cgi.fix_pathinfo=0~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*opcache.enable=.*~opcache.enable=1~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*opcache.interned_strings_buffer=.*~opcache.interned_strings_buffer=64~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.save_handler =.*~session.save_handler = memcached~' ${PHP_INI_FILE} && \
    sed -i -e "s~;session.save_path =.*~session.save_path = $MEMCACHED_SERVER:$MEMCACHED_PORT~" ${PHP_INI_FILE} && \
    sed -i -e 's~.*disable_functions =.*~disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,passthru,shell_exec,system,popen,parse_ini_file,show_source,escapeshellarg,escapeshellcmd~' ${PHP_INI_FILE} && \
    sed -i -e 's~;catch_workers_output = .*~catch_workers_output = yes~' ${PHP_FPM_CONF} && \
    sed -i -e 's~.*listen.backlog =.*~listen.backlog = 1024~' ${PHP_FPM_CONF} && \
    sed -i -e 's~.*clear_env = no~clear_env = no~' ${PHP_FPM_CONF} && \
    sed -i -e "s~.*user =.*~user = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*group =.*~group = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*listen\.owner =.*~listen\.owner = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*listen\.group =.*~listen\.group = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*listen\.mode =.~listen\.mode = 0660~" ${PHP_FPM_CONF} && \
    sed -i -e 's~.*listen = .*~listen = /run/php-fpm.sock~' ${PHP_FPM_CONF} && \
    printf "defaults\ndomain ${LOCALHOST}\naccount default\nhost ${SMTPSERVER}\nport ${SMTP_PORT}\nprotocol smtp\ntls on\ntls_certcheck off\ntls_starttls on\nauth on\nuser ${SMTP_USER}\npassword ${SMTP_PASS}\nfrom ${SMTP_FROM}\nlogfile /tmp/.msmtp.log\nsyslog off\n" > /etc/msmtprc && \
    sed -i -e 's~.*pm = .*~pm = ondemand~' ${PHP_FPM_CONF}

# Setup permissions for nobody user
RUN chown -R nobody.nobody /run && \
  openssl req -x509 -sha256 -newkey rsa:1024 -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt -days 3650 -nodes -subj '/CN=localhost' && \
  chmod 0644 /etc/ssl/certs/localhost.crt && \
  chmod 0600 /etc/ssl/certs/localhost.key && \
  chown nobody.nobody /var/log/php7 && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  mkdir -p /var/www/html/app/application/vendor && mkdir -p /var/log/supervisor && mkdir -p /var/www/vendor && mkdir -p /root/.composer/cache/files && mkdir -p /root/.composer/cache/repo && \
  chown -R nobody.nobody /var/www && \
  chown -R nobody:nobody /var/lib/nginx && \
  chown nobody.nobody /var/log/supervisor

# Make the document root a volume
WORKDIR /var/www/html
#RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Switch to use a non-root user from here on
#USER nobody

# If you make the assumption that you change your codebase more often than your Composer dependencies — then your Dockerfile should run composer install before copying across your codebase. This will mean that your composer install layer will be cached even if your codebase changes. The layer will only be invalidated when you actually change your dependencies.
COPY --chown=nobody:nobody app /var/www/html/app

#RUN composer dump-autoload --no-scripts --no-dev --optimize

USER root

# Expose the port nginx is reachable on
EXPOSE ${PORT} 8443

# Let supervisord manage everything
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
