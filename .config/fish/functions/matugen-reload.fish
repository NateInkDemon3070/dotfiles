function matugen-reload --description "Recargar colores matugen con el wallpaper actual"
    set -l WALLPAPER (cat ~/.cache/wal/wal)

    if not test -f "$WALLPAPER"
        echo "No se encontró wallpaper en ~/.cache/wal/wal"
        return 1
    end

    set -l SCHEME (~/.config/sway/scripts/detect-scheme.sh "$WALLPAPER")

    pkill -f "matugen image" 2>/dev/null

    matugen image "$WALLPAPER" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q

    bash "$HOME/.config/matugen/scripts/set-papirus-color.sh" 2>/dev/null

    pkill -USR1 thunar 2>/dev/null
    pkill -USR1 nautilus 2>/dev/null
    pkill -USR1 -x kitty 2>/dev/null

    echo "Colores recargados con matugen"
end
