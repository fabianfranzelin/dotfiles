#!/bin/sh

# Set default keyboard layout to german and replace caps lock by
# control
setxkbmap -layout de -option ctrl:nocaps

# Start Qtile
~/.local/bin/startqtile

# Start xcfe
# /usr/bin/startxfce4
