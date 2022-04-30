;;; .emacs --- this file starts here

;;; Commentary:
;; inspired by https://github.com/daviwil/dotfiles/blob/master/Emacs.org
;; and https://git.sr.ht/~sirn/dotfiles/tree/217c239cf19b668deaccc40ad76c60ffbcfdad20/item/etc/emacs/packages

;;; Code:

;; ==================================================================
;; Load Packages for different modes
;; ===================================================================
(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

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

;; make sure that the path environment from shell is available in
;; emacs
(use-package exec-path-from-shell
  :unless (string-equal system-type "windows-nt")
  :demand t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

(defun ff/emacs-config-home ()
  "Provide the home of the Emacs configuration folder."
  (interactive)
  (let* ((xdg-config-home (getenv "XDG_CONFIG_HOME"))
         (emacs-d-folder (expand-file-name "~/.emacs.d")))
    (if xdg-config-home
	    (let ((xdg-emacs-config-home (concat xdg-config-home "/emacs")))
          (if (file-directory-p xdg-emacs-config-home) xdg-emacs-config-home emacs-d-folder))
      emacs-d-folder)))

(defvar emacs-config-home (ff/emacs-config-home)
  "Location of the Emacs configuration.")
(defvar local-load-path (concat emacs-config-home "/elisp-local")
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-load-path)

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package
;; -------------------------------------------------------------------
(defvar ff/user-emacs-directory (expand-file-name "~/.cache/emacs")
  "Location of all temporary files.")

;; Create the folder if it does not exist already
(unless (file-directory-p ff/user-emacs-directory)
  (make-directory (eval ff/user-emacs-directory)))

(setq user-emacs-directory ff/user-emacs-directory)

(use-package no-littering)


;; -------------------------------------------------------------------
;; configure native compilation

(when (featurep 'native-compile)
  ;; Silence compiler warnings as they can be pretty disruptive
  (setq native-comp-async-report-warnings-errors nil)

  ;; Make native compilation happens asynchronously
  (setq native-comp-deferred-compilation t)

  ;; Set the right directory to store the native compilation cache
  (add-to-list 'native-comp-eln-load-path (expand-file-name "var/eln-cache/" user-emacs-directory)))

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
