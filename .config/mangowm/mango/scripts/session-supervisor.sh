#!/bin/bash
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

if [ ! -S "/run/user/$(id -u)/bus" ]; then
  dbus-daemon --session --fork --address="unix:path=/run/user/$(id -u)/bus" --print-pid=1 --print-address=1 >/dev/null 2>&1
fi
dbus-update-activation-environment DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" XDG_SESSION_TYPE=wayland 2>/dev/null || true

SVDIR="$HOME/.config/runit/sv"

for old in $(pgrep -f "runsvdir $SVDIR"); do
  kill "$old" 2>/dev/null
done

for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  [ -z "$(pgrep -f "runsvdir $SVDIR")" ] && break
  sleep 1
done

for p in pipewire pipewire-pulse wireplumber waybar swayosd-server easyeffects mpd mpdris2-rs listenbrainz-mpd; do
  pkill -x "$p" 2>/dev/null
done
pkill -f "update-playlists.sh" 2>/dev/null
pkill -f "rpc.py" 2>/dev/null

RU="/run/user/$(id -u)"
for f in pipewire-0 pipewire-0.lock pipewire-0-manager pipewire-0-manager.lock; do
  rm -f "$RU/$f" 2>/dev/null
done
rm -rf "$RU/pulse" 2>/dev/null

exec runsvdir "$SVDIR"
