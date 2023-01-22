;;; ff-core.el --- Setup all basic settings

;;; Commentary:
;; Configuration for basic settings

;;; Code:

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; enables local variables per default
(setq enable-local-variables t)
;; dir-local variables will be applied to remote files.
(setq enable-remote-dir-locals t)

;; dont warn for following symlinked files
(setq vc-follow-symlinks t)

;; disable lockfiles
(setq create-lockfiles nil)

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
(add-to-list 'recentf-exclude "^/ssh:.*")
(add-to-list 'recentf-exclude "^/docker:.*")
;; make sure that recentf is not littering emacs user home
(add-to-list 'recentf-exclude no-littering-var-directory)
(add-to-list 'recentf-exclude no-littering-etc-directory)

;; set unicode encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Iterate through CamelCase
(global-subword-mode t)

;; save desktop session automatically
(use-package desktop
  :custom
  ((desktop-load-locked-desktop t)))

;; enable smooth scrolling mode
(pixel-scroll-precision-mode t)

;; highlight the marked region (C-SPC) and use commands (like
;; latex-environment) on current region.
(transient-mark-mode t) ;; C-SPC - for selection
;; for highlighting rectangles, use the (rectangle-mark-mode).
;; C-x SPC - for selection; C-x SPC C-t for inserting stuff

;; Indentation: use only spaces, no tabs
(setq-default indent-tabs-mode nil)

;; enable auto pair mode globally
(electric-pair-mode t)

;; save cursor position in files even when buffers are killed
(save-place-mode)

;; -------------------------------------------------------------------
;; Global key bindings
;; -------------------------------------------------------------------
;; Kill this buffer, instead of prompting for which one to kill
(global-set-key (kbd "C-x k") #'(lambda() (interactive) (kill-buffer (current-buffer))))

;; make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; disable scroll lock mode permanently
(defun do-nothing () "Does simply nothing." (interactive))
(global-set-key (kbd "<Scroll_Lock>") 'do-nothing)
(defvar scroll-lock-mode nil)

;; convenient setting to move between open buffers
(global-set-key (kbd "C-S-B") 'windmove-left)
(global-set-key (kbd "C-S-F") 'windmove-right)
(global-set-key (kbd "C-S-P") 'windmove-up)
(global-set-key (kbd "C-S-N") 'windmove-down)

(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)

;; winner mode for for redo/undo window configurations
(winner-mode 1)
(global-set-key (kbd "C-c p") 'winner-undo)
(global-set-key (kbd "C-c n") 'winner-redo)

;; -------------------------------------------------------------
;; Core packages
;; -------------------------------------------------------------

;; make sure that the path environment from shell is available
(use-package exec-path-from-shell
   :unless (string-equal system-type "windows-nt")
   :custom (exec-path-from-shell-variables '("PATH" "MANPATH" "SSH_AUTH_SOCK" "HTTP_PROXY" "HTTPS_PROXY"))
   :config
   (exec-path-from-shell-initialize))

;; this is required for several, non-officially supported binaries
;; like plantuml and languagetool
(defun ff/download-and-extract-zip-archive (url name extract-to expected-binary-file package-name)
  "Download and install zip archives."
  (let* ((temporary-file (concat temporary-file-directory name ".zip")))
    (unless (file-directory-p extract-to) (make-directory extract-to t))
    (unless  (file-exists-p expected-binary-file)
      (unless (file-exists-p temporary-file)
        (message (concat "[" package-name "] Downloading " name " to " temporary-file))
        (url-copy-file url temporary-file))
      (message (concat "[" package-name "] Decompress " name " to " extract-to))
      (call-process-shell-command (concat "unzip " temporary-file " -d " extract-to) nil 0))))

;; Turn on syntax colouring in all modes supporting it
(use-package tree-sitter
  :hook ((python-mode . tree-sitter-hl-mode)
         (c-mode . tree-sitter-hl-mode)
         (c++-mode . tree-sitter-hl-mode)
         (typescript-mode . tree-sitter-hl-mode)
         (sh-mode . tree-sitter-hl-mode)
         (java-mode . tree-sitter-hl-mode)
         (json-mode . tree-sitter-hl-mode)
         (yaml-mode . tree-sitter-hl-mode)))

;; support for various languages for tree sitter
(use-package tree-sitter-langs)

;; Let kill operate on the whole line when no region is selected
(use-package whole-line-or-region
  :init (whole-line-or-region-global-mode t))

;; volatile highlights - temporarily highlight changes from pasting
(use-package volatile-highlights
  :init (volatile-highlights-mode t))

;; -------------------------------------------------------------
;; Delete trailing white spaces only for lines that are touched. This
;; replaces the obvious, more intrusive, approach of
(use-package ws-butler
  :init (ws-butler-global-mode t))

;; -------------------------------------------------------------
;; Better help
;; -------------------------------------------------------------------
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
(defun ff/tab-bar-list ()
  "Provide string list of all tab names."
  (interactive)
  (mapcar #'(lambda (tab) (alist-get 'name tab))
		  (tab-bar-tabs)))

(defun ff/tab-bar-show-tab-list ()
  "Show list of all tab names."
  (interactive)
  (message (string-join (ff/tab-bar-list) " ")))

(defun ff/tab-bar-tab-exists (name)
  "Check whether the given tab-name exists already.
NAME: name of a tab"
  (member name (ff/tab-bar-list)))

(defun ff/tab-bar-new-tab (name)
  "Create a new tab with the given name.
NAME: name of a tab"
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
         ("C-x t h t" . ff/tab-bar-run-todos)
         ("C-x t h c" . ff/tab-bar-run-notes)
         ("C-x t h n" . ff/tab-bar-run-aos)
         ("C-x t l" . ff/tab-bar-show-tab-list)))

;; -------------------------------------------------------------------
;; Project (built in project handling mode; similar to projectile)
;; -------------------------------------------------------------------
(defun ff/project-root ()
  "Provide path to project root directory."
  (interactive "P")
  (expand-file-name (project-root (project-current t))))

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

(defun ff/project-project-tab ()
  "Switch to a workspace with the project name."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
    (when (not (member project-name (ff/tab-bar--names)))
      (tab-bar-new-tab)
      (tab-bar-rename-tab project-name))
    (tab-bar-switch-to-tab project-name)))

(defun ff/project-switch-project ()
  "Switch to a workspace with the project name."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
    (when (not (member project-name (ff/tab-bar--names)))
      (tab-bar-new-tab)
      (tab-bar-rename-tab project-name))
    (tab-bar-switch-to-tab project-name)
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
                              (project-dired "Dired"))))
  :bind (:map project-prefix-map
              ("P" . ff/project-switch-project)
              ("m" . ff/project-magit)
              ("v" . ff/project-vterm)
              ("a" . affe-find)
              ("g" . affe-grep)
              ("t" . ff/project-project-tab)))

;; -------------------------------------------------------------
;; NOTE: The first time you load your configuration on a new machine,
;; you’ll need to run `M-x all-the-icons-install-fonts` so that mode
;; line icons display correctly.
(use-package all-the-icons)

(use-package which-key
  :custom ((which-key-idle-delay 1))
  :init (which-key-mode 1))

;; -------------------------------------------------------------
;; center the text for the corresponding modes; writing documentation
;; is easier with this setting.
(use-package olivetti
  :custom ((olivetti-body-width 0.66))
  :hook ((org-mode . olivetti-mode)
         (rst-mode . olivetti-mode)
         (markdown-mode . olivetti-mode)
         (LaTeX-mode . olivetti-mode)))

;; -------------------------------------------------------------------
;; Tramp
;; -------------------------------------------------------------------
(use-package tramp
  :straight nil
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
  ;; Use remote PATH on tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (make-directory tramp-auto-save-directory t))

;; docker-tramp is part of Emacs 29 core
;; multihop example: /ssh:frf2lr@ws|docker:vscode@c8416d9f4da6:/
(when (< emacs-major-version 29)
  (use-package docker-tramp))

;; -------------------------------------------------------------------
;; Transpose frame
;; -------------------------------------------------------------------
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
  ((dired-auto-revert-buffer nil) ; Auto update when buffer is revisited
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
         ("l" . dired-up-directory) ;; backspace does not work in terminal-mode
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
;; Auto-saving changed files when they lose focus
;; -------------------------------------------------------------------
(setq auto-save-default nil)

(use-package super-save
  :custom
  ((super-save-auto-save-when-idle nil))
  :init
  (super-save-mode t))

;; -------------------------------------------------------------------
;; Popper - handle pop up buffers nicely
;; -------------------------------------------------------------------
(use-package popper
  :custom
  (popper-reference-buffers '("\\*Messages\\*"
                              "Output\\*$"
                              "\\*Async Shell Command\\*"
                              magit-process-mode
                              help-mode
                              helpful-mode
                              compilation-mode))
  ;; group poppers by project.el projects
  (popper-group-function #'popper-group-by-project)
  :init
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
  (rg-enable-menu)
  :config
  (rg-define-search ff/rg-current-dir
    "Search for thing at point in files matching the current file
under the current directory."
    :query ask
    :format literal
    :dir current
    :menu ("Search" "a" "Current folder")))

;; -------------------------------------------------------------------
;; Gumshoe: jump back and forth through marked positions
;; -------------------------------------------------------------------
(use-package gumshoe
  :straight (gumshoe :type git
                     :host github
                     :repo "Overdr0ne/gumshoe"
                     :branch "master")
  :custom
  ((gumshoe-slot-schema '(buffer line))
   (gumshoe-idle-time 0.2)
   (gumshoe-log-len 50)
   (gumshoe-show-footprints-p nil))
  :init
  ;; Enabing global-gumshoe-mode will initiate tracking
  (global-gumshoe-mode t)
  :bind (;; enable browser like key bindings to move forth and
         ;; back in bookmarks
         ("M-p" . global-gumshoe-backtracking-mode-back)
         ("M-n" . global-gumshoe-backtracking-mode-forward)))

;; -------------------------------------------------------------------
;; Drag stuff around with M-up/down
;; -------------------------------------------------------------------
(use-package drag-stuff
  :config
  (drag-stuff-global-mode t)
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
;; Ace window: select windows based on numbers
;; -------------------------------------------------------------------
(use-package ace-window
  :bind (("M-o" . ace-window)))

(provide 'ff-core)

;;; ff-core.el ends here
