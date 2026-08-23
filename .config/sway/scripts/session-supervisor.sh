#!/bin/bash
# Arranca el supervisor de servicios de usuario (runsvdir) garantizando que
# solo exista UNO. Mata los supervisores huérfanos de sesiones anteriores
# (que quedan vivos al cerrar sway y causan servicios duplicados/conflictos)
# y espera a que terminen antes de iniciar el nuestro.
#
# Se ejecuta desde el config de sway en lugar de `exec runsvdir ...`.

# Sesión D-Bus estándar: exporta la dirección del bus y garantiza que el
# daemon esté corriendo en /run/user/<uid>/bus (sin systemd no lo arranca nadie).
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

if [ ! -S "/run/user/$(id -u)/bus" ]; then
  dbus-daemon --session --fork --address="unix:path=/run/user/$(id -u)/bus" --print-pid=1 --print-address=1 >/dev/null 2>&1
fi
dbus-update-activation-environment DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" XDG_SESSION_TYPE=wayland 2>/dev/null || true

for old in $(pgrep -f "runsvdir /home/jpablo/.config/runit/sv"); do
  kill "$old" 2>/dev/null
done

for i in 1 2 3 4 5 6 7 8 9 10; do
  [ -z "$(pgrep -f "runsvdir /home/jpablo/.config/runit/sv")" ] && break
  sleep 1
done

exec runsvdir /home/jpablo/.config/runit/sv
