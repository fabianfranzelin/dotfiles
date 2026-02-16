#!/usr/bin/env sh

# Load specific settings for ThinkPad
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
