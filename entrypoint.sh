#!/bin/sh

# Função para verificar se o banco de dados está acessível
wait_for_db() {
  max_retries=30
  retry_count=0

  while ! nc -z $DB_HOST $DB_PORT; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
      echo "Máximo de tentativas atingido. Não foi possível conectar ao banco de dados."
      exit 1
    fi
    echo "Tentativa $retry_count/$max_retries: Aguardando banco de dados..."
    sleep 1
  done
  echo "Banco de dados está acessível."
}

# Chama a função para aguardar o banco de dados
wait_for_db

# Execute as migrações do banco de dados
php artisan migrate --force || {
  echo "Erro ao executar migrações."
  exit 1
}

# Inicie o servidor Apache
apache2-foreground
