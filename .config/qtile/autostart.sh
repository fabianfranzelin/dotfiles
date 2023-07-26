#!/usr/bin/env bash

# Set default keyboard layout to german and replace caps lock by
# control
set_default_keyboard_layout

# Not available in default repositories of Ubuntu.
# picom &
nm-applet &

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
# xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
nitrogen --set-zoom-fill \
         "$HOME/.local/share/backgrounds/samuel-ferrara-uOi3lg8fGl4-unsplash.jpg" &
