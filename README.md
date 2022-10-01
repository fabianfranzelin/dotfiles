# My dotfiles

[![CI](https://github.com/fabianfranzelin/dotfiles/actions/workflows/ci.yml/badge.svg?branch=nightly)](https://github.com/fabianfranzelin/dotfiles/actions?query=workflow) [![Last commit](https://img.shields.io/github/last-commit/fabianfranzelin/dotfiles)](https://github.com/fabianfranzelin/dotfiles/commits) [![License](https://img.shields.io/github/license/fabianfranzelin/dotfiles)](https://github.com/fabianfranzelin/dotfiles/blob/nightly/LICENSE)

In this repository, I gather my system configurations that allow me to have
a consistent computing experience over multiple Linux machines.

It configures three main tools: [GNU Emacs](https://www.gnu.org/software/emacs/), [ZSH](https://zsh.sourceforge.io/) and [Qtile](http://docs.qtile.org/en/stable/).

I use [GNU Stow](https://www.gnu.org/software/stow/) to install my configuration files on my Linux
distributions. Everything can be rolled out by calling the main
configure script of the repository

```shell
./configure -i
```
