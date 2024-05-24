#!/usr/bin/env bash

# Set default keyboard layout to german and replace caps lock by
# control
# setxkbmap -layout de -option ctrl:nocaps && xmodmap -e "keycode 111 = Alt_L Meta_L Alt_L Meta_L"

# Network manager applet
[ -x "$(command -v nm-applet)" ] && nm-applet &

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
# xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
nitrogen --set-zoom-fill \
         "$HOME/.local/share/backgrounds/samuel-ferrara-uOi3lg8fGl4-unsplash.jpg" &

# The osd-toolkit is optional. It can be ignored if not available
[ -x "$(command -v osd-toolkit)" ] && osd-toolkit &
