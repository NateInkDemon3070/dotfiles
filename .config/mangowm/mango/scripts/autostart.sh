#!/bin/bash
exec >>/tmp/mango-autostart.log 2>&1
echo "[$(date)] === INICIO AUTOSTART ==="

source ~/.profile 2>/dev/null || true

# ── Servicios de usuario (runsvdir: pipewire, wireplumber, etc.) ─
if ! pgrep -f "runsvdir $HOME/.config/runit/sv" >/dev/null; then
  setsid bash "$HOME/.config/mango/scripts/session-supervisor.sh" >/dev/null 2>&1 </dev/null &
  disown
  echo "[$(date)] session-supervisor lanzado"
fi

for _ in $(seq 1 48); do
  [ -S "/run/user/$(id -u)/pipewire-0" ] && break
  sleep 0.25
done
echo "[$(date)] pipewire socket: $([ -S "/run/user/$(id -u)/pipewire-0" ] && echo ok || echo 'no')"

# ── awww-daemon (wallpaper engine) ─────────────────────────────
if ! awww query >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
  disown
  for _ in $(seq 1 20); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
  done
  echo "[$(date)] awww-daemon iniciado"
fi

# ── Waybar
if ! pgrep -x waybar >/dev/null; then
  bash "$HOME/.config/waybar/scripts/launch-waybar.sh" 2>/dev/null && echo "[$(date)] waybar iniciado" || echo "[$(date)] ERROR iniciando waybar"
fi

# ── Waybar: esperar al watcher SNI (bandeja) ──────────────────────────
# Chromium/Electron sólo registra su icono de bandeja si el watcher
# org.kde.StatusNotifierWatcher ya existe al arrancar la app.
for i in $(seq 1 40); do
  busctl --user list --no-pager 2>/dev/null | grep -q org.kde.StatusNotifierWatcher && break
  sleep 0.25
done
echo "[$(date)] watcher SNI: $(busctl --user list --no-pager 2>/dev/null | grep -c org.kde.StatusNotifierWatcher)"

# ── Portales xdg ─────
if ! pgrep -f "xdg-desktop-portal-wlr" >/dev/null 2>&1; then
  dbus-send --session --type=method_call --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1 || true
fi
for i in $(seq 1 20); do
  pgrep -f "xdg-desktop-portal-wlr" >/dev/null 2>&1 && break
  sleep 0.25
done
echo "[$(date)] portal-wlr activo: $(pgrep -f xdg-desktop-portal-wlr || echo 'no')"

# ── keep-mpd-active ──
if ! pgrep -f "keep-mpd-active.sh" >/dev/null; then
  nohup /home/jpablo/.config/mango/scripts/keep-mpd-active.sh >/dev/null 2>&1 &
  echo "[$(date)] keep-mpd-active iniciado"
fi

# ── xembedsniproxy ────
if ! pgrep -x "xembedsniproxy" >/dev/null; then
  /usr/local/bin/xembedsniproxy >/dev/null 2>&1 &
  disown
  echo "[$(date)] xembedsniproxy iniciado"
fi

if [ -n "$DISPLAY" ]; then
  for i in $(seq 1 40); do
    if xprop -root _NET_SYSTEM_TRAY_S0 2>/dev/null | grep -q "window id"; then
      break
    fi
    sleep 0.25
  done
fi

# ── udiskie ─────────────────────────────
if ! pgrep -x "udiskie" >/dev/null; then
  udiskie &
  disown
  echo "[$(date)] udiskie programado (automontaje, sin tray)"
fi

# ── lxqt-policykit-agent ─────────────────────────────────────────
if ! pgrep -f "lxqt-policykit-agent" >/dev/null; then
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

# ── easyeffects ─
if ! pgrep -x "easyeffects" >/dev/null; then
  nohup easyeffects --hide-window --service-mode >/dev/null 2>&1 &
  disown
  echo "[$(date)] easyeffects iniciado (service mode)"
fi

# ── gamma/color de pantalla ─────
if [ -f "$HOME/.local/state/mangogamma/last" ]; then
  gpreset=$(cat "$HOME/.local/state/mangogamma/last" 2>/dev/null)
  if [ -n "$gpreset" ]; then
    bash "$HOME/.config/mango/scripts/gamma.sh" "$gpreset" >/dev/null 2>&1
    echo "[$(date)] gamma aplicado: $gpreset"
  fi
fi

# ── hypridle ─
if ! pgrep -x hypridle >/dev/null; then
  nohup hypridle >/dev/null 2>&1 &
  disown
  echo "[$(date)] hypridle iniciado (10 min idle)"
fi

echo "[$(date)] === AUTOSTART COMPLETADO ==="
