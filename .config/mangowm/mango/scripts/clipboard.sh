#!/usr/bin/env bash
set -uo pipefail

selected=$(cliphist list | fuzzel --dmenu --cache=/dev/null \
  --prompt="Portapapeles   " --placeholder="Buscar en el portapapeles..." \
  --with-nth=2) || exit 0

[ -n "$selected" ] || exit 0

printf '%s' "$selected" | cliphist decode | wl-copy
