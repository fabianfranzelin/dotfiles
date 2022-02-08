;;; basic-settings.el --- Setup all basic settings

;;; Commentary:
;; Configuration for basic settings

;;; Code:

;; set frame transparency and maximize frame by default
(set-frame-parameter (selected-frame) 'alpha '(100 . 100))
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; The default is 800 kilobytes. Measured in bytes.
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
(load custom-file t)

;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

;; disable backup
(setq backup-inhibited t)
(setq make-backup-files nil)

;; no splash screen
(setq inhibit-splash-screen t)

;; revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; define alias for yes-or-no decision
(defalias 'yes-or-no-p 'y-or-n-p)

;; let me confirm emacs before killing it
(setq confirm-kill-emacs 'yes-or-no-p)

;; Support wheel mouse scrolling
(mouse-wheel-mode t)

;; enable recentf-mode
(recentf-mode)

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

;; Iterate through CamelCase
(global-subword-mode t)

;; Color theme
(use-package material-theme
  :config
  (load-theme 'material t))

;; -------------------------------------------------------------------
;; Global key bindings
;; -------------------------------------------------------------------
;; Create a new frame
(global-set-key "\C-n" 'make-frame)

;; Kill this buffer, instead of prompting for which one to kill
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; disable scroll lock mode permanently
(defun do-nothing () "Does simply nothing." (interactive))
(global-set-key (kbd "<Scroll_Lock>") 'do-nothing)
(defvar scroll-lock-mode nil)

;; convenient setting to move between open buffers
(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)


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

;; volatile highlights - temporarily highlight changes from pasting
;; etc
(use-package volatile-highlights
  :init
  (volatile-highlights-mode t))

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

(use-package which-key
  :diminish which-key-mode
  :init (which-key-mode 1)
  :config (setq which-key-idle-delay 0.5))

;; center the text for the corresponding modes; writing documentation
;; is easier with this setting.
(use-package visual-fill-column
  :hook ((org-mode . ff/visual-fill-center-text)
         (rst-mode . ff/visual-fill-center-text)))


;; -------------------------------------------------------------------
;; Perspectives and workspaces
;; -------------------------------------------------------------------
(use-package perspective
  :init
  (unless (equal persp-mode t)
    (persp-mode))
  :config
  (setq persp-initial-frame-name "Main"))

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
  (gumshoe-idle-time 0.2)
  (gumshoe-log-len 50)
  (gumshoe-show-footprints-p nil)
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
        tramp-default-method "ssh"
        tramp-verbose 1)

  ;; make sure vc stuff is not making tramp slower
  (setq vc-ignore-dir-regexp
	    (format "%s\\|%s"
		        vc-ignore-dir-regexp
		        tramp-file-name-regexp))

  (setq vc-handled-backends '(Git)))

(customize-set-variable 'tramp-use-ssh-controlmaster-options nil)

;; multihop example: /ssh:frf2lr@ws|docker:vscode@c8416d9f4da6:/
(use-package docker-tramp)

;; -------------------------------------------------------------------
;; Tab bar
;; -------------------------------------------------------------------
(use-package tab-bar
  :config
  ;; Don't turn on tab-bar-mode when tabs are created
  (setq tab-bar-show 1
        tab-bar-new-tab-choice "*scratch*"
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil)
  :bind (("C-x t n" . tab-new)
         ("C-x t w" . tab-close)
         ("C-<prior>" . tab-previous)
         ("C-<next>" . tab-next)))

;; -------------------------------------------------------------------
;; Completion system
;; ------------------------------------------------------------------
(use-package setup-completion
  :load-path local-load-path)

;; (use-package setup-ivy
;;   :load-path local-load-path)

;; -------------------------------------------------------------------
;; Company
;; -------------------------------------------------------------------
(use-package company
  :after (lsp-mode yasnippet)
  :hook (lsp-mode . company-mode)
  :config
  (setq company-backends (delete 'company-semantic company-backends)
        company-minimum-prefix-length 1
        company-idle-delay 0.0 ;; default is 0.2
        company-echo-delay 0.0
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
  :init
  (company-prescient-mode 1))

(use-package company-box
  :hook (company-mode . company-box-mode))

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
;; rename buffer content: C-x C-q, C-c C-c to apply and C-c ESC to cancel
(use-package dired
  :ensure nil
  :defer 1
  :after org-download
  :commands (dired dired-jump)
  :hook ((dired-mode . auto-revert-mode)
         (dired-mode . dired-hide-details-mode)
         (dired-mode . hl-line-mode)
         ;; enables drag-and-drop in dired
         (dired-mode . org-download-enable))
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
  :config
  (global-undo-tree-mode)
  ;; increase undo limit
  (setq undo-limit 8000000))

;; -------------------------------------------------------------------
;; Credential management
;; -------------------------------------------------------------------
(use-package auth-source-pass
  :config
  (auth-source-pass-enable))

;; -------------------------------------------------------------------
;; Open files externally
;; -------------------------------------------------------------------
(use-package openwith
  :ensure-system-package ((vlc . "sudo apt install vlc -y")
                          (okular . "sudo apt install okular -y")
                          (eog . "sudo apt install eog -y")
                          (firefox . "sudo apt install firefox -y"))
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
;; Use doom modeline
;; -------------------------------------------------------------------
(use-package minions
  :hook (minions-mode . doom-modeline-mode))

(use-package doom-modeline
  :init
  (doom-modeline-mode +1)
  :config
  (setq doom-modeline-height 15
        doom-modeline-bar-width 6
        doom-modeline-modal-icon t
        doom-modeline-lsp t
        doom-modeline-github nil
        doom-modeline-mu4e nil
        doom-modeline-irc nil
        doom-modeline-minor-modes nil
        doom-modeline-persp-name nil
        doom-modeline-buffer-file-name-style 'truncate-except-project
        doom-modeline-buffer-modification-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-encoding nil
        doom-modeline-vcs-max-length 48))

;; -------------------------------------------------------------------
;; Auto-saving changed files
;; -------------------------------------------------------------------
(setq auto-save-default t)

(use-package super-save
  :init
  (super-save-mode t)
  :config
  ;; enable auto save
  (setq super-save-auto-save-when-idle t))

;; -------------------------------------------------------------------
;; Insert Pairs of Matching Elements
;; -------------------------------------------------------------------
(use-package paren
  :init
  (show-paren-mode 1)
  :config
  (set-face-background 'show-paren-match (face-background 'default))
  (set-face-foreground 'show-paren-match "#def")
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold)
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (setq show-paren-style 'mixed)	;; The entire expression
  (setq blink-matching-paren t))

;; -------------------------------------------------------------------
;; Save history during sessions
;; -------------------------------------------------------------------
(use-package savehist
  :init
  (savehist-mode t)
  :config
  (setq savehist-additional-variables '(extended-command-history kill-ring)))

;; -------------------------------------------------------------------
;; Popper - handle pop up buffers nicely
;; -------------------------------------------------------------------
(use-package popper
  :after projectile
  :bind (("C-*" . popper-toggle-latest)
         ("M-*" . popper-cycle)
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
  :ensure-system-package (rg . "sudo apt install ripgrep -y")
  :init (rg-enable-menu))

;; -------------------------------------------------------------------
;; Org-mode
;; -------------------------------------------------------------------
(use-package setup-org-mode
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Projectile mode
;; -------------------------------------------------------------------
(defun ff/switch-project-action ()
  "Switch to a workspace with the project name and start `magit-status'."
  (persp-switch (projectile-project-name))
  (projectile-find-file))

(use-package projectile
  :ensure-system-package ((fdfind . "sudo apt install fd-find -y"))
  :diminish projectile-mode
  :custom (projectile-completion-system 'default)
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/workspace")
    (setq projectile-project-search-path '("~/workspace")))
  (setq projectile-switch-project-action #'ff/switch-project-action)
  ;; enable projectile mode
  (projectile-mode t)
  :config
  (setq projectile-file-exists-remote-cache-expire nil
        projectile-globally-ignored-directories
        (quote
         (".idea" ".eunit" ".git" ".hg" ".svn"
          ".fslckout" ".bzr" "_darcs" ".tox"
          "build" "target" "_build" ".history"
          "tmp" ".ccls-root" ".ccls-cache"
          "compile_commands.json" ".clangd"
          ".ccls"))
        projectile-require-project-root t
        projectile-indexing-method 'alien
        projectile-sort-order 'recentf
        projectile-enable-caching t))

;; -------------------------------------------------------------------
;; Lsp-mode
;; -------------------------------------------------------------------
(use-package setup-lsp
  :load-path local-load-path)

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
  :after lsp-mode treemacs
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
  :hook (dap-stopped . (lambda (arg) (call-interactively #'dap-hydra)))
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
  :load-path local-load-path
  :after shell-loader)

(use-package setup-vterm
  :load-path local-load-path
  :after shell-loader)

;; -------------------------------------------------------------------
;; Show number of lines in the left side of the buffer
;; -------------------------------------------------------------------
(global-display-line-numbers-mode 1)

(dolist (mode '(org-mode-hook
                rst-mode-hook
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
(defun yas-rst-mode-labels (text)
  "Create labels for sections in rst.
TEXT: title"
  (downcase (replace-regexp-in-string " \\|:\\|-" "_" text)))

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

;; -------------------------------------------------------------------
;; Spell checker: Language tool and ispell/aspell
;; -------------------------------------------------------------------
(use-package setup-spellcheck
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Git - magit
;; -------------------------------------------------------------------
(use-package setup-magit
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Emacs application framework: it does not seem to be stable
;; -------------------------------------------------------------------
;; (use-package setup-eaf
;;   :load-path local-load-path)

;; -------------------------------------------------------------------
;; Ace window: select windows based on numbers
;; -------------------------------------------------------------------
(use-package ace-window
  :bind (("M-o" . ace-window)))

;; -------------------------------------------------------------------
;; Direnv integration
;; -------------------------------------------------------------------
(use-package direnv
 :init (direnv-mode))

(provide 'basic-settings)

;;; basic-settings.el ends here
