#!/usr/bin/env sh

#------------------------------------------------------------------------------#
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return ;;
esac

#------------------------------------------------------------------------------#
# set as a default for configurations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# ----------------------------------------------------
# Dotfiles setup
export __SHELL_LIB="$HOME/.local/bin/shell"
source "${__SHELL_LIB}/shellrc.sh"

# ----------------------------------------------------
# personal

# We're in Emacs, yo
export VISUAL=emacsclient
export EDITOR="$VISUAL"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# git
export GIT_EDITOR=vim

# Make sure `ls` collates dotfiles first (for dired)
export LC_COLLATE="C"

# Start gnome keyring
eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
export SSH_AUTH_SOCK

# expand path to include local bin directory
PATH=$HOME/opt/bin:$HOME/.local/bin:/usr/lib/ccache:$PATH

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
# SGpp
export SGPP_HOME=$HOME/workspace/SGpp_ff
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SGPP_HOME/lib/sgpp
export PYTHONPATH=$PYTHONPATH:$SGPP_HOME/lib

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos_base"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

#------------------------------------------------------------------------------#
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

#------------------------------------------------------------------------------#
# make aliases available in eshell
# mkdir -p "$HOME/.emacs.d/eshell"
# alias | sed 's/^alias //' | sed -E "s/^([^=]+)='(.+?)'$/\1=\2/" | sed "s/'\\\\''/'/g" | sed "s/'\\\\$/'/;" | sed -E 's/^([^=]+)=(.+)$/alias \1 \2/' > "$HOME/.emacs.d/eshell/alias"

#------------------------------------------------------------------------------#
# enable direnv for bash or zsh
eval "$(direnv hook $(echo $0 | cut -d'/' -f3))" > /dev/null
