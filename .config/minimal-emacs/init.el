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
  :preface (ff/vc-install :name "doom-themes")
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

;; Save history during sessions so that vertico can pick up the latest
;; used ones
(use-package savehist
  :preface (ff/vc-install :name "savehist")
  :init (savehist-mode t))

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
        ("v" . project-vc-dir)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           org-mode                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'org)
(customize-set-variable 'org-confirm-babel-evaluate nil)

(provide 'init)

;;; init.el ends here
