#!/bin/bash
WIDGET_DIR="$HOME/.config/eww"
DEFAULT_COVER="$WIDGET_DIR/eww-music-widget/assets/DEFAULTImage.jpeg"
CACHE_DIR="$HOME/.cache/eww/music-widget"
mkdir -p "$CACHE_DIR"

show_default_cover() {
    echo "$DEFAULT_COVER"
    exit 0
}

FILE=$(mpc -f "%file%" current 2>/dev/null)
if [[ -z "$FILE" ]]; then
    show_default_cover
fi

URL_HASH=$(echo -n "$FILE" | md5sum | awk '{print $1}')
CACHED_COVER="$CACHE_DIR/$URL_HASH.jpg"

if [ ! -f "$CACHED_COVER" ]; then
    mpc readpicture "$FILE" > "$CACHED_COVER" 2>/dev/null
    if [[ $? -ne 0 ]] || [[ ! -s "$CACHED_COVER" ]]; then
        rm -f "$CACHED_COVER"
        show_default_cover
    fi
fi

if file "$CACHED_COVER" | grep -qE 'image|jpeg|png|jpg|gif'; then
    echo "$CACHED_COVER"
else
    rm -f "$CACHED_COVER"
    show_default_cover
fi
