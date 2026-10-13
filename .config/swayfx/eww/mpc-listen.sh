#!/bin/bash
emit_info() {
    local status_line=$(mpc status 2>/dev/null)
    local title=$(mpc -f "%title%" current 2>/dev/null)
    local artist=$(mpc -f "%artist%" current 2>/dev/null)
    local total=$(mpc -f "%time%" current 2>/dev/null)
    local elapsed=$(echo "$status_line" | grep -oP '\d+:\d+(?=\/)' | head -1)
    local state=$(echo "$status_line" | grep -oP '\[(playing|paused|stopped)\]' | tr -d '[]')

    [[ -z "$title" ]] && title="No Music Playing"
    [[ -z "$artist" ]] && artist="Unknown Artist"
    [[ -z "$state" ]] && state="stopped"
    [[ -z "$elapsed" ]] && elapsed="0:00"
    [[ -z "$total" ]] && total="0"

    local total_sec=0
    if [[ "$total" =~ ^([0-9]+):([0-9]+)$ ]]; then
        total_sec=$(( ${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]} ))
    fi

    local elapsed_sec=0
    if [[ "$elapsed" =~ ^([0-9]+):([0-9]+)$ ]]; then
        elapsed_sec=$(( ${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]} ))
    fi

    local repeat_state=$(echo "$status_line" | grep -oP 'repeat:\s*\K\w+')
    local random_state=$(echo "$status_line" | grep -oP 'random:\s*\K\w+')
    [[ "$repeat_state" == "on" ]] && repeat_state="true" || repeat_state="false"
    [[ "$random_state" == "on" ]] && random_state="true" || random_state="false"

    printf '{"title":"%s","artist":"%s","status":"%s","elapsed":"%s","total":%d,"elapsed_sec":%d,"repeat":%s,"random":%s}\n' \
        "$title" "$artist" "$state" "$elapsed" "$total_sec" "$elapsed_sec" "$repeat_state" "$random_state"
}

emit_info

mpc idleloop player 2>/dev/null | while read -r event; do
    emit_info
done
