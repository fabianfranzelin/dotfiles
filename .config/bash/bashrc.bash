#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091,SC3001

#------------------------------------------------------------------------------#
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return ;;
esac

# When using Emacs TRAMP, we skip all the set up since it messes with
# the TRAMP protocol.
[[ "$TERM" == "dumb" ]] && PS1="$ " && return

#------------------------------------------------------------------------------#
# set as a default for configurations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

#------------------------------------------------------------------------------#
# Directory of dotfiles for bash
export BASHDOTDIR="${XDG_CONFIG_HOME}/bash"

#------------------------------------------------------------------------------#
# Source profile EARLY so PATH and env vars are available for completions/plugins
. "${HOME}/.profile"

#------------------------------------------------------------------------------#
# Bash history configuration
shopt -s histappend        # append to history file, don't overwrite
shopt -s cmdhist           # save multi-line commands as one entry
HISTCONTROL=ignoreboth:erasedups  # ignore duplicates and lines starting with space
HISTSIZE=10000
HISTFILESIZE=20000
# Write history after each command (not just on shell exit)
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

# shellcheck source=gear.bash
. "${BASHDOTDIR}/gear.bash"

# ----------------------------------------------------
# Prompt setup
# shellcheck source=prompts/left/default.sh
. "${BASHDOTDIR}/prompts/left/default.sh"

#------------------------------------------------------------------------------#
# vterm setup
[[ -f "${BASHDOTDIR}/vterm.bash" ]] && . "${BASHDOTDIR}/vterm.bash"

#------------------------------------------------------------------------------#
# ros setup

for ROS_VERSION in "noetic" "humble"; do
    if [ -f "/opt/ros/${ROS_VERSION}/setup.bash" ]; then
        . "/opt/ros/${ROS_VERSION}/setup.bash" > /dev/null
    fi
done

#------------------------------------------------------------------------------#
# Kubernetes setup
if command -v kubectl > /dev/null 2>&1; then
    # shellcheck disable=SC2039
    . <(kubectl completion bash)
fi

#------------------------------------------------------------------------------#
# enable direnv
if command -v direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)" > /dev/null
fi

# enable autocompletion for uv
if command -v uv > /dev/null 2>&1; then
    eval "$(uv --generate-shell-completion bash)"
fi

# cargo/rust env
[[ -f "$HOME/.local/share/../bin/env" ]] && . "$HOME/.local/share/../bin/env"
