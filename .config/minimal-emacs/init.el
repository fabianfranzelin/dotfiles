;;; init.el --- this file starts here

;;; Commentary:
;;; Code:

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(cl-defun ff/vc-install (&key (fetcher "github") repo name rev backend)
  "Install a package from a remote if it's not already installed.
This is a thin wrapper around `package-vc-install' in order to
make non-interactive usage more ergonomic.  Takes the following
named arguments:

- FETCHER the remote where to get the package (e.g., \"gitlab\").
  If omitted, this defaults to \"github\".

- REPO should be the name of the repository (e.g.,
  \"slotThe/arXiv-citation\".

- NAME, REV, and BACKEND are as in `package-vc-install' (which
  see)."
  (let* ((url (format "https://www.%s.com/%s" fetcher repo))
         (iname (when name (intern name)))
         (pac-name (or iname (intern (file-name-base repo)))))
    (unless (package-installed-p pac-name)
      (cond (iname
	     (package-vc-install iname))
	    (repo
	     (package-vc-install url iname rev backend))
	    (t
	     (message "Do not do anything for %s" name))))))

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package

(use-package no-littering
  :preface (ff/vc-install :name "no-littering")
  :custom
  (custom-file (no-littering-expand-etc-file-name "custom.el"))
  :init
  ;; setup a new custom file and load it
  (load custom-file t)
  :config
  ;; this sets the path right for undo-tree, auto-save and backup files
  (no-littering-theme-backups))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Core                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@
gmail.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; enables local variables per default
(customize-set-variable 'enable-local-variables t)

;; dont warn for following symlinked files
(setq vc-follow-symlinks t)

;; disable lockfiles
(setq create-lockfiles nil)

;; define alias for yes-or-no decision
(defalias 'yes-or-no-p 'y-or-n-p)

;; Support wheel mouse scrolling
(mouse-wheel-mode t)

;; set unicode encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Iterate through CamelCase
(global-subword-mode t)

;; enable visual line mode to truncate long line
(global-visual-line-mode t)

;; enable auto pair mode globally
(electric-pair-mode t)
(electric-indent-mode nil)

(require 'repeat)
(repeat-mode 1)

;; https://www.emacswiki.org/emacs/Repeatable
(defun ff/repeat-command (command)
  "Repeat COMMAND."
  (let ((repeat-previous-repeated-command  command)
        (repeat-message-function           #'ignore)
        (last-repeatable-command           'repeat))
    (repeat nil)))

;; make the undo/redo functions repeatable
(tab-bar-history-mode 1)
(setq tab-bar-history-limit 100)
(keymap-global-set "C-c p" #'(lambda () (interactive) (ff/repeat-command 'tab-bar-history-back)))
(keymap-global-set "C-c n" #'(lambda () (interactive) (ff/repeat-command 'tab-bar-history-forward)))

;; Kill this buffer, instead of prompting for which one to kill
(defun ff/kill-buffer-current ()
  "Kill current buffer."
  (interactive)
  (kill-buffer (current-buffer)))

(keymap-global-set "C-x k" #'(lambda ()
                               (interactive)
                               (ff/repeat-command 'ff/kill-buffer-current)))

;; save cursor position in files even when buffers are killed
(save-place-mode)

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

(use-package pass
  :preface (ff/vc-install :repo "NicolasPetton" :name "pass")
  :custom (pass-show-keybindings nil))

(defun ff/unlock-key ()
  "Unlock gpg key."
  (interactive)
  (if (password-store-get "usernames/public@github")
      (message "GPG key is unlocked")
    (message "Wrong password. GPG key is not unlocked.")))

(keymap-global-set "C-c C-g" 'ff/unlock-key)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; disable scrollbar
(when (display-graphic-p)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)
  (tool-bar-mode -1))

;; set cursor style to filled bar
(setq-default cursor-type 'box)

;; no splash screen
(setq inhibit-startup-screen t)

;; -------------------------------------------------------------------
(use-package doom-themes
  :preface (ff/vc-install :repo "doomemacs" :name "doom-themes")
  :custom
  (doom-themes-enable-bold t)    ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  ;; Global settings (defaults)
  (load-theme 'doom-palenight t)
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

(defun ff/minibuffer-backward-kill (arg)
  "Delete parent folder completely when hitting it with the cursor.
ARG: position"
  (interactive "p")
  (if minibuffer-completing-file-name
      (progn
        ;; Expand the home path when hitting ~/ and continue
        (when (string-match-p "^~/$" (minibuffer-contents))
          (delete-minibuffer-contents)
          (insert (expand-file-name "~/")))

        ;; Expand home path when hitting tilde with tramp
        (when (string-match-p "^/.*:.*:~/$" (minibuffer-contents))
          (zap-up-to-char (- arg) ?~)
          (delete-char -1)
          (insert (expand-file-name "~/")))

        ;; Continue
        (cond ((string-match-p "^/.*:.*:.*/.*/$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?/))
              ((string-match-p "^/.*:.*:.*/$" (minibuffer-contents))
               (zap-up-to-char (- (+ arg 1)) ?:))
              ((string-match-p "^/.*:.*:.*/$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?:))
              ((string-match-p "^/.*:$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?/))
              ((or (string-match-p "^/.*/$" (minibuffer-contents))
                   (string-match-p "^~/.*/$" (minibuffer-contents)))
               (zap-up-to-char (- arg) ?/))
              (t ;; default
               (delete-char -1))))
    (delete-char -1)))

(defun ff/minibuffer-move-to-dir (dir)
  "Go the the specified directory when completing file names.
DIR: directory"
  (interactive "p")
  (cond (minibuffer-completing-file-name
         (delete-minibuffer-contents)
         (insert (substitute-in-file-name dir)))
        (t
         (move-beginning-of-line 0))))

(use-package vertico
  :preface (ff/vc-install :name "vertico")
  :custom
  (vertico-count 10)
  (vertico-cycle t)
  :init
  (vertico-mode t)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  :config
  (custom-set-faces '(vertico-current ((t (:background "#3a3f5a")))))
  :bind (:map vertico-map
              ("C-f" . vertico-exit)
              ("C-j" . vertico-exit-input)
              :map minibuffer-local-map
              ("C-l" . ff/minibuffer-backward-kill)
              ("C-a" . (lambda() (interactive) (ff/minibuffer-move-to-dir "/")))
              ("C-o" . (lambda() (interactive) (ff/minibuffer-move-to-dir "~/")))))

(use-package orderless
  :preface (ff/vc-install :name "orderless")
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; -------------------------------------------------------------------
;; Consult
;; -------------------------------------------------------------------
(use-package consult
  :preface (ff/vc-install :name "consult")
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :bind (:map global-map
	      ("C-s" . consult-line)
              ("C-c i" . consult-imenu)
              ("M-y" . consult-yank-replace)
              ;; C-x bindings (ctl-x-map)
              ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
              ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
              ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
              ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
              ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
              ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
              ;; M-g bindings (goto-map)
              ("M-g e" . consult-compile-error)
              ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
              ;; ("M-g g" . consult-goto-line)             ;; orig. goto-line
              ;; ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
              ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
              ("M-g m" . consult-mark)
              ("M-g k" . consult-global-mark)
              ("M-g i" . consult-imenu)
              ("M-g I" . consult-imenu-multi)
              ;; M-s bindings (search-map)
              ("M-s d" . consult-find)
              ("M-s D" . consult-locate)
              ("M-s g" . consult-grep)
              ("M-s G" . consult-git-grep)
              ("M-s r" . consult-ripgrep)
              ("M-s l" . consult-line)
              ("M-s L" . consult-line-multi)
              ("M-s k" . consult-keep-lines)
              ("M-s u" . consult-focus-lines)
              :map minibuffer-local-map
              ("M-y" . yank-pop)
              ("C-s" . consult-history)))

;; Save history during sessions so that vertico can pick up the latest
;; used ones
(use-package savehist
  :preface (ff/vc-install :name "savehist")
  :init (savehist-mode t))

;; Make window movement more efficient
(use-package ace-window
  :preface (ff/vc-install :name "ace-window")  
  :bind
  (:map global-map
        ("M-o" . ace-window)
        :map diff-mode-map
        ("M-o" . nil)))

;; -------------------------------------------------------------------
(use-package dired
  :ensure nil
  :custom
  (dired-auto-revert-buffer nil) ; Auto update when buffer is revisited
  (dired-dwim-target t)
  (dired-recursive-deletes 'always)
  (dired-recursive-copies 'always)
  (delete-by-moving-to-trash t)
  (dired-listing-switches "-agho --group-directories-first")
  (dired-hide-details-hide-symlink-targets nil)
  :init
  (setq dired-vc-rename-file t)
  (require 'dired-x)
  (autoload 'dired-omit-mode "dired-x")
  :hook
  (dired-mode . auto-revert-mode)
  (dired-mode . dired-hide-details-mode)
  (dired-mode . hl-line-mode)
  :bind
  (("C-x C-j" . dired-jump)
   :map dired-mode-map
   ("l" . dired-up-directory)
   ("TAB" . dired-find-file)))

;; -------------------------------------------------------------------
;; Tramp
(use-package tramp
  :ensure nil
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Version control           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun ff/stage-commit-push-all ()
  "Stage, commit, and push all changed files in a Git repo."
  (interactive)
  (magit-stage-modified)
  (magit-commit-create '("-m" "update some stuff"))
  (magit-push-current-to-upstream nil))

(use-package magit
  :ensure t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  ;; Show word based diff
  (magit-diff-refine-hunk 'all)
  :bind
  (:map magit-mode-map
        ("C-c C-a" . ff/stage-commit-push-all)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Project                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package run-command
  :preface (ff/vc-install :name "run-command")
  :custom (run-command-default-runner #'run-command-runner-compile))

(defun ff/project-magit ()
  "Show the Git status of the current project."
  (interactive)
  (magit-status (locate-dominating-file (project-root (project-current t)) ".git")))

(use-package project
  :custom
  (project-switch-commands '((project-find-file "Find file")
                             (project-find-dir "Find directory")
                             (ff/project-magit "Magit")
                             (project-dired "Dired")
                             (project-vc-dir "VC-Dir")))
  (project-vc-extra-root-markers '(".project.el"))
  (project-vc-ignores '("build/" "install/" ".*cache/" "__pycache__"))
  :bind
  (:map project-prefix-map
        ("g" . ff/project-magit)
        ("v" . project-vc-dir)
        ("C" . run-command)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           org-mode                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'org)
(customize-set-variable
 'org-confirm-babel-evaluate nil)

;; for some reason, this is needed to make org-mode work
(customize-set-variable
 'org-directory "~/workspace/org")
(customize-set-variable
 'org-agenda-files `(,(expand-file-name "notes" org-directory)
                     ,(expand-file-name "notes/journal" org-directory)))

;; Todo types
;;     TODO - A task that should be done at some point
;;     NEXT - This task should be done next (in the Getting Things Done sense)
;;     WAIT - Waiting for someone else to be actionable again
;;     DONE - It's done!
(customize-set-variable
 'org-todo-keywords
 '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d!)" "DISCARD(c)")))

(customize-set-variable
 'org-todo-keyword-faces
 '(("NEXT" . (:foreground "orange red" :weight bold))
   ("WAIT" . (:foreground "HotPink2" :weight bold))))

;; Customize org-agenda
(customize-set-variable 'org-agenda-window-setup 'current-window)
(customize-set-variable 'org-agenda-span 'week)
(customize-set-variable 'org-agenda-start-with-log-mode t)

;; Make done tasks show up in the agenda log
(customize-set-variable 'org-log-done 'time)
(customize-set-variable 'org-log-into-drawer t)

(customize-set-variable
 'org-columns-default-format
 "%20CATEGORY(Category) %65ITEM(Task) %TODO %6Effort(Estim){:}  %6CLOCKSUM(Clock) %TAGS")

(customize-set-variable
 'org-agenda-custom-commands
 `(("d" "Dashboard"
    ((agenda "" ((org-deadline-warning-days 14)))
     (todo "NEXT"
           ((org-agenda-overriding-header "Next Actions")
            (org-agenda-max-todos nil)))
     (todo "WAIT"
           ((org-agenda-overriding-header "Waiting for Action")
            (org-agenda-max-todos nil)))
     (todo "TODO"
           ((org-agenda-overriding-header "Unprocessed Inbox Tasks")
            (org-agenda-files '(,(expand-file-name "notes/journal/inbox.org" org-directory)))
            (org-agenda-text-search-extra-files nil)))
     (alltodo "")))
   ("n" "Next Tasks"
    ((agenda "" ((org-deadline-warning-days 7)))
     (todo "NEXT"
           ((org-agenda-overriding-header "Next Tasks")))))
   ("A" "Agenda and all TODOs"
    ((agenda "")
     (alltodo "")))))

(provide 'init)

;;; init.el ends here
