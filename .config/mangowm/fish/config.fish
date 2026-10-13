set -gx PATH ~/.local/bin $PATH

set -gx SVDIR ~/.config/runit/sv

starship init fish | source

function fish_greeting; end

# proto
set -gx PROTO_HOME "$HOME/.proto";
set -gx PATH "$PROTO_HOME/shims" "$PROTO_HOME/bin" $PATH;
