#!/bin/bash
exec >>/tmp/mango-autostart.log 2>&1
echo "[$(date)] === INICIO AUTOSTART ==="

source ~/.profile 2>/dev/null || true

# ── Servicios de usuario (runsvdir: pipewire, wireplumber, etc.) ─
# Un solo runsvdir por sesión. session-supervisor.sh limpia supervisores
# huérfanos de sesiones anteriores y arranca todo ~/.config/runit/sv.
# Se lanza aquí (no en config.conf) para garantizar que exista aunque sólo
# haya un exec_once.
if ! pgrep -f "runsvdir $HOME/.config/runit/sv" >/dev/null; then
  setsid bash "$HOME/.config/mango/scripts/session-supervisor.sh" >/dev/null 2>&1 < /dev/null &
  disown
  echo "[$(date)] session-supervisor lanzado"
fi

# Esperar a que PipeWire cree su socket antes de seguir, para que
# easyeffects y las apps de audio no arranquen sin servidor de sonido.
for _ in $(seq 1 48); do
  [ -S "/run/user/$(id -u)/pipewire-0" ] && break
  sleep 0.25
done
echo "[$(date)] pipewire socket: $([ -S "/run/user/$(id -u)/pipewire-0" ] && echo ok || echo 'no')"

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

# ── Waybar (gestionado por launch-waybar.sh; no pasa por runit,
#    para que el cambio de barra sea rápido sin delays de respawn) ──
# Se lanza ANTES de cualquier espera (awww ya listo) para que la barra
# salga lo antes posible en el arranque de la sesión.
if ! pgrep -x waybar >/dev/null; then
  bash "$HOME/.config/waybar/scripts/launch-waybar.sh" 2>/dev/null && echo "[$(date)] waybar iniciado" || echo "[$(date)] ERROR iniciando waybar"
fi

# ── Portales xdg: activación temprana con backend wlr fijo ─────
# Evita que apps (OBS, etc.) activen el portal tarde con entorno raro
# y que xdg-desktop-portal elija un backend distinto de wlr.
# Nota: pgrep -x no sirve con nombres >15 chars (comm), por eso -f.
if ! pgrep -f "xdg-desktop-portal-wlr" >/dev/null 2>&1; then
  dbus-send --session --type=method_call --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1 || true
fi
for i in $(seq 1 20); do
  pgrep -f "xdg-desktop-portal-wlr" >/dev/null 2>&1 && break
  sleep 0.25
done
echo "[$(date)] portal-wlr activo: $(pgrep -f xdg-desktop-portal-wlr || echo 'no')"

# ── swayosd (gestionado por runit) ───────────────────────────────

# ── keep-mpd-active (mantiene mpd como player activo en MPRIS) ──
if ! pgrep -f "keep-mpd-active.sh" >/dev/null; then
  nohup /home/jpablo/.config/mango/scripts/keep-mpd-active.sh >/dev/null 2>&1 &
  echo "[$(date)] keep-mpd-active iniciado"
fi

# ── mpd-notify (notificación al cambiar de canción) ──────────────
if ! pgrep -f "mpd-notify.sh" >/dev/null; then
  nohup /home/jpablo/.config/mango/scripts/mpd-notify.sh >/dev/null 2>&1 &
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

# ── easyeffects (servicio en segundo plano, sin ventana ni tray) ─
if ! pgrep -x "easyeffects" >/dev/null; then
  nohup easyeffects --hide-window --service-mode >/dev/null 2>&1 &
  disown
  echo "[$(date)] easyeffects iniciado (service mode)"
fi

# ── gamma/color de pantalla (perfil elegido, persistente) ─────
# El compositor borra la rampa de gamma al arrancar, así que se
# reaplica el último perfil guardado en ~/.local/state/mangogamma/last
if [ -f "$HOME/.local/state/mangogamma/last" ]; then
  gpreset=$(cat "$HOME/.local/state/mangogamma/last" 2>/dev/null)
  if [ -n "$gpreset" ]; then
    bash "$HOME/.config/mango/scripts/gamma.sh" "$gpreset" >/dev/null 2>&1
    echo "[$(date)] gamma aplicado: $gpreset"
  fi
fi

# ── swayidle (bloqueo + apagar pantalla tras 10 min de inactividad) ─
# Usa ext-idle-notify (soportado por mangowm). Al volver de la
# suspensión o actividad también desbloquea el monitor con wlopm.
if ! pgrep -x swayidle >/dev/null; then
  nohup swayidle -w \
    timeout 600 'pgrep -x hyprlock >/dev/null || hyprlock & sleep 1; wlopm --off "*"' \
    resume 'wlopm --on "*"' \
    before-sleep 'pgrep -x hyprlock >/dev/null || hyprlock' \
    >/dev/null 2>&1 &
  disown
  echo "[$(date)] swayidle iniciado (10 min idle)"
fi

echo "[$(date)] === AUTOSTART COMPLETADO ==="
