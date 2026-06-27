#!/bin/bash

if ! mpc status >/dev/null 2>&1; then
  rofi -e "MPD no está corriendo"
  exit 1
fi

# Obtenemos la info de la canción
current=$(mpc current -f "%artist% - %title%" 2>/dev/null)
[ -z "$current" ] && current="(sin canción)"

if mpc status | grep -q "\[playing\]"; then
  toggle="  Pausar"
else
  toggle="  Reanudar"
fi

# Definimos las opciones
options="  Anterior\n$toggle\n  Siguiente\n  Aleatorio\n  Repetir"

# Lanzamos Rofi
choice=$(echo -e "$options" | rofi -dmenu -i -p "$current" \
  -theme-str '
        @import "~/.cache/wal/colors-rofi-dark.rasi"

        * { font: "JetBrainsMono Nerd Font 12"; }

        window {
            width: 600px;
            background-color: rgba(15, 17, 20, 0.9);
            border: 2px;
            border-color: @accent-alt;
            border-radius: 0px;
        }

        /* Creamos un contenedor principal horizontal */
        mainbox {
            children: [ inputbar, listview ];
            orientation: horizontal;
        }

        /* Inputbar para la info de la canción */
        inputbar {
            width: 300px;
            padding: 20px;
            background-color: transparent;
            children: [ prompt ];
        }

        /* Listview para los botones a la derecha */
        listview {
            width: 250px;
            columns: 1;
            lines: 5;
            padding: 10px;
            background-color: transparent;
        }

        element {
            padding: 10px;
            background-color: transparent;
        }

        element selected.normal {
            background-color: rgba(255, 255, 255, 0.1);
            text-color: @accent-alt;
        }
    ')

# Ejecutar acción
case "$choice" in
"  Anterior") mpc prev ;;
"  Pausar" | "  Reanudar") mpc toggle ;;
"  Siguiente") mpc next ;;
"  Aleatorio") mpc random ;;
"  Repetir") mpc repeat ;;
esac
