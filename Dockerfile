FROM php:8.0-fpm

# Install extensions
RUN docker-php-ext-install pdo_mysql exif pcntl
# RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
# RUN docker-php-ext-install gd

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    mcrypt \
    openssl \
    curl

# Add and Enable PHP-PDO Extenstions
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable pdo_mysql

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node
RUN apt-get update &&\
    apt-get install -y --no-install-recommends gnupg &&\
    curl -sL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends nodejs &&\
    npm config set registry https://registry.npmmirror.com --global &&\
    npm install --global gulp-cli

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
