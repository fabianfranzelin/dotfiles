#!/usr/bin/env sh

#------------------------------------------------------------------------------#
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return ;;
esac

#------------------------------------------------------------------------------#
# setup
export DOTFILES="$HOME/workspace/dotfiles/."
. "${DOTFILES}/utils/faq.sh"

# set as a default for configurations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# ----------------------------------------------------
# Dotfiles setup
source "${DOTFILES}/shell/shellrc.sh"

# ----------------------------------------------------
# ZSH settings

if (__is_zsh); then
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # use oh-my-zsh init
    . "${DOTFILES}/shell/oh-my-zsh.sh"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

    # bash compinit in zsh
    bindkey -e

    autoload -U bashcompinit
    bashcompinit

    # ----------------------------------------------------
    # vterm setup
    source "${DOTFILES}/shell/vterm.zsh"
fi

#------------------------------------------------------------------------------#
# Bash setup

if (__is_bash); then
    # ----------------------------------------------------
    # Dotfiles setup
    source "${DOTFILES}/shell/shellrc.sh"

    # ----------------------------------------------------
    # Prompt setup
    source "${DOTFILES}/shell/prompts/left/default.sh"
    source "${DOTFILES}/shell/prompts/right/git_info.sh"
fi

# ----------------------------------------------------
# fixes fancy prompt issues when called from remote modules like emacs
if [[ $TERM == "dumb" ]]; then
    export PS1="$ "
fi

# ----------------------------------------------------
# personal

# We're in Emacs, yo
export VISUAL=emacsclient
export EDITOR="$VISUAL"

# Make sure `ls` collates dotfiles first (for dired)
export LC_COLLATE="C"

# Start gnome keyring
if [[ -n "$DESKTOP_SESSION" ]]; then
    eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
    export SSH_AUTH_SOCK
else
    # start ssh agent for remote sessions and add personal
    # certificates to prevent repeated password input
    . "${HOME}/.ssh-find-agent"
    ssh_find_agent -a
    if [ -z "$SSH_AUTH_SOCK" ]
    then
        eval $(ssh-agent) > /dev/null
        ssh-add
    fi
fi

# expand path to include local bin directory
PATH=$HOME/opt/bin:$HOME/.local/bin:$PATH

#------------------------------------------------------------------------------#
# ros setup

if (__is_zsh); then
    # melodic is only for Ubuntu 20.04
    if [[ -f "/opt/ros/noetic/setup.zsh" ]]; then
        source "/opt/ros/noetic/setup.zsh" > /dev/null
    fi
elif (__is_bash); then
    # melodic is only for Ubuntu 20.04
    if [[ -f "/opt/ros/noetic/setup.bash" ]]; then
        source "/opt/ros/noetic/setup.bash" > /dev/null
    fi
fi

#------------------------------------------------------------------------------#
# Export the path to Java so that tools pick it up correctly
export JAVA_HOME="$(dirname $(dirname $(readlink $(readlink $(which java)))))"

# certificates path
export CERT_PATH="$HOME/.local/share/certificates"

# Postgres debug port
export POSTGRES_PORT=2345

#------------------------------------------------------------------------------#
# Kubernetes setup
if command -v kubectl &> /dev/null
then
    if (__is_zsh); then
        source <(kubectl completion zsh)
    elif (__is_bash); then
        source <(kubectl completion bash)
    fi
fi

#------------------------------------------------------------------------------#
# npm
NPM_VERSION='v13.14.0'
NPM_DISTRO='linux-x64'
export PATH="/usr/local/lib/nodejs/node-${NPM_VERSION}-${NPM_DISTRO}/bin:${PATH}"

#------------------------------------------------------------------------------#
# SGpp
export SGPP_HOME=$HOME/workspace/SGpp_ff
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SGPP_HOME/lib/sgpp
export PYTHONPATH=$PYTHONPATH:$SGPP_HOME/lib

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME=$HOME/workspace/aos_base
export RECOMPUTE_HOME=$AOS_BASE_HOME/recompute
export AOS_BUILD_DIR=$AOS_BASE_HOME/_build
export AOS_INSTALL_DIR=$AOS_BASE_HOME/_install
export RECOMPUTE_BUILD_DIR=$AOS_BASE_HOME/build_recapp
export RECOMPUTE_INSTALL_DIR=$AOS_BASE_HOME/install_recapp/recompute

#------------------------------------------------------------------------------#
## DoL player
if [[ -d "${RECOMPUTE_INSTALL_DIR}" ]]; then
    "${RECOMPUTE_INSTALL_DIR}/host/bin/test/dol_source_env.sh"
    export DOL_MANIFEST_DIR="${RECOMPUTE_INSTALL_DIR}/target/share/manifests"
    PATH=$PATH:${RECOMPUTE_BUILD_DIR}/recompute/source/host/tooling/sequenceprofiler
fi

# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
# export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"

# Virtual environments for python
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME

# Make sure that the debian package virtualenvwrapper is installed for
# the following to work. If errors occur, install it via "pip3 install
# virtualenvwrapper"
if [[ -f "/usr/share/virtualenvwrapper/virtualenvwrapper.sh" ]]; then
    source "/usr/share/virtualenvwrapper/virtualenvwrapper.sh"

    # pip bash completion start
    _pip_completion()
    {
        COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                                 COMP_CWORD=$COMP_CWORD \
                                 PIP_AUTO_COMPLETE=1 $1 ) )
    }
    complete -o default -F _pip_completion pip
    # pip bash completion end
fi

# make aliases available in eshell
mkdir -p "$HOME/.emacs.d/eshell"
alias | sed 's/^alias //' | sed -E "s/^([^=]+)='(.+?)'$/\1=\2/" | sed "s/'\\\\''/'/g" | sed "s/'\\\\$/'/;" | sed -E 's/^([^=]+)=(.+)$/alias \1 \2/' > "$HOME/.emacs.d/eshell/alias"
