#!/usr/bin/env sh

# shellcheck disable=SC1090

# Load specific settings for WSL

#------------------------------------------------------------------------------#
# load credentials
__DOTFILES=$(git rev-parse --show-toplevel)
__WORKSTATIONS_CONFIGS_PATH="${__DOTFILES}/.local/bin/shell/workstations"
[ -f "${__WORKSTATIONS_CONFIGS_PATH}/b_credentials.sh" ] && . "${__WORKSTATIONS_CONFIGS_PATH}/b_credentials.sh"

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

# .bashrc
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

alias init='wsl.exe -d wsl-vpnkit service wsl-vpnkit start; sudo service cntlm start; sudo service docker start'

#------------------------------------------------------------------------------#
# Azure DevOps
# Run cat BOSCH-CA-DE_pem.cer /opt/az/lib/python3.6/site-packages/certifi/cacert.pem > azure-bosch-cert.pem
export REQUESTS_CA_BUNDLE="${HOME}/.local/share/certificates/bosch/azure-bosch-cert.pem"

#------------------------------------------------------------------------------#
# Ford
if [ -f "${HOME}/.forddat3/devcontainer" ]; then
    . "${HOME}/.forddat3/devcontainer"
fi
