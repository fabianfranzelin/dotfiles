;;; ff-core.el --- Setup all basic settings

;;; Commentary:
;; Configuration for basic settings

;;; Code:

(require 'ff-ensure-system-packages)

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
;; tramp and ssh
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
(electric-indent-mode nil)

(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (electric-pair-local-mode 0))))

;; save cursor position in files even when buffers are killed
(save-place-mode)

;; Create backup files in cache
(setq backup-directory-alist `(("." . ,(expand-file-name "saves" no-littering-var-directory))))
(setq backup-by-copying nil)
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

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
(require 'repeat)
(repeat-mode 1)

(defvar-keymap ff/window-key-map
  :doc "Bindings for managing windows, configured to be repeatable."
  :repeat t
  "c" 'delete-window
  "h" 'split-window-horizontally
  "v" 'split-window-vertically
  "b" 'windmove-left
  "f" 'windmove-right
  "n" 'windmove-down
  "p" 'windmove-up
  "B" 'windmove-swap-states-left
  "F" 'windmove-swate-states-right
  "N" 'windmove-swate-states-down
  "P" 'windmove-swap-states-up)

(global-set-key (kbd "C-c w") ff/window-key-map)

;; winner mode for for redo/undo window configurations
(winner-mode 1)

;; https://www.emacswiki.org/emacs/Repeatable
(defun ff/repeat-command (command)
  "Repeat COMMAND."
  (let ((repeat-previous-repeated-command  command)
        (repeat-message-function           #'ignore)
        (last-repeatable-command           'repeat))
    (repeat nil)))

;; make the undo/redo functions repeatable
(global-set-key (kbd "C-c p") #'(lambda () (interactive) (ff/repeat-command 'winner-undo)))
(global-set-key (kbd "C-c n") #'(lambda () (interactive) (ff/repeat-command 'winner-redo)))

;; highlight current line
(global-set-key (kbd "C-c h") 'global-hl-line-mode)

;; newline and indent
(global-set-key (kbd "C-j") 'newline-and-indent)

;; -------------------------------------------------------------
;; Core packages
;; -------------------------------------------------------------

;; make sure that the path environment from shell is available
(use-package exec-path-from-shell
  :unless (string-equal system-type "windows-nt")
  :custom (exec-path-from-shell-variables '("PATH"
                                            "MANPATH"
                                            "SSH_AUTH_SOCK"
                                            "HTTP_PROXY"
                                            "HTTPS_PROXY"))
  :config (exec-path-from-shell-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-c C-d" . helpful-at-point)
         ("C-h F" . helpful-function)
         ("C-h C" . helpful-command)))

;; -------------------------------------------------------------
;; Show available keybindings
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
(use-package tramp
  :straight nil
  :custom
  ((tramp-terminal-type "dumb")
   (tramp-default-method "ssh")
   (tramp-use-ssh-controlmaster-options nil)
   (vc-handled-backends '(Git)))
  :config
  (setq tramp-verbose 3
        tramp-auto-save-directory (expand-file-name "tramp/backups" no-littering-var-directory)
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

;; -------------------------------------------------------------------
;; Transpose frame
;; -------------------------------------------------------------------
(use-package transpose-frame
  :bind (("C-c b t" . transpose-frame)))

;; -------------------------------------------------------------------
;; Set up dired with async
;; -------------------------------------------------------------------
;; rename buffer content: C-x C-q, (wdired) C-c C-c to apply and C-c
;; ESC to cancel copy path of file: 0 w in dired buffer
(use-package dired
  :straight nil
  :custom
  ((dired-auto-revert-buffer nil) ; Auto update when buffer is revisited
   (dired-dwim-target t)
   (dired-recursive-deletes 'always)
   (dired-recursive-copies 'always)
   (delete-by-moving-to-trash t)
   (dired-listing-switches "-agho --group-directories-first")
   (dired-hide-details-hide-symlink-targets nil))
  :init
  (require 'dired-x)
  :config
  (autoload 'dired-omit-mode "dired-x")
  :hook ((dired-mode . auto-revert-mode)
         (dired-mode . dired-hide-details-mode)
         (dired-mode . hl-line-mode)
         ;; enables drag-and-drop in dired
         (dired-mode . org-download-enable))
  :bind (("C-x C-j" . dired-jump)
         :map dired-mode-map
         ("l" . dired-up-directory)
         ("TAB" . dired-find-file)))

(use-package dired-hacks
  :after (dired)
  :config
  (require 'dired-rainbow)

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

(use-package dired-hide-dotfiles
  :after (dired)
  :bind (:map dired-mode-map
              ("H" . dired-hide-dotfiles-mode)))

(use-package dired-rsync
  :bind (:map dired-mode-map
              ("C" . dired-rsync)))

;; -------------------------------------------------------------------
;; Undo tree - make undos more powerful
;; -------------------------------------------------------------------
(use-package undo-tree
  :init
  (global-undo-tree-mode)
  :config
  (setq undo-limit 8000000))

;; -------------------------------------------------------------------
;; Credential management
;; -------------------------------------------------------------------
(require 'auth-source-pass)
(auth-source-pass-enable)

(require 'auth-source)
;; Do not allow unencrypted auth-sources. Use GPG
(setq auth-sources `(password-store ,(expand-file-name "~/.password-store/authinfo.gpg")))
;; Use the Emacs minibuffer for GPG pinentry
;; https://vxlabs.com/2021/03/21/gnupg-pinentry-via-the-emacs-minibuffer/
(setq epa-pinentry-mode 'loopback)

(defun ff/restart-ssh-agent ()
  "Add all known ssh-keys from pass."
  (interactive)
  (async-shell-command "pkill -9 ssh-agent && eval $(ssh-agent -s) && ssh-add-keys"))

(use-package pass
  :custom ((pass-show-keybindings nil)))

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
  :custom ((super-save-auto-save-when-idle nil))
  :init (super-save-mode t))

;; -------------------------------------------------------------------
;; Popper - handle pop up buffers nicely
;; -------------------------------------------------------------------
(use-package popper
  :custom
  (popper-reference-buffers '("\\*Messages\\*"
                              "Output\\*$"
                              "\\*Async Shell Command\\*"
                              "\\*Dogears List\\*"
                              "\\*Backtrace\\*"
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
;; Fuzzy finder like fzf: In contrast to project.el it includes also
;; files that are not under version control
;; -------------------------------------------------------------------
(use-package affe
  :preface
  (defun ff/affe-find (dir)
    "Start the fuzzy find in the current directory.
DIR: directory"
    (affe-find dir))
  :after embark
  ;; search also in hidden and ignored files by git
  :custom ((affe-find-command
            (cond
             ((executable-find "rg") "rg --color=never --files -uu")
             (t "find -not ( -wholename */.* -prune ) -type f")))
           (affe-grep-command
            (cond
             ((executable-find "rg") "rg -uu --null --color=never --max-columns=1000 --no-heading --line-number -v ^$ .")
             (t "grep -I -r --exclude=.* --exclude-dir=.* --null --color=never --line-number -v ^$"))))
  :config
  ;; use orderless as expression compiler
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (orderless-pattern-compiler input))
    (cons input (apply-partially #'orderless--highlight input)))
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)

  :bind (("C-x a f" . affe-find)
         ("C-x a g" . affe-grep)
         :map embark-file-map
         ("a" . ff/affe-find)))

;; -------------------------------------------------------------------
;; Dogears: automatically bookmarks positions in buffers
;; -------------------------------------------------------------------
(use-package dogears
  :custom
  ((dogears-idle 0.5)
   (dogears-limit 50))
  :init
  (dogears-mode t)
  ;; These bindings are optional, of course:
  :bind (:map global-map
              ("M-g d" . dogears-go)
              ("M-g M-b" . dogears-back)
              ("M-g M-f" . dogears-forward)
              ("M-g M-d" . dogears-list)))

;; -------------------------------------------------------------------
;; Drag stuff around with M-up/down
;; -------------------------------------------------------------------
(use-package drag-stuff
  :config (drag-stuff-global-mode t)
  :bind (("M-p" . drag-stuff-up)
         ("M-<up>" . drag-stuff-up)
         ("M-n" . drag-stuff-down)
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
  (yas-wrap-around-region t)
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

(with-eval-after-load 'yasnippet-snippets
  (require 'yasnippet)
  ;; make snippets available in ts-modes when not already available
  (mapcar (lambda (element)
            (let* ((parent-mode (car element))
                   (target-mode (cdr element))
                   (target-folder (expand-file-name target-mode yasnippet-snippets-dir)))
              (unless (file-exists-p target-folder)
                (make-directory target-folder t)
                (with-temp-buffer
                  (insert parent-mode)
                  (write-file (expand-file-name ".yas-parents" target-folder))))))
          '(("python-mode" . "python-ts-mode")
            ("dockerfile-mode" . "dockerfile-ts-mode")
            ("sh-mode" . "bash-ts-mode")
            ("c++-mode" . "c++-ts-mode")
            ("c-mode" . "c-ts-mode")
            ("cmake-mode" . "cmake-ts-mode")
            ("css-mode" . "css-ts-mode")
            ("java-mode" . "java-ts-mode")
            ("js-mode" . "js-ts-mode")
            ("typescript-mode" . "typescript-ts-mode")
            ("typescript-mode". "tsx-ts-mode")
            ("yaml-mode" . "yaml-ts-mode"))))

;; -------------------------------------------------------------------
;; Ace window: select windows based on numbers
;; -------------------------------------------------------------------
(use-package ace-window
  :bind (("M-o" . ace-window)))

;; -------------------------------------------------------------------
;; Avy: Jump in buffer with three key strokes
;; -------------------------------------------------------------------
(use-package avy
  :custom
  ((avy-timeout 0.1))
  :bind (("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g c" . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zoom globally for all buffers
(use-package zoom-frm
  :bind (("C-c +" . zoom-frm-in)
         ("C-c -" . zoom-frm-out)))

(provide 'ff-core)

;;; ff-core.el ends here
