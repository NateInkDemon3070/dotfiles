function pacman --description 'Gestor de paquetes: buscar/usar pacman o subcomandos update/uninstall'
    switch "$argv[1]"
        case update
            sudo (command -s pacman) -Syu
        case uninstall
            if test -n "$argv[2]"
                sudo (command -s pacman) -Rns $argv[2..-1]
            else
                set -l pkg (command pacman -Qq | fzf \
                    --multi \
                    --preview 'command pacman -Qi {1}' \
                    --preview-label='alt-p: ocultar/mostrar preview, alt-j/k: desplazar, tab: multi-seleccion' \
                    --preview-label-pos='bottom' \
                    --preview-window 'down:65%:wrap:border-sharp' \
                    --bind 'alt-p:toggle-preview' \
                    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up' \
                    --bind 'alt-k:preview-up,alt-j:preview-down' \
                    --color 'pointer:green,marker:green' \
                    --border sharp \
                    --header 'Desinstalador de Paquetes - Selecciona con Tab, Enter para eliminar' \
                    --prompt 'Paquete: ')
                if test -n "$pkg"
                    sudo (command -s pacman) -Rns $pkg
                end
            end
        case '*'
            pacfetch
    end
end