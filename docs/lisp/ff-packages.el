;;; ff-packages.el --- Package management and dependency installation -*- lexical-binding: t; -*-
;;; Commentary:
;; Sets up package archives and installs required dependencies.
;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name ".packages-org-html-export" (temporary-file-directory)))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'htmlize)
(package-install 'pyvenv)
(package-install 'ox-reveal)

(provide 'ff-packages)
;;; ff-packages.el ends here
