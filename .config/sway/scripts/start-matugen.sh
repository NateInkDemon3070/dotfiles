#!/bin/bash

WALLPAPER_FILE="$HOME/.cache/wal/wal"

if [[ -f "$WALLPAPER_FILE" ]]; then
  WALLPAPER=$(cat "$WALLPAPER_FILE")
  if [[ -f "$WALLPAPER" ]]; then
    # GTK4 theme lo crea como symlink a /usr/share/themes/ → Permission denied
    for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
      [ -L "$f" ] && rm -f "$f" && touch "$f"
    done

    SCHEME=$(~/.config/sway/scripts/detect-scheme.sh "$WALLPAPER")
    pkill -f "matugen image" 2>/dev/null
    /usr/bin/matugen image "$WALLPAPER" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q
  fi
fi
