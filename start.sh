#!/bin/sh
set -e

echo "Iniciando quicssh en Render..."

# Generar token si no existe
if [ -z "$ACCESS_TOKEN" ]; then
  export ACCESS_TOKEN=$(openssl rand -hex 16)
  echo "Token generado: $ACCESS_TOKEN"
fi

# Render asigna puerto dinámico
if [ -z "$PORT" ]; then
  export PORT=10000
fi

# Crear configuración dinámica
cat > /app/config-render.yaml << EOF
server:
  listen: ":$PORT"
  tls_cert: "/app/cert.pem"
  tls_key: "/app/key.pem"
  enable_quic: true
  quic_over_tcp: true
  
ssh:
  backend: "localhost:2222"
  
auth:
  tokens:
    - "$ACCESS_TOKEN"
    
web:
  enabled: true
  port: 8080
  path: "/health"
EOF

# Iniciar SSH interno (solo para prueba)
echo "Iniciando SSH de prueba..."
ssh-keygen -A
echo "root:${ROOT_PASSWORD:-password123}" | chpasswd
/usr/sbin/sshd -p 2222 -D -e &
SSHD_PID=$!

# Iniciar quicssh
echo "Iniciando quicssh en puerto $PORT..."
exec ./quicssh-server --config /app/config-render.yaml
