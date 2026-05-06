#!/usr/bin/env zsh

#------------------------------------------------------------------------------#
# autoloading own functions
__SHELL_LIB="${XDG_CONFIG_HOME}/shell"

fpath=(
    "${__SHELL_LIB}/func"
    "${fpath[@]}"
)

dirs=( "${__SHELL_LIB}" )
for dir in "${dirs[@]}"; do
    if [ -d "${dir}/func" ]; then
        # is folder empty?
        if [ -n "$(ls -A "${dir}/func")" ]; then
            for file in "${dir}/func/"*; do
                autoload -Uz "${file}";
            done
        fi
    fi
done

#------------------------------------------------------------------------------#
# autoloading others

autoload -Uz compinit && compinit -u
autoload colors && colors

# bash auto completion
autoload -U bashcompinit
bashcompinit

# append to the history file, don't overwrite it
setopt append_history
# share history across terminals
setopt share_history
# immediately append to history file, not just when a term is killed
setopt inc_append_history
# do not save duplicated command
setopt hist_save_no_dups
# make history compatible with bash. This disables the znt-history
# widget, hence, I need to enable it manually once more
unsetopt extendedhistory

#------------------------------------------------------------------------------#
# keybindings

# man zshzle
# shows manual for bindkey

# zle -al
# shows all available cmds

# showkey -a
# shows keys when pressed

# default: emacs
bindkey -e

# load zsh history widget
autoload znt-history-widget
zle -N znt-history-widget
bindkey "^R" znt-history-widget

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
