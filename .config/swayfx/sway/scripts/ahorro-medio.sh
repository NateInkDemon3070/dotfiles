#!/usr/bin/env bash
set -euo pipefail

echo "[*] Modo ahorro MEDIO"

# Brillo al 40%
brightnessctl set 40% 2>/dev/null || true

# CPU governor -> powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo powersave | doas tee "$cpu" >/dev/null 2>&1 || true
done

# Apagar Bluetooth
doas rfkill block bluetooth 2>/dev/null || true

# Suspensión automática de USB
for dev in /sys/bus/usb/devices/*/power/control; do
  echo auto | doas tee "$dev" >/dev/null 2>&1 || true
done

echo "[✓] Brillo 40%, CPU powersave, Bluetooth off, USB auto-suspend"
