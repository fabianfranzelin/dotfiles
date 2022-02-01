;;; init.el --- this file starts here

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

(use-package auto-package-update
  :init
  ;; for emacs 28, quelpa is required as a dependency
  (when (> emacs-major-version 27)
    (use-package quelpa))
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-hide-results t
        ;; update the packages every week
        auto-package-update-interval 7)
  (auto-package-update-maybe))

;; add the possibility to define system dependencies in use-package
;; declaration
(use-package use-package-ensure-system-package)

;; get latest signatures for elpa
(setq package-check-signature nil)
(use-package gnu-elpa-keyring-update)

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

;;; init.el ends here
