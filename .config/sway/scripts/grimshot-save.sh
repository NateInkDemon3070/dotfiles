#!/bin/sh
mkdir -p /home/jpablo/Imagenes/Capturas
env XDG_SCREENSHOTS_DIR=/home/jpablo/Imagenes/Capturas grimshot --notify save "$@"
