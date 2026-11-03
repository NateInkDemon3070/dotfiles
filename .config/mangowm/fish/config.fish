set -gx PATH ~/.local/bin $PATH

set -gx SVDIR ~/.config/runit/sv

set -gx XCURSOR_THEME Hatsune-Miku-cursors
set -gx XCURSOR_SIZE 22

set -gx LC_TIME es_VE.UTF-8@12h

starship init fish | source

function fish_greeting; end

alias hora='date +%r'

# proto
set -gx PROTO_HOME "$HOME/.proto";
set -gx PATH "$PROTO_HOME/shims" "$PROTO_HOME/bin" $PATH;
