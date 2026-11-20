function cleanup --description "Remove orphan packages and clean system cache"
    # Remove orphan packages
    set -l orphans (pacman -Qtdq 2>/dev/null)
    if test -n "$orphans"
        echo "Removing orphan packages..."
        sudo pacman -Rns --noconfirm $orphans
    else
        echo "No orphan packages found."
    end

    # Clean pacman cache
    echo "Cleaning pacman cache..."
    if command -v paccache &>/dev/null
        sudo paccache -rk1
        sudo paccache -ruk0
    else
        sudo pacman -Scc --noconfirm
    end
end
