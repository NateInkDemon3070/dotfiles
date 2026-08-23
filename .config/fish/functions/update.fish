function update
    aur-safe --update-blocklist
    paru -Syu
    flatpak update -y
    pip install --upgrade (pip list --outdated --format=freeze | cut -d= -f1)
end
