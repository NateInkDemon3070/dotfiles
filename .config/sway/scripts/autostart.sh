#!/bin/bash
exec >>/tmp/sway-autostart.log 2>&1
echo "[$(date)] === INICIO AUTOSTART ==="

source ~/.profile 2>/dev/null || true

# ── D-Bus: ya creado por session-supervisor.sh ───────────────────

# ── Waybar (supervisado por runit; se reinicia solo si se cae) ──
sv up "$HOME/.config/runit/sv/waybar" 2>/dev/null || true

# ── swayosd ──────────────────────────────────────────────────────
if ! pgrep -x "swayosd-server" >/dev/null; then
  /usr/bin/swayosd-server -s /home/jpablo/.config/swayosd/style.css >/dev/null 2>&1 &
  disown
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

# ── nm-applet (solo si está instalado) ──────────────────────────
if command -v nm-applet >/dev/null; then
  (env -u WAYLAND_DISPLAY GDK_BACKEND=x11 nm-applet --indicator) &
  disown
  echo "[$(date)] nm-applet programado"
fi

# ── puente Rich Presence: Vesktop flatpak → discord-ipc-0 del host ──
ln -sfn "$XDG_RUNTIME_DIR/.flatpak/dev.vencord.Vesktop/xdg-run/discord-ipc-0" \
  "$XDG_RUNTIME_DIR/discord-ipc-0"

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
