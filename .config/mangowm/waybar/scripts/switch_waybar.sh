#!/bin/bash

CONFIG_DIR="/home/jpablo/.config/waybar"
STATE_FILE="$CONFIG_DIR/scripts/.current_bar"
LAUNCHER="$CONFIG_DIR/scripts/launch-waybar.sh"

if [ "$1" == "random" ]; then
    echo $(( ( RANDOM % 4 ) + 1 )) > "$STATE_FILE"
    pkill -TERM -x waybar 2>/dev/null || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -x waybar >/dev/null || break
        sleep 0.02
    done
    pgrep -x waybar | xargs -r kill -9 2>/dev/null || true
    bash "$LAUNCHER"
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

pkill -TERM -x waybar 2>/dev/null || true
for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -x waybar >/dev/null || break
    sleep 0.02
done
pgrep -x waybar | xargs -r kill -9 2>/dev/null || true
bash "$LAUNCHER"