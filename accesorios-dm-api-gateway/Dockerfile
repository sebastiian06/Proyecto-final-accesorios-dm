FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache curl

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Crear directorio para logs
RUN mkdir -p logs

# Exponer puerto
EXPOSE 8000

# Usuario no root por seguridad
USER node

# Comando para producción
CMD ["node", "src/index.js"]