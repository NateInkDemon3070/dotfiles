#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/home/jpablo/.config/mango/scripts"

maximo="󰈐 Ahorro Máximo"
medio=" Ahorro Medio"
avion=" Modo Avión"
normal=" Estado Normal"

selected=$(echo -e "$maximo\n$medio\n$avion\n$normal" | fuzzel --dmenu --cache=/dev/null --prompt="Perfil de Energía   " --placeholder="Buscar perfil..." --lines=4)

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
