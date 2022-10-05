;;; basic-settings.el --- Setup all basic settings

;;; Commentary:
;; Configuration for basic settings

;;; Code:

;; make sure that the path environment from shell is available in
;; emacs
 (use-package exec-path-from-shell
   :unless (string-equal system-type "windows-nt")
   :custom (exec-path-from-shell-variables '("PATH" "MANPATH" "SSH_AUTH_SOCK" "HTTP_PROXY" "HTTPS_PROXY"))
   :config
   (exec-path-from-shell-initialize))

;; set frame transparency and maximize frame by default
(set-frame-parameter (selected-frame) 'alpha '(98 . 98))
(add-to-list 'default-frame-alist '(alpha . (98 . 98)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 2 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; enables local variables per default
(setq enable-local-variables t)
;; dir-local variables will be applied to remote files.
(setq enable-remote-dir-locals t)

;; dont warn for following symlinked files
(setq vc-follow-symlinks t)

;; disable lockfiles
(setq create-lockfiles nil)

;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

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

(defun ff/ask-before-closing-frame ()
  "Close only if y was pressed."
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to close this frame? "))
      (server-save-buffers-kill-terminal nil)
    (message "Canceled frame close")))

(when (daemonp)
  (global-set-key (kbd "C-x C-c") 'ff/ask-before-closing-frame))

;; Support wheel mouse scrolling
(mouse-wheel-mode t)

;; enable recentf-mode but ignore files that where opened with docker
;; tramp
(recentf-mode t)
(add-to-list 'recentf-exclude "^/docker:.*")
;; make sure that recentf is not littering emacs user home
(add-to-list 'recentf-exclude no-littering-var-directory)
(add-to-list 'recentf-exclude no-littering-etc-directory)

;; Turn on syntax colouring in all modes supporting it
(global-font-lock-mode t)

;; I want the current user name, the emacs version and the name of the
;; file I'm editing to be displayed in the title-bar.
(setq frame-title-format
      (list (getenv "USER") "@Emacs " emacs-version ": "
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; set unicode encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Iterate through CamelCase
(global-subword-mode t)

;; save desktop session automatically
(use-package desktop
  :custom
  ((desktop-load-locked-desktop t))
  :init
  (if (daemonp)
      ;; delay desktop save mode until one frame is created
      (add-hook 'after-make-frame-functions 'desktop-save-mode)
    (desktop-save-mode)))

;; Color theme
(use-package doom-themes
  :custom
  ((doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
   (doom-themes-enable-bold t)    ; if nil, bold is universally disabled
   (doom-themes-enable-italic t)) ; if nil, italics is universally disabled
  :config
  ;; Global settings (defaults)
  (load-theme 'doom-palenight t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)

  ;; Currently disabled: it is just not the right way to do it :)
  ;; (defun ff/load-theme (frame)
  ;;   "Set theme depending on frame running in GUI or terminal.

  ;; For details, check
  ;; https://emacs.stackexchange.com/questions/24609/determine-graphical-display-on-startup-for-emacs-server-client

  ;; FRAME: frame to be checked"
  ;;   (if (display-graphic-p frame)
  ;;       ;; make this the default theme if X is available
  ;;       (load-theme 'doom-vibrant t)
  ;;     ;; when emacs is running in terminal mode, this theme works better
  ;;     (load-theme 'doom-material t)))

  ;; (with-eval-after-load 'doom-themes
  ;;   ;; Run for already-existing frames
  ;;   (mapc 'ff/load-theme (frame-list))
  ;;   ;; Run when a new frame is created
  ;;   (unless (daemonp)
  ;;     (add-hook 'after-make-frame-functions 'ff/load-theme)))

  ;; Add frame borders and window dividers
  (modify-all-frames-parameters
   '((right-divider-width . 0)
     (internal-border-width . 0)))
  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background)))

;; -------------------------------------------------------------------
;; Define font size and methods to adjust it on the fly
(set-face-attribute 'default nil :height 110) ;; default = 110

;; define functions that increase and decrease the font-size for the
;; whole frame globally
(defun ff/adjust-font-size-per-frame (increment)
  "Adjust the font size for all buffers in the current frame.
INCREMENT: Value of which the current font-size is changed"
  (interactive "P")
  (let ((current-height (face-attribute 'default :height)))
    (set-face-attribute 'default nil :height (+ current-height increment))))

(global-set-key (kbd "C-c +") #'(lambda() (interactive) (ff/adjust-font-size-per-frame 10)))
(global-set-key (kbd "C-c -") #'(lambda() (interactive) (ff/adjust-font-size-per-frame -10)))

;; -------------------------------------------------------------------
;; Global key bindings
;; -------------------------------------------------------------------
;; Create a new frame
(global-set-key (kbd "C-n") 'make-frame)

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
;; latex-environment) on current region.
(transient-mark-mode t) ;; C-SPC - for selection
;; for highlighting rectangles, use the (rectangle-mark-mode).
;; C-x SPC - for selection; C-x SPC C-t for inserting stuff

;; Indentation
(setq-default indent-tabs-mode nil)    ; use only spaces and no tabs
(setq-default tab-width 4)

;; Delete trailing white spaces only for lines that are touched. This
;; replaces the obvious, more intrusive, approach of
;; (add-hook 'before-save-hook 'delete-trailing-whitespace)
(use-package ws-butler
  :hook ((prog-mode . ws-butler-mode)))

;; enable auto pair mode globally
(electric-pair-mode t)

;; save cursor position in files even when buffers are killed
(save-place-mode)

;; Let kill operate on the whole line when no region is selected
(use-package whole-line-or-region
  :init (whole-line-or-region-global-mode))

;; volatile highlights - temporarily highlight changes from pasting
;; etc
(use-package volatile-highlights
  :init (volatile-highlights-mode t))

;; winner mode for for redo/undo window configurations
(winner-mode 1)

;; package that allows to define nice user interfaces
(use-package hydra)

;; -------------------------------------------------------------
;; Better help
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-c C-d" . helpful-at-point)
         ("C-h F" . helpful-function)
         ("C-h C" . helpful-command)))

;; -------------------------------------------------------------------
;; Tab bar
;; -------------------------------------------------------------------
(defun ff/tab-bar-tab-exists (name)
  (member name
	  (mapcar #'(lambda (tab) (alist-get 'name tab))
		  (tab-bar-tabs))))

(defun ff/tab-bar-new-tab (name)
  (when (eq nil tab-bar-mode)
    (tab-bar-mode))
  (tab-bar-new-tab)
  (tab-bar-rename-tab name))

(defun ff/tab-bar-switch-or-create (name func)
  (if (ff/tab-bar-tab-exists name)
      (tab-bar-switch-to-tab name)
    (ff/tab-bar-new-tab name))
  (funcall func))

(defun ff/tab-bar-run-todos ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/todos.org"))))

(defun ff/tab-bar-run-notes ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/notes.org"))))

(defun ff/tab-bar-run-aos ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/aos.org"))))

(defhydra ff/tab-bar-quick-access (:color teal)
  "My tab-bar helpers"
  ("t" ff/tab-bar-run-todos "Todos")
  ("c" ff/tab-bar-run-notes "Notes (CRE)")
  ("n" ff/tab-bar-run-aos "Notes (AOS)"))

(use-package tab-bar
  :custom
  ;; Don't turn on tab-bar-mode when tabs are created
  ((tab-bar-show nil)
   (tab-bar-new-tab-choice "*scratch*"))
  :init
  (tab-bar-mode t)
  :bind (("C-x t n" . tab-new)
         ("C-x t w" . tab-close)
         ("C-<prior>" . tab-previous)
         ("C-<next>" . tab-next)
         ("C-x t h" . ff/tab-bar-quick-access/body)))

;; -------------------------------------------------------------------
;; Project (built in project handling mode; similar to projectile)
;; -------------------------------------------------------------------
(defun ff/project-root ()
  "Provide path to project root directory."
  (interactive "P")
  (cdr (project-current)))

(defun ff/tab-bar--names (&optional tabs frame)
  "Return the list of tabs sorted by name.
TABS: tabs as alist
FRAME: frame"
  (let* ((tabs (or tabs (funcall tab-bar-tabs-function frame))))
    (mapcar (lambda (tab) (alist-get 'name tab)) tabs)))

(defun ff/project-name (dir)
  "Define the name of a project as the name of the root directory.

DIR: root directory of project"
  (file-name-nondirectory (directory-file-name (file-name-directory dir))))

(defun ff/project-switch-project ()
  "Switch to a workspace with the project name and start `magit-status'."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
  (when (not (member project-name (ff/tab-bar--names)))
    (tab-bar-new-tab)
    (tab-bar-rename-tab project-name))

  (project-switch-project project-dir)))

(defun ff/project-magit ()
  "Show the Git status of the current project."
  (interactive)
  (magit-status (project-root (project-current t))))

(defun ff/project-vterm ()
  "Start a new vterm in project root.

PROJECT-ROOT: Path to the root directory of the current project."
  (interactive)
  (ff/start-vterm-in-dir (project-root (project-current t))))

(use-package project
  :custom
  ((project-switch-commands '((project-find-file "Find file")
                              (project-find-dir "Find directory")
                              (ff/project-magit "Magit")
                              (project-dired "Dired")
                              (ff/project-vterm "Vterm"))))
  :bind (:map project-prefix-map
              ("p" . ff/project-switch-project)
              ("m" . ff/project-magit)
              ("v" . ff/project-vterm)))

;; -------------------------------------------------------------
;; Multiple cursors
(use-package multiple-cursors
  :bind (;; Do what I mean with currently selected word
         ("C-c m j" . mc/mark-all-dwim)
         ;; Mark lines, then create cursors
         ("C-c m c" . mc/edit-lines)
         ;; Expand region
         ("C-c m l" . mc/expand-region)
         ;; Select region first, then create cursors
         ("C-c m /" . mc/mark-all-like-this)
         ("C-c m ," . mc/mark-previous-like-this)
         ("C-c m ." . mc/mark-next-like-this)
         ;; Skip this match and move to next one
         ("C-c m <" . mc/skip-to-previous-like-this)
         ("C-c m >" . mc/skip-to-next-like-this)))

;; -------------------------------------------------------------
;; present a nice dashboard on startup
(use-package page-break-lines)

(use-package dashboard
  :after (all-the-icons page-break-lines)
  :custom
  (;; Content is not centered by default. To center, set
   (dashboard-center-content t)
   ;; To disable shortcut "jump" indicators for each section, set
   (dashboard-show-shortcuts t)
   (dashboard-items '((projects . 5)
                      (agenda . 5)
                      (recents  . 5)))
   (dashboard-set-heading-icons t)
   (dashboard-set-file-icons t)
   (dashboard-set-init-info t)
   (dashboard-week-agenda t)
   (dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
   ;; Show dashboard for newly created frames
   (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
   ;; set the project backend to project.el
   (dashboard-projects-backend `project-el))
  :config
  (dashboard-setup-startup-hook))

;; -------------------------------------------------------------
;; NOTE: The first time you load your configuration on a new machine,
;; you’ll need to run `M-x all-the-icons-install-fonts` so that mode
;; line icons display correctly.
(use-package all-the-icons
  :defer t)

(use-package which-key
  :diminish which-key-mode
  :custom ((which-key-idle-delay 1))
  :init (which-key-mode 1))

;; -------------------------------------------------------------
;; center the text for the corresponding modes; writing documentation
;; is easier with this setting.
(defun ff/visual-fill-center-text ()
  (setq visual-fill-column-width 120
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook ((org-mode . ff/visual-fill-center-text)
         (rst-mode . ff/visual-fill-center-text)
         (LaTeX-mode . ff/visual-fill-center-text)))

;; -------------------------------------------------------------------
;; Tramp
;; -------------------------------------------------------------------
(use-package tramp
  :custom
  ((tramp-terminal-type "dumb")
   (tramp-default-method "ssh")
   (tramp-verbose 1)
   (tramp-use-ssh-controlmaster-options nil)
   (vc-handled-backends '(Git)))
  :config
  (setq tramp-auto-save-directory (expand-file-name "tramp/backups" no-littering-var-directory)
        tramp-persistency-file-name (expand-file-name "tramp/persistency_data" no-littering-var-directory)
        ;; make sure vc stuff is not making tramp slower
        vc-ignore-dir-regexp
        (format "%s\\|%s"
		        vc-ignore-dir-regexp
		        tramp-file-name-regexp))
  (put 'temporary-file-directory 'standard-value '("/tmp"))
  ;; Use remote PATH on tramp (handy for eshell).
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (make-directory tramp-auto-save-directory t))

;; multihop example: /ssh:frf2lr@ws|docker:vscode@c8416d9f4da6:/
(use-package docker-tramp)

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
;; Set up dired with async
;; -------------------------------------------------------------------

;; generic package to allow concurrency for certain tasks in
;; Emacs. Currently only used for dired.
(use-package async)

;; rename buffer content: C-x C-q, C-c C-c to apply and C-c ESC to cancel
;; copy path of file: 0 w in dired buffer
(use-package dired
  :straight nil
  :after (org-download async)
  :custom
  ((dired-auto-revert-buffer t) ; Auto update when buffer is revisited
   (dired-dwim-target t)
   (dired-recursive-deletes 'always)
   (dired-recursive-copies 'always)
   (delete-by-moving-to-trash t)
   (dired-listing-switches "-agho --group-directories-first")
   (dired-hide-details-hide-symlink-targets nil))
  :config
  (autoload 'dired-omit-mode "dired-x")
  ;; enable async copy
  (autoload 'dired-async-mode "dired-async.el" nil t)
  (dired-async-mode 1)
  :hook ((dired-mode . auto-revert-mode)
         (dired-mode . dired-hide-details-mode)
         (dired-mode . hl-line-mode)
         ;; enables drag-and-drop in dired
         (dired-mode . org-download-enable))
  :bind (("C-x C-j" . dired-jump)
         :map dired-mode-map
         ("<backspace>" . dired-up-directory)
         ("C-l" . dired-up-directory) ;; backspace does not work in terminal-mode
         ("TAB" . dired-find-file)))

(use-package dired-rainbow
  :after (dired)
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
  :after (dired)
  :hook ((dired-mode . all-the-icons-dired-mode)))

(use-package dired-hide-dotfiles
  :after (dired)
  :bind (:map dired-mode-map
              ("H" . dired-hide-dotfiles-mode)))

;; -------------------------------------------------------------------
;; Undo tree - make undos more powerful
;; -------------------------------------------------------------------
(use-package undo-tree
  :init
  (global-undo-tree-mode)
  :config
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
  :if (display-graphic-p)
  :init
  ;; ensure system dependencies
  (ff/ensure-apt-package "vlc" "vlc")
  (ff/ensure-apt-package "eog" "eog")
  (ff/ensure-apt-package "firefox" "firefox")
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
                '("html" "htm"))
               "firefox" '(file)))))

;; -------------------------------------------------------------------
;; Use doom modeline
;; -------------------------------------------------------------------
(use-package doom-modeline
  :custom
  ((doom-modeline-height 15)
   (doom-modeline-bar-width 6)
   (doom-modeline-modal-icon t)
   (doom-modeline-lsp t)
   (doom-modeline-github nil)
   (doom-modeline-mu4e nil)
   (doom-modeline-irc nil)
   (doom-modeline-minor-modes nil)
   (doom-modeline-persp-name nil)
   (doom-modeline-display-default-persp-name nil)
   (doom-modeline-persp-icon nil)
   (doom-modeline-lsp t)
   (doom-modeline-buffer-file-name-style 'truncate-except-project)
   (doom-modeline-buffer-modification-icon t)
   (doom-modeline-major-mode-icon t)
   (doom-modeline-buffer-encoding nil)
   (doom-modeline-vcs-max-length 48))
  :init
  ;; show column numbers on the modeline
  (column-number-mode 1)
  (doom-modeline-mode +1))

;; -------------------------------------------------------------------
;; Auto-saving changed files when they lose focus
;; -------------------------------------------------------------------
(setq auto-save-default nil)

(use-package super-save
  :custom
  ((super-save-auto-save-when-idle nil))
  :init
  (super-save-mode t))

;; -------------------------------------------------------------------
;; Insert Pairs of Matching Elements
;; -------------------------------------------------------------------
(use-package paren
  :custom
  ((show-paren-style 'mixed)	;; The entire expression
   (blink-matching-paren t))
  :init
  (show-paren-mode 1)
  :config
  (set-face-background 'show-paren-match (face-background 'default))
  (set-face-foreground 'show-paren-match "#def")
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold)
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a"))

;; -------------------------------------------------------------------
;; Save history during sessions
;; -------------------------------------------------------------------
(use-package savehist
  :custom
  (savehist-additional-variables '(extended-command-history kill-ring))
  :init
  (savehist-mode t))
;; -------------------------------------------------------------------
;; Popper - handle pop up buffers nicely
;; -------------------------------------------------------------------
(use-package popper
  :custom
  (popper-reference-buffers '("\\*Messages\\*"
                              "Output\\*$"
                              "\\*Async Shell Command\\*"
                              help-mode
                              helpful-mode
                              compilation-mode))
  :init
  ;; group poppers by project.el projects
  (setq popper-group-function #'popper-group-by-project)
  (popper-mode t)
  (popper-echo-mode t)
  :bind (("C-*" . popper-toggle-latest)
         ("M-*" . popper-cycle)
         ("C-M-*" . popper-toggle-type)))

;; -------------------------------------------------------------------
;; Ripgrep integration
;; -------------------------------------------------------------------
(use-package rg
  :init
  (ff/ensure-apt-package "ripgrep" "rg")
  (rg-enable-menu))

;; -------------------------------------------------------------------
;; Gumshoe: jump back and forth through marked positions
;; -------------------------------------------------------------------
(use-package gumshoe
  :custom
  ((gumshoe-slot-schema '(time buffer position line))
   (gumshoe-idle-time 0.2)
   (gumshoe-log-len 50)
   (gumshoe-show-footprints-p nil))
  :init
  ;; Enabing global-gumshoe-mode will initiate tracking
  (global-gumshoe-mode)
  :bind (;; enable browser like key bindings to move forth and
         ;; back in bookmarks
         ("M-<left>" . gumshoe-backtrack-back)
         ("M-<right>" . gumshoe-backtrack-forward)))

;; -------------------------------------------------------------------
;; Treemacs
;; -------------------------------------------------------------------
(defun treemacs-custom-filter (file _)
  "Custom filter function for files in treemacs.

FILE: filename"
  (or (s-ends-with? ".aux" file)
      (s-ends-with? ".lint" file)))

(defun ff/lsp-treemacs-symbols-toggle ()
  "Toggle the lsp-treemacs-symbols buffer."
  (interactive)
  (if (get-buffer "*LSP Symbols List*")
      (kill-buffer "*LSP Symbols List*")
    (progn (lsp-treemacs-symbols)
           (other-window -1))))

(use-package treemacs
  :after (lsp-mode)
  :commands
  (treemacs
   treemacs-follow-mode
   treemacs-filewatch-mode
   treemacs-fringe-indicator-mode)
  :custom
  ((treemacs-width 40)
   (treemacs-indentation 1)
   (treemacs-space-between-root-nodes nil))
  :init
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode nil)
  :config
  (push #'treemacs-custom-filter treemacs-ignored-file-predicates)
  :bind (("C-x t t" . treemacs)
         ("C-x t s" . ff/lsp-treemacs-symbols-toggle)))

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
                compilation-mode-hook
                pdf-view-mode-hook))
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
  :custom
  ((yas-wrap-around-region t))
  :init
  ;; add pesonal snippets directory
  (add-to-list 'yas-snippet-dirs (expand-file-name "snippets/" emacs-config-home))
  ;; enable yas everywhere
  (yas-global-mode 1)
  :config
  (setq yas-verbosity 1)
  :bind (("C-c C-y" . yas-insert-snippet)))

(use-package yasnippet-snippets
  :after (yasnippet))

;; -------------------------------------------------------------------
;; Code style checker
;; -------------------------------------------------------------------
(use-package flycheck
  :hook ((lsp-mode . flycheck-mode))
  :init (global-flycheck-mode))

;; -------------------------------------------------------------------
;; Ace window: select windows based on numbers
;; -------------------------------------------------------------------
(use-package ace-window
  :bind (("M-o" . ace-window)))

;; -------------------------------------------------------------------
;; Direnv: I am using the buffer local version and not the direnv
;; package
;; -------------------------------------------------------------------
(use-package envrc
  :init (envrc-global-mode t))

(provide 'basic-settings)

;;; basic-settings.el ends here
