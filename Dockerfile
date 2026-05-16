
# etapa builder
FROM node:20-alpine AS builder

LABEL descripcion="api casino online"

WORKDIR /app

# copiar package files
COPY package.json package-lock.json ./

# instalar dependencias
RUN npm ci --omit=dev

# copiar codigo fuente
COPY . .

# etapa runtime
FROM node:20-alpine AS runtime

WORKDIR /app

# copiar app desde builder
COPY --from=builder --chown=node:node /app ./

# crear carpeta persistente
RUN mkdir -p /data && chown -R node:node /data

# usuario no root
USER node

# puerto api
EXPOSE 3000

# healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

# iniciar api
CMD ["node", "src/server.js"]