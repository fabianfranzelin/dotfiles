#!/usr/bin/env sh

# shellcheck disable=SC1090

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
esac

#------------------------------------------------------------------------------#
# initialization
export __SHELL_LIB="${HOME}/.local/bin/shell"
. "${__SHELL_LIB}/faq.sh"

#------------------------------------------------------------------------------#
# load gear for used shell

if ( __is_zsh ); then
    # shellcheck source=gear.zsh
    . "${__SHELL_LIB}/gear.zsh"

    # Directory of dotfiles for zsh
    export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

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
    if [ -f "${ZDOTDIR}/.p10k.zsh" ]; then
        . "${ZDOTDIR}/.p10k.zsh"
    fi

    # bash compinit in zsh
    bindkey -e

    autoload -U bashcompinit
    bashcompinit

    # ----------------------------------------------------
    # vterm setup
    # shellcheck source=vterm.zsh
    . "${__SHELL_LIB}/vterm.zsh"

elif ( __is_bash ); then
    # shellcheck source=gear.bash
    . "${__SHELL_LIB}/gear.bash"

    # ----------------------------------------------------
    # Prompt setup
    # shellcheck source=prompts/left/default.sh
    . "${__SHELL_LIB}/prompts/left/default.sh"
elif [ "$TERM" = "dumb" ]; then
    # fixes fancy prompt issues when called from remote modules like emacs
    export PS1="$ "
fi

# Load aliases
. "${__SHELL_LIB}/aliases.sh"
