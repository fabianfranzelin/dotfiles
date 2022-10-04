#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for Bosch

#------------------------------------------------------------------------------#
# load credentials
# ----------------------------------------------------
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"
[ -f "${__SHELL_LIB}/workstations/b_credentials.sh" ] && . "${__SHELL_LIB}/workstations/b_credentials.sh"

#------------------------------------------------------------------------------#
# proxy

export no_proxy="localhost,127.0.0.*,192.168.*,.local,172.*,.bosch.*,.bosch-iot-cloud.com"
export http_proxy="http://127.0.0.1:3128"
export https_proxy="http://127.0.0.1:3128"
export HTTP_PROXY="http://127.0.0.1:3128"
export HTTPS_PROXY="http://127.0.0.1:3128"
export ALL_proxy="http://127.0.0.1:3128"
export all_proxy="http://127.0.0.1:3128"
export ftp_proxy="http://127.0.0.1:3128"

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos_base"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

# make sure that there is a conan cache folder available
AOS_CONAN_CACHE="${HOME}/conan_download_cache"
[ ! -d "${AOS_CONAN_CACHE}" ] && mkdir -p "${AOS_CONAN_CACHE}"

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
