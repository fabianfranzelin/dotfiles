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
# Directory of dotfiles for zsh
export BASHDOTDIR="${XDG_CONFIG_HOME}/bash"

# shellcheck source=gear.bash
. "${BASHDOTDIR}/gear.bash"

# ----------------------------------------------------
# Prompt setup
# shellcheck source=prompts/left/default.sh
. "${BASHDOTDIR}/prompts/left/default.sh"

#------------------------------------------------------------------------------#
# set as a default for configurations
. "${HOME}/.profile"

#------------------------------------------------------------------------------#
# ros setup

for ROS_VERSION in "noetic" "humble"; do
    if [ -f "/opt/ros/${ROS_VERSION}/setup.bash" ]; then
        . "/opt/ros/${ROS_VERSION}/setup.bash" > /dev/null
    fi
done

#------------------------------------------------------------------------------#
# Kubernetes setup
if command -v kubectl > /dev/null
then
    # shellcheck disable=SC2039
    . <(kubectl completion bash)
fi

#------------------------------------------------------------------------------#
# enable direnv for bash or zsh
eval "$(direnv hook "$(command -v bash)")" > /dev/null
