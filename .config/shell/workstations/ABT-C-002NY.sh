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

# initialize default setup
# alias init='autorandr --load gottenheim; set_keyboard_layout; unlock_key; osd-vpn-connect; emacs --daemon'
alias init='autorandr --load home-docking-station; set_keyboard_layout; unlock_key; osd-vpn-connect'

#------------------------------------------------------------------------------#
# AOS
export AOS_BASE_HOME="${HOME}/workspace/aos"
export AOS_BUILD_DIR="${AOS_BASE_HOME}/build"
export AOS_INSTALL_DIR="${AOS_BASE_HOME}/install"

export ENVIRONMENT_NAME="Classic-with-Bosch-BCN-Services"
export CONAN_DISABLE_STRICT_MODE=1

# QNX
export SWT_GTK3=0
export FLEXLM_TIMEOUT=3000000

# Parasoft
PARASOFT_INSTALL_DIR="${HOME}/.local/share/parasoft"
PATH="$PATH:${PARASOFT_INSTALL_DIR}/cpptest/bin/cli:${PARASOFT_INSTALL_DIR}/cpptest_ct/bin"

#------------------------------------------------------------------------------#
# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"
