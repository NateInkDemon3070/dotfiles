#!/usr/bin/env sh
set -e

COMMAND="$1"
VALUE="$2"
STEP=5

get_volume() {
    mpc volume 2>/dev/null | grep -oP '\d+(?=%)'
}

case $COMMAND in
    up)
        current=$(get_volume)
        new=$(( current + ${VALUE:-$STEP} ))
        [ "$new" -gt 100 ] && new=100
        mpc volume "$new"
        ;;
    down)
        current=$(get_volume)
        new=$(( current - ${VALUE:-$STEP} ))
        [ "$new" -lt 0 ] && new=0
        mpc volume "$new"
        ;;
    mute)
        current=$(get_volume)
        if [ "$current" -eq 0 ]; then
            mpc volume 100
        else
            mpc volume 0
        fi
        ;;
    get)
        get_volume
        ;;
    set)
        if [ -z "$VALUE" ]; then
            echo "Usage: $0 set <0-100>" >&2
            exit 1
        fi
        mpc volume "$VALUE"
        ;;
    *)
        echo "Usage: $0 <up|down|mute|get|set> [value]" >&2
        exit 1
        ;;
esac
