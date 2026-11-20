#!/usr/bin/env bash
set -uo pipefail

start_dir="${1:-$HOME}"
dir=$(realpath -m -- "$start_dir")

icon_for() {
  case "${1##*.}" in
  png | PNG | svg | SVG) printf '%s' "$1" ;;
  jpg | jpeg | JPG | JPEG | webp | WEBP | gif | GIF | bmp | BMP) printf 'image-x-generic' ;;
  mp4 | mkv | webm | avi | mov | MP4 | MKV | WEBM | AVI | MOV) printf 'video-x-generic' ;;
  mp3 | flac | ogg | wav | m4a | MP3 | FLAC | OGG | WAV | M4A) printf 'audio-x-generic' ;;
  pdf | PDF) printf 'application-pdf' ;;
  zip | tar | gz | xz | zst | 7z | rar | ZIP | TAR | GZ | XZ | ZST | 7Z | RAR) printf 'package-x-generic' ;;
  *) printf 'text-x-generic' ;;
  esac
}

while :; do
  dirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' 2>/dev/null | sort -f)
  files=$(find "$dir" -mindepth 1 -maxdepth 1 ! -type d ! -name '.*' -printf '%f\n' 2>/dev/null | sort -f)

  selected=$(
    {
      if [ "$dir" != "/" ]; then
        printf '../\0icon\x1fgo-up\n'
      fi
      while IFS= read -r name; do
        [ -n "$name" ] && printf '%s/\0icon\x1ffolder\n' "$name"
      done <<<"$dirs"
      while IFS= read -r name; do
        [ -n "$name" ] && printf '%s\0icon\x1f%s\n' "$name" "$(icon_for "$dir/$name")"
      done <<<"$files"
    } | fuzzel --dmenu --cache=/dev/null --prompt="$dir   " \
      --placeholder="Buscar archivo..." --lines=14 --width=72
  ) || exit 0

  [ -n "$selected" ] || exit 0

  if [ "$selected" = "../" ]; then
    dir=$(dirname -- "$dir")
    continue
  fi

  target="$dir/${selected%/}"

  if [ -d "$target" ]; then
    dir=$(realpath -m -- "$target")
  elif [ -f "$target" ]; then
    xdg-open "$target" >/dev/null 2>&1 &
    exit 0
  fi
done
