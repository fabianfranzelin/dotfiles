;;; init.el --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

;; ==================================================================
;; Load Packages for different modes
;; ===================================================================
(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; Package Management
(require 'package)
(setq package-enable-at-startup nil)

(setq package-archives '(("org" . "https://orgmode.org/elpa/") ;; will be deprecated soon
                         ("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialise packages
(when (< emacs-major-version 27)
  (package-initialize))

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; ensure all packages to be installed
(require 'use-package-ensure)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :init
  ;; for emacs 28, quelpa is required as a dependency
  (when (> emacs-major-version 27)
    (use-package quelpa))
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-hide-results t
        ;; update the packages every week
        auto-package-update-interval 7)
  (auto-package-update-maybe))

;; add the possibility to define system dependencies in use-package
;; declaration
(use-package use-package-ensure-system-package)

;; get latest signatures for elpa
(use-package gnu-elpa-keyring-update)

;; make sure that the path environment from shell is available in
;; emacs
(use-package exec-path-from-shell
  :unless (string-equal system-type "windows-nt")
  :demand t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

(defun ff/emacs-config-home ()
  "Provide the home of the Emacs configuration folder."
  (interactive)
  (let* ((xdg-config-home (getenv "XDG_CONFIG_HOME"))
         (emacs-d-folder (expand-file-name "~/.emacs.d")))
    (if xdg-config-home
	    (let ((xdg-emacs-config-home (concat xdg-config-home "/emacs")))
          (if (file-directory-p xdg-emacs-config-home) xdg-emacs-config-home emacs-d-folder))
      emacs-d-folder)))

(defvar emacs-config-home (ff/emacs-config-home)
  "Location of the Emacs configuration.")
(defvar local-load-path (concat emacs-config-home "/elisp-local")
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-load-path)

(use-package helpers
  :load-path local-load-path)

(use-package shell-loader
  :load-path local-load-path)

;; ===================================================================
;; Basic Settings
;; ===================================================================
(server-start)

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 100 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; enables local variables per default
(setq enable-local-variables :all)
;; dir-local variables will be applied to remote files.
(setq enable-remote-dir-locals t)

;; disable backup
(setq backup-inhibited t)
(setq make-backup-files nil)

;; make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; enable auto save
(setq auto-save-default t)

;; dont warn for following symlinked files
(setq vc-follow-symlinks t)

;; disable lockfiles
(setq create-lockfiles nil)

;; setup a new custom file
(defvar emacs-d-custom (concat (ff/emacs-config-home) "/custom.el")
  "Path to custom file in emacs.d directory.")
(unless (file-exists-p emacs-d-custom)
  (with-temp-buffer (write-file emacs-d-custom)))

(setq custom-file emacs-d-custom)
(load custom-file)

;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar
(set-fringe-mode 10)

;; disable scroll lock mode permanently
(defun do-nothing () "Does simply nothing." (interactive))
(global-set-key (kbd "<Scroll_Lock>") 'do-nothing)
(defvar scroll-lock-mode nil)

;; enable revert from disk
(global-auto-revert-mode t)

(defalias 'yes-or-no-p 'y-or-n-p)

;; let me confirm emacs before killing it
(setq confirm-kill-emacs 'yes-or-no-p)

;; Support wheel mouse scrolling
(mouse-wheel-mode t)

;; Kill this buffer, instead of prompting for which one to kill
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; Turn on syntax colouring in all modes supporting it
(global-font-lock-mode t)

;; I want the current user name, the emacs version and the name of the
;; file I'm editing to be displayed in the title-bar.
(setq frame-title-format
      (list (getenv "USER") "@Emacs " emacs-version ": "
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; set unicode encoding
(defvar prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'latin-1)
(setq buffer-file-coding-system 'utf-8)

;; no splash screen
(setq inhibit-splash-screen t)

;; increase undo limit
(setq undo-limit 8000000)

;; Iterate through CamelCase
(global-subword-mode t)

;; Color theme
(use-package material-theme
  :demand t
  :config
  (load-theme 'material t))

;; Key bindings
(global-set-key "\C-n" 'make-frame)

;; higlight the marked region (C-SPC) and use commands (like
;; latex-environment) on current region. Rectangle mark mode is
;; enabled via C-x SPC.
(transient-mark-mode t) ;; C-SPC - for selection
(rectangle-mark-mode t) ;; C-x SPC - for selection; C-x SPC C-t for
                        ;; inserting stuff

;; Indentation
(setq-default indent-tabs-mode nil)    ; use only spaces and no tabs
(setq-default tab-width 4)

;; Delete trailing white spaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; enable auto pair mode globally
(electric-pair-mode t)

;; Let kill operate on the whole line when no region is selected
(use-package whole-line-or-region
  :config (whole-line-or-region-global-mode))

;; Remove indicators from the mode line
(use-package diminish)

;; Helps to keep track of your cursor
(use-package beacon
  :config
  (beacon-mode t)
  (setq beacon-color "#ff0000"))

;; volatile highlights - temporarily highlight changes from pasting
;; etc
(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :config
  (volatile-highlights-mode t))

;; convenient setting to move between open buffers
(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)

;; winner mode for for redo/undo window configurations
(winner-mode 1)

;; setup all the icons with fix for fonts from
;; https://github.com/domtronn/all-the-icons.el/issues/107
(require 'font-lock)
(use-package font-lock+
  :load-path local-load-path)

;; NOTE: The first time you load your configuration on a new machine,
;; you’ll need to run `M-x all-the-icons-install-fonts` so that mode
;; line icons display correctly.
(use-package all-the-icons
  :after font-lock+)

;; Google search integration
(use-package google-this
  :init (google-this-mode t)
  :config (global-set-key (kbd "C-c g") 'google-this-mode-submap))

(use-package evil-nerd-commenter
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package which-key
  :diminish which-key-mode
  :init (which-key-mode 1)
  :config (setq which-key-idle-delay 0.5))

;; -------------------------------------------------------------------
;; Gumshoe: jump back and forth through marked positions
;; -------------------------------------------------------------------
(use-package gumshoe
  :init
  ;; Enabing global-gumshoe-mode will initiate tracking
  (global-gumshoe-mode +1)
  ;; customize peruse slot display if you like
  (setf gumshoe-slot-schema '(time buffer position line))
  :custom
  (gumshoe-idle-time 5)
  (gusmhoe-log-len 20)
  :bind (;; enable browser like key bindings to move forth and
         ;; back in bookmarks
         ("M-<left>" . gumshoe-backtrack-back)
         ("M-<right>" . gumshoe-backtrack-forward)))

;; -------------------------------------------------------------------
;; Tramp
;; -------------------------------------------------------------------
(use-package tramp
  :ensure nil
  :config
  (put 'temporary-file-directory 'standard-value '("/tmp"))
  ;; Use remote PATH on tramp (handy for eshell).
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)

  (setq tramp-auto-save-directory "~/.cache/emacs/backups"
        tramp-persistency-file-name "~/.emacs.d/data/tramp"
        tramp-terminal-type "dumb"
        tramp-default-method "ssh")

  ;; make sure vc stuff is not making tramp slower
  (setq vc-ignore-dir-regexp
	(format "%s\\|%s"
		vc-ignore-dir-regexp
		tramp-file-name-regexp)))

(customize-set-variable 'tramp-use-ssh-controlmaster-options nil)

;; multihop example: /ssh:frf2lr@ws|docker:vscode@c8416d9f4da6:/
(use-package docker-tramp)

;; -------------------------------------------------------------------
;; Tab bar
;; -------------------------------------------------------------------
(use-package tab-bar
  :config
  ;; Don't turn on tab-bar-mode when tabs are created
  (setq tab-bar-show nil
        tab-bar-new-tab-choice "*scratch*"
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil))

;; -------------------------------------------------------------------
;; Ivy project
;; ------------------------------------------------------------------
(use-package setup-ivy
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Company
;; -------------------------------------------------------------------
(use-package company
  :after (lsp-mode yasnippet)
  :hook (lsp-mode . company-mode)
  :config
  (setq company-backends (delete 'company-semantic company-backends)
        company-minimum-prefix-length 1
        company-idle-delay 0.2 ;; default is 0.2
        company-echo-delay 0.2
        ;; aligns annotation to the right hand side
        company-tooltip-align-annotations t)

  ;; The company-backends support list of lists. Lists are evaluated
  ;; at once, which
  (defvar +ff/company-default-backends '((company-capf
                                          company-files
                                          :with company-yasnippet)
                                         (company-abbrev
                                          company-ispell)))
  (setq company-backends +ff/company-default-backends)

  ;; enable company globally
  (global-company-mode 1)
  :bind (("C-c C-y" . company-yasnippet)
         :map company-active-map
         ("TAB" . company-complete-selection)))


;; disable company mode for terminals
(dolist (mode '(term-mode-hook
                vterm-mode-hook
                eshell-mode-hook
                dap-ui-repl-mode-hook))
  (add-hook mode (lambda () (company-mode 0))))

(use-package company-prescient
  :config
  (company-prescient-mode 1))

(use-package company-quickhelp
  :after company)

;; -------------------------------------------------------------------
;; Simple text
;; -------------------------------------------------------------------
(defun ff/configure-text-mode ()
  "Configure text mode."
  (interactive)
  (define-key text-mode-map (kbd "<tab>") 'company-indent-or-complete-common)
  (set (make-local-variable 'company-backends)
       '((company-abbrev
          company-dabbrev
          company-ispell
          company-files))))

(use-package text-mode
  :ensure nil
  :after company
  :hook (text-mode . ff/configure-text-mode))

;; -------------------------------------------------------------------
;; Buffer move & transpose frame
;; -------------------------------------------------------------------
(use-package buffer-move
  :bind (("C-c b <down>" . buf-move-down)
         ("C-c b <up>" . buf-move-up)
         ("C-c b <left>" . buf-move-left)
         ("C-c b <right>" . buf-move-right)))

(use-package transpose-frame
  :bind (("C-c b t" . transpose-frame)))

;; -------------------------------------------------------------------
;; Set up dired
;; -------------------------------------------------------------------
(use-package dired
  :ensure nil
  :defer 1
  :commands (dired dired-jump)
  :hook ((dired-mode . auto-revert-mode)
         (dired-mode . dired-hide-details-mode)
         (dired-mode . hl-line-mode))
  :bind (("C-x C-j" . dired-jump)
         :map dired-mode-map
         ("<backspace>" . dired-up-directory)
         ("TAB" . dired-find-file))
  :custom
  ((dired-auto-revert-buffer t) ; Auto update when buffer is revisited
   (dired-dwim-target t)
   (dired-recursive-deletes 'always)
   (dired-recursive-copies 'always)
   (delete-by-moving-to-trash t))
  :config
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-hide-details-hide-symlink-targets nil)

  (autoload 'dired-omit-mode "dired-x"))

(use-package dired-rainbow
  :defer 2
  :config
  (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
  (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
  (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
  (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
  (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
  (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
  (dired-rainbow-define media "#de751f" ("mp3" "mp4" "mkv" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
  (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
  (dired-rainbow-define log "#c17d11" ("log"))
  (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
  (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
  (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
  (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
  (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
  (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
  (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
  (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
  (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
  (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
  (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :bind (:map dired-mode-map
              ("H" . dired-hide-dotfiles-mode)))

;; -------------------------------------------------------------------
;; Undo tree - make undos more powerful
;; -------------------------------------------------------------------
(use-package undo-tree
  :config (global-undo-tree-mode))

;; -------------------------------------------------------------------
;; Credential management
;; -------------------------------------------------------------------
(use-package ivy-pass
  :commands ivy-pass
  :config
  (setq password-store-password-length 20))

(use-package auth-source-pass
  :config
  (auth-source-pass-enable))

;; -------------------------------------------------------------------
;; Open files externally
;; -------------------------------------------------------------------
(use-package openwith
  :ensure-system-package ((vlc . vlc)
                          (okular . okular)
                          (eog . eog)
                          (firefox . firefox))
  :init (openwith-mode t)
  :config
  (setq openwith-associations
        (list
         (list (openwith-make-extension-regexp
                '("mpg" "mpeg" "mp3" "mp4"
                  "avi" "wmv" "wav" "mov" "flv"
                  "ogm" "ogg" "mkv"))
               "vlc" '(file))
         (list (openwith-make-extension-regexp
                '("xbm" "pbm" "pgm" "ppm" "pnm"
                  "png" "gif" "bmp" "tif" "jpeg"
                  "jpg"))
               "eog" '(file))
         (list (openwith-make-extension-regexp
                '("pdf"))
               "okular" '(file))
         (list (openwith-make-extension-regexp
                '("html"))
               "firefox" '(file)))))

;; -------------------------------------------------------------------
;; Copy filename of buffer into clipboard
;; -------------------------------------------------------------------
(defun my-put-file-name-on-clipboard ()
  "Put the current file name on the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (with-temp-buffer
        (insert filename)
        (clipboard-kill-region (point-min) (point-max)))
      (message filename))))

(global-set-key [f12] 'my-put-file-name-on-clipboard)

;; -------------------------------------------------------------------
;; Beautify modline
;; -------------------------------------------------------------------
(use-package diminish)

(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t)
  (sml/setup)
  (sml/apply-theme 'respectful)  ; Respect the theme colors
  (setq sml/mode-width 'right
        sml/name-width 60)

  (setq-default mode-line-format
                `("%e"
                  mode-line-front-space
                  evil-mode-line-tag
                  mode-line-mule-info
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-frame-identification
                  mode-line-buffer-identification
                  sml/pos-id-separator
                  (vc-mode vc-mode)
                  " "
                  ;; mode-line-position
                  sml/pre-modes-separator
                  mode-line-modes
                  " "
                  mode-line-misc-info))

  (setq rm-blacklist
        (mapconcat
         'identity
         ;; These names must start with a space!
         '(" GitGutter" " MRev" " company"
           " Undo-Tree" " Projectile.*" " Z" " Ind"
           " Org-Agenda.*" " ElDoc" " SP/s" " cider.*")
         "\\|")))


;; -------------------------------------------------------------------
;; Auto-saving changed files
;; -------------------------------------------------------------------
(use-package super-save
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode t)
  (setq super-save-auto-save-when-idle t))

;; -------------------------------------------------------------------
;; Insert Pairs of Matching Elements
;; -------------------------------------------------------------------
;; Highlight parens
(use-package paren
  :config
  (set-face-background 'show-paren-match (face-background 'default))
  (set-face-foreground 'show-paren-match "#def")
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold)
  ;; (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (setq show-paren-style 'mixed)	;; The entire expression
  (setq blink-matching-paren t)
  (show-paren-mode 1))

;; -------------------------------------------------------------------
;; Save history during sessions
;; -------------------------------------------------------------------
(use-package savehist
  :init
  (savehist-mode t)
  :config
  (setq savehist-additional-variables '(extended-command-history kill-ring)))

;; -------------------------------------------------------------------
;; Popper
;; -------------------------------------------------------------------
(use-package popper
  :after projectile
  :bind (("C-*"   . popper-toggle-latest)
         ("M-*"   . popper-cycle)
         ("C-M-*" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  ;; group poppers by projectile projects
  (setq popper-group-function #'popper-group-by-projectile)
  (popper-mode t))

;; -------------------------------------------------------------------
;; Ripgrep integration
;; -------------------------------------------------------------------
(use-package rg
  :ensure-system-package (rg . ripgrep)
  :init (rg-enable-menu))

;; -------------------------------------------------------------------
;; Org-mode
;; -------------------------------------------------------------------
(use-package setup-org-mode
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Projectile mode
;; -------------------------------------------------------------------
(use-package projectile
  :diminish projectile-mode
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/workspace")
    (setq projectile-project-search-path '("~/workspace")))
  (setq projectile-switch-project-action #'projectile-dired)
  ;; enable projectile mode
  (projectile-mode t)
  :config
  (setq projectile-file-exists-remote-cache-expire nil
        projectile-globally-ignored-directories
        (quote
         (".idea" ".eunit" ".git" ".hg" ".svn"
          ".fslckout" ".bzr" "_darcs" ".tox"
          "build" "target" "_build" ".history"
          "tmp", "*ccls-cache" ".ccls-root"
          ".ccls-cache" "compile_commands.json"
          ".clangd"))
        projectile-require-project-root nil
        projectile-indexing-method 'alien
        ;; projectile-enable-caching nil
        projectile-completion-system 'default
        projectile-svn-command "find . -type f -not -iwholename '*.svn/*' -print0"))

(use-package counsel-projectile
  :after projectile
  :config
  (setq counsel-projectile-sort-files t)
  (counsel-projectile-mode t))

;; -------------------------------------------------------------------
;; Lsp-mode
;; -------------------------------------------------------------------
(use-package setup-lsp
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; highlight symbol and replace
;; -------------------------------------------------------------------
(use-package highlight-symbol
  :bind* (("C-c h" . highlight-symbol)
          ("C-c r" . highlight-symbol-query-replace)))

;; -------------------------------------------------------------------
;; Treemacs
;; -------------------------------------------------------------------
(defun treemacs-custom-filter (file _)
  "Custom filter function for files in treemacs.

FILE: filename"
  (or (s-ends-with? ".aux" file)
      (s-ends-with? ".lint" file)))

(use-package treemacs
  :commands (treemacs
             treemacs-follow-mode
             treemacs-filewatch-mode
             treemacs-fringe-indicator-mode)
  :bind (("C-x t t" . treemacs)
         ("C-x t s" . ff/lsp-treemacs-symbols-toggle))
  :init
  (when window-system
    (setq treemacs-width 40
          treemacs-indentation 1
          treemacs-space-between-root-nodes nil)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode nil))
  :config
  ;; (add-to-list 'treemacs-pre-file-insert-predicates #'treemacs-is-file-git-ignored?)
  (push #'treemacs-custom-filter treemacs-ignored-file-predicates))

(use-package lsp-treemacs
  :after lsp-mode treemacs company
  :commands lsp-treemacs-errors-list
  :config
  (setq gc-cons-threshold (* 100 1024 1024)
        read-process-output-max (* 1024 1024)
        treemacs-space-between-root-nodes nil
        ;; clangd is fast
        lsp-idle-delay 0.1
        ;; be more ide-ish
        lsp-headerline-breadcrumb-enable t)
  ;; enables bidirectional sync
  (lsp-treemacs-sync-mode t))

;; -------------------------------------------------------------------
;; Enable dap
;; -------------------------------------------------------------------
(use-package dap-mode
  :init
  ;; use tooltips for mouse hover
  ;; if it is not enabled `dap-mode' will use the minibuffer.
  (tooltip-mode 1)
  ;; displays floating panel with debug buttons
  ;; requies emacs 26+
  (dap-ui-controls-mode 1)
  :config (dap-auto-configure-mode)
  :hook ((dap-stopped . (lambda (arg) (call-interactively #'dap-hydra))))
  :bind(("C-c d d" . dap-debug)
        ("C-c d h" . dap-hydra)
        ("C-c d t" . dap-breakpoint-toggle)
        ("C-c d r" . dap-ui-repl)))

;; -------------------------------------------------------------------
;; Eshell & Vterm
;; -------------------------------------------------------------------
(use-package setup-eshell
  :load-path local-load-path)

(use-package setup-vterm
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Show number of lines in the left side of the buffer
;; -------------------------------------------------------------------
(column-number-mode 1)
(global-display-line-numbers-mode 1)

(dolist (mode '(org-mode-hook
                term-mode-hook
                eshell-mode-hook
                vterm-mode-hook
                treemacs-mode-hook
                compilation-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; -------------------------------------------------------------------
;; Drag stuff around with M-up/down
;; -------------------------------------------------------------------
(use-package drag-stuff
  :config (drag-stuff-global-mode t)
  :bind (("M-<up>" . drag-stuff-up)
         ("M-<down>" . drag-stuff-down)))

;; -------------------------------------------------------------------
;; Yasnippet
;; -------------------------------------------------------------------
(use-package yasnippet
  :config
  (setq yas-verbosity 1
	    yas-wrap-around-region t)

  ;; enable yas everywhere
  (yas-reload-all)
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;; -------------------------------------------------------------------
;; Code style checker
;; -------------------------------------------------------------------
(use-package flycheck
  :init (global-flycheck-mode))

;; ===================================================================
;; Adjusting modes for programming
;; ===================================================================
;; -------------------------------------------------------------------
;; Emacs lisp
;; -------------------------------------------------------------------

;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

;; -------------------------------------------------------------------
;; C/C++
;; -------------------------------------------------------------------
(use-package setup-cc
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; CRAN R
;; -------------------------------------------------------------------
(use-package ess
  :init
  (setq ess-use-eldoc nil)
  ;; ESS will not print the evaluated commands, also speeds up the
  ;; evaluation
  (setq ess-eval-visibly nil)
  ;; if you don't want to be prompted each time you start an
  ;; interactive R session
  (setq ess-ask-for-ess-directory nil)
  :config
  (setq ess-nuke-trailing-whitespace-p t
        tab-always-indent t))

;; -------------------------------------------------------------------
;; Latex
;; -------------------------------------------------------------------
(use-package setup-latex
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Spell checker: Language tool and ispell/aspell
;; -------------------------------------------------------------------
(use-package setup-spellcheck
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Python
;; -------------------------------------------------------------------
(use-package setup-python
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Shell
;; -------------------------------------------------------------------
(use-package flymake-shell
  :commands flymake-shell-load
  :hook ((sh-set-shell . flymake-shell-load)))

(use-package flymake-shellcheck
  :ensure-system-package (shellcheck . shellcheck)
  :commands flymake-shellcheck-load
  :hook ((sh-mode . flymake-shellcheck-load)))

;; -------------------------------------------------------------------
;; Swig-Mode
;; -------------------------------------------------------------------
(defun swig-switch-compile-command-auto ()
  "Switch compile command if a setup.py file is present in the current folder."
  (if (file-exists-p "setup.py")
      (setq compile-command "python setup.py install --install-lib=.")
    (setq compile-command "make -k"))
  (message compile-command))

;; compile command taking several compilation modes into account
(defun swig-compile()
  "Run compilation of swig interface."
  (interactive)
  (swig-switch-compile-command-auto)
  (compile compile-command))

(use-package swig-mode
  :load-path local-load-path
  :mode (("\\.i$" . swig-mode)))

;; -------------------------------------------------------------------
;; Git - magit
;; -------------------------------------------------------------------
(use-package setup-magit
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; yaml mode
;; -------------------------------------------------------------------
(use-package yaml-mode
  :ensure-system-package ((pip3 . python3-pip)
                          (yamllint . "python3 -m pip install -U 'yamllint'"))
  :mode (("\\.yml$" . yaml-mode)
         ("\\.yaml$" . yaml-mode)))

(use-package flymake-yaml)

;; -------------------------------------------------------------------
;; dockerfile mode
;; -------------------------------------------------------------------
(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode))
  :init
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package docker
  :bind ("C-x d" . docker))

;; -------------------------------------------------------------------
;; Kubernetes
;; -------------------------------------------------------------------
(use-package kubernetes)

;; -------------------------------------------------------------------
;; markdown mode
;; -------------------------------------------------------------------
(use-package markdown-mode
  :commands markdown-mode
  :ensure-system-package ((markdown . markdown)
                          (pandoc . pandoc))
  :init
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)
  :config
  ;; The default command for markdown (~markdown~), doesn't support tables
  ;; (e.g. GitHub flavored markdown). Pandoc does, so let's use that.
  (setq markdown-command "pandoc --from markdown --to html")
  (setq markdown-command-needs-filename t))

;; -------------------------------------------------------------------
;; RST mode
;; -------------------------------------------------------------------
(use-package poly-rst
  :mode (("\\.rst$" . poly-rst-mode)
         ("\\.rest$" . poly-rst-mode))
  :init
  (set-default 'truncate-lines t))

;; C-c C-e r r (org-rst-export-to-rst)
;;    Export as a text file written in reStructured syntax.
;; C-c C-e r R (org-rst-export-as-rst)
;;    Export as a temporary buffer. Do not create a file.
(use-package ox-rst)

(use-package rst
  :mode (("\\.txtt$" . rst-mode)
         ("\\.rst$" . rst-mode)
         ("\\.rest$" . rst-mode))
  ;; enable support of virtualenvironments
  :hook ((rst-mode . pyvenv-mode)))

;; -------------------------------------------------------------------
;; Typescript
;; -------------------------------------------------------------------
(use-package tide
  :after (typescript-mode company)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package nvm)

(use-package typescript-mode
  :after (dap-node company)
  :mode (("\\.ts$" . typescript-mode)
         ("\\.tsx$" . typescript-mode))
  :config
  (setq typescript-indent-level 4)
  (dap-node-setup))

;; note, for some reason the mode directive does not work here, so I
;; added the typescript mode explicitly to tsx files.
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

(use-package json-snatcher
  :hook ((js-mode-hook . js-mode-bindings)
         (js2-mode-hook . js-mode-bindings))
  :bind (("C-C C-g" . jsons-print-path)))

;; -------------------------------------------------------------------
;; Plantuml mode
;; -------------------------------------------------------------------

(defun ff/plantuml-create-svg (source_filename)
  "Create SVG from current puml file.
SOURCE_FILENAME: filename to the puml file."
  (interactive)
  (message (concat "Converting " source_filename))
  (call-process-shell-command (concat
                               "java -jar "
                               plantuml-jar-path
                               source_filename
                               " -tsvg -charset utf-8"))
  (message "Conversion succeeded."))

(use-package plantuml-mode
  :ensure-system-package (dot . graphviz)
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  ;; Consider using (plantuml-download-jar) as alternative
  (defvar plantuml-version "1.2021.10" "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-jar-asl-" plantuml-version) "Name of plantuml executable")
  (defvar plantuml-url
    (concat "https://sourceforge.net/projects/plantuml/files/" plantuml-version "/" plantuml-name ".zip/download")
    "URL to download plantuml from sourceforge.")
  (defvar plantuml-extract-to (expand-file-name (concat "~/opt/plantuml/" plantuml-name))
    "DEstination of plantuml binaries")
  (defvar plantuml-expected-binary (concat plantuml-extract-to "/plantuml.jar")
    "Path to java archive of plantuml.")
  (ff/download-and-extract-zip-archive plantuml-url
                                       plantuml-name
                                       plantuml-extract-to
                                       plantuml-expected-binary
                                       "plantuml")
  :config
  ;; Sample jar configuration
  (setq plantuml-jar-path plantuml-expected-binary
        plantuml-default-exec-mode 'jar
        plantuml-indent-level 4)
  ;; remap preview to personal function; for some reason, bind does
  ;; not accept it
  (define-key plantuml-mode-map [remap plantuml-preview] 'ff/plantum-preview)
  :bind (:map plantuml-mode-map
              ("C-M-i" . plantuml-complete-symbol)
              ("C-c C-e" . (lambda() (interactive) (ff/plantuml-create-svg (buffer-file-name))))))

(use-package flycheck-plantuml
  :after (plantuml-mode flycheck)
  :commands (flycheck-plantuml-setup))

;; -------------------------------------------------------------------
;; Groovy mode for Jenkins
;; -------------------------------------------------------------------
(use-package groovy-mode
  :mode (("\\.groovy$" . groovy-mode)))

(use-package groovy-imports)

;; -------------------------------------------------------------------
;; Java mode
;; -------------------------------------------------------------------
(use-package lsp-java
  :after lsp-mode
  :hook ((java-mode . lsp)))

;; -------------------------------------------------------------------
;; Json
;; -------------------------------------------------------------------
(use-package json-mode
  :mode (("\\.json$" . json-mode)))

(use-package flymake-json
  :ensure-system-package ((npm . npm)
                          (jsonlint . "sudo env \"PATH=$PATH\" npm install jsonlint -g"))
  :after json-mode
  :hook ((json-mode . flymake-json-load)
         (js-mode . flymake-json-maybe-load)))

;; -------------------------------------------------------------------
;; Jinja2 mode for code generation
;; -------------------------------------------------------------------
(use-package jinja2-mode
  :mode ("\\.j2\\'" "\\.jinja2\\'"))

;; -------------------------------------------------------------------
;; Restclient
;; -------------------------------------------------------------------
(use-package restclient)

;;; init.el ends here
