#!/bin/bash
# Vigila el config del mango y el colors-mango-border (matugen); al cambiar,
# regenera los colores de mango y recarga.
for p in $(pgrep -f "mango-config-watcher.sh"); do
    [ "$p" != "$$" ] && kill "$p" 2>/dev/null
done

CONFIG="$HOME/.config/mango/config.conf"
WAL="$HOME/.cache/wal/colors-mango-border"
GEN="$(dirname "$0")/gen-colors.sh"

# generar colores al arranque (por si matugen ya corrió)
bash "$GEN" 2>/dev/null

while true; do
    inotifywait -e close_write -q "$CONFIG" "$WAL" >/dev/null 2>&1
    sleep 0.3
    bash "$GEN" 2>/dev/null
    mmsg dispatch reload_config 2>/dev/null
done