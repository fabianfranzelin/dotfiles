#!/usr/bin/env sh

# shellcheck disable=SC1090,SC2139

alias reboot='systemctl reboot'
alias shutdown='systemctl poweroff'
MY_LOGIN_SESSION=$(loginctl session-status | head -n 1 | awk '{print $1}')
alias logout="loginctl terminate-session ${MY_LOGIN_SESSION}"

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
alias eds="systemctl --user start emacs"
alias edr="systemctl --user restart emacs"
alias emacs_stop="systemctl --user stop emacs"
alias emacs_start="systemctl --user start emacs"
alias emacs_restart="systemctl --user restart emacs"
alias ff='find_file'
