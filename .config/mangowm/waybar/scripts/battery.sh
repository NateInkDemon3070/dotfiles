#!/usr/bin/env bash
# Módulo de batería para Waybar.
#
# Uso: battery.sh [horizontal|compact|side]
#
# - Muestra capacidad, icono y tooltip como el módulo "battery" original.
# - Cuando quedan <= 30 s de batería (descargando), activa la clase
#   "critical" (el CSS la pinta en rojo e intermitente) y muestra una
#   notificación que va contando los 30 segundos.
# - Al conectar el cargador cierra la notificación y limpia el estado.

set -u

MODE="${1:-horizontal}"
BAT="${BATTERY_DEVICE:-BAT0}"
SYS="${BATTERY_SYSFS:-/sys/class/power_supply/$BAT}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
ALERT_UNTIL_FILE="$CACHE_DIR/battery-alert-until"
ALERT_ID_FILE="$CACHE_DIR/battery-alert-id"
ALERT_FINAL_FILE="$CACHE_DIR/battery-alert-final"
ALERT_SECONDS=30

mkdir -p "$CACHE_DIR"

# Sin batería (o batería no presente): no mostrar nada.
[[ -d "$SYS" ]] || exit 0
[[ "$(cat "$SYS/present" 2>/dev/null || echo 1)" == "0" ]] && exit 0

read_val() {
    cat "$SYS/$1" 2>/dev/null || true
}

status="$(read_val status)"
capacity="$(read_val capacity)"
charge_now="$(read_val charge_now)"
current_now="$(read_val current_now)"
energy_now="$(read_val energy_now)"
power_now="$(read_val power_now)"

[[ "$capacity" =~ ^[0-9]+$ ]] || capacity=0

is_charging=0
case "$status" in
    Charging|Full|"Not charging") is_charging=1 ;;
esac

# Segundos restantes estimados a partir de sysfs (se actualiza rápido).
# Si la batería usa energía en vez de carga, se usa esa vía.
ttl=""
if [[ "$status" == "Discharging" ]]; then
    if [[ "$charge_now" =~ ^[0-9]+$ && "$current_now" =~ ^[0-9]+$ && "$current_now" -gt 0 ]]; then
        ttl=$(( charge_now * 3600 / current_now ))
    elif [[ "$energy_now" =~ ^[0-9]+$ && "$power_now" =~ ^[0-9]+$ && "$power_now" -gt 0 ]]; then
        ttl=$(( energy_now * 3600 / power_now ))
    fi
fi

# Respaldo: UPower (solo si sysfs no da una estimación).
if [[ -z "$ttl" && "$status" == "Discharging" ]]; then
    ttl="$(busctl get-property org.freedesktop.UPower \
        /org/freedesktop/UPower/devices/DisplayDevice \
        org.freedesktop.UPower.Device TimeToEmpty 2>/dev/null | awk '{print $2}')"
    [[ "$ttl" =~ ^[0-9]+$ ]] || ttl=""
fi

notif_id=""
if [[ -f "$ALERT_ID_FILE" ]]; then
    notif_id="$(cat "$ALERT_ID_FILE" 2>/dev/null || true)"
fi

close_notification() {
    local id
    id="$(cat "$ALERT_ID_FILE" 2>/dev/null || true)"
    if [[ "$id" =~ ^[0-9]+$ ]]; then
        gdbus call --session \
            --dest org.freedesktop.Notifications \
            --object-path /org/freedesktop/Notifications \
            --method org.freedesktop.Notifications.CloseNotification "$id" \
            >/dev/null 2>&1 || true
    fi
    rm -f "$ALERT_ID_FILE"
}

send_notification() {
    local remaining="$1"
    local final="${2:-0}"
    local body new_id timeout

    if (( final || remaining <= 0 )); then
        body="La batería se está agotando"
        timeout=0
    else
        body="Quedan ${remaining} segundos de batería"
        timeout=4000
    fi

    if [[ "$notif_id" =~ ^[0-9]+$ ]]; then
        new_id="$(notify-send -p -u critical -a "Batería" -i battery-caution \
            -t "$timeout" -r "$notif_id" "Batería crítica" "$body" 2>/dev/null || true)"
    else
        new_id="$(notify-send -p -u critical -a "Batería" -i battery-caution \
            -t "$timeout" "Batería crítica" "$body" 2>/dev/null || true)"
    fi

    if [[ "$new_id" =~ ^[0-9]+$ ]]; then
        notif_id="$new_id"
        echo "$notif_id" > "$ALERT_ID_FILE"
    fi
}

now="$(date +%s)"
alert_active=0
alert_class=""
final_sent=0
[[ -f "$ALERT_FINAL_FILE" ]] && final_sent=1

# Limpiar estado obsoleto: p. ej. si se reinició el equipo con la batería ya
# cargada, o si el aviso quedó huérfano de una sesión anterior.
if [[ ! -f "$ALERT_UNTIL_FILE" && -f "$ALERT_ID_FILE" ]]; then
    close_notification
fi
if [[ -f "$ALERT_UNTIL_FILE" ]]; then
    stored_until="$(cat "$ALERT_UNTIL_FILE" 2>/dev/null || echo 0)"
    [[ "$stored_until" =~ ^[0-9]+$ ]] || stored_until=0
    if [[ "$status" != "Discharging" ]] || \
        { (( now - stored_until > ALERT_SECONDS * 2 )) && [[ -n "$ttl" && "$ttl" -gt 60 ]]; }; then
        close_notification
        rm -f "$ALERT_UNTIL_FILE" "$ALERT_FINAL_FILE"
        final_sent=0
    fi
fi

if (( is_charging )); then
    # Cargando/conectado: se cancela cualquier aviso pendiente.
    if [[ -f "$ALERT_UNTIL_FILE" || -f "$ALERT_ID_FILE" ]]; then
        close_notification
        rm -f "$ALERT_UNTIL_FILE" "$ALERT_FINAL_FILE"
    fi
elif [[ -f "$ALERT_UNTIL_FILE" ]]; then
    # Cuenta atrás ya iniciada: se mantiene hasta agotarse o cargar.
    alert_active=1
elif [[ -n "$ttl" && "$ttl" -le "$ALERT_SECONDS" ]]; then
    # Se acaba de cruzar el umbral: cuenta atrás local de 30 s.
    echo $(( now + ALERT_SECONDS )) > "$ALERT_UNTIL_FILE"
    rm -f "$ALERT_FINAL_FILE"
    final_sent=0
    alert_active=1
fi

if (( alert_active )); then
    alert_class="critical"
    until_epoch="$(cat "$ALERT_UNTIL_FILE" 2>/dev/null || echo "$now")"
    [[ "$until_epoch" =~ ^[0-9]+$ ]] || until_epoch="$now"
    remaining=$(( until_epoch - now ))

    if (( remaining > 0 )); then
        send_notification "$remaining"
    elif (( ! final_sent )); then
        send_notification 0 1
        touch "$ALERT_FINAL_FILE"
    fi
fi

# Iconos equivalentes a los de cada configuración original.
case "$MODE" in
    side)
        if [[ "$status" == "Charging" ]]; then
            icons=(" 󰢜" " 󰂆" " 󰂇" " 󰂈" " 󰂅")
        else
            icons=(" " " " " " " " " ")
        fi
        ;;
    compact)
        if [[ "$status" == "Charging" ]]; then
            icons=("󰢜" "󰂆" "󰂇" "󰂈" "󰂅")
        else
            icons=("" "" "" "" "")
        fi
        ;;
    *)
        if [[ "$status" == "Charging" ]]; then
            icons=("󰢜" "󰂆" "󰂇" "󰂈" "󰂉" "󰂊" "󰂋" "󰂅")
        else
            icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
        fi
        ;;
esac

icon_count=${#icons[@]}
divisor=$(( 100 / icon_count ))
(( divisor < 1 )) && divisor=1
icon_index=$(( capacity / divisor ))
(( icon_index >= icon_count )) && icon_index=$(( icon_count - 1 ))
icon="${icons[$icon_index]}"

if [[ "$MODE" == "side" ]]; then
    text="$(printf '%s%%\n%s' "$capacity" "$icon")"
else
    text="$icon $capacity%"
fi

if [[ "$status" == "Discharging" && -n "$ttl" ]]; then
    if (( ttl >= 3600 )); then
        time_text="$(( ttl / 3600 )) h $(( (ttl % 3600) / 60 )) min"
    elif (( ttl >= 60 )); then
        time_text="$(( ttl / 60 )) min $(( ttl % 60 )) s"
    else
        time_text="${ttl} s"
    fi
    tooltip="$(printf 'Batería: %s%%\nEstado: descargando\nTiempo restante: %s' "$capacity" "$time_text")"
elif [[ "$status" == "Charging" ]]; then
    tooltip="$(printf 'Batería: %s%%\nEstado: cargando' "$capacity")"
else
    tooltip="$(printf 'Batería: %s%%\nEstado: %s' "$capacity" "${status:-desconocido}")"
fi

if [[ -n "$alert_class" ]]; then
    jq -cn --arg text "$text" --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: ["critical"]}'
else
    jq -cn --arg text "$text" --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip}'
fi
