#!/usr/bin/env bash
set -euo pipefail

echo "[*] Restaurando sistema a estado normal"

# Brillo al 100%
brightnessctl set 100% 2>/dev/null || true

# CPU governor -> performance (o schedutil si está disponible)
gov="performance"
if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]] && \
   grep -qw schedutil /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null; then
  gov="schedutil"
fi
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo "$gov" | doas tee "$cpu" >/dev/null 2>&1 || true
done

# Activar WiFi y Bluetooth
doas rfkill unblock wifi 2>/dev/null || true
doas rfkill unblock bluetooth 2>/dev/null || true

# Desactivar suspensión automática de USB y PCIe
for dev in /sys/bus/usb/devices/*/power/control; do
  echo on | doas tee "$dev" >/dev/null 2>&1 || true
done
for dev in /sys/bus/pci/devices/*/power/control; do
  echo on | doas tee "$dev" >/dev/null 2>&1 || true
done

# Restaurar NMI watchdog
echo 1 | doas tee /proc/sys/kernel/nmi_watchdog >/dev/null 2>&1 || true

# Timeout de discos normal (30s)
echo 30 | doas tee /sys/block/*/device/timeout >/dev/null 2>&1 || true

# Iniciar servicios de red
for s in NetworkManager dhcpcd wpa_supplicant bluetoothd; do
  doas sv up "$s" 2>/dev/null || true
done

echo "[✓] Sistema restaurado a estado normal"
