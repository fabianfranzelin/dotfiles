#!/usr/bin/env sh

# shellcheck disable=SC1090,SC1091

#------------------------------------------------------------------------------#
# Tool initialization - these are heavier operations that may add startup time

#------------------------------------------------------------------------------#
# Java
if command -v java > /dev/null 2>&1; then
    JAVA_HOME="$(dirname "$(dirname "$(readlink "$(readlink "$(command -v java)")")")")"
    export JAVA_HOME
fi

#------------------------------------------------------------------------------#
# NVM - lazy loaded for faster shell startup
# Instead of sourcing nvm.sh immediately, we create wrapper functions that
# load nvm on first use.
export NVM_DIR="${HOME}/.config/nvm"

if [ -s "$NVM_DIR/nvm.sh" ]
then
    unset -f nvm node npm npx 2>/dev/null
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

#------------------------------------------------------------------------------#
# SSH agent management
# If no SSH_AUTH_SOCK is set (and not overridden by workstation config),
# start or reuse an ssh-agent.
if [ -z "$SSH_AUTH_SOCK" ]; then
    __SSH_AGENT_ENV="${XDG_STATE_HOME:-$HOME/.local/state}/ssh/agent.env"
    if [ -f "$__SSH_AGENT_ENV" ]; then
        . "$__SSH_AGENT_ENV" > /dev/null
        # Check if the agent is still running
        if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            unset SSH_AGENT_PID SSH_AUTH_SOCK
        fi
    fi

    if [ -z "$SSH_AUTH_SOCK" ]; then
        mkdir -p "$(dirname "$__SSH_AGENT_ENV")"
        eval "$(ssh-agent -s)" > /dev/null
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$__SSH_AGENT_ENV"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "$__SSH_AGENT_ENV"
    fi
    unset __SSH_AGENT_ENV
fi

#------------------------------------------------------------------------------#
# Ollama
export OLLAMA_MODELS=/home/frf2lr/.cache/llms
