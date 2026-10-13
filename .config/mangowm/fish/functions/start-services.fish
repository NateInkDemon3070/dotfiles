function start-services
    bash ~/.config/mango/scripts/autostart.sh
    echo "---"
    echo "Log: /tmp/mango-autostart.log"
    tail -5 /tmp/mango-autostart.log
end