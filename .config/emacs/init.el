;;; init.el --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@gmail.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; -------------------------------------------------------------------
;; Daemon settings
;; -------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;; -------------------------------------------------------------------
;; define path of local lisp packages that are part of the dotfiles
;; repo
(defvar emacs-config-home (expand-file-name ".config/emacs" (getenv "HOME"))
  "Location of the Emacs configuration.")
(defvar local-lisp-path (expand-file-name "lisp" emacs-config-home)
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-lisp-path)

;; -------------------------------------------------------------------
;; Package Management - straight.el
(require 'ff-straight)

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

;; -------------------------------------------------------------------
(require 'ff-core)
(require 'ff-vertical-completion)
(require 'ff-setup-vterm)
(require 'ff-version-control)
(require 'ff-project-management)
(require 'ff-organize-life)
(require 'ff-programming-settings)
(require 'ff-write-documents)
(require 'ff-setup-gui)
(require 'ff-spellcheck)
(require 'ff-ai-assistant)
(require 'ff-multimedia)
;; -------------------------------------------------------------------

(provide 'init)
;;; init.el ends here
