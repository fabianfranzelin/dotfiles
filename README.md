# dotfiles

Dry and short:  
These dotfiles should speed up a personal workflow and help installing and setting up a personal working system.
Focus lays on keeping overview since using this repo should feel like speeding up manual steps.
Therefore, kind of plugin-structure is not implemented.
Instead, (more or less) slight customization of existing files is supported providing some flexibility without the need of forking the whole project.

Hence, the general idea of these files is:  

1. Create a `custom`-folder (ignored by git) inside the folder `dotfiles`.
2. Create all necessary dotfiles in `custom` by copying originals or linking to them.
3. Create symlinks from `${HOME}` linking to files in `custom`-folder.

So result in home will be

```zsh
DOTFILES="${HOME}/dotfiles"

~/
├── .gitconfig@ -> ${DOTFILES}/custom/git/config*
├── .gitconfig.general@ -> ${DOTFILES}/custom/git/config.general*
│
├── .bashrc@ -> ${HOME}/.profile
├── .zshrc@ -> ${HOME}/.profile
├── .profile@ -> ${DOTFILES}/custom/shell/shellrc.sh
│
├── .ssh
│   ├── config@ -> ${DOTFILES}/custom/shell/ssh/config*
│   └── ...
└── ...
```

`Visual Studio code` is also configured.
Paths are linux-related (see [vscode-website](https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations))

```zsh
DOTFILES="${HOME}/dotfiles"

# path is linux-related
${HOME}/.config/Code/User/
├── settings.json@ -> ${DOTFILES}/custom/vscode/settings.json
└── keybindings.json@ -> ${DOTFILES}/custom/vscode/keybindings.json
```

All these steps can be done automatically by using the provided script `dotfiles`.

## Table of Contents

1. [News](#news)
1. [Features](#features)
    1. [Shell environment](#shell-environment)
    1. [git aliases](#git-aliases)
    1. [System setup](#system-setup)
1. [Structure](#structure)
1. [Usage](#usage)
    1. [Optional: Change default location](#change-default-location)
    1. [Optional: Manual setup](#manual-setup)
1. [Contributing](#contributing)
1. [FAQ / Troubleshooting](#faq)
    1. [Syntax error (e.g. with brackets)](#syntax-error-with-brackets)
    1. [`Zsh`: Insecure files or directories](#insecure-files-and-dirs)
1. [TODO](#todo)

## News <a name="news"></a>

The project works fine and is running stable. `:)`
However, the goal of this project is to provide a very clean and flat setup.
The current setup is clean and short, but not as flat as it could be.
Main reason for this are the install-scripts and the `dotfiles`-tool, which is just a wrapper for these.
For instance, some users already had a setup.
It was easy to refactor their setup, but some info has been missing about the changes made by the `symlink`-scripts.
The scripts are programmed carefully and ask before removing something, but it should be clearer in the code itself.
It is probably better to move the install-content from here to [the howto-repo][web_github_howto] to reduce the complexity of these dotfiles.

Further, tools are activated automatically dependent of the computers-system and whether the tools are installed.
Maybe this can be reduced to a config-file (or similar since it's bash..) for easier overview and easier configuration, e.g. when only some tools should be used.

At last, the TODOs from this README should be converted to issues.

## Features <a name="features"></a>

Besides the function `dotfiles` for handy setup, useful aliases and functions are provided.
These dotfiles are used with `bash` and `zsh`.

### Shell environment <a name="shell-environment"></a>

Beside autocompletion for several tools, aliases and exports can be found in [`shell/shellrc.sh`](https://github.com/dominicparga/dotfiles/blob/master/shell/shellrc.sh).
Some commands like `grep` or `tree` are just flagged to use colors.
Those are not mentioned here.

| new cmd | note |
|:---------:|------|
| SAFETY ALIASES |
| `cp` | is alias for `cp -i -P`, so asks before replacing existing file. |
| `mv` | is alias for `mv -i`, so asks before replacing existing file. |
| COMMAND ls |
| `l` | shows items as a colored list. |
| `la` | shows hidden items as well. |
| `ll` | shows items as a colored list and access rights. |
| `lla` | shows hidden items as well. |
| WORKING QUICKLY |
| `c` | is alias for `clear`. |
| `g` | is alias for `git`. |
| `..` | is alias for `cd ..`. |
| `.2` or `...` | goes back 2 folders. |
| `.3` or `....` | goes back 3 folders. |
| ... | ... |
| `.6` or `.......` | goes back 6 folders. |
| `mkd` | creates folder(s) and enters it. |
| MORE HANDY FUNCTIONS |
| `alert` | can be called like `sleep 2; alert`. |
| `dotfiles` | for setting scripts and installing tools. |
| `gitignore` | uses the `gitignore.io` API to return gitignore entries. |

### Git aliases <a name="git-aliases"></a>

Have a look at the handy [git aliases](https://github.com/dominicparga/dotfiles/blob/master/git/config).
In addition, visual-studio-code is opening as diff-tool and for commit-messages.

`g` is alias for `git` (see above).

| alias | note |
|:---------:|------|
| GENERAL |
| `g h` | helps using `git help` more often ;) (`g h ALIAS` shows the replacement for the alias). |
| `g s` | is alias for `git status` and one of the most used aliases. |
| EFFICIENT STAGING |
| `g unstage FILES ` | removes all changes from the index with respect to the given FILES (but keeps the changes in workspace). Simply spoken, all green FILES in `git status` become red again. |
| `g discard FILES` | removes all changes from the workspace with respect to the given FILES. Simply spoken, all red FILES in `git status` disappear. (__ATTENTION!__ Obviously, those changes will be lost.) |
| `g undo` | removes the last commit from history, but keeps its changes in the index. __ATTENTION!__ This alias can be very handy but it is recommended using this only for local commits, since removing pushed commits messes up the history. |
| COMMITTING |
| `g a FILES` | adds the given files. |
| `g aa` | adds all changes and executes git status afterwards. |
| `g c` | commits. |
| `g ca` | commits after `g aa`. |
| `g cm "commits a commit lol"` | commits with a message. |
| `g cam "commits a commit lol"` | is `g ca` with a message. |
| MERGING |
| `g m BRANCH` | `git merge BRANCH` |
| `g squash BRANCH/COMMIT` | merges content without merging the git history. So the resulting commit looks like it has cherry-picked all commits of BRANCH/COMMIT. |
| `g squeeze BRANCH/COMMIT` | is a different name for `g squash ...`. |
| BRANCHING |
| `g co BRANCH/COMMIT` | `git checkout BRANCH/COMMIT` |
| `g cob BRANCH` | `git checkout -b BRANCH` |
| `g b` | `git branch` |
| `g ba` | `git branch --list -a` |
| `g bv` | `git branch --list -v` |
| `g bav` | `git branch --list -av` |
| LOGGING |
| `g last N` | logs the last N commit messages. Default for N is 3. |
| `g l` | shows the history of the local branch as a graph. |
| `g la` | shows the global history as a graph. |

> __Note:__ `g l` uses `git log` and `g la` adds the flag `--all`.
> Due to `git help log`, this flag refers to stored references in `.git/refs`.

### System setup <a name="system-setup"></a>

You can setup your system (macOS, linux) using `dotfiles install-system`.
Executing `dotfiles help` may help.

## Structure <a name="structure"></a>

The following (incomplete) tree is supported.
In general, every file in custom can be removed and calling `dotfiles custom` will recreate the default version of it.
So playing around with this project is only cricital in the case that own changes in custom are removed manually. ;)

The idea behind the custom folder is, besides supporting private files (e.g. ssh-configs), to reduce the need of forking/merging the project.
Every symlink will link to a file in custom, that usually executes the draft outside the custom folder per default.

```zsh
dotfiles/
├── custom/
│   ├── custom/                         # completely untouched by the project
│   ├── git/
│   │   └── config                      # includes git/config per default
│   ├── install/
│   │   ├── macOS/
│   │   ├── python/
│   │   ├── ubuntu/
│   │   └── vscode/
│   ├── shell/
│   │   ├── func/                       # extends/overrides shell/func/*
│   │   ├── ssh/
│   │   │   └── config                  # symlinked to
│   │   └── shellrc.sh                  # sources shell/shellrc.sh
│   └── vscode/
│       ├── keybindings.json            # symlinked to
│       └── settings.json               # symlinked to
├── git/
├── install/
├── kutgw/
├── macOS/
├── shell/
├── utils/
│   └── drafts/                         # defaults for custom
└── README.md
```

|         folder in DOTFILES            | description |
|---------------------------------------|-------------|
| `custom/`                             | `dotfiles/custom/` is ignored by git (thus it could be set under git as well). It is organized exactly like the dotfiles-folder to use personal scripts replacing/extending default ones. The folder `dotfiles/custom/custom/` can be used to store general notes or thoughts, or to keep up good/old/outdated work. It won't be used in any script. |
| `custom/shell/ssh/config`             | `${HOME}/.ssh/config` symlinks to this. |
| `git/`                                | `git/config` contains useful git aliases and other configs. From HOME, `custom/git/config` gets linked to. It includes `git/config` and may contain user specific info (e.g. `user.name`). |
| `install/`                            | Scripts like `install/python/pkgs.sh` helps setting up a system. When using the dotfiles' wrapper function, custom counterparts of them are preferred and replaces the default ones. |
| `kutgw/`                              | It stands for "keep up the good work". |
| `shell/`                              | `shell/` consists of scripts for setting the shell environment. `custom/shell/shellrc.sh` *fully* overwrites `shell/shellrc.sh`. |
| `shell/func/`                         | provides useful shell functions. Functions in `custom/shell/func/` are autoloaded/included and overwrite default functions in `shell/func/` if their name is the same. |
| `shell/prompts/`                      | contains some prompts. |
| `utils/`                              | contains scripts for interacting with the dotfiles quickly. |
| `utils/drafts/` | Contains drafts that will be copied into a fresh created `custom/`. It is the solution to the problem of having (frequently changing) user dependent scripts (e.g. vscode's `settings.json`) and a git repo, that shouldn't need to be forked only for slight changes. |
| `vscode/`                             | [Visual studio code](https://code.visualstudio.com/) uses some `settings.json` and `keybindings.json` for user settings and keybindings. Since these files slightly change a lot in usage, often temporary, they are provided as drafts and symlinked to `custom/vscode/...`. |

## Usage <a name="usage"></a>

The project has to be cloned to `${HOME}/dotfiles` and the provided wrapper function can be used to set all symlinks.
Executing the following will create a folder `custom/...` in the dotfiles folder and create all needed symlinks in HOME.

> __Note:__ This default location can be changed.
> See [Change default location](#change-default-location) below for more infos.
> The function name `dotfiles` is independent of your chosen foldername.

The command `symlink` creates the symlinks verbosely, so don't be surprised of the ~10 lines of feedback.

```zsh
cd ~
git clone https://github.com/dominicparga/dotfiles.git

. "${HOME}/dotfiles/shell/shellrc.sh"
dotfiles symlink all
```

Sometimes, a syntax-error is shown, e.g. in `shell/func/alert`.
It does not occur (and everything is working as expected) after opening a new terminal-window.

> __Note:__ `custom/` contains some generic info that should probably be updated by hand (e.g. gitconfig's `user.name`).

### Optional: Change default location <a name="change-default-location"></a>

Changing the default location `${HOME}/dotfiles` needs to rename the folder and change the variable `DOTFILES` defined at top of `${DOTFILES}/shell/shellrc.sh`.
To provide this without the need of forking the whole project, a file `custom/shell/shellrc.sh` is preferred over the default `shell/shellrc.sh`.

`dotfiles symlinks` (respectively `dotfiles custom`) creates the file `custom/shell/shellrc.sh` (amongst others), but you have to remove it manually before.

```zsh
# e.g. choosing .dotfiles instead of dotfiles as folder name
export DOTFILES="${HOME}/.dotfiles"

cd ~
git clone https://github.com/dominicparga/dotfiles.git "${DOTFILES}"

. "${DOTFILES}/shell/shellrc.sh"
dotfiles symlink all
```

### Optional: Manual setup <a name="manual-setup"></a>

The wrapper function calls the following scripts.

```zsh
cd ~
git clone https://github.com/dominicparga/dotfiles.git "dotfiles"

. "${HOME}/dotfiles/shell/shellrc.sh"
bash "${DOTFILES}/utils/create_custom.sh"
bash "${DOTFILES}/utils/symlink_dotfiles.sh" all
```

Fully manually, `custom/` and all symlinks has to be created by hand.

## Contributing <a name="contributing"></a>

These dotfiles are created in a __modular__ and __lightweight__ way.
For example, to find the `shellrc.sh`, the respective script is located in `shell`.
This should be kept (in general) since looking for, e.g., "python" should not need you to look in other folders than `python/`.

For more detailed information, please look [at the contribution section](CONTRIBUTING.md).

## FAQ / Troubleshooting <a name="faq"></a>

### Syntax error (e.g. with brackets) <a name="syntax-error-with-brackets"></a>

These dotfiles are used with `bash` and `zsh`.
Check if `sh` is symlinked

```zsh
ls -1GF --color=auto -lh -a $(which sh)`)
```

For instance, `dash` (not `bash`) does not support `[[ ... ]]`, which is used a lot here.

### `Zsh`: Insecure files or directories <a name="insecure-files-and-dirs"></a>

Your file permissions for your `dotfiles` are probably too loose.
Execute the following to set the permissions to `drwxr-xr-x`.

```zsh
chmod -R 755 ${DOTFILES}
```

## TODO <a name="todo"></a>

### add notes

* installation notes
  * download nord
  * install xcode-tools
  * hidden files
  * virtualbox needs sth.
  * teamviewer settings
  * magnet aus Apple Store
* refactor 3-lines
* readonly PROGNAME=$(basename $0)

### shell scripting

* alert: add usage description to alert function (sound arg)
* alert: add message to alert as input arg
* dotfiles: print info of all features and new functionality
* editing: function for quickly editing shellrc (other files?)
* java: function for changing java version
* kubectl: probably too slow like <(heroku ...)?
* LaTeX: script for creating a LaTeX folder structure
* macOS: install Nord and Dracula
* prompt: function for changing prompt
* python: pip install $(pip list --outdated | awk '{ print $1 }') --upgrade
* README: add vscode (vim-)keybindings
* ubuntu: install Dracula
* ubuntu: set PYTHON_INTERPRETER_PATH in shellrc
* vscode: add snippets

[web_github_howto]: https://github.com/dominicparga/howto
