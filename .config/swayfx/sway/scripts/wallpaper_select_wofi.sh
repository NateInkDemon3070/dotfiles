#!/usr/bin/env bash

if pgrep -x wofi >/dev/null; then
  pkill wofi
fi

wallpapers_dir="$HOME/Wallpapers"

TRANSITION_STEP=30

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Configuración de Wofi
cat >"$tmpdir/config" <<'EOF'
width=75%
height=70%
allow_markup=true
allow_images=true
insensitive=true
location=center
halign=fill
valign=fill
filter_rate=100
EOF

# Estilos CSS
cat >"$tmpdir/style.css" <<'EOF'
@import url("file:///home/jpablo/.cache/wal/colors-waybar.css");

window {
    background-color: rgba(15, 17, 20, 0.85);
    border: 2px solid @color4;
    border-radius: 0px;
    font-family: "Terminess Nerd Font";
    font-size: 11px;
}

#outer-box {
    padding: 20px;
    background-color: transparent;
}

#input {
    background-color: rgba(255, 255, 255, 0.05);
    border: none;
    border-radius: 0px;
    padding: 15px;
    color: @foreground;
    margin-bottom: 20px;
}

#scroll {
    background-color: transparent;
    margin: 10px;
}

#inner-box {
    background-color: transparent;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
}

#entry {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 15px;
    border: 2px solid transparent;
    border-radius: 0px;
    width: 28%;
    margin-bottom: 20px;
    background-color: transparent;
    color: @foreground;
}

#entry:selected {
    background-color: rgba(255, 255, 255, 0.05);
    border: 2px solid @color4;
}

#entry image {
    margin-bottom: 10px;
}

#entry label {
    margin-top: 10px;
    color: inherit;
    font-weight: bold;
    text-align: center;
}
EOF

# Generar la lista dinámicamente recorriendo cada archivo de tu carpeta de wallpapers
selected_line=$(for a in "$wallpapers_dir"/*; do
  # Comprobamos que sea un archivo de imagen válido antes de agregarlo
  if [ -f "$a" ]; then
    name=$(basename "${a%.*}")
    # Generamos la estructura que wofi interpretará: Imagen arriba y Nombre abajo
    echo -e "<img src='$a' width='220' height='140'/>\n$name"
  fi
done | wofi --show dmenu -p "Buscar..." \
  -c "$tmpdir/config" \
  -s "$tmpdir/style.css" \
  --columns 3)

[ -z "$selected_line" ] && exit 0

# Limpiamos las etiquetas HTML para extraer únicamente el nombre del archivo seleccionado
selected_wallpaper=$(echo "$selected_line" | sed -e 's/<[^>]*>//g' | xargs)

image_fullname_path=$(find "$wallpapers_dir" -type f -name "$selected_wallpaper.*" | head -n 1)

if ! awww query >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  disown
  for _ in $(seq 1 20); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
  done
fi
awww img --transition-step "$TRANSITION_STEP" "$image_fullname_path"

echo "$image_fullname_path" >"$HOME/.cache/wal/wal"
for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
  [ -L "$f" ] && rm -f "$f" && touch "$f"
done
SCHEME=$(~/.config/sway/scripts/detect-scheme.sh "$image_fullname_path")
pkill -f "matugen image" 2>/dev/null
matugen image "$image_fullname_path" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q

echo "Aplicado: $(basename "$image_fullname_path")"
