#!/bin/bash

CONFIG_DIR="/home/jpablo/.config/waybar"
STATE_FILE="$CONFIG_DIR/scripts/.current_bar"
SERVICE="$HOME/.config/runit/sv/waybar"

if [ "$1" == "random" ]; then
    NEXT=$(( ( RANDOM % 4 ) + 1 ))
    echo "$NEXT" > "$STATE_FILE"
    sv restart "$SERVICE" 2>/dev/null || true
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

sv restart "$SERVICE" 2>/dev/null || true
