#!/usr/bin/env sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
esac

#------------------------------------------------------------------------------#
# initialization
export __SHELL_LIB="${HOME}/.local/bin/shell"
. "${__SHELL_LIB}/utils/faq.sh"

#------------------------------------------------------------------------------#
# load gear for used shell

if ( __is_zsh ); then
    # shellcheck source=gear.zsh
    . "${__SHELL_LIB}/gear.zsh"

    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # use oh-my-zsh init
    # shellcheck source=oh-my-zsh.sh
    . "${__SHELL_LIB}/oh-my-zsh.sh"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    if [ -f "$HOME/.p10k.zsh" ]; then
        . "$HOME/.p10k.zsh"
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
    # shellcheck source=prompts/left/git_info.sh
    . "${__SHELL_LIB}/prompts/right/git_info.sh"
elif [ "$TERM" = "dumb" ]; then
    # fixes fancy prompt issues when called from remote modules like emacs
    export PS1="$ "
fi

#------------------------------------------------------------------------------#
# aliases

alias reboot='shutdown now --reboot'

alias cp='cp -i -P'
alias mv='mv -i'
alias grep='grep --color=auto'

alias c='clear'
# macOS: --color=auto needed for coreutils
alias l='ls -1F --color=auto'
alias la='ls -1F --color=auto -a'
alias ll='ls -1F --color=auto -lh'
alias lla='ls -1F --color=auto -lha'

alias reboot='shutdown now --reboot'

alias cp='cp -i -P'
alias mv='mv -i'
alias grep='grep --color=auto'

alias c='clear'
# macOS: --color=auto needed for coreutils
alias l='ls -1F --color=auto'
alias la='ls -1F --color=auto -a'
alias ll='ls -1F --color=auto -lh'
alias lla='ls -1F --color=auto -lha'

alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias .6='cd ../../../../../..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias cddot="cd ${DOTFILES}"

# 'A' for ANSI line graphics
# 'C' for colorization
# 'F' for types, e.g. dir -> dir/
alias tree='tree -A -C -F'

alias g='git'

alias py='python'
alias py2='python2'
alias py3='python3'
# Kubernetes
alias k='kubectl --namespace=development-${USER}'
alias kp='kubectl --namespace=production'

# Docker
alias doi='docker images'
alias doc='docker container list'
alias dosp='docker system prune -f'
alias dormi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias doir='docker image rm'

alias ff='find_file'

#------------------------------------------------------------------------------#
# cleanup

unset __SHELL_LIB
