#!/bin/sh

f="$1"

if [ -z "$f" ] || [ -d "$f" ] || ! [ -e "$f" ]; then
	exit 0
fi

case "$(file -b --mime-type "$f" 2>/dev/null)" in
	image/*) imv "$f" ;;
	audio/*) mpv "$f" ;;
	*) nvim "$f" ;;
esac