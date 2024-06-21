#!/usr/bin/env bash

# Set default keyboard layout to german and replace caps lock by
# control
# setxkbmap -layout de -option ctrl:nocaps && xmodmap -e "keycode 111 = Alt_L Meta_L Alt_L Meta_L"

# Start Emacs server
emacs --daemon
