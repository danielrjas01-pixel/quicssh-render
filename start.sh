cat > start.sh << 'EOF'
#!/bin/sh
set -e

echo "========================================"
echo "🚀 CHISEL TUNNEL SERVER - RENDER"
echo "========================================"

# Puerto (Render lo inyecta automáticamente)
PORT=${PORT:-10000}

# Token de autenticación (generar si no existe)
AUTH_TOKEN=${AUTH_TOKEN:-$(openssl rand -hex 16)}

# Mostrar información de conexión
echo "🔧 CONFIGURACIÓN:"
echo "   🔌 Puerto: $PORT"
echo "   🔑 Token: $AUTH_TOKEN"
echo "   🌍 URL: https://$(hostname):$PORT"
echo ""
echo "📋 COMANDO PARA CLIENTE:"
echo "   ./chisel client --auth user:$AUTH_TOKEN \\"
echo "     https://$(hostname):$PORT \\"
echo "     R:localhost:2222:localhost:22"
echo "========================================"

# Iniciar Chisel Server
exec ./chisel-server server \
  --port "$PORT" \
  --auth "user:$AUTH_TOKEN" \
  --key "/app/key.pem" \
  --cert "/app/cert.pem" \
  --reverse \
  --socks5 \
  --keepalive 30s
EOF

# Hacer ejecutable
chmod +x start.sh
