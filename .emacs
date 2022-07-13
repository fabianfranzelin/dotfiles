;;; .emacs --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; -------------------------------------------------------------------
;; Package Management - straight.el

;; Download straight directly from github
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; replace builtin use-package by straights version
(straight-use-package 'use-package)

;; ensure all packages to be installed
(setq straight-use-package-by-default t)

;; -------------------------------------------------------------------
;; Package Management - package.el

;; (require 'package)
;; (setq package-enable-at-startup nil)

;; (setq package-archives '(("org" . "https://orgmode.org/elpa/") ;; will be deprecated soon
;;                          ("melpa" . "https://melpa.org/packages/")
;;                          ("elpa" . "https://elpa.gnu.org/packages/")))

;; ;; Initialise packages
;; (when (< emacs-major-version 27)
;;   (package-initialize))

;; (when (not package-archive-contents)
;;   (package-refresh-contents t))

;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))
;; (require 'use-package)

;; ;; ensure all packages to be installed
;; (require 'use-package-ensure)
;; (setq use-package-always-ensure t)

;; ;; get latest signatures for elpa
;; (setq package-check-signature nil)
;; (use-package gnu-elpa-keyring-update)

;; -------------------------------------------------------------------
;; define path of local lisp packages that are part of the dotfiles
;; repo
(defvar emacs-config-home (expand-file-name ".emacs.d" (getenv "HOME"))
  "Location of the Emacs configuration.")
(defvar local-load-path (expand-file-name "elisp-local" emacs-config-home)
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-load-path)


;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package

(use-package no-littering
  :init
  ;; write auto-save files not into the local folder but into the
  ;; no-littering cache
  (setq auto-save-file-name-transforms
	    `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

  ;; setup a new custom file and load it
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file t))

;; -------------------------------------------------------------------
(require 'helpers)

(require 'shell-loader)
(setq ff/shell-vertical-alignment t)

;; -------------------------------------------------------------------
;; Daemon settings
;; -------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;; -------------------------------------------------------------------
;; Basic settings
;; -------------------------------------------------------------------
(require 'basic-settings)

;; -------------------------------------------------------------------
;; Adjusting modes for programming
;; -------------------------------------------------------------------
(require 'programming-settings)

;;; .emacs ends here
