#!/usr/bin/env bash
# Genera la cache de colores de matugen (~/.cache/wal) que consumen waybar,
# eww, rofi, kitty, etc. Sirve para dejar funcionando un clon/dispositivo nuevo.
#
# Uso:
#   gen-cache.sh                  # usa el wallpaper actual o uno de ~/Wallpapers
#   gen-cache.sh /ruta/imagen     # usa esa imagen
set -u

CACHE="$HOME/.cache/wal"
CFG="$HOME/.config/matugen/config.toml"
DETECT="$HOME/.config/mango/scripts/detect-scheme.sh"
WAL_FILE="$CACHE/wal"

wallpaper="${1:-}"

# 1) ultimo wallpaper usado
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    [ -f "$WAL_FILE" ] && wallpaper="$(cat "$WAL_FILE" 2>/dev/null)"
fi
# 2) copia en la cache de wallpaper
if [ -z "${wallpaper:-}" ] || [ ! -f "$wallpaper" ]; then
    [ -f "$HOME/.cache/wallpaper/current" ] && wallpaper="$HOME/.cache/wallpaper/current"
fi
# 3) cualquiera de ~/Wallpapers o del repo
if [ -z "${wallpaper:-}" ] || [ ! -f "$wallpaper" ]; then
    for d in "$HOME/Wallpapers" "$HOME/dotfiles/Wallpapers"; do
        [ -d "$d" ] || continue
        wallpaper="$(find "$d" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)"
        [ -n "$wallpaper" ] && break
    done
fi

if [ -z "${wallpaper:-}" ] || [ ! -f "$wallpaper" ]; then
    echo "gen-cache: no encontre ningun wallpaper" >&2
    exit 1
fi
if ! command -v matugen >/dev/null 2>&1; then
    echo "gen-cache: matugen no esta instalado" >&2
    exit 1
fi
if [ ! -f "$CFG" ]; then
    echo "gen-cache: falta $CFG" >&2
    exit 1
fi

mkdir -p "$CACHE"
printf '%s\n' "$wallpaper" > "$WAL_FILE"

# gtk4: si gtk.css es symlink a /usr/share, escribir da permission denied
for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
    if [ -L "$f" ]; then
        rm -f "$f"
        touch "$f"
    fi
done

# esquema segun saturacion de la imagen (neutral para B/N, fidelity para color)
scheme="scheme-fidelity"
if [ -x "$DETECT" ]; then
    scheme="$("$DETECT" "$wallpaper" 2>/dev/null)"
    [ -z "$scheme" ] && scheme="scheme-fidelity"
fi

pkill -f "matugen image" 2>/dev/null

matugen image "$wallpaper" -c "$CFG" --type "$scheme" -q
rc=$?

# recargas opcionales (no fallan si la app no esta corriendo)
pkill -SIGUSR2 waybar 2>/dev/null

if [ "$rc" -eq 0 ]; then
    echo "gen-cache: colores generados desde $wallpaper ($scheme)"
fi
exit "$rc"
