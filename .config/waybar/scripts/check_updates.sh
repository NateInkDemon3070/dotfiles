#!/usr/bin/env bash

# Definición de colores
BLUE='\e[1;34m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
CYAN='\e[1;36m'
ITALIC='\e[3m'
NC='\e[0m'

# Lista de paquetes críticos para proteger
CRITICAL_PKGS="hyprland|networkmanager|waybar|linux|grub|sudo|kitty|pacman|yay|pipewire|mesa|sddm"

if [ -z "$@" ]; then
    echo "Busca arriba el paquete a instalar..."
    echo "1. Desinstalar (Ver Lista y Borrar)"
    echo "2. Actualizar Sistema Completo"
else
    pkg_choice="$@"

    kitty --class rofi_terminal -e sh -c "
        while true; do
            clear
            if [[ '$pkg_choice' == '1'* ]]; then
                echo -e '${BLUE}--- LISTA DE PAQUETES (PACMAN/YAY) ---${NC}'
                # Filtro para marcar paquetes peligrosos en rojo
                pacman -Qq | awk -v crit=\"$CRITICAL_PKGS\" '{
                    if (\$1 ~ \"^(\" crit \")$\")
                        print \"\033[1;31m\" \$1 \" [PELIGRO]\033[0m\";
                    else
                        print \$1;
                }' | column

                echo ''
                echo -e '${GREEN}--- LISTA DE PAQUETES (FLATPAK) ---${NC}'
                flatpak list --columns=application
                echo ''
                echo -e '${YELLOW}INSTRUCCIONES:${NC}'
                echo 'Dale hacia arriba y veras los ids y nombres de los paquetes que hay en tu sistema'
                echo 'Borrar normal:  yay -Rns nombre'
                echo 'Borrar Flatpak: flatpak uninstall ID'
                echo ''
                read -p 'Comando a ejecutar: ' final_cmd
                if [ -n \"\$final_cmd\" ]; then
                    eval \$final_cmd
                fi

            elif [[ '$pkg_choice' == '2'* ]]; then
                echo -e '${CYAN}--- INICIANDO ACTUALIZACION TOTAL ---${NC}'
                echo -e '${YELLOW}1. Sincronizando repositorios y actualizando Pacman/Yay...${NC}'
                yay -Syu
                echo -e '\n${YELLOW}2. Actualizando paquetes Flatpak...${NC}'
                flatpak update -y
                echo -e '\n${YELLOW}3. Limpiando cache y paquetes huerfanos...${NC}'
                yay -Sc --noconfirm
