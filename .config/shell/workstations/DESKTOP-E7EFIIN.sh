#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for WSL

#------------------------------------------------------------------------------#
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"

#------------------------------------------------------------------------------#
# WSL specific stuff

# Make X server available
export DISPLAY="`grep nameserver /etc/resolv.conf | sed 's/nameserver //'`:0"
export LIBGL_ALWAYS_INDIRECT=1

# Set default browser use `xdg-open` to call it
export BROWSER=wslview
alias firefox="xdg-open"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

alias init='vcxsrv-multi-window'
