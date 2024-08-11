;;; early-init.el --- Early initialization file before init.el is loaded -*- lexical-binding: t; -*-

;;; Commentary:
;; Check https://www.gnu.org/software/emacs/manual/html_node/emacs/Early-Init-File.html

;;; Code:

;; -------------------------------------------------------------------
;; define path of local lisp packages that are part of the dotfiles
;; repo
(defvar emacs-config-home (expand-file-name ".config/emacs" (getenv "HOME"))
  "Location of the Emacs configuration.")
(defvar local-lisp-path (expand-file-name "lisp" emacs-config-home)
  "Load path for local Emacs configurations.")
(add-to-list 'load-path local-lisp-path)

;; -------------------------------------------------------------------
;;; Garbage collection
;; Increase the GC threshold for faster startup
;; The default is 800 kilobytes. Measured in bytes.
(customize-set-variable 'gc-cons-threshold (* 50 1000 1000))

;;; Emacs lisp source/compiled preference
;; Prefer loading newest compiled .el file
(customize-set-variable 'load-prefer-newer noninteractive)

;; -------------------------------------------------------------------
;; Disable package.el since we use straight.el
(customize-set-variable 'package-enable-at-startup nil)

;; -------------------------------------------------------------------
;; Change my user Emacs directory to non-default location since it is
;; under version control
(setq user-emacs-directory (expand-file-name "~/.cache/emacs"))

;; put the package downloads into the user emacs directory
(customize-set-variable 'package-user-dir
                        (expand-file-name "elpa" user-emacs-directory))

;; -------------------------------------------------------------------
;; configure native compilation

;; store the eln-cache into the standard paths of the no-littering
;; package
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))

(when (featurep 'native-compile)
  ;; Set the right directory to store the native compilation cache
  (add-to-list 'native-comp-eln-load-path (expand-file-name "var/eln-cache/" user-emacs-directory))

  ;; Silence compiler warnings as they can be pretty disruptive
  (customize-set-variable 'native-comp-async-report-warnings-errors nil)
  ;; Make native compilation happens asynchronously
  (setq native-comp-jit-compilation t))

;; -------------------------------------------------------------------
;;; UI configuration
;; Remove some unneeded UI elements (the user can turn back on anything they wish)
(setq inhibit-startup-message t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(mouse-color . "white") default-frame-alist)

;; Make the initial buffer load faster by setting its mode to fundamental-mode
(customize-set-variable 'initial-major-mode 'fundamental-mode)

(provide 'early-init)
;;; early-init.el ends here
