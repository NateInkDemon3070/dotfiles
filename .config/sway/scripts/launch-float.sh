#!/bin/bash
# Lanza una aplicación como ventana flotante en Sway
case "$1" in
  kitty)
    exec kitty --class floating_tui "${@:2}" ;;
  blueman-manager)
    # asegura que el applet esté corriendo y mata el tray
    pgrep -x blueman-applet >/dev/null || blueman-applet &
    killall -q blueman-tray 2>/dev/null
    exec blueman-manager ;;
  *)
    exec "$@" ;;
esac
