#!/usr/bin/env bash
set -euo pipefail

echo "[*] Modo ahorro MÁXIMO"

# Brillo al 20%
brightnessctl set 20% 2>/dev/null || true

# CPU governor -> powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo powersave | doas tee "$cpu" >/dev/null 2>&1 || true
done

# Apagar WiFi y Bluetooth
doas rfkill block wifi 2>/dev/null || true
doas rfkill block bluetooth 2>/dev/null || true

# Suspensión USB y PCIe
for dev in /sys/bus/usb/devices/*/power/control; do
  echo auto | doas tee "$dev" >/dev/null 2>&1 || true
done
for dev in /sys/bus/pci/devices/*/power/control; do
  echo auto | doas tee "$dev" >/dev/null 2>&1 || true
done

# Desactivar NMI watchdog (consume energía constante)
echo 0 | doas tee /proc/sys/kernel/nmi_watchdog >/dev/null 2>&1 || true

# Timeout de discos más agresivo
echo 120 | doas tee /sys/block/*/device/timeout >/dev/null 2>&1 || true

# Apagar servicios no esenciales
for s in NetworkManager dhcpcd wpa_supplicant; do
  doas sv down "$s" 2>/dev/null || true
done

echo "[✓] Brillo 20%, CPU powersave, WiFi/Bluetooth off, PCIe/USB suspend, watchdog off, red off"
