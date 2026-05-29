#!/usr/bin/env bash

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
# xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
nitrogen --set-zoom-fill \
    "$HOME/.local/share/backgrounds/pexels-eberhardgross-12365567.jpg" &

run_once() {
    if ! pgrep -f "$(basename "$1")" > /dev/null; then
        "$@" &
    fi
}

if [ "$(hostname)" = "FEWI-C-0007J" ]
then
    # Use this widget to create vpn session
    run_once osd-toolkit
fi

# Network manager applet
[ -x "$(command -v nm-applet)" ] && run_once nm-applet

# Screenshot app
run_once flameshot
# disable screen off when in power mode
run_once caffeine-indicator
