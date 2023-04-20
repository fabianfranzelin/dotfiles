#!/bin/sh

# Set default keyboard layout to German
setxkbmap -layout de -option ctrl:nocaps

# Start Qtile
~/.local/bin/startqtile
