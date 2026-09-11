#!/bin/bash
exec >>/tmp/sway-autostart.log 2>&1
echo "[$(date)] === INICIO AUTOSTART ==="

source ~/.profile 2>/dev/null || true

# ── awww-daemon (wallpaper engine) ─────────────────────────────
# Arranca LO PRIMERO: restaura el último wallpaper desde el caché,
# para que el fondo aparezca antes que waybar y sin fondo negro.
if ! awww query >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  disown
  for _ in $(seq 1 20); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
  done
  echo "[$(date)] awww-daemon iniciado"
fi

# ── D-Bus: ya creado por session-supervisor.sh ───────────────────

# ── Portales xdg: activación temprana con backend wlr fijo ─────
# Evita que apps (OBS, etc.) activen el portal tarde con entorno raro
# y que xdg-desktop-portal elija un backend distinto de wlr.
if ! pgrep -x "xdg-desktop-portal-wlr" >/dev/null 2>&1; then
  dbus-send --session --type=method_call --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1 || true
fi
for i in $(seq 1 20); do
  pgrep -x "xdg-desktop-portal-wlr" >/dev/null 2>&1 && break
  sleep 0.25
done
echo "[$(date)] portal-wlr activo: $(pgrep -x xdg-desktop-portal-wlr || echo 'no')"

# ── Waybar (supervisado por runit; se reinicia solo si se cae) ──
sv up "$HOME/.config/runit/sv/waybar" 2>/dev/null || true

# ── swayosd (gestionado por runit) ───────────────────────────────

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

# ── xembedsniproxy (puente XEmbed → SNI para trays GTK/X11) ────
if ! pgrep -x "xembedsniproxy" >/dev/null; then
  /usr/local/bin/xembedsniproxy >/dev/null 2>&1 &
  disown
  echo "[$(date)] xembedsniproxy iniciado"
fi

# esperar a que reclame la selección de tray (solo con XWayland)
if [ -n "$DISPLAY" ]; then
  for i in $(seq 1 40); do
    if xprop -root _NET_SYSTEM_TRAY_S0 2>/dev/null | grep -q "window id"; then
      break
    fi
    sleep 0.25
  done
fi

# ── udiskie (automontaje, SIN tray) ─────────────────────────────
if ! pgrep -x "udiskie" >/dev/null; then
  udiskie &
  disown
  echo "[$(date)] udiskie programado (automontaje, sin tray)"
fi

# ── lxqt-policykit-agent ─────────────────────────────────────────
if ! pgrep -x "lxqt-policykit-agent" >/dev/null; then
  /usr/sbin/lxqt-policykit-agent &
  disown
  echo "[$(date)] lxqt-policykit-agent iniciado"
fi

# ── nm-applet (solo si está instalado) ──────────────────────────
if command -v nm-applet >/dev/null; then
  (env -u WAYLAND_DISPLAY GDK_BACKEND=x11 nm-applet --indicator) &
  disown
  echo "[$(date)] nm-applet programado"
fi

# ── cliphist ─────────────────────────────────────────────────────
if ! pgrep -f "wl-paste.*cliphist.*store" >/dev/null; then
  wl-paste --type text --watch cliphist store &
  disown
  wl-paste --type image --watch cliphist store &
  disown
  echo "[$(date)] cliphist iniciado"
fi

# ── easyeffects (servicio en segundo plano, sin ventana ni tray) ─
if ! pgrep -x "easyeffects" >/dev/null; then
  nohup easyeffects --hide-window --service-mode >/dev/null 2>&1 &
  disown
  echo "[$(date)] easyeffects iniciado (service mode)"
fi

echo "[$(date)] === AUTOSTART COMPLETADO ==="
