set -x XCURSOR_THEME breeze_cursors
set -x XCURSOR_SIZE 24

set -gx LC_MESSAGES es_ES.UTF-8

set -g fish_greeting

set -gx PATH ~/.local/bin $PATH

# Iniciar sway con bus D-Bus de sesion
alias sway='dbus-run-session sway'

if status is-interactive
    # fastfetch
    starship init fish | source

    # dlplaylist: descarga playlists de musica con yt-dlp
    abbr --add dlplaylist yt-dlp -f ba -x --audio-format opus --embed-metadata --embed-thumbnail --convert-thumbnails jpg --ppa "ffmpeg: -mapping_family 0" --no-keep-video -o "%(title)s.%(ext)s" --sleep-interval 5 --max-sleep-interval 15

    # formatdisk: formatear discos desde la terminal
    abbr --add formatdisk /home/jpablo/disk-formatter/target/release/disk_formatter

    # recarga matugen con el wallpaper actual
    function matugen-reload
        set -l w (cat ~/.cache/wal/wal 2>/dev/null)
        if test -f "$w"
            for f in ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css
                if test -L "$f"
                    rm -f "$f"; and touch "$f"
                end
            end
            set -l s (~/.config/sway/scripts/detect-scheme.sh "$w")
            matugen image "$w" -c ~/.config/matugen/config.toml --type "$s" -q
        else
            echo "No hay wallpaper valido en ~/.cache/wal/wal"
        end
    end
    alias mutagen='matugen-reload'

    # dotfiles: gestion de dotfiles con bare git repo
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

    # lazydot: lazygit para dotfiles
    function lazydot
        GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME lazygit --use-config-dir=$HOME/.config/lazygit $argv
    end

    # alias para que cualquier comando que use sudo termine usando doas
    function sudo --wraps=/usr/bin/doas
        doas $argv
    end

    # aur-safe: wrapper que analiza paquetes AUR antes de instalarlos
    # Funciona con paru y yay automaticamente
    if not set -q AUR_SAFE_DISABLED
        # Detecta que AUR helper esta instalado
        if type -q paru
            function paru --wraps=/usr/bin/paru
                ~/.local/bin/aur-safe $argv
            end
        end
        if type -q yay
            function yay --wraps=/usr/bin/yay
                ~/.local/bin/aur-safe $argv
            end
        end
    end
end
