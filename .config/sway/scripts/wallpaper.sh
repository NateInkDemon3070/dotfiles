#!/bin/bash

TRANSITION_STEP=30
WALLPAPER=$(find ~/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

ensure_awww() {
  if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    disown
    for _ in $(seq 1 20); do
      awww query >/dev/null 2>&1 && break
      sleep 0.1
    done
  fi
}

if [ -f "$WALLPAPER" ]; then
  ensure_awww
  awww img --transition-step "$TRANSITION_STEP" "$WALLPAPER"

  echo "$WALLPAPER" > "$HOME/.cache/wal/wal"
  for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
    [ -L "$f" ] && rm -f "$f" && touch "$f"
  done
  SCHEME=$(~/.config/sway/scripts/detect-scheme.sh "$WALLPAPER")
  pkill -f "matugen image" 2>/dev/null
  matugen image "$WALLPAPER" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q
  # Recargar GTK
  for app in thunar nautilus; do pkill -USR1 "$app" 2>/dev/null; done
  pkill -USR1 -x kitty 2>/dev/null
  echo "Wallpaper aplicado con awww: $(basename "$WALLPAPER")"
else
  echo "Error: No encontré imágenes"
  exit 1
fi
