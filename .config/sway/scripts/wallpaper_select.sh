#!/usr/bin/env bash

if pidof rofi >/dev/null; then
  pkill rofi
fi

wallpapers_dir="$HOME/Wallpapers"

transitions=("grow")
rand_anim=${transitions[$RANDOM % ${#transitions[@]}]}

selected_wallpaper=$(for a in "$wallpapers_dir"/*; do
  echo -en "$(basename "${a%.*}")\0icon\x1f$a\n"
done | rofi -dmenu -p " " \
  -theme-str '
    @import "~/.cache/wal/colors-rofi-dark.rasi"

    * {
        bg-base: rgba(15, 17, 20, 0.85);
        accent-alt: @selected-normal-background;
        font: "JetBrainsMono Nerd Font 11";
        background-color: transparent;
        text-color: @foreground;
    }

    window {
        width: 75%;
        height: 70%;
        background-color: @bg-base;
        border: 2px;
        border-color: @accent-alt;
        border-radius: 0px;
        location: center;
        anchor: center;
    }

    listview {
        columns: 3;
        lines: 2;
        spacing: 20px;
        padding: 30px;
        fixed-height: false;
        scrollbar: false;
    }

    element {
        orientation: vertical;
        padding: 15px;
        border-radius: 0px;
        background-color: transparent;
    }

    element selected.normal {
        background-color: rgba(255, 255, 255, 0.05);
        border: 2px;
        border-color: @accent-alt;
        text-color: @accent-alt;
    }

    element-icon {
        size: 220px;
        horizontal-align: 0.5;
    }

    element-text {
        horizontal-align: 0.5;
        vertical-align: 0.5;
        padding: 10px 0 0 0;
        text-color: inherit;
    }

    inputbar {
        padding: 20px;
        background-color: rgba(255, 255, 255, 0.05);
        children: [prompt, entry];
    }
    ')

[ -z "$selected_wallpaper" ] && exit 0

image_fullname_path=$(find "$wallpapers_dir" -type f -name "$selected_wallpaper.*" | head -n 1)

killall swaybg 2>/dev/null
swaybg -i "$image_fullname_path" -m fill &

sleep 0.3
echo "$image_fullname_path" > "$HOME/.cache/wal/wal"
for f in "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css"; do
  [ -L "$f" ] && rm -f "$f" && touch "$f"
done
SCHEME=$(~/.config/sway/scripts/detect-scheme.sh "$image_fullname_path")
pkill -f "matugen image" 2>/dev/null
matugen image "$image_fullname_path" -c "$HOME/.config/matugen/config.toml" --type "$SCHEME" -q

echo "Aplicado [$rand_anim]: $(basename "$image_fullname_path")"
