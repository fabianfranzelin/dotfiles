#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for Bosch

#------------------------------------------------------------------------------#
# Dotfiles setup
export __SHELL_LIB="${XDG_CONFIG_HOME}/shell"

export HTTP_PROXY="http://127.0.0.1:3128"
export HTTPS_PROXY="http://127.0.0.1:3128"

# Set default browser use `xdg-open` to call it
export BROWSER=firefox

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

export ENVIRONMENT_NAME="Classic-with-Bosch-BCN-Services"

# QNX
export SWT_GTK3=0
export FLEXLM_TIMEOUT=3000000

# make sure that there is a conan cache folder is not available
export CONAN_USER_HOME="${HOME}/.aos_conan_download_cache"
export AOS_WORKDIR="${HOME}/.aos_conan_download_cache"
mkdir -p "${AOS_WORKDIR}"
export DISABLE_RECOMPUTE_DEPENDENCY_CHECK=1

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
