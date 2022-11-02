#!/usr/bin/env bash

# Set default keyboard layout to German and switch caps lock and left
# ctrl
setxkbmap -option ctrl:swapcaps  # Swap left Ctrl and Caps Lock
setxkbmap -option ctrl:nocaps    # Make Caps Lock a Ctrl key
setxkbmap -layout de -option ctrl:nocaps # Switch to my default keyboard layout

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

# Emacs daemon
emacs --daemon &
