#!/usr/bin/env zsh


# shellcheck disable=SC1090,SC1091,SC3001

#------------------------------------------------------------------------------#
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return ;;
esac

# When using Emacs TRAMP, we skip all the set up since it messes with
# the TRAMP protocol.
# https://blog.karssen.org/2016/03/02/fixing-emacs-tramp-mode-when-using-zsh/
if [[ "$TERM" == "dumb" && "${INSIDE_EMACS}" != "vterm" ]]; then
  unsetopt zle
  PS1="$ "
  return
fi

#------------------------------------------------------------------------------#
# set as a default for configurations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

#------------------------------------------------------------------------------#
# Directory of dotfiles for zsh
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# place comp dump in the cache
export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/.zcompdump-$HOST"

#------------------------------------------------------------------------------#
# Source profile EARLY so PATH and env vars are available for plugins
. "${HOME}/.profile"

#------------------------------------------------------------------------------#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]; then
    . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# use oh-my-zsh init
# shellcheck source=oh-my-zsh.sh
. "${ZDOTDIR}/oh-my-zsh.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f "${ZDOTDIR}/.p10k.zsh" ]] && . "${ZDOTDIR}/.p10k.zsh"

# shellcheck source=gear.zsh
. "${ZDOTDIR}/gear.zsh"

# ----------------------------------------------------
# vterm setup
# shellcheck source=vterm.zsh
[[ -f "${ZDOTDIR}/vterm.zsh" ]] && . "${ZDOTDIR}/vterm.zsh"

#------------------------------------------------------------------------------#
# ros setup

for ROS_VERSION in "noetic" "humble"; do
    if [ -f "/opt/ros/${ROS_VERSION}/setup.zsh" ]; then
        . "/opt/ros/${ROS_VERSION}/setup.zsh" > /dev/null
    fi
done

#------------------------------------------------------------------------------#
# Kubernetes setup
if command -v kubectl > /dev/null 2>&1; then
    # shellcheck disable=SC2039
    . <(kubectl completion zsh)
fi

#------------------------------------------------------------------------------#
# enable direnv for zsh
if command -v direnv > /dev/null 2>&1; then
    eval "$(direnv hook zsh)" > /dev/null
fi

# enable uv autocompletion
if command -v uv > /dev/null 2>&1; then
    eval "$(uv --generate-shell-completion zsh)"
fi
