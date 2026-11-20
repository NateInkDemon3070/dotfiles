#!/usr/bin/env bash

GAMEMODE_FILE="$HOME/.cache/gamemode_enabled"
SWAY_OVERRIDE="$HOME/.config/sway/gamemode.conf"

GOVERNOR="performance"

_tune_system() {
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$GOVERNOR" | doas tee "$cpu" >/dev/null 2>&1 || true
    done
    echo 10 | doas tee /proc/sys/vm/swappiness >/dev/null 2>&1 || true
    echo 200 | doas tee /proc/sys/vm/vfs_cache_pressure >/dev/null 2>&1 || true
    echo 0 | doas tee /proc/sys/kernel/numa_balancing >/dev/null 2>&1 || true
}

_restore_system() {
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo schedutil | doas tee "$cpu" >/dev/null 2>&1 || true
    done
    echo 100 | doas tee /proc/sys/vm/swappiness >/dev/null 2>&1 || true
    echo 100 | doas tee /proc/sys/vm/vfs_cache_pressure >/dev/null 2>&1 || true
    echo 1 | doas tee /proc/sys/kernel/numa_balancing >/dev/null 2>&1 || true
}

_swayfx_game_on() {
    cat > "$SWAY_OVERRIDE" << 'EOF'
# Modo juego - overrides para rendimiento
blur disable
shadows disable
gaps inner 0
gaps outer 0
default_border pixel 1
corner_radius 0
smart_gaps off
EOF
    swaymsg reload 2>/dev/null || true
}

_swayfx_game_off() {
    rm -f "$SWAY_OVERRIDE"
    swaymsg reload 2>/dev/null || true
}

if [ -f "$GAMEMODE_FILE" ]; then
    _swayfx_game_off
    _restore_system
    rm "$GAMEMODE_FILE"
    notify-send "System" "Gamemode deactivated" -i joystick
else
    _swayfx_game_on
    _tune_system
    touch "$GAMEMODE_FILE"
    notify-send "System" "Gamemode activated" -i joystick
fi
