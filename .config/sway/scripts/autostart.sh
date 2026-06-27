#!/bin/bash
exec >>/tmp/sway-autostart.log 2>&1
echo "[$(date)] === INICIO AUTOSTART ==="

source ~/.profile 2>/dev/null || true

# Iniciar sesión D-Bus única si no existe
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --exit-with-session --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
  export DBUS_SESSION_BUS_PID
  dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Sway XCURSOR_THEME XCURSOR_SIZE
fi
# Guardar dirección para wrappers
echo "$DBUS_SESSION_BUS_ADDRESS" >/tmp/sway-dbus-address
echo "[$(date)] D-Bus session: $DBUS_SESSION_BUS_ADDRESS"

# ── Waybar ───────────────────────────────────────────────────────
if ! pgrep -x "waybar" >/dev/null; then
  waybar &
  echo "[$(date)] waybar iniciado"
fi

# ── swaync (una sola instancia) ──────────────────────────────────
for pid in $(pgrep -x swaync); do
  [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null && sleep 0.3
done
swaync &
echo "[$(date)] swaync iniciado"

# ── swayosd ──────────────────────────────────────────────────────
if ! pgrep -x "swayosd-server" >/dev/null; then
  /usr/bin/swayosd-server -s /home/jpablo/.config/swayosd/style.css >/dev/null 2>&1 &
  echo "[$(date)] swayosd-server iniciado"
fi

# ── keep-mpd-active (mantiene mpd como player activo en MPRIS) ──
if ! pgrep -f "keep-mpd-active.sh" >/dev/null; then
  nohup /home/jpablo/.config/sway/scripts/keep-mpd-active.sh >/dev/null 2>&1 &
  echo "[$(date)] keep-mpd-active iniciado"
fi

# ── mpd-notify (notificación al cambiar de canción) ──────────────
if ! pgrep -f "mpd-notify.sh" >/dev/null; then
  nohup /home/jpablo/.config/sway/scripts/mpd-notify.sh >/dev/null 2>&1 &
  echo "[$(date)] mpd-notify iniciado"
fi

# ── wallpaper (aleatorio + matugen) ──────────────────────────────
echo "[$(date)] Ejecutando wallpaper.sh..."
sleep 1
~/.config/sway/scripts/wallpaper.sh
echo "[$(date)] wallpaper.sh listo"

# ── udiskie ──────────────────────────────────────────────────────
(sleep 1 && exec udiskie) &
echo "[$(date)] udiskie programado"

# ── nm-applet (solo si está instalado) ──────────────────────────
if command -v nm-applet >/dev/null; then
  (sleep 2 && exec nm-applet --indicator) &
  echo "[$(date)] nm-applet programado"
fi

# ── cliphist ─────────────────────────────────────────────────────
if ! pgrep -f "wl-paste.*cliphist.*store" >/dev/null; then
  wl-paste --type text --watch cliphist store &
  wl-paste --type image --watch cliphist store &
  echo "[$(date)] cliphist iniciado"
fi

echo "[$(date)] === AUTOSTART COMPLETADO ==="
