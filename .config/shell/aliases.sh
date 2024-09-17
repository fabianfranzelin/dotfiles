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

   # vpn
   alias vpn_reconnect="/usr/bin/gnome-terminal -- bash -c \"osd-vpn-disconnect && osd-vpn-connect -k\""
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
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# 'A' for ANSI line graphics
# 'C' for colorization
# 'F' for types, e.g. dir -> dir/
alias tree='tree -A -C -F'

alias g='git'

alias py='python'
alias py2='python2'
alias py3='python3'
alias ipy3='ipython3'

# Kubernetes
alias k='kubectl --namespace=development-${USER}'
alias kp='kubectl --namespace=production'

# Docker
alias doi='docker images'
alias doc='docker container list'
alias dosp='docker system prune -f'
alias dormi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias doir='docker image rm'

# Emacs
alias e="emacsclient -c -a emacs"
alias en="emacsclient -nw"
alias eds="e --daemon"
alias edk="killall emacs"
alias edr="edk; eds"
alias em="emacs --init-directory=~/.config/minimal-emacs"
alias emd="er --daemon"
alias er="emacs --init-directory=~/.config/rational-emacs"
alias erd="er --daemon"

alias emacs_stop="edk"
alias emacs_start="eds"
alias emacs_restart="edr"
alias ff='find_file'

# unlock gpg key
alias unlock_key="pass usernames/public@github > /dev/null"
alias u="unlock_key"
alias kill_gpg_agent="gpgconf --kill gpg-agent"
