#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for Bosch

#------------------------------------------------------------------------------#
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"

#------------------------------------------------------------------------------#
# proxy

pass passwords/$(pass usernames/bosch)@login | kinit > /dev/null

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
