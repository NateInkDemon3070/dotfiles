alias sudo doas

set -gx PATH ~/.local/bin $PATH

set -gx SVDIR ~/.config/runit/sv

starship init fish | source

function fish_greeting; end
