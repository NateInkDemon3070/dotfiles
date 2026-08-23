# Qt: usar GTK theme solo fuera de KDE (para Sway)
if test "$XDG_CURRENT_DESKTOP" != KDE
    set -gx QT_QPA_PLATFORMTHEME qt6ct
end

# Runit: servicios de usuario
set -gx SVDIR $HOME/.config/runit/sv

set -g fish_greeting ""
starship init fish | source
alias ls lsd

fish_add_path /home/jpablo/.spicetify

# opencode
fish_add_path /home/jpablo/.opencode/bin
set -gx PATH $HOME/.local/bin $PATH

# zoxide (igual que en zsh)
zoxide init fish | source

# fzf (key-bindings + completions)
fzf --fish | source

# Salida coloreada
alias grep 'grep --color=auto'
alias egrep 'egrep --color=auto'
alias fgrep 'fgrep --color=auto'
alias diff 'diff --color=auto'
alias ip 'ip --color=auto'

# bat: cat con resaltado de sintaxis
alias cat bat
set -gx BAT_THEME ansi

# fd: búsqueda rápida de archivos
alias find fd
alias findi 'fd -i'

# diff-so-fancy: diffs legibles y con color
function dif
    diff -u $argv | diff-so-fancy | less -RF
end

# Autosugestión en gris (estilo fish por defecto)
set -g fish_color_autosuggestion 555
