# Use uma imagem oficial do PHP com Apache
FROM php:8.2-apache

# Instale dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo pdo_mysql zip

# Instale Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Defina o diretório de trabalho
WORKDIR /var/www/html

# Copie os arquivos da aplicação para o contêiner
COPY . .

# Instale as dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Instale as dependências do Node.js e construa os assets
RUN npm install && npm run build

# Defina as permissões corretas
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Ative o mod_rewrite do Apache
RUN a2enmod rewrite

# Exponha a porta 80
EXPOSE 80

RUN php artisan migrate

# Inicie o servidor Apache
CMD ["apache2-foreground"]
