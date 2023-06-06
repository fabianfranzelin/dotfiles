#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for Bosch

#------------------------------------------------------------------------------#
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"

#------------------------------------------------------------------------------#
# authentication and tokens
pass passwords/$(pass usernames/bosch)@login | kinit > /dev/null
load_tokens

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos_base"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

export ENVIRONMENT_NAME="Classic-with-Bosch-BCN-Services"

# QNX
export SWT_GTK3=0
export FLEXLM_TIMEOUT=3000000

# make sure that there is a conan cache folder is not available
AOS_CONAN_CACHE="${HOME}/conan_download_cache"
[ -d "${AOS_CONAN_CACHE}" ] && echo "${__COLOR_WARN}WARN: HOME/conan_download_cache exists. Docker setup for AOS will not work if this folder is not removed.${__COLOR_RESET}"

#------------------------------------------------------------------------------#
# PJ-Rec

#------------------------------------------------------------------------------#
# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"

#------------------------------------------------------------------------------#
# Ford
if [ -f "${HOME}/.forddat3/devcontainer" ]; then
    . "${HOME}/.forddat3/devcontainer"
fi
