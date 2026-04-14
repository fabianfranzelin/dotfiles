#!/usr/bin/env sh

# shellcheck disable=SC1090,SC2139

if ( __is_linux )
then
    # these aliases require systemd running, hence it just works on
    # native Linux
    alias reboot='systemctl reboot'
    alias shutdown='systemctl poweroff'
    MY_LOGIN_SESSION=$(loginctl session-status | head -n 1 | awk '{print $1}')
    alias logout="loginctl terminate-session ${MY_LOGIN_SESSION}"

    # Seahorse
    alias restart_gnome_keyring_daemon="gnome-keyring-daemon --replace --components=pkcs11,secrets,ssh && seahorse"
fi

alias cp='cp -i -P'
alias mv='mv -i'
alias grep='grep --color=auto'

alias c='clear'
# macOS: --color=auto needed for coreutils
alias l='ls -1F --color=auto'
alias la='ls -1F --color=auto -a'
alias ll='ls -1F --color=auto -lh'
alias lla='ls -1F --color=auto -lha'

alias cp='cp -i -P'
alias mv='mv -i'
alias grep='grep --color=auto'

alias c='clear'
# macOS: --color=auto needed for coreutils
alias l='ls -1F --color=auto'
alias la='ls -1F --color=auto -a'
alias ll='ls -1F --color=auto -altrh'
alias lla='ls -1F --color=auto -lha'

alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias .6='cd ../../../../../..'
alias .7='cd ../../../../../../,,'
alias .8='cd ../../../../../../../..'
alias ..='cd ..'
alias ...='.2'
alias ....='.3'
alias .....='.4'
alias ......='.5'
alias .......='.6'
alias ........='.7'

# 'A' for ANSI line graphics
# 'C' for colorization
# 'F' for types, e.g. dir -> dir/
alias tree='tree -A -C -F'

alias g='git'

alias py='python'
alias py3='python3'
alias ipy3='ipython3'

# Docker
alias doi='docker images'
alias doc='docker container list'
alias dosp='docker system prune -f'
alias dormi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias doir='docker image rm'

# Emacs #######################################################################
alias e="emacsclient -c -a emacs"
alias en="emacsclient -nw"
alias ek="killall emacs"
alias ef="emacs --daemon"
alias em="emacs --init-directory=~/.config/minimal-emacs"
alias en="emacs --init-directory=~/.config/native-emacs"

alias emacs_stop="edk"
alias emacs_start="efs"
alias emacs_restart="edr"
alias ff='find_file'

# unlock gpg key: note, that pinentry-curses does not work with every
# terminal. So I enforce here one that is actually supported
alias unlock_key="TERM=xterm-256color pass usernames/public@github > /dev/null"
alias u="unlock_key"
alias kill_gpg_agent="gpgconf --kill gpg-agent"

alias spa='sshpass -p "$(pass passwords/frf2lr@pauline)" ssh frf2lr@pauline'
alias sp='sshpass -p "$(pass passwords/frf2lr@pauline)" ssh -t frf2lr@pauline "emacsclient -nw -a emacs; exec /usr/bin/zsh"'
