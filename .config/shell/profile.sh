#!/usr/bin/env sh

# shellcheck disable=SC1090,SC1091,SC3001

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
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

#------------------------------------------------------------------------------#
# initialization
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"
. "${__SHELL_LIB}/faq.sh"
. "${__SHELL_LIB}/aliases.sh"

# ----------------------------------------------------
# personal

# We're in Emacs, yo
export EDITOR="emacsclient -nw -a vim" # Editor opens in terminal mode
export VISUAL="emacsclient -c -a emacs"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'


# fixes fancy prompt issues when called from remote modules like emacs
if [ "$TERM" = "dumb" ]; then
    export PS1="$ "
fi

# Make sure `ls` collates dotfiles first (for dired)
export LC_COLLATE="C"

# Start gnome keyring
if ( __is_linux ) then
   eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
   export SSH_AUTH_SOCK
fi

# expand path to include local bin directory
export PATH="${HOME}/opt/bin:${HOME}/.local/bin:/usr/lib/ccache:${PATH}"

# Fix for docker /dev/shm issue: https://github.com/docker/buildx/issues/418
export DOCKER_BUILDKIT=0

#------------------------------------------------------------------------------#
# Export the path to Java so that tools pick it up correctly
JAVA_HOME="$(dirname "$(dirname "$(readlink "$(readlink "$(command -v java)")")")")"
export JAVA_HOME

# R setup
export R_ENVIRON_USER="${XDG_CONFIG_HOME}/R/environ.sh"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/R/profile.R"

# certificates path
export CERT_PATH="${HOME}/.local/share/certificates"

# Postgres debug port
export POSTGRES_PORT=2345

#------------------------------------------------------------------------------#
# SGpp
export SGPP_HOME="${HOME}/workspace/SGpp_ff"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${SGPP_HOME}/lib/sgpp"
export PYTHONPATH="${PYTHONPATH}:${SGPP_HOME}/lib"

#------------------------------------------------------------------------------#
# Virtual environments for python
export WORKON_HOME="${HOME}/.virtualenvs"
export PIP_VIRTUALENV_BASE="${WORKON_HOME}"

#------------------------------------------------------------------------------#
# NPM
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

#------------------------------------------------------------------------------#
# make aliases available in eshell
# mkdir -p "${XDG_CONFIG_HOME}/emacs/eshell"
# alias | sed 's/^alias //' | sed -E "s/^([^=]+)='(.+?)'$/\1=\2/" | sed "s/'\\\\''/'/g" | sed "s/'\\\\$/'/;" | sed -E 's/^([^=]+)=(.+)$/alias \1 \2/' > "$HOME/.emacs.d/eshell/alias"

#------------------------------------------------------------------------------#
# Load specific settings per workstation
[ "$(hostname)" = "ThinkPad" ] && . "${__SHELL_LIB}/workstations/ThinkPad.sh"
[ "$(hostname)" = "ST39-C-00066" ] && . "${__SHELL_LIB}/workstations/st39-c-00066.sh"
[ "$(hostname)" = "LR-Z7407" ] && . "${__SHELL_LIB}/workstations/LR-Z7407.sh"
[ "$(hostname)" = "LE-C-001RA" ] && . "${__SHELL_LIB}/workstations/LE-C-001RA.sh"
