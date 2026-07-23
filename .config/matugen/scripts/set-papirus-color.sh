#!/bin/bash

COLORS_CSS="$HOME/.cache/wal/colors.css"
CACHE_FILE="$HOME/.cache/wal/papirus-color"

[ ! -f "$COLORS_CSS" ] && exit 1

# Calculate saturation (0-100) from hex color
saturation() {
    local r=$((16#${1:1:2})) g=$((16#${1:3:2})) b=$((16#${1:5:2}))
    local max min
    max=$r; [ "$g" -gt "$max" ] && max=$g; [ "$b" -gt "$max" ] && max=$b
    min=$r; [ "$g" -lt "$min" ] && min=$g; [ "$b" -lt "$min" ] && min=$b
    [ "$max" -eq 0 ] && { echo 0; return; }
    echo $(( (max - min) * 100 / max ))
}

# Pick the most saturated color from the palette for folder accents
BEST_COLOR=""
BEST_SAT=0
for var in color1 color3 color9 color10 color11 color12 cursor; do
    hex=$(grep -- "--$var" "$COLORS_CSS" | sed "s/.*--$var: *\(#[^;]*\).*/\1/" | head -1)
    [ -z "$hex" ] && continue
    sat=$(saturation "$hex")
    if [ "$sat" -gt "$BEST_SAT" ]; then
        BEST_SAT=$sat
        BEST_COLOR=$hex
    fi
done

[ -z "$BEST_COLOR" ] && exit 1
PRIMARY=$BEST_COLOR

papirus_colors() {
    cat <<'EOF'
adwaita #93c0ea
black #4f4f4f
blue #5294e2
bluegrey #607d8b
breeze #57b8ec
brown #ae8e6c
carmine #a30002
cyan #00bcd4
darkcyan #45abb7
deeporange #eb6637
green #87b158
grey #8e8e8e
indigo #5c6bc0
magenta #ca71df
nordic #81a1c1
orange #ee923a
palebrown #d1bfae
paleorange #eeca8f
pink #f06292
red #e25252
teal #16a085
violet #7e57c2
white #e4e4e4
yaru #676767
yellow #f9bd30
EOF
}

# Convert RGB to hue (0-360)
rgb_to_hue() {
    local r=$1 g=$2 b=$3
    local max min diff hue
    max=$r
    min=$r
    [ "$g" -gt "$max" ] && max=$g
    [ "$b" -gt "$max" ] && max=$b
    [ "$g" -lt "$min" ] && min=$g
    [ "$b" -lt "$min" ] && min=$b
    diff=$((max - min))
    if [ "$diff" -eq 0 ]; then
        echo 0
        return
    fi
    if [ "$max" -eq "$r" ]; then
        hue=$(( ((g - b) * 60) / diff ))
    elif [ "$max" -eq "$g" ]; then
        hue=$(( 120 + ((b - r) * 60) / diff ))
    else
        hue=$(( 240 + ((r - g) * 60) / diff ))
    fi
    [ "$hue" -lt 0 ] && hue=$((hue + 360))
    echo "$hue"
}

pr=$((16#${PRIMARY:1:2}))
pg=$((16#${PRIMARY:3:2}))
pb=$((16#${PRIMARY:5:2}))
PHUE=$(rgb_to_hue $pr $pg $pb)

CLOSEST=""
CLOSEST_DIST=999

while IFS=" " read -r name hex; do
    cr=$((16#${hex:1:2}))
    cg=$((16#${hex:3:2}))
    cb=$((16#${hex:5:2}))
    CHUE=$(rgb_to_hue $cr $cg $cb)
    # Circular hue difference
    dh=$((PHUE - CHUE))
    [ "$dh" -lt 0 ] && dh=$((-dh))
    [ "$dh" -gt 180 ] && dh=$((360 - dh))
    # Weight: hue diff (70%) + saturation/luma diff (30%)
    dr=$((pr - cr)); dr=$((dr < 0 ? -dr : dr))
    dg=$((pg - cg)); dg=$((dg < 0 ? -dg : dg))
    db=$((pb - cb)); db=$((db < 0 ? -db : db))
    dist=$((dh + (dr + dg + db) / 12))
    if [ "$dist" -lt "$CLOSEST_DIST" ]; then
        CLOSEST_DIST=$dist
        CLOSEST=$name
    fi
done < <(papirus_colors)

echo "$CLOSEST" > "$CACHE_FILE"
pkexec papirus-folders -t Papirus -C "$CLOSEST" 2>/dev/null || true
