#!/usr/bin/env bash

if command -v paccache >/dev/null; then
    echo ":: Limpiando caché de paquetes antiguos..."
    paccache -r -k 2
fi

if [ -n "$(pacman -Qtdq)" ]; then
    echo ":: Eliminando paquetes huérfanos..."
    doas pacman -Rns $(pacman -Qtdq) --noconfirm
else
    echo ":: No hay paquetes huérfanos para limpiar."
fi

rm -rf ~/.cache/thumbnails/*
rm -rf ~/.cache/gamemode_enabled

echo ":: Liberando RAM (caché de página, dentries e inodos)..."
sync
doas sh -c 'echo 3 > /proc/sys/vm/drop_caches'

notify-send "Limpieza Completa" "Caché de paquetes, huérfanos y RAM liberados." -i terminal
