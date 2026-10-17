#!/bin/bash

LAUNCHER="$HOME/.config/waybar/scripts/launch-waybar.sh"

if pgrep -x waybar >/dev/null; then
    pkill -TERM -x waybar 2>/dev/null || true
    for _ in $(seq 1 30); do
        pgrep -x waybar >/dev/null || break
        sleep 0.02
    done
    pgrep -x waybar | xargs -r kill -9 2>/dev/null || true
else
    bash "$LAUNCHER"
fi
