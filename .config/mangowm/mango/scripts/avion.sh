#!/usr/bin/env bash
set -euo pipefail

SERVICES=(NetworkManager dhcpcd wpa_supplicant bluetoothd)

case "${1:-off}" in
  off|on)
    action="$1"
    ;;
  *)
    echo "Uso: avion {off|on}"
    echo "  off  — Desactiva WiFi, Bluetooth y servicios de red"
    echo "  on   — Reactiva todo"
    exit 1
    ;;
esac

case "$action" in
  off)
    echo "[*] Modo avión ACTIVADO"
    doas rfkill block wifi
    doas rfkill block bluetooth
    for s in "${SERVICES[@]}"; do
      doas sv down "$s" 2>/dev/null || true
    done
    echo "[✓] Servicios detenidos: ${SERVICES[*]}"
    ;;
  on)
    echo "[*] Modo avión DESACTIVADO"
    doas rfkill unblock wifi
    doas rfkill unblock bluetooth
    for s in "${SERVICES[@]}"; do
      doas sv up "$s" 2>/dev/null || true
    done
    echo "[✓] Servicios iniciados: ${SERVICES[*]}"
    ;;
esac
