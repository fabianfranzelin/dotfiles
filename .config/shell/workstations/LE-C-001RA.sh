#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for WSL

#------------------------------------------------------------------------------#
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"

#------------------------------------------------------------------------------#
# WSL specific stuff

# .profile
export no_proxy="localhost,127.0.0.*,192.168.*,.local,172.*,.bosch.*,.bosch-iot-cloud.com"
export http_proxy="http://127.0.0.1:3128"
export https_proxy="http://127.0.0.1:3128"
export HTTP_PROXY="http://127.0.0.1:3128"
export HTTPS_PROXY="http://127.0.0.1:3128"
export ALL_proxy="http://127.0.0.1:3128"
export all_proxy="http://127.0.0.1:3128"
export ftp_proxy="http://127.0.0.1:3128"

# Make X server available
export DISPLAY="`grep nameserver /etc/resolv.conf | sed 's/nameserver //'`:0"
export LIBGL_ALWAYS_INDIRECT=1

# .bashrc
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

alias init='wsl.exe -d wsl-vpnkit service wsl-vpnkit start; sudo service cntlm start; sudo service docker start; load_tokens'

# Restart ssh-agent on each startup. I do not know why this is required in WSL
pkill -9 ssh-agent && eval "$(ssh-agent -s)" > /dev/null
export SSH_AUTH_SOCK

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

# make sure that there is a conan cache folder is not available
export CONAN_USER_HOME="${HOME}/.aos_conan_download_cache"
export AOS_WORKDIR="${HOME}/.aos_conan_download_cache"
mkdir -p "${AOS_WORKDIR}"

#------------------------------------------------------------------------------#
# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"

#------------------------------------------------------------------------------#
# Ford
if [ -f "${HOME}/.forddat3/devcontainer" ]; then
    . "${HOME}/.forddat3/devcontainer"
fi
