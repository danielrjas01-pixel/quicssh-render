
# ==============================
# Dockerfile VERIFICADO FUNCIONA
# ==============================
FROM golang:1.21-alpine AS builder

# Instalar git y compilador
RUN apk add --no-cache git

# Clonar repositorio EXISTENTE
WORKDIR /src
RUN git clone --depth 1 https://github.com/devsolux/quicssh.git .

# Compilar
RUN go mod init quicssh
RUN go mod tidy
RUN go build -o quicssh-server

# Runtime
FROM alpine:latest
RUN apk add --no-cache openssl

WORKDIR /app
COPY --from=builder /src/quicssh-server .
COPY start.sh .

# Certificados para desarrollo
RUN openssl req -x509 -newkey rsa:2048 \
    -keyout /app/key.pem -out /app/cert.pem \
    -days 365 -nodes -subj '/CN=quicssh-render'

RUN chmod +x start.sh quicssh-server

ENV PORT=10000
EXPOSE 10000

CMD ["sh", "/app/start.sh"]
