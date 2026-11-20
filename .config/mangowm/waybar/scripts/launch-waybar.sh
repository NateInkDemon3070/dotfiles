#!/bin/bash

CONFIG_DIR="/home/jpablo/.config/waybar"
STATE_FILE="$CONFIG_DIR/scripts/.current_bar"

if [ -s "$STATE_FILE" ]; then
    CURRENT=$(cat "$STATE_FILE")
else
    CURRENT=1
    echo "$CURRENT" > "$STATE_FILE"
fi

case "$CURRENT" in
    2) CFG="$CONFIG_DIR/config_alt.jsonc"  ; CSS="$CONFIG_DIR/style_alt.css" ;;
    3) CFG="$CONFIG_DIR/config_side.jsonc" ; CSS="$CONFIG_DIR/style_side.css" ;;
    4) CFG="$CONFIG_DIR/config_win.jsonc"  ; CSS="$CONFIG_DIR/style_solid.css" ;;
    *) CFG="$CONFIG_DIR/config.jsonc"      ; CSS="$CONFIG_DIR/style.css" ;;
esac

nohup setsid waybar -c "$CFG" -s "$CSS" >/dev/null 2>&1 &
disown