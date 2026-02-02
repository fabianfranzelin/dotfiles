#!/usr/bin/env bash

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
# xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
nitrogen --set-zoom-fill \
    "$HOME/.local/share/backgrounds/pexels-eberhardgross-12365567.jpg" &

if [ "$(hostname)" = "ABT-C-002NY" ]
then
    # Use this widget to create vpn session
    osd-toolkit &
fi

# Network manager applet
[ -x "$(command -v nm-applet)" ] && nm-applet &

# Screenshot app
flameshot &
# disable screen off when in power mode
caffeine-indicator &
