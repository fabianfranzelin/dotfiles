;;; init.el --- this file starts here

;;; Commentary:
;;; Code:

;; -------------------------------------------------------------------
;; Package Management - straight.el

;; use latest develop for straight itself; check
;; https://github.com/radian-software/straight.el/issues/1059
(customize-set-variable 'straight-repository-branch "develop")

;; set actual repository user from github, so that pull straight works
;; with given recipe from
;; https://github.com/radian-software/straight.el#overriding-recipes
(customize-set-variable 'straight-repository-user "radian-software")

;; Download straight directly from github
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; replace builtin use-package by straights version
(straight-use-package 'use-package)

;; ensure all packages to be installed
(customize-set-variable 'straight-use-package-by-default t)

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package
(use-package no-littering
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
      user-mail-address "fabian.franzelin@de.bosch.com"
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

;; enable auto pair mode globally
(electric-pair-mode t)
(electric-indent-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

;; set cursor style to filled bar
(setq-default cursor-type 'box)

;; no splash screen
(setq inhibit-startup-screen t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Version control           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit
  :commands magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  ;; Show word based diff
  (magit-diff-refine-hunk 'all))

;; -------------------------------------------------------------------

(provide 'init)

;;; init.el ends here
