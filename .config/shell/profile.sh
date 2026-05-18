#!/usr/bin/env sh

# shellcheck disable=SC1090,SC1091,SC3001

#------------------------------------------------------------------------------#
# If not running interactively, don't do anything

case $- in
    *i*) ;;
    *) return ;;
esac

#------------------------------------------------------------------------------#
# Environment variables, PATH, and basic settings
. "${HOME}/.config/shell/env.sh"

#------------------------------------------------------------------------------#
# Shell helpers and aliases
. "${__SHELL_LIB}/faq.sh"
. "${__SHELL_LIB}/aliases.sh"

#------------------------------------------------------------------------------#
# Tool initialization (NVM lazy-load, Java, SSH agent)
. "${__SHELL_LIB}/tools.sh"

#------------------------------------------------------------------------------#
# Load specific settings per workstation (may override SSH agent, proxy, etc.)
__HOST_SETTINGS="${__SHELL_LIB}/workstations/$(hostname).sh"
[ -f "${__HOST_SETTINGS}" ] && . "${__HOST_SETTINGS}"
