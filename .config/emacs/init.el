;;; init.el --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; -------------------------------------------------------------------
;; Daemon settings
;; -------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;; -------------------------------------------------------------------
;; Package Management - straight.el

;; use latest develop for straight itself; check
; https://github.com/radian-software/straight.el/issues/1059
(setq straight-repository-branch "develop")

;; set actual repository user from github, so that pull straight works
;; with given recipe from
;; https://github.com/radian-software/straight.el#overriding-recipes
(setq straight-repository-user "radian-software")

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
(setq straight-use-package-by-default t)

;; -------------------------------------------------------------------
;; define path of local lisp packages that are part of the dotfiles
;; repo
(defvar emacs-config-home (expand-file-name ".config/emacs" (getenv "HOME"))
  "Location of the Emacs configuration.")
(defvar local-lisp-path (expand-file-name "lisp" emacs-config-home)
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-lisp-path)

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package
(use-package no-littering
  :init
;; setup a new custom file and load it
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file t)
  :config
  ;; this sets the path right for undo-tree, auto-save and backup files
  (no-littering-theme-backups))

;; -------------------------------------------------------------------
(require 'ff-core)
(require 'ff-vertico-completion)
(require 'ff-setup-vterm)
(require 'ff-magit-version-control)
(require 'ff-project-management)
(require 'ff-programming-settings)
(require 'ff-organize-life)
(require 'ff-write-documents)
(require 'ff-setup-gui)
(require 'ff-spellcheck)
(require 'ff-ai-assistant)
;; -------------------------------------------------------------------

(provide 'init)
;;; init.el ends here
