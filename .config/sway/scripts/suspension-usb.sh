#!/usr/bin/env bash
set -euo pipefail

# Suspensión ligera (s2idle) para mantener los puertos USB energizados
# y poder cargar el celular mientras el sistema "duerme".

echo "[*] Modo suspensión USB"

state="/tmp/usb-charge-state.txt"
: > "$state"

# Fijar los puertos USB en "on" (sin autosuspend) guardando el estado previo
for dev in /sys/bus/usb/devices/*/power/control; do
  if [[ -r "$dev" ]]; then
    echo "$dev $(cat "$dev")" >> "$state"
    echo on | doas tee "$dev" >/dev/null 2>&1 || true
  fi
done

# Bloquear pantalla y apagar el monitor para ahorrar energía
swaylock &
sleep 1
swaymsg output "*" dpms off 2>/dev/null || true

# Suspender con s2idle: la CPU duerme pero el chipset y los puertos USB siguen activos
if ! echo freeze | doas tee /sys/power/state >/dev/null 2>&1; then
  loginctl suspend
fi

# Al despertar: restaurar monitor y estado previo de los puertos
sleep 2
swaymsg output "*" dpms on 2>/dev/null || true

while read -r dev val; do
  if [[ -f "$dev" ]]; then
    echo "$val" | doas tee "$dev" >/dev/null 2>&1 || true
  fi
done < "$state"
rm -f "$state"

echo "[✓] Modo suspensión USB finalizado"
