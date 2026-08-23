#!/usr/bin/env bash
set -euo pipefail

shutdown="󰐥 Apagar"
reboot="󰜉 Reiniciar"
lock="󰌾 Bloquear"
suspend_usb="󰂄 Suspensión USB"
hibernate="󰒲 Hibernar"
logout="󰍃 Cerrar Sesión"
profiles=" Perfiles"

selected=$(echo -e "$lock\n$suspend_usb\n$hibernate\n$logout\n$reboot\n$shutdown\n$profiles" | rofi -dmenu -i -p "Menú de Sistema" -theme ~/.config/rofi/config.rasi)

case "$selected" in
"$shutdown") loginctl poweroff ;;
"$reboot") loginctl reboot ;;
"$lock") swaylock ;;
"$hibernate")
  swaylock &
  sleep 1
  loginctl hibernate
  ;;
"$logout") swaymsg exit ;;
"$suspend_usb") bash /home/jpablo/.config/sway/scripts/suspension-usb.sh ;;
"$profiles") bash /home/jpablo/.config/sway/scripts/profiles.sh ;;
esac
