#!/bin/bash

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mpd-notify"
mkdir -p "$CACHE_DIR"

# Leer music_directory del config de MPD
MUSIC_DIR=$(sed -n 's/^music_directory\s*"\(.*\)"/\1/p' ~/.config/mpd/mpd.conf 2>/dev/null)
MUSIC_DIR="${MUSIC_DIR/#\~/$HOME}"

# Si no se pudo leer, usar default
[ -z "$MUSIC_DIR" ] && MUSIC_DIR="$HOME/Música"

last_song=""

while true; do
  mpc idle player >/dev/null 2>&1

  current_file=$(mpc current -f "%file%")
  [ -z "$current_file" ] && continue

  # No repetir si es el mismo tema (pausa/reanudar)
  [ "$current_file" = "$last_song" ] && continue
  last_song="$current_file"

  full_path="$MUSIC_DIR/$current_file"
  song_info=$(mpc current -f "%artist% - %title%")
  [ "$song_info" = " - " ] && song_info=$(basename "$current_file")

  art_file="$CACHE_DIR/cover.png"
  rm -f "$art_file"

  if [ -f "$full_path" ]; then
    ffmpeg -y -i "$full_path" -an -vcodec png -f image2pipe - 2>/dev/null | head -c 2000000 >"$art_file" 2>/dev/null
  fi

  if [ ! -s "$art_file" ] && [ -n "$current_file" ]; then
    dir=$(dirname "$full_path")
    for cover in "cover.jpg" "cover.png" "folder.jpg" "album.jpg" "Cover.jpg" "front.jpg" "front.png" "Front.jpg"; do
      if [ -f "$dir/$cover" ]; then
        art_file="$dir/$cover"
        break
      fi
    done
  fi

  if [ -s "$art_file" ]; then
    notify-send -i "$art_file" -t 5000 "Reproduciendo" "$song_info"
  else
    notify-send -t 5000 "Reproduciendo" "$song_info"
  fi
done
