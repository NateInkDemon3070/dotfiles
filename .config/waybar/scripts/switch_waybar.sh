#!/bin/bash

CONFIG_DIR="/home/jpablo/.config/waybar"
STATE_FILE="$CONFIG_DIR/scripts/.current_bar"

if [ "$1" == "random" ]; then
    NEXT=$(( ( RANDOM % 4 ) + 1 ))
    echo "$NEXT" > "$STATE_FILE"
    case $NEXT in
        1) waybar -c "$CONFIG_DIR/config_alt.jsonc" -s "$CONFIG_DIR/style_alt.css" &>/dev/null &
        ;;
        2) waybar -c "$CONFIG_DIR/config_win.jsonc" -s "$CONFIG_DIR/style_solid.css" &>/dev/null &
        ;;
        3) waybar -c "$CONFIG_DIR/config.jsonc" -s "$CONFIG_DIR/style.css" &>/dev/null &
        ;;
        4) waybar -c "$CONFIG_DIR/config_side.jsonc" -s "$CONFIG_DIR/style_side.css" &>/dev/null &
        ;;
    esac
    disown
    exit 0
fi

if [ ! -s "$STATE_FILE" ]; then
    echo "1" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

case $CURRENT in
    1) NEXT=2 ;;
    2) NEXT=3 ;;
    3) NEXT=4 ;;
    4) NEXT=1 ;;
    *) NEXT=1 ;;
esac

echo "$NEXT" > "$STATE_FILE"

pkill -x waybar 2>/dev/null
for i in $(seq 1 20); do
    pgrep -x waybar >/dev/null || break
    sleep 0.05
done

case $NEXT in
    1) waybar -c "$CONFIG_DIR/config_alt.jsonc" -s "$CONFIG_DIR/style_alt.css" &>/dev/null &
    ;;
    2) waybar -c "$CONFIG_DIR/config_win.jsonc" -s "$CONFIG_DIR/style_solid.css" &>/dev/null &
    ;;
    3) waybar -c "$CONFIG_DIR/config.jsonc" -s "$CONFIG_DIR/style.css" &>/dev/null &
    ;;
    4) waybar -c "$CONFIG_DIR/config_side.jsonc" -s "$CONFIG_DIR/style_side.css" &>/dev/null &
    ;;
esac

disown
