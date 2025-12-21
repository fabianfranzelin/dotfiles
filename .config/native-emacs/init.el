;;; init.el --- this file starts here

;;; Commentary:
;;; Code:

(require 'use-package)
;; Automatically install packages
(customize-set-variable 'use-package-always-ensure t)

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
(customize-set-variable 'vc-follow-symlinks t)

;; disable lockfiles
(customize-set-variable 'create-lockfiles nil)

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

(keymap-global-set "M-o" 'other-window)

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
;; Show available keybindings
(use-package which-key
  :ensure nil
  :custom
  (which-key-idle-delay 1)
  :hook
  (after-init . which-key-mode))

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
;; Use the Emacs minibuffer for GPG pinentry
;; https://vxlabs.com/2021/03/21/gnupg-pinentry-via-the-emacs-minibuffer/
(customize-set-variable 'epg-pinentry-mode 'loopback)

(require 'epg)
(defun ff/unlock-first-gpg-key ()
  "Identify the first available private GPG key and unlock it by signing a test string."
  (interactive)
  (let* ((context (epg-make-context 'OpenPGP))
         ;; Filter for secret/private keys only
         (keys (epg-list-keys context nil t)))
    (if (null keys)
        (message "No private GPG keys found.")
      (let* ((first-key (car keys))
             (key-id (epg-sub-key-id (car (epg-key-sub-key-list first-key)))))
        (condition-case err
            (progn
              ;; Attempt to sign a dummy string to trigger the pinentry/unlock
              (epg-sign-string context "unlock-test" 'detach)
              (message "Successfully unlocked key: %s" key-id))
          (error
           (message "Failed to unlock key %s: %s" key-id (error-message-string err))))))))

(keymap-global-set "C-c C-g" 'ff/unlock-first-gpg-key)

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
(customize-set-variable 'inhibit-startup-screen t)

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

;; vertical completion
(fido-vertical-mode t)

;; Enable fuzzy matching
(customize-set-variable 'completion-styles '(flex basic partial-completion emacs22))
(customize-set-variable 'completion-category-overrides '((file (styles partial-completion))))
(setq completion-category-defaults nil)

;; Configure TAB for selection in minibuffer
(define-key minibuffer-local-map (kbd "<tab>") 'icomplete-fido-ret)
(define-key minibuffer-local-map (kbd "C-a") (lambda() (interactive) (ff/minibuffer-move-to-dir "/")))
(define-key minibuffer-local-map (kbd "C-o") (lambda() (interactive) (ff/minibuffer-move-to-dir "~/")))
(define-key minibuffer-local-map (kbd "C-l") 'ff/minibuffer-backward-kill)g

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
  ;; (tramp-auto-save-directory (expand-file-name "tramp/backups" no-littering-var-directory))
  ;; (tramp-persistency-file-name (expand-file-name "tramp/persistency_data" no-littering-var-directory))
  ;; make sure vc stuff is not making tramp slower
  (vc-ignore-dir-regexp (format "%s\\|%s"
		                vc-ignore-dir-regexp
		                tramp-file-name-regexp))
  ;; https://www.gnu.org/software/emacs/manual/html_node/tramp/Password-handling.html
  (ange-ftp-netrc-filename (expand-file-name "authinfo.gpg" (getenv "PASSWORD_STORE_DIR"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Version control           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Project                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package tab-bar
  :ensure nil
  :hook
  (after-init . tab-bar-mode)
  :custom
  ;; Don't turn on tab-bar-mode when tabs are created
  (tab-bar-show nil)
  :bind
  (:map global-map
        ("C-x t n" . tab-new)
        ;; after a tab is closed, the *scratch* tab appears
        ;; automatically; Hence, we close that one as well after
        ;; closing the actually intended one to actually get to the
        ;; previous user tab.
        ("C-x t w" . tab-close)))

(require 'project)

(defun ff/project-name (dir)
  "Define the name of a project as the name of the root directory.

DIR: root directory of project"
  (file-name-nondirectory (directory-file-name (file-name-directory dir))))

(defun ff/tab-bar--names (&optional tabs frame)
  "Return the list of tabs sorted by name.
TABS: tabs as alist
FRAME: frame"
  (let* ((tabs (or tabs (funcall tab-bar-tabs-function frame))))
    (mapcar (lambda (tab) (alist-get 'name tab)) tabs)))

(defun ff/project-project-tab ()
  "Switch to a workspace with the project name."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
    (unless (member project-name (ff/tab-bar--names))
      (tab-bar-new-tab)
      (tab-rename project-name))
    (tab-bar-switch-to-tab project-name)))

(defun ff/project-switch-project (&optional project)
  "Switch to a workspace with the project name.
PROJECT: path to project"
  (interactive)
  (let* ((project-dir (or project (project-prompt-project-dir)))
         (project-name (ff/project-name project-dir)))
    (unless (member project-name (ff/tab-bar--names))
      (tab-bar-new-tab)
      (tab-rename project-name))
    (tab-bar-switch-to-tab project-name)
    (project-switch-project project-dir)))

(use-package project
  :ensure nil
  :custom
  (project-switch-commands '((project-find-file "Find file")
                             (project-find-dir "Find directory")
                             (project-dired "Dired")
                             (project-vc-dir "VC-Dir")))
  (project-vc-extra-root-markers '(".project.el"))
  (project-vc-ignores '("build/" "install/" ".*cache/" "__pycache__"))
  :bind
  (:map project-prefix-map
        ("P" . ff/project-switch-project)
        ("v" . project-vc-dir)
        ("t" . ff/project-project-tab)))

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
