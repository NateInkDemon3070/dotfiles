#!/bin/sh
mkdir -p /home/jpablo/Imágenes/Capturas
env XDG_SCREENSHOTS_DIR=/home/jpablo/Imagenes/Capturas grimshot --notify save "$@"
