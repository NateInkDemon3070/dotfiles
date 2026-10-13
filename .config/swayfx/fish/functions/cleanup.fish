function cleanup --description "Remove orphan packages and clean system cache"
    # Remove orphan packages
    set -l orphans (pacman -Qtdq 2>/dev/null)
    if test -n "$orphans"
        echo "Removing orphan packages..."
        doas pacman -Rns --noconfirm $orphans
    else
        echo "No orphan packages found."
    end

    # Clean pacman cache
    echo "Cleaning pacman cache..."
    if command -v paccache &>/dev/null
        doas paccache -rk1
        doas paccache -ruk0
    else
        doas pacman -Scc --noconfirm
    end
end
