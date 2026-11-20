#!/bin/bash
# Reinicia los portales xdg y garantiza que el watcher SNI (bandeja) esté disponible.
# Log: ~/.local/state/mango/portals.log
LOG_DIR="$HOME/.local/state/mango"
LOG="$LOG_DIR/portals.log"
mkdir -p "$LOG_DIR"

sni_ready() {
  busctl --user list --no-pager 2>/dev/null | grep -q org.kde.StatusNotifierWatcher
}

{
  echo "=== [$(date)] reiniciando portales ==="

  pkill -f '/usr/lib/xdg-desktop-portal'
  sleep 1
  setsid /usr/lib/xdg-desktop-portal        >>"$LOG" 2>&1 &
  setsid /usr/lib/xdg-desktop-portal-wlr    >>"$LOG" 2>&1 &
  setsid /usr/lib/xdg-desktop-portal-gtk    >>"$LOG" 2>&1 &
  sleep 1.5

  echo "portal=$(pgrep -f '/usr/lib/xdg-desktop-portal$' || echo NO)"
  echo "portal-wlr=$(pgrep -f 'xdg-desktop-portal-wlr' || echo NO)"
  echo "portal-gtk=$(pgrep -f 'xdg-desktop-portal-gtk' || echo NO)"

  # El watcher SNI lo provee el módulo tray de waybar. Sin él, las apps
  # Electron/Chromium no registran su icono de bandeja (sólo lo hacen al
  # arrancar), así que lo comprobamos y relanzamos waybar si falta.
  if ! sni_ready; then
    echo "watcher SNI ausente -> relanzando waybar"
    pkill -TERM -x waybar 2>/dev/null || true
    sleep 1
    bash "$HOME/.config/waybar/scripts/launch-waybar.sh"
    for i in $(seq 1 40); do
      sni_ready && break
      sleep 0.25
    done
  fi
  echo "watcher SNI=$(sni_ready && echo OK || echo NO)"

  echo "=== fin ==="
} >>"$LOG" 2>&1

tail -8 "$LOG"
