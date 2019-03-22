# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
esac

################################################################################
# initialization

if [[ -z "${DOTFILES}" ]]; then
    export DOTFILES="${HOME}/dotfiles"
fi
_shell_lib="${DOTFILES}/shell"
_custom_shell_lib="${DOTFILES}/custom/shell"

################################################################################
# autoloading

if [[ -n "${ZSH_NAME}" ]]; then
    ############################################################################
    # own functions

    fpath=(
        "${_custom_shell_lib}/func"
        "${_shell_lib}/func"
        "${fpath[@]}"
    )

    _dirs=( "${_shell_lib}" "${_custom_shell_lib}" )
    for _dir in "${_dirs[@]}"; do
        if [[ -d "${_dir}/func" ]]; then
            # is folder empty?
            if [[ -n "$(ls -A "${_dir}/func")" ]]; then
                for _file in "${_dir}/func/"*; do
                    autoload -Uz "${_file}";
                done
            fi
        fi
    done

    ############################################################################
    # brew autocompletion

    if ( which brew 1>/dev/null 2>/dev/null ); then
        # ATTENTION! has to be before 'autoload -Uz compinit'
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    fi

    ############################################################################
    # others

    autoload -Uz compinit && compinit
    autoload colors && colors

    ############################################################################
    # kubectl autocompletion

    if ( which kubectl 1>/dev/null 2>/dev/null ); then
        . <(kubectl completion zsh)
    fi

elif [[ -n "${BASH}" ]]; then
    ############################################################################
    # own functions
    # check in both cases whether directory exists and is not empty

    _dirs=( "${_shell_lib}" "${_custom_shell_lib}" )
    for _dir in "${_dirs[@]}"; do
        if [[ -d "${_dir}/func" ]]; then
            # is folder empty?
            if [[ -n "$(ls -A "${_dir}/func")" ]]; then
                for _file in "${_dir}/func/"*; do
                    . "${_file}";
                done
            fi
        fi
    done

    ############################################################################
    # brew autocompletion

    if ( which brew 1>/dev/null 2>/dev/null ); then
        for _file in "$(brew --prefix)/etc/bash_completion.d/"*; do
            [[ -f "${_file}" ]] && . "${_file}"
        done

        _file="$(brew --prefix)/etc/profile.d/bash_completion.sh"
        [[ -f "${_file}" ]] && . "${_file}"
    fi

    ############################################################################
    # (from previous, default bashrc on ubuntu)
    # enable programmable completion features (you don't need to enable this, if
    # it's already enabled in /etc/bash.bashrc and /etc/profile)

    if ! shopt -oq posix; then
        if [ -f '/usr/share/bash-completion/bash_completion' ]; then
            . '/usr/share/bash-completion/bash_completion'
        elif [ -f '/etc/bash_completion' ]; then
            . '/etc/bash_completion'
        fi
    fi

    ############################################################################
    # kubectl autocompletion

    if ( which kubectl 1>/dev/null 2>/dev/null ); then
        . <(kubectl completion bash)
    fi
fi

################################################################################
# history

HISTSIZE=10000
SAVEHIST=10000

if [[ -n "${ZSH_NAME}" ]]; then
    HISTFILE="${HOME}/.zsh_history"
    # append to the history file, don't overwrite it
    setopt append_history
    # share history across terminals
    setopt share_history
    # immediately append to history file, not just when a term is killed
    setopt inc_append_history

elif [[ -n "${BASH}" ]]; then
    HISTFILE="${HOME}/.bash_history"
    # append to the history file, don't overwrite it
    shopt -s histappend
fi

################################################################################
# exports

# coreutils
if ( is_machine 'macOS' ); then
    # head links to ghead instead of macOS-head
    PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
fi

# general
export EDITOR='vi'
export VISUAL='code'

# git
if ( which "${VISUAL}" 1>/dev/null 2>/dev/null); then
    export GIT_EDITOR="${VISUAL} --wait"
else
    export GIT_EDITOR="${EDITOR}"
fi

# python
if ( is_machine 'macOS' ); then
    # used in vscode to find a default python interpreter
    export PYTHON_INTERPRETER_PATH='/usr/local/bin/python3'

    export PATH="${HOME}/Library/Python/2.7/bin:${PATH}"
    export PATH="${HOME}/Library/Python/3.7/bin:${PATH}"
fi

# java
if ( is_machine 'macOS' ); then
    export JAVA_HOME="$(/usr/libexec/java_home)"
    export PATH="${JAVA_HOME}:${PATH}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
fi

################################################################################
# aliases

alias cd="cd -P"
alias cp="cp -i"
alias mv="mv -i"
alias grep="grep --color=auto"

alias c="clear"
# macOS: --color=auto needed for coreutils
alias l="ls -1GF --color=auto"
alias la="l -a"
alias ll="l -lh"
alias lla="ll -a"

alias .2="cd ../.."
alias ..="cd .."
alias .3="cd ../../.."
alias ...="cd ../.."
alias .4="cd ../../../.."
alias ....="cd ../../../.."
alias .5="cd ../../../../.."
alias .....="cd ../../../../.."
alias .6="cd ../../../../../.."
alias ......="cd ../../../../../.."

alias cddot="cd ${DOTFILES}"

# 'A' for ANSI line graphics
# 'C' for colorization
alias tree="tree -AC"

alias g=git

alias py='python'
alias py2='python2'
alias py3='python3'

if ( is_machine 'macOS' ); then
    alias javahome='/usr/libexec/java_home'
    alias javac8='javahome -v 1.8 --exec javac'
    alias jar8='javahome -v 1.8 --exec jar'
    alias java8='javahome -v 1.8 --exec java'
fi

################################################################################
# prompt

. "${_shell_lib}/prompts/left/short_path.sh"
. "${_shell_lib}/prompts/right/git_info.sh"

################################################################################
# cleanup

#unset DOTFILES
unset _shell_lib
unset _custom_shell_lib
unset _dir
unset _dirs
unset _file