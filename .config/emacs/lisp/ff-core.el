;;; ff-core.el --- Setup all basic settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for basic settings

;;; Code:

;; -------------------------------------------------------------------
(customize-set-variable 'user-full-name "Fabian Franzelin")
(customize-set-variable 'user-mail-address "fabian.franzelin@gmail.com")
(customize-set-variable 'inhibit-startup-echo-area-message (getenv "USER"))

;; -------------------------------------------------------------------
;; Daemon settings
;; -------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;; -------------------------------------------------------------------
;; Package Management - straight.el
(require 'ff-straight)

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package
(use-package no-littering
  :demand t
  :custom
  (custom-file (no-littering-expand-etc-file-name "custom.el"))
  :config
  ;; setup a new custom file and load it
  (load custom-file t)
  ;; this sets the path right for undo-tree, auto-save and backup files
  (no-littering-theme-backups))

;; -------------------------------------------------------------------
(require 'ff-ensure-system-packages)

(defun ff/is-mobile ()
  "Define small screen sizes as mobile."
  (and (< (display-pixel-width) 750)
       (< (display-pixel-height) 500)))

;; enables local variables per default
(customize-set-variable 'enable-local-variables t)
;; dir-local variables will be applied to remote files.
(customize-set-variable 'enable-remote-dir-locals t)

;; don't warn for following symlinked files
(customize-set-variable 'vc-follow-symlinks t)

;; disable lockfiles
(customize-set-variable 'create-lockfiles nil)

;; revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; use short answers for yes-or-no prompts
(setopt use-short-answers t)

;; ignore bell function
(customize-set-variable 'ring-bell-function 'ignore)

;; let me confirm Emacs before killing it
(customize-set-variable 'confirm-kill-emacs 'yes-or-no-p)

(defun ff/ask-before-closing-frame ()
  "Close only if y was pressed."
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to close this frame? "))
      (server-save-buffers-kill-terminal nil)
    (message "Canceled frame close")))

(when (daemonp)
  (keymap-global-set "C-x C-c" 'ff/ask-before-closing-frame))

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
(save-place-mode t)

;; Create backup files in cache
(customize-set-variable 'backup-directory-alist `(("." . ,(expand-file-name "saves" no-littering-var-directory))))
(customize-set-variable 'backup-by-copying nil)
(customize-set-variable 'delete-old-versions t)
(customize-set-variable 'kept-new-versions 6)
(customize-set-variable 'kept-old-versions 2)
(customize-set-variable 'version-control t)

(defun ff/sudo-shell-command (command)
  "Launch sudo command asynchronously with tramp.

COMMAND: command to be executed"
  (interactive "MShell command (sudo): ")
  (with-temp-buffer
    (cd "/sudo::/")
    (async-shell-command command)))

;; add newline with C-n when at end of buffer.
(customize-set-variable 'next-line-add-newlines nil)

;; -------------------------------------------------------------------
;; Global key bindings
;; -------------------------------------------------------------------

;; the menu key shall trigger alt-x explicitly
(keymap-global-set "<menu>" 'execute-extended-command)
(define-key context-menu-mode-map [menu] nil)

;; convenient setting to move between open buffers
(require 'repeat)
(repeat-mode 1)

;; Kill this buffer, instead of prompting for which one to kill
(defun ff/kill-buffer-current ()
  "Kill current buffer."
  (interactive)
  (kill-buffer (current-buffer)))

(keymap-global-set "C-x k" #'(lambda ()
                               (interactive)
                               (ff/repeat-command 'ff/kill-buffer-current)))

;; make ESC quit prompts
(keymap-global-set "<escape>" 'keyboard-escape-quit)

;; disable scroll lock mode permanently
(defun do-nothing () "Does simply nothing." (interactive))
(keymap-global-set "<Scroll_Lock>" 'do-nothing)
(defvar scroll-lock-mode nil)

(defun ff/split-window-right ()
  "Split window right and move to the new window."
  (interactive)
  (split-window-right)
  (other-window 1))

(keymap-global-set "C-x 3" 'ff/split-window-right)

(defun ff/split-window-below ()
  "Split window right and move to the new window."
  (interactive)
  (split-window-below)
  (other-window 1))

(keymap-global-set "C-x 2" 'ff/split-window-below)

;; window movement
(defvar-keymap ff/window-key-map
  :doc "Bindings for managing windows, configured to be repeatable."
  :repeat t
  "c" 'delete-window
  "h" 'split-window-horizontally
  "v" 'split-window-vertically
  "b" 'windmove-swap-states-left
  "f" 'windmove-swap-states-right
  "n" 'windmove-swap-states-down
  "p" 'windmove-swap-states-up)

(keymap-global-set "C-q" ff/window-key-map)

;; https://www.emacswiki.org/emacs/Repeatable
(defun ff/repeat-command (command)
  "Repeat COMMAND."
  (let ((repeat-previous-repeated-command command)
        (repeat-message-function #'ignore)
        (last-repeatable-command 'repeat))
    (repeat nil)))

;; make the undo/redo functions repeatable
(tab-bar-history-mode 1)
(setq tab-bar-history-limit 100)
(keymap-global-set "C-c p" #'(lambda () (interactive) (ff/repeat-command 'tab-bar-history-back)))
(keymap-global-set "C-c n" #'(lambda () (interactive) (ff/repeat-command 'tab-bar-history-forward)))

;; highlight current line
(keymap-global-set "C-c h" 'global-hl-line-mode)

;; newline and indent
(keymap-global-set "C-j" 'newline-and-indent)

;; let firefox be the default browser
(ff/ensure-apt-package "firefox" "firefox")
(customize-set-variable 'browse-url-browser-function 'browse-url-firefox)

;; cycle through windows within the same frame
(keymap-global-set "M-o" 'other-window)

;; enable view-mode per default in read-only buffers
(customize-set-variable 'view-read-only t)

;; use single keys for navigating in read-only buffers
(with-eval-after-load 'view
  (define-key view-mode-map "n" 'next-line)
  (define-key view-mode-map "p" 'previous-line)
  (define-key view-mode-map "f" 'forward-char)
  (define-key view-mode-map "b" 'backward-char)
  (define-key view-mode-map "a" 'beginning-of-visual-line)
  (define-key view-mode-map "e" 'end-of-visual-line)
  (define-key view-mode-map "l" 'recenter-top-bottom)
  (define-key view-mode-map "k" 'ff/kill-buffer-current)
  (define-key view-mode-map "q" 'View-exit))

(keymap-global-set "C-c v" 'view-mode)

;; -------------------------------------------------------------
;; Core packages
;; -------------------------------------------------------------

;; make sure that the path environment from shell is available
(use-package exec-path-from-shell
  :unless (string-equal system-type "windows-nt")
  :demand t
  :custom
  (exec-path-from-shell-variables '("PATH"
                                    "MANPATH"
                                    "SSH_AUTH_SOCK"
                                    "HTTP_PROXY"
                                    "HTTPS_PROXY"
                                    "NO_PROXY"
                                    "no_proxy"
                                    "BROWSER"
                                    "HISTFILE"
                                    "PASSWORD_STORE_DIR"))
  :config
  (exec-path-from-shell-initialize))

;; -------------------------------------------------------------------
;; Proxy management
;; -------------------------------------------------------------------
(defvar ff/--proxy-env-backup nil
  "Alist storing the original proxy environment variable values.")

(defun ff/--proxy-save-values ()
  "Save current proxy environment variables if not already saved."
  (unless ff/--proxy-env-backup
    (setq ff/--proxy-env-backup
          (mapcar (lambda (var) (cons var (getenv var)))
                  '("HTTP_PROXY" "HTTPS_PROXY" "NO_PROXY" "no_proxy")))))

(defun ff/--proxy-build-url-proxy-services ()
  "Build `url-proxy-services' from the current HTTP_PROXY and HTTPS_PROXY env vars."
  (let ((http (getenv "HTTP_PROXY"))
        (https (getenv "HTTPS_PROXY"))
        (no-proxy (getenv "NO_PROXY"))
        result)
    (when http
      (let ((host-port (replace-regexp-in-string "^https?://" "" http)))
        (push (cons "http" host-port) result)))
    (when https
      (let ((host-port (replace-regexp-in-string "^https?://" "" https)))
        (push (cons "https" host-port) result)))
    (when no-proxy
      (push (cons "no_proxy" (replace-regexp-in-string "," " " no-proxy)) result))
    result))

(defun ff/proxy-disable ()
  "Disable proxy for the running Emacs instance."
  (interactive)
  (ff/--proxy-save-values)
  (dolist (var '("HTTP_PROXY" "HTTPS_PROXY" "NO_PROXY" "no_proxy"))
    (setenv var nil))
  (setq url-proxy-services nil)
  (message "Proxy disabled."))

(defun ff/proxy-enable ()
  "Re-enable proxy for the running Emacs instance from saved values."
  (interactive)
  (unless ff/--proxy-env-backup
    (user-error "No saved proxy values found; proxy was never disabled"))
  (dolist (entry ff/--proxy-env-backup)
    (setenv (car entry) (cdr entry)))
  (setq url-proxy-services (ff/--proxy-build-url-proxy-services))
  (setq ff/--proxy-env-backup nil)
  (message "Proxy enabled: HTTP_PROXY=%s" (getenv "HTTP_PROXY")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let kill operate on the whole line when no region is selected
(use-package whole-line-or-region
  :hook
  (after-init . whole-line-or-region-global-mode))

;; volatile highlights - temporarily highlight changes from pasting
(use-package volatile-highlights
  :hook
  (after-init . volatile-highlights-mode))

;; -------------------------------------------------------------
;; Delete trailing white spaces only for lines that are touched. This
;; replaces the obvious, more intrusive, approach of
(use-package ws-butler
  :straight (:host github :repo "lewang/ws-butler" :branch "master")
  :hook
  (after-init . ws-butler-global-mode))

;; -------------------------------------------------------------
;; Better help
(use-package helpful
  :bind
  (:map global-map
        ("C-h f" . helpful-callable)
        ("C-h v" . helpful-variable)
        ("C-h k" . helpful-key)
        ("C-c C-d" . helpful-at-point)
        ("C-h F" . helpful-function)
        ("C-h C" . helpful-command)))

;; -------------------------------------------------------------
;; Show available keybindings
(use-package which-key
  :straight (:type built-in)
  :custom
  (which-key-idle-delay 1)
  :hook
  (after-init . which-key-mode))

;; -------------------------------------------------------------------
;; Tramp
(use-package tramp
  :straight (:type built-in)
  :custom
  (tramp-terminal-type "dumb")
  (tramp-default-method "ssh")
  (tramp-use-ssh-controlmaster-options nil)
  (vc-handled-backends '(Git))
  (tramp-verbose 3)
  (tramp-auto-save-directory (expand-file-name "tramp/backups" no-littering-var-directory))
  (tramp-persistency-file-name (expand-file-name "tramp/persistency_data" no-littering-var-directory))
  ;; make sure vc stuff is not making tramp slower
  (vc-ignore-dir-regexp (format "%s\\|%s"
		                vc-ignore-dir-regexp
		                tramp-file-name-regexp))
  ;; https://www.gnu.org/software/emacs/manual/html_node/tramp/Password-handling.html
  (ange-ftp-netrc-filename (expand-file-name "authinfo.gpg" (getenv "PASSWORD_STORE_DIR")))
  :config
  (put 'temporary-file-directory 'standard-value '("/tmp"))
  ;; Use remote PATH on tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (make-directory tramp-auto-save-directory t))

;; docker-tramp is part of Emacs 29 core
;; multihop example: /ssh:frf2lr@ws|docker:vscode@c8416d9f4da6:/

(defun ff/tramp-call-process-direct (protocol host user command &optional args)
  "Execute a remote COMMAND directly on HOST via TRAMP using PROTOCOL and return output.
USER specifies the remote user.  ARGS is a list of command arguments.

Example usage: (message (my/tramp-call-process-direct \"your-remote-host.com\" \"your-username\" \"ls\" '(\"-l\" \"/tmp\")))"
  (let* ((tramp-program (format "/%s:%s@%s:/bin/%s" protocol user host command))
         (process-buffer (generate-new-buffer "*tramp-output*")))
    (message "Executing remote command: %s %S" tramp-program args)
    (with-current-buffer process-buffer
      (apply 'call-process tramp-program nil (current-buffer) nil args))
    (prog1 (buffer-string)
      (kill-buffer process-buffer))))

;; -------------------------------------------------------------------
;; Transpose frame
;; -------------------------------------------------------------------
(use-package transpose-frame
  :bind
  (:map global-map
        ("C-c t" . transpose-frame)))

;; -------------------------------------------------------------------
;; Set up dired with async
;; -------------------------------------------------------------------
;; mainly required for dired-async
(use-package async
  :hook
  (after-init . dired-async-mode))

;; rename buffer content: C-x C-q, (wdired) C-c C-c to apply and C-c
;; ESC to cancel copy path of file: 0 w in dired buffer
(use-package dired
  :straight (:type built-in)
  :after async
  :custom
  (dired-auto-revert-buffer nil) ; Auto update when buffer is revisited
  (dired-dwim-target t)
  (dired-recursive-deletes 'always)
  (dired-recursive-copies 'always)
  (delete-by-moving-to-trash t)
  (dired-listing-switches "-agho --group-directories-first")
  (dired-hide-details-hide-symlink-targets nil)
  (dired-mouse-drag-files t)
  (dired-vc-rename-file t)
  :init
  (require 'dired-x)
  (autoload 'dired-omit-mode "dired-x")
  :hook
  (dired-mode . auto-revert-mode)
  (dired-mode . dired-hide-details-mode)
  (dired-mode . hl-line-mode)
  :bind
  (:map global-map
        ("C-x C-j" . dired-jump)
        :map dired-mode-map
        ("l" . dired-up-directory)
        ("TAB" . dired-find-file)))

(use-package diredfl
  :config
  (diredfl-global-mode 1))

(use-package dired-hide-dotfiles
  :after dired
  :bind
  (:map dired-mode-map
        ("H" . dired-hide-dotfiles-mode)))

(use-package dired-rsync
  :after dired
  :bind (:map dired-mode-map
              ("r" . dired-rsync)))

(use-package dired-subtree
  :after dired
  :bind
  (:map dired-mode-map
        ("<backtab>" . dired-subtree-toggle)))

(use-package dired-git-info
  :bind
  (:map dired-mode-map
        (")" . dired-git-info-mode)))

(use-package trashed
  :commands trashed
  :custom
  (trashed-action-confirmer 'y-or-n-p)
  (trashed-use-header-line t)
  (trashed-sort-key '("Date deleted" . t))
  (trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package dwim-shell-command
  :bind
  (:map
   dired-mode-map
   ([remap dired-do-async-shell-command] . dwim-shell-command)
   ([remap dired-do-shell-command] . dwim-shell-command)
   ([remap dired-smart-shell-command] . dwim-shell-command)
   ("C-d j" . dwim-shell-commands-join-as-pdf)
   ("C-d r" . dwim-shell-commands-reorient-image)
   ("C-d v" . dwim-shell-commands-video-to-mp3)
   ("C-d m" . dwim-shell-commands-audio-to-mp3)
   ("C-d z" . dwim-shell-commands-zip)
   ("C-d o" . ff/dwim-shell-commands-rebot)
   :map global-map
   ("C-x D g" . dwim-shell-commands-kill-gpg-agent)
   ("C-x D p" . dwim-shell-commands-kill-process)
   ("C-x D s" . ff/dwim-shell-commands-add-ssh-keys)
   ("C-x D k" . ff/dwim-shell-commands-set-keyboard-layout)
   ("C-x D m" . ff/dwim-shell-commands-mount-pauline)
   ("C-x D d" . ff/proxy-disable)
   ("C-x D e" . ff/proxy-enable))
  :config
  (require 'dwim-shell-commands)
  (defun ff/dwim-shell-commands-add-ssh-keys ()
    "Restart ssh agent and add ssh keys from password store."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Restart ssh agent and add ssh keys from password store."
     "ssh-add-keys"
     :utils "ssh-add-keys"
     :silent-success t))
  (defun ff/dwim-shell-commands-set-keyboard-layout ()
    "Set default keyboard layout."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Set default keyboard layout."
     "set_keyboard_layout"
     :utils "set_keyboard_layout"
     :silent-success t))
  (defun ff/dwim-shell-commands-rebot ()
    "Set default keyboard layout."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Launch rebot to convert xml files to html reports."
     "rebot '<<f>>'"
     :utils "rebot"
     :silent-success t))
  (defun ff/dwim-shell-commands-mount-pauline ()
    "Set default keyboard layout."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Mount Pauline's hard drives via sshfs."
     "sshfs-pauline"
     :utils "sshfs-pauline"
     :silent-success t)))

;; -------------------------------------------------------------------
;; Undo tree - make undos more powerful
;; -------------------------------------------------------------------
(use-package vundo
  :bind
  (:map global-map
        ("C-x u" . vundo)
        ("C-_" . undo)
        ("M-_" . undo-redo)))

;; -------------------------------------------------------------------
;; Credential management
;; -------------------------------------------------------------------
(unless (getenv "PASSWORD_STORE_DIR")
  (setenv "PASSWORD_STORE_DIR" (expand-file-name "~/.local/share/password-store")))

(require 'auth-source-pass)
(auth-source-pass-enable)

(require 'auth-source)
;; Do not allow unencrypted auth-sources. Use GPG
(customize-set-variable 'auth-sources
                        `(password-store ,(expand-file-name
                                           "authinfo.gpg"
                                           (getenv "PASSWORD_STORE_DIR"))))

(require 'epg)
;; Use the Emacs minibuffer for GPG pinentry
;; https://vxlabs.com/2021/03/21/gnupg-pinentry-via-the-emacs-minibuffer/
(customize-set-variable 'epa-pinentry-mode 'loopback)

(defun ff/unlock-first-gpg-key (&rest _)
  "Identify the first available private GPG key and unlock it by signing a test string.
Returns t so it can be used as :before-while advice without blocking the advised function."
  (interactive)
  (let* ((context (epg-make-context 'OpenPGP))
         ;; Filter for secret/private keys only
         (keys (epg-list-keys context nil t)))
    (if (null keys)
        (progn (message "No private GPG keys found.") t)
      (let* ((first-key (car keys))
             (key-id (epg-sub-key-id (car (epg-key-sub-key-list first-key)))))
        (condition-case err
            (progn
              ;; Attempt to sign a dummy string to trigger the pinentry/unlock
              (epg-sign-string context "unlock-test" 'detach)
              (message "Successfully unlocked key: %s" key-id)
              t)
          (error
           (message "Failed to unlock key %s: %s" key-id (error-message-string err))
           t))))))

(keymap-global-set "C-c C-g" 'ff/unlock-first-gpg-key)

(use-package pass
  :custom (pass-show-keybindings nil))

;; -------------------------------------------------------------------
;; Auto-saving changed files when they lose focus
;; -------------------------------------------------------------------
(customize-set-variable 'auto-save-default nil)

(use-package super-save
  :custom
  (super-save-auto-save-when-idle nil)
  :hook
  (after-init . super-save-mode))

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
                              compilation-mode
                              reverso-result-mode
                              special-mode))
  :hook
  (after-init . popper-mode)
  (after-init . popper-echo-mode)
  :config
  ;; group poppers by project.el projects
  (with-eval-after-load 'project
    (customize-set-variable 'popper-group-function #'popper-group-by-project))
  :bind
  (:map global-map
        ("C-*" . popper-toggle)
        ("M-*" . popper-cycle)
        ("C-M-*" . popper-toggle-type)))

;; -------------------------------------------------------------------
;; Ripgrep integration
;; -------------------------------------------------------------------
(use-package rg
  :straight (rg :type git :host github :repo "fabianfranzelin/rg.el")
  :preface
  (ff/ensure-apt-package "ripgrep" "rg")
  :hook
  (after-init . rg-enable-menu)
  :config
  (rg-define-search ff/rg-current-dir
    "Search for thing at point in files matching the current file
    under the current directory."
    :dir current
    :flags ("--hidden")
    :query ask
    :format literal
    :menu ("Search" "a" "(ff) Current folder"))
  (rg-define-search ff/rg-current-project
    "Search for thing at point in files matching the current file
    under the project directory."
    :dir (locate-dominating-file default-directory ".git")
    :flags ("--hidden")
    :query ask
    :format literal
    :menu ("Search" "P" "(ff) Project")))

;; -------------------------------------------------------------------
;; Fuzzy finder like fzf: In contrast to project.el it includes also
;; files that are not under version control
;; -------------------------------------------------------------------
(use-package affe
  :after embark
  :preface
  (defun ff/affe-find (dir)
    "Start the fuzzy find in the current directory.
    DIR: directory"
    (affe-find dir))
  (defun ff/affe-grep (dir)
    "Start the fuzzy grep in the current directory.
    DIR: directory"
    (affe-grep dir))
  ;; search also in hidden and ignored files by git
  :custom
  ;; Extend the search for hidden and ignored (-uu) as well as for a
  ;; case sensitive (-s) content
  (affe-find-command
   (cond
    ((executable-find "rg") "rg --color=never --files -uu -s")
    (t "find -not ( -wholename */.* -prune ) -type f")))
  (affe-grep-command
   (cond
    ((executable-find "rg") "rg -uu -s --null --color=never --max-columns=1000 --no-heading --line-number -v ^$ .")
    (t "grep -I -r --exclude=.* --exclude-dir=.* --null --color=never --line-number -v ^$")))
  :config
  ;; use orderless as expression compiler
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))
  (customize-set-variable 'affe-regexp-compiler #'affe-orderless-regexp-compiler)
  :bind
  (:map global-map
        ("M-s a g" . affe-grep)
        ("M-s a G" . (lambda () (interactive) (ff/affe-grep default-directory)))
        :map project-prefix-map
        ("a" . affe-find)
        ("A" . (lambda () (interactive) (ff/affe-find default-directory)))
        :map embark-file-map
        ("a" . ff/affe-find)))

;; -------------------------------------------------------------------
;; Dogears: automatically bookmarks positions in buffers
;; -------------------------------------------------------------------
(use-package dogears
  :hook
  (after-init . dogears-mode)
  :custom
  (dogears-idle 0.2)
  (dogears-limit 50)
  ;; These bindings are optional, of course:
  :bind
  (:map global-map
        ("M-g M-b" . (lambda () (interactive) (ff/repeat-command 'dogears-back)))
        ("M-g M-f" . (lambda () (interactive) (ff/repeat-command 'dogears-forward)))))

;; -------------------------------------------------------------------
;; Drag stuff around with M-up/down
;; -------------------------------------------------------------------
(use-package drag-stuff
  :config (drag-stuff-global-mode t)
  :bind
  (:map global-map
        ("M-p" . drag-stuff-up)
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
  :hook
  ;; enable yas everywhere
  (after-init . yas-global-mode)
  :config
  (setq yas-verbosity 1)
  :bind
  (:map global-map
        ("C-c C-y" . yas-insert-snippet)))

(use-package yasnippet-snippets
  :after yasnippet)

(with-eval-after-load 'yasnippet-snippets
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
          '(("sh-mode" . "bash-ts-mode")
            ("js-mode" . "js-ts-mode")
            ("typescript-mode" . "typescript-ts-mode")
            ("json-mode" . "json-ts-mode")
            ("css-mode" . "css-ts-mode")
            ("c-mode" . "c-ts-mode")
            ("c++-mode" . "c++-ts-mode")
            ("java-mode" . "java-ts-mode")
            ("python-mode" . "python-ts-mode")
            ("dockerfile-mode" . "dockerfile-ts-mode")
            ("cmake-mode" . "cmake-ts-mode")
            ("yaml-mode" . "yaml-ts-mode")
            ("markdown-mode" . "markdown-ts-mode")))

  ;; update snippet directories
  ;; add pesonal snippets directory
  (customize-set-variable 'yas-snippet-dirs `(,(expand-file-name "snippets/" emacs-config-home)
                                              ,yasnippet-snippets-dir)))

;; -------------------------------------------------------------------
;; Avy: Jump in buffer with three key strokes
;; -------------------------------------------------------------------
(use-package avy
  :custom
  (avy-timeout 0.1)
  :bind
  (:map global-map
        ("M-g c" . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zoom globally for all buffers
(use-package zoom-frm
  :bind
  (:map global-map
        ("C-c +" . (lambda () (interactive) (ff/repeat-command 'zoom-frm-in)))
        ("C-c -" . (lambda () (interactive) (ff/repeat-command 'zoom-frm-out)))))

(provide 'ff-core)

;;; ff-core.el ends here
