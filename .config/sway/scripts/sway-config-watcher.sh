#!/bin/bash
# Matar watchers previos para evitar acumulación en cada reload de sway
pkill -f "sway-config-watcher.sh" 2>/dev/null

CONFIG="$HOME/.config/sway/config"

while true; do
    inotifywait -e close_write -q "$CONFIG" >/dev/null 2>&1
    sleep 0.3
    swaymsg reload 2>/dev/null
done
