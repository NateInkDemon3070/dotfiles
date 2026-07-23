#!/bin/bash

WALLPAPER=$(find ~/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

if [ -f "$WALLPAPER" ]; then
  killall swaybg 2>/dev/null
  swaybg -i "$WALLPAPER" -m fill &

  sleep 0.3
  echo "$WALLPAPER" > "$HOME/.cache/wal/wal"
  for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
    [ -L "$f" ] && rm -f "$f" && touch "$f"
  done
  SCHEME=$(~/.config/sway/scripts/detect-scheme.sh "$WALLPAPER")
  pkill -f "matugen image" 2>/dev/null
  matugen image "$WALLPAPER" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q
  bash "$HOME/.config/matugen/scripts/set-papirus-color.sh" 2>/dev/null
  # Recargar GTK
  for app in thunar nautilus kitty; do pkill -USR1 "$app" 2>/dev/null; done
  echo "Wallpaper aplicado con swaybg: $(basename "$WALLPAPER")"
else
  echo "Error: No encontré imágenes"
  exit 1
fi
