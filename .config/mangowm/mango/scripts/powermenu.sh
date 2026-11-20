#!/usr/bin/env bash
set -euo pipefail

shutdown="󰐥 Apagar"
reboot="󰜉 Reiniciar"
lock="󰌾 Bloquear"
suspend_usb="󰂄 Suspensión USB"
hibernate="󰒲 Hibernar"
logout="󰍃 Cerrar Sesión"
profiles=" Perfiles"

selected=$(echo -e "$lock\n$suspend_usb\n$hibernate\n$logout\n$reboot\n$shutdown\n$profiles" | fuzzel --dmenu --cache=/dev/null --prompt="Menú de Sistema   " --placeholder="Buscar opción..." --lines=7)

case "$selected" in
"$shutdown") loginctl poweroff ;;
"$reboot") loginctl reboot ;;
"$lock") hyprlock ;;
"$hibernate")
  hyprlock &
  sleep 1
  loginctl hibernate
  ;;
"$logout")
  # Detener los servicios de usuario de forma ordenada: SIGTERM al runsvdir,
  # que apaga todos los servicios (pipewire, wireplumber, mpd, etc.) y sale.
  old=$(pgrep -f '^runsvdir /home/jpablo/.config/runit/sv')
  [ -n "$old" ] && kill $old 2>/dev/null
  for _ in $(seq 1 15); do
    pgrep -f '^runsvdir /home/jpablo/.config/runit/sv' >/dev/null || break
    sleep 1
  done
  pkill mango
  ;;
"$suspend_usb") bash /home/jpablo/.config/mango/scripts/suspension-usb.sh ;;
"$profiles") bash /home/jpablo/.config/mango/scripts/profiles.sh ;;
esac
