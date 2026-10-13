#!/bin/bash
# gamma.sh <preset>  -- aplica un perfil de gamma/contraste al monitor via
# wlr-gamma-control-v1. Reemplaza el perfil anterior.
# El proceso mangogamma queda en background manteniendo la rampa viva;
# al morir, el compositor restaura la tabla original (neutral).

PRESETS="neutral soft warm cool night bright crisp"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/mangogamma"
mkdir -p "$STATE_DIR"
FADE="${MANGOGAMMA_FADE:-400}"
BIN="$HOME/.local/bin/mangogamma"
[ -x "$BIN" ] || BIN=$(command -v mangogamma 2>/dev/null)

notify() {
  command -v swayosd-client >/dev/null 2>&1 && \
    swayosd-client --custom "Gamma: $1" --position 5 >/dev/null 2>&1 && return 0
  command -v notify-send >/dev/null 2>&1 && notify-send "Gamma" "$1" >/dev/null 2>&1
}

valid() {
  local p
  for p in $PRESETS; do
    [ "$p" = "$1" ] && return 0
  done
  return 1
}

# mata el perfil anterior (con contador y timeout para no quedar colgado)
if [ -f "$STATE_DIR/pid" ]; then
  oldpid=$(cat "$STATE_DIR/pid" 2>/dev/null)
  if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      kill -0 "$oldpid" 2>/dev/null || break
      sleep 0.05
    done
    kill -9 "$oldpid" 2>/dev/null
    sleep 0.1
  fi
  rm -f "$STATE_DIR/pid"
fi

preset="${1:-neutral}"

if [ "$preset" = "off" ] || [ "$preset" = "reset" ]; then
  rm -f "$STATE_HOME/last"
  echo "mangogamma: tabla restaurada a neutro"
  exit 0
fi

STATE_HOME="$HOME/.local/state/mangogamma"
mkdir -p "$STATE_HOME"

if [ "$preset" = "toggle" ]; then
  last=$(cat "$STATE_HOME/last" 2>/dev/null || echo soft)
  [ "$last" = "soft" ] && preset="neutral" || preset="soft"
fi

if ! valid "$preset"; then
  echo "uso: gamma.sh <$PRESETS|off|toggle>" >&2
  exit 1
fi

nohup "$BIN" "$preset" --fade "$FADE" >"$STATE_DIR/log" 2>&1 &
echo $! > "$STATE_DIR/pid"
echo "$preset" > "$STATE_HOME/last"

# espera breve para detectar fallos del compositor
sleep 0.3
if ! kill -0 "$(cat "$STATE_DIR/pid")" 2>/dev/null; then
  cat "$STATE_DIR/log" >&2
  exit 1
fi

notify "$preset"