FROM golang:1.21-alpine AS builder

# Instalar dependencias
RUN apk add --no-cache git gcc musl-dev

# Clonar y compilar quicssh
WORKDIR /src
RUN git clone https://github.com/mxplusb/quicssh.git .
RUN go mod init quicssh && go mod tidy
RUN go build -o quicssh-server

# Imagen final
FROM alpine:latest

RUN apk add --no-cache ca-certificates openssh-client

# Crear usuario no root
RUN adduser -D -g '' appuser

WORKDIR /app
COPY --from=builder /src/quicssh-server .
COPY config.yaml .
COPY start.sh .

# Certificados auto-generados (para desarrollo)
RUN apk add --no-cache openssl && \
    openssl req -x509 -newkey rsa:4096 \
    -keyout key.pem -out cert.pem \
    -days 365 -nodes -subj '/CN=localhost'

RUN chown -R appuser:appuser /app && \
    chmod +x start.sh quicssh-server

USER appuser

EXPOSE 443

CMD ["./start.sh"]
