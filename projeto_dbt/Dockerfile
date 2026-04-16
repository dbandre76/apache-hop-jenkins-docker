FROM python:3.9-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar o dbt e o dbt-postgres
RUN pip install --no-cache-dir dbt-core==1.9.4 dbt-postgres==1.9.0

# Definir diretório de trabalho
WORKDIR /dbt

EXPOSE 9100 8080 9000

# Manter o container ativo
CMD ["tail", "-f", "/dev/null"]