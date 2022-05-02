;;; .emacs --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; define path of local lisp packages that are part of the dotfiles
;; repo
(defvar emacs-config-home (expand-file-name "~/.emacs.d")
  "Location of the Emacs configuration.")
(defvar local-load-path (concat emacs-config-home "/elisp-local")
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-load-path)

;; -------------------------------------------------------------------
;; configure native compilation

(when (featurep 'native-compile)
  ;; Set the right directory to store the native compilation cache
  (add-to-list 'native-comp-eln-load-path (expand-file-name "var/eln-cache/" user-emacs-directory))

  ;; Silence compiler warnings as they can be pretty disruptive
  (setq native-comp-async-report-warnings-errors nil)

  ;; Make native compilation happens asynchronously
  (setq native-comp-deferred-compilation t)

  (setq native-comp-deferred-compilation-deny-list '("bytecomp-.*")))

;; -------------------------------------------------------------------
;; Package Management
(require 'package)
(setq package-enable-at-startup nil)

(setq package-archives '(("org" . "https://orgmode.org/elpa/") ;; will be deprecated soon
                         ("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialise packages
(when (< emacs-major-version 27)
  (package-initialize))

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; ensure all packages to be installed
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; get latest signatures for elpa
(setq package-check-signature nil)
(use-package gnu-elpa-keyring-update)

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

(use-package helpers
  :load-path local-load-path)

(use-package shell-loader
  :load-path local-load-path
  :custom (ff/shell-vertical-alignment t))

;; -------------------------------------------------------------------
;; Daemon settings
;; -------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;; -------------------------------------------------------------------
;; Basic settings
;; -------------------------------------------------------------------
(use-package basic-settings
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Adjusting modes for programming
;; -------------------------------------------------------------------
(use-package programming-settings
  :load-path local-load-path)

;;; .emacs ends here
