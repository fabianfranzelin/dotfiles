#!/usr/bin/env zsh

. "${DOTFILES}/utils/faq.sh"

if ( __is_zsh ); then
    . "${DOTFILES}/shell/prompts/right/git_info.zsh"
fi
