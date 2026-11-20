#!/bin/sh

f="$1"

if [ -z "$f" ]; then
	exit 0
fi

if [ -d "$f" ]; then
	ls --color=always "$f"
	exit 0
fi

if [ ! -f "$f" ]; then
	echo "unavailable: $f"
	exit 0
fi

case "$(file --mime-type "$f" 2>/dev/null)" in
*image*)
		chafa --format=symbols "$f"
		;;
*)
		bat --color=always "$f"
		;;
esac