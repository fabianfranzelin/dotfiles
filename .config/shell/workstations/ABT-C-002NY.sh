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

# initialize default setup according to the available wifis
current_wifi=$(nmcli dev wifi list)

if echo "$current_wifi" | grep -q "Tomate"; then
    alias init='autorandr --load gottenheim; set_keyboard_layout; unlock_key; osd-vpn-connect -k'
elif echo "$current_wifi" | grep -q "Pauline"; then
    alias init='autorandr --load pauline; set_keyboard_layout; unlock_key; osd-vpn-connect -k'
else
    alias init='set_keyboard_layout; unlock_key; osd-vpn-connect -k'
fi

#------------------------------------------------------------------------------#
# Azure DevOps
# Run  cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
# export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"
