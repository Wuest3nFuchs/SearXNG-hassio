#!/usr/bin/ash
set -e

# Erzeuge Profilordner, falls nicht vorhanden
if [ ! -d /config/searxng ]; then
  mkdir -p /config/searxng
fi

# (Optional) Kopiere Beispielkonfiguration falls keine vorhanden
if [ ! -f /config/searxng/settings.yml ]; then
  cat > /config/searxng/settings.yml <<'EOF'
http server:
  bind_address: 0.0.0.0
  port: 8080
EOF
fi

# Start-Befehl: übergebe an das Image (Supervisor verwendet image entrypoint)
exec "$@"
