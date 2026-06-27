#!/bin/bash

AUTOSTART="$HOME/.config/sway/scripts/autostart.sh"

echo "=== Agregar servicio a autostart.sh ==="
echo ""

read -p "Nombre del servicio (ej: syncthing): " SERVICE_NAME
[ -z "$SERVICE_NAME" ] && echo "Nombre requerido" && exit 1

read -p "Binario para pgrep (default: $SERVICE_NAME): " PGREP_NAME
PGREP_NAME="${PGREP_NAME:-$SERVICE_NAME}"

read -p "Comando a ejecutar (default: $SERVICE_NAME): " COMMAND
COMMAND="${COMMAND:-$SERVICE_NAME}"

read -p "Delay en segundos antes de iniciar (default: 0): " DELAY
DELAY="${DELAY:-0}"

read -p "Argumentos extra: " EXTRA_ARGS

SEPARATOR=$(printf '%.0s─' $(seq 1 50))

if [ "$DELAY" -gt 0 ]; then
  BLOCK=$(cat <<EOF

# ── $SERVICE_NAME ────────────────────────────────────────────
if ! pgrep -x "$PGREP_NAME" >/dev/null; then
  (sleep $DELAY && exec $COMMAND $EXTRA_ARGS) &
  echo "[\$(date)] $SERVICE_NAME iniciado"
fi
EOF
)
else
  BLOCK=$(cat <<EOF

# ── $SERVICE_NAME ────────────────────────────────────────────
if ! pgrep -x "$PGREP_NAME" >/dev/null; then
  $COMMAND $EXTRA_ARGS &
  echo "[\$(date)] $SERVICE_NAME iniciado"
fi
EOF
)
fi

echo "$BLOCK" >> "$AUTOSTART"

echo ""
echo " Servicio '$SERVICE_NAME' agregado a autostart.sh"
echo " Log: /tmp/sway-autostart.log"
echo ""
echo " Para probarlo: bash ~/.config/sway/scripts/start-services.sh"
