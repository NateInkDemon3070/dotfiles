#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/home/jpablo/.config/sway/scripts"

maximo="󰈐 Ahorro Máximo"
medio=" Ahorro Medio"
avion=" Modo Avión"
normal=" Estado Normal"

selected=$(echo -e "$maximo\n$medio\n$avion\n$normal" | rofi -dmenu -i -p "Perfil de Energía" -theme ~/.config/rofi/config.rasi)

case "$selected" in
"$maximo")
  bash "$SCRIPT_DIR/ahorro-maximo.sh"
  ;;
"$medio")
  bash "$SCRIPT_DIR/ahorro-medio.sh"
  ;;
"$avion")
  bash "$SCRIPT_DIR/avion.sh" off
  ;;
"$normal")
  bash "$SCRIPT_DIR/normal.sh"
  ;;
esac
