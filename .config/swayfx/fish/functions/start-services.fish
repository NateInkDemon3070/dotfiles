function start-services
    bash ~/.config/sway/autostart.sh
    echo "---"
    echo "Log: /tmp/sway-autostart.log"
    tail -5 /tmp/sway-autostart.log
end