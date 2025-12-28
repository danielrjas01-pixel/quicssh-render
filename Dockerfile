# Dockerfile CORREGIDO - usa wget
FROM golang:1.21-alpine AS builder

# Instalar wget y git
RUN apk add --no-cache wget tar

WORKDIR /src

# Descargar como tar.gz en lugar de git clone
RUN wget https://github.com/devsolux/quicssh/archive/refs/heads/main.tar.gz -O quicssh.tar.gz && \
    tar -xzf quicssh.tar.gz && \
    mv quicssh-main/* . && \
    rm -rf quicssh-main quicssh.tar.gz

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

# Certificados
RUN openssl req -x509 -newkey rsa:2048 \
    -keyout /app/key.pem -out /app/cert.pem \
    -days 365 -nodes -subj '/CN=quicssh-render'

RUN chmod +x start.sh quicssh-server

ENV PORT=10000
EXPOSE 10000

CMD ["sh", "/app/start.sh"]
