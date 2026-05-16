#conviertes la base de datos en una imagen propia del proyecto
FROM postgres:16-alpine

# copiar script de inicializacion
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql

# puerto postgres
EXPOSE 5432