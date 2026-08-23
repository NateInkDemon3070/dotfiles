#!/bin/bash
# Sincroniza la config de fastfetch hacia la plantilla de matugen:
# cada cambio en ~/.config/fastfetch/config.jsonc se copia a
# ~/.config/matugen/templates/fastfetch.jsonc, restaurando los
# placeholders {{colors.*}} en los valores de color.

CONFIG="$HOME/.config/fastfetch/config.jsonc"
DIR="$(dirname "$CONFIG")"
TEMPLATE="$HOME/.config/matugen/templates/fastfetch.jsonc"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

sync_template() {
  sed -E \
    -e 's/^([[:space:]]*"1-2":[[:space:]]*)"[^"]*"/\1"{{colors.primary.default.hex}}"/' \
    -e 's/^([[:space:]]*"3-4":[[:space:]]*)"[^"]*"/\1"{{colors.secondary.default.hex}}"/' \
    -e 's/^([[:space:]]*"5-6":[[:space:]]*)"[^"]*"/\1"{{colors.tertiary.default.hex}}"/' \
    -e 's/^([[:space:]]*"7-8":[[:space:]]*)"[^"]*"/\1"{{colors.primary.light.hex}}"/' \
    -e 's/^([[:space:]]*"9-13":[[:space:]]*)"[^"]*"/\1"{{colors.tertiary.light.hex}}"/' \
    -e 's/^([[:space:]]*"keys":[[:space:]]*)"[^"]*"/\1"{{colors.primary.default.hex}}"/' \
    -e 's/^([[:space:]]*"title":[[:space:]]*)"[^"]*"/\1"{{colors.on_surface.default.hex}}"/' \
    -e 's/^([[:space:]]*"separator":[[:space:]]*)"[^"]*"/\1"{{colors.outline.default.hex}}"/' \
    "$CONFIG" > "$TMP" 2>/dev/null || return

  # Solo escribir si hay cambios reales (evita escrituras inútiles)
  if ! cmp -s "$TMP" "$TEMPLATE"; then
    cp "$TMP" "$TEMPLATE"
    chmod 644 "$TEMPLATE"
  fi
}

sync_template

# Vigilar el directorio (y no el archivo) para sobrevivir a edits
# que reemplazan el archivo por rename (vim, etc.)
inotifywait -q -m -e close_write,moved_to --format '%w%f' "$DIR" | while read -r f; do
  [ "$f" = "$CONFIG" ] || continue
  sleep 0.2
  sync_template
done
