;;; early-init.el --- Setup early-init

;;; Commentary:
;; Check https://www.gnu.org/software/emacs/manual/html_node/emacs/Early-Init-File.html

;;; Code:

;; -------------------------------------------------------------------
;; Change my user emacs directory to non-default location since it is
;; under version control
(setq user-emacs-directory (expand-file-name "~/.cache/emacs"))

;; put the package downloads into the user emacs directory
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))

;; store the eln-cache into the standard paths of the no-littering
;; package
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
  (expand-file-name  "var/eln-cache/" user-emacs-directory))))

;; -------------------------------------------------------------------
;; configure native compilation

(when (featurep 'native-compile)
  ;; Set the right directory to store the native compilation cache
  (add-to-list 'native-comp-eln-load-path (expand-file-name "var/eln-cache/" user-emacs-directory))

  ;; Silence compiler warnings as they can be pretty disruptive
  (setq native-comp-async-report-warnings-errors nil)

  ;; Make native compilation happens asynchronously
  (setq native-comp-deferred-compilation t))

;;; early-init.el ends here
