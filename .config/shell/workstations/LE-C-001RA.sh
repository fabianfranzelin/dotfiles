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

alias init='wsl.exe -d wsl-vpnkit service wsl-vpnkit start; sudo service cntlm start; sudo service docker start'

# Restart ssh-agent on each startup. I do not know why this is required in WSL
pkill -9 ssh-agent && eval "$(ssh-agent -s)" > /dev/null
export SSH_AUTH_SOCK

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos_base"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

# make sure that there is a conan cache folder available
AOS_CONAN_CACHE="${HOME}/conan_download_cache"
[ -d "${AOS_CONAN_CACHE}" ] && echo "${__COLOR_WARN}WARN: HOME/conan_download_cache exists. Docker setup for AOS will not work if this folder is not removed.${__COLOR_RESET}"

#------------------------------------------------------------------------------#
# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"

#------------------------------------------------------------------------------#
# Ford
if [ -f "${HOME}/.forddat3/devcontainer" ]; then
    . "${HOME}/.forddat3/devcontainer"
fi

#------------------------------------------------------------------------------#
# AOS
export BOSCH_USER
BOSCH_USER="$(pass usernames/bosch)"
export BITBUCKET_TOKEN
BITBUCKET_TOKEN="$(pass tokens/${BOSCH_USER}@sourcecode01.de.bosch.com)"
export ARTIFACTORY_APIKEY
ARTIFACTORY_APIKEY="$(pass tokens/${BOSCH_USER}@rb-artifactory.bosch.com)"
export CONAN_LOGIN_USERNAME
CONAN_LOGIN_USERNAME="${BOSCH_USER}"
export CONAN_PASSWORD
CONAN_PASSWORD="${ARTIFACTORY_APIKEY}"

export RECOMPUTE_CONAN_PROFILE="ubuntu2004_x86_64_gcc8_debug"
export DISABLE_RECOMPUTE_DEPENDENCY_CHECK=1

#------------------------------------------------------------------------------#
# PJ-Rec
export ARTIFACTORY_USER
ARTIFACTORY_USER="$(pass usernames/bosch)"
export ARTIFACTORY_KEY
ARTIFACTORY_KEY="$(pass tokens/${ARTIFACTORY_USER}@artifactory.boschdevcloud.com)"
export ARTIFACTORY_KEY_RB
ARTIFACTORY_KEY_RB="${ARTIFACTORY_APIKEY}"

#------------------------------------------------------------------------------#
# One-parking
export ARTIFACTORY_API_KEY
ARTIFACTORY_API_KEY="${ARTIFACTORY_APIKEY}"
export BDC_428_ARTIFACTORY_API_KEY
BDC_428_ARTIFACTORY_API_KEY="${ARTIFACTORY_KEY}"
