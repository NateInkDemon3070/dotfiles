#!/bin/bash
killall xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk 2>/dev/null
sleep 0.5
/usr/lib/xdg-desktop-portal -r &>/dev/null &
/usr/lib/xdg-desktop-portal-wlr -r &>/dev/null &
/usr/lib/xdg-desktop-portal-gtk &>/dev/null &
sleep 1
echo "Portales reiniciados. Probá OBS."
