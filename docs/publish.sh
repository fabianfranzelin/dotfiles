#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob globstar

script_name=$(readlink -f "${BASH_SOURCE[0]}")
dotfiles_docs_root=$(realpath "$(dirname "${script_name}")")

(
    cd "${dotfiles_docs_root}"

    echo "
#+TITLE: dotfiles (docs)
#+AUTHOR: Fabian Franzelin
#+EMAIL: fabian.franzelin@gmail.com
#+CREATOR: Fabian Franzelin
#+LANGUAGE: en

The documentation is published [[here][https://fabianfranzelin.github.io/dotfiles]].
" > "public/README.org"

    python3 ./publish_on_github.py publish "$@"
)
