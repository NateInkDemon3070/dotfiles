#!/usr/bin/env bash
set -u

conf="$HOME/.cache/wal/colors-kitty.conf"
[ -f "$conf" ] || exit 0

for sock in /tmp/kitty-*; do
    if [ ! -S "$sock" ] || [ ! -O "$sock" ]; then continue; fi
    timeout 3 /usr/bin/kitty @ --to "unix:$sock" set-colors --all --configured "$conf" >/dev/null 2>&1 || true
done

timeout 5 pkill -USR1 -x kitty >/dev/null 2>&1 || true
