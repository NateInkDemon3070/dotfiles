#!/bin/bash
# Regenera ~/.config/mango/colors.conf a partir de colors-mango-border de matugen
SRC="$HOME/.cache/wal/colors-mango-border"
OUT="$HOME/.config/mango/colors.conf"
[ -f "$SRC" ] || exit 0

hex() { printf '0x%sff\n' "${1#\#}"; }

focused=$(awk '/^client.focused /{print $2}' "$SRC")
unfocused=$(awk '/^client.unfocused /{print $2}' "$SRC")
urgent=$(awk '/^client.urgent /{print $2}' "$SRC")

[ -n "$focused" ] && [ -n "$unfocused" ] && [ -n "$urgent" ] || exit 0

cat > "$OUT" <<EOF
# generado por gen-colors.sh desde colors-mango-border (matugen)
focus_color=$(hex "$focused")
border_color=$(hex "$unfocused")
urgent_color=$(hex "$urgent")
EOF