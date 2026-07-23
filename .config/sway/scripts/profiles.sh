#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/home/jpablo/.config/sway/scripts"

maximo="󰈐 Ahorro Máximo"
medio=" Ahorro Medio"
avion=" Modo Avión"
normal=" Estado Normal"

selected=$(echo -e "$maximo\n$medio\n$avion\n$normal" | wofi --dmenu -i -p "Perfil de Energía" --style ~/.cache/wal/colors-wofi.css)

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
