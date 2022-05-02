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

;;; early-init.el ends here
