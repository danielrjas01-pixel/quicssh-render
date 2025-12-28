# ESTE es el contenido CORRECTO del Dockerfile:
#cat > Dockerfile << 'EOF'
# ==========================================
# Dockerfile para Chisel Tunnel en Render
# ==========================================

# Fase 1: Compilación
FROM golang:1.21-alpine AS builder

# Instalar git
RUN apk add --no-cache git

# Directorio de trabajo
WORKDIR /src

# Clonar Chisel
RUN git clone --depth 1 https://github.com/jpillora/chisel.git .

# Compilar Chisel
RUN go build -o chisel-server ./cmd/chisel

# ------------------------------------------------------

# Fase 2: Runtime
FROM alpine:latest

# Instalar herramientas
RUN apk add --no-cache openssl ca-certificates

# Directorio de la aplicación
WORKDIR /app

# Copiar binario
COPY --from=builder /src/chisel-server .

# Copiar script de inicio
COPY start.sh .

# Hacer ejecutables
RUN chmod +x start.sh chisel-server

# Generar certificado
RUN openssl req -x509 -newkey rsa:2048 \
    -keyout /app/key.pem -out /app/cert.pem \
    -days 365 -nodes -subj '/CN=chisel-tunnel.render.com'

# Puerto expuesto
EXPOSE 10000

# Comando de inicio
CMD ["sh", "/app/start.sh"]
EOF
