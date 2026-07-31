#!/usr/bin/env bash
set -euo pipefail

shutdown="󰐥 Apagar"
reboot="󰜉 Reiniciar"
lock="󰌾 Bloquear"
suspend="󰤄 Suspender"
logout="󰍃 Cerrar Sesión"
profiles=" Perfiles"

selected=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown\n$profiles" | rofi -dmenu -i -p "Menú de Sistema" -theme ~/.config/rofi/config.rasi)

case "$selected" in
"$shutdown") loginctl poweroff ;;
"$reboot") loginctl reboot ;;
"$lock") swaylock ;;
"$suspend")
  swaylock &
  sleep 1
  loginctl suspend
  ;;
"$logout") swaymsg exit ;;
"$profiles") bash /home/jpablo/.config/sway/scripts/profiles.sh ;;
esac
