#!/bin/bash
set -u

WALL="${1:-}"

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
  if command -v awww >/dev/null 2>&1; then
    WALL=$(awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n1)
  fi
fi

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
  [ -f "$HOME/.cache/wal/wal" ] && WALL=$(cat "$HOME/.cache/wal/wal")
fi

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
  WALL="$HOME/.cache/wallpaper/current"
fi

[ -f "$WALL" ] || exit 1

DEST=/var/cache/sddm/wallpaper
mkdir -p "$(dirname "$DEST")" 2>/dev/null || true

cp -f "$WALL" "$DEST" 2>/dev/null || exit 0
chmod 644 "$DEST" 2>/dev/null || true

echo "Fondo de SDDM actualizado: $WALL"
