#!/usr/bin/emacs -x

;;; build.el --- Build the org notes into HTML files
;;; Commentary:

;;; Code:

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(customize-set-variable 'package-user-dir
                        (expand-file-name ".packages-org-html-export" (temporary-file-directory)))
(customize-set-variable 'package-archives
                        '(("melpa" . "https://melpa.org/packages/")
                          ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

;; always confirm org-babel evaluation
(require 'org)
(customize-set-variable 'org-confirm-babel-evaluate nil)
(customize-set-variable 'org-time-stamp-custom-formats '("<%d-%b-%y>" . "<%-l:%M %p, %a %d-%B '%y>"))
(customize-set-variable 'org-display-custom-times t)

;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (shell . t)
   (R . t)
   (org . t)
   (latex . t)
   (dot . t)
   (gnuplot . t)
   (plantuml . t)))

;; Load the publishing system
(require 'ox-publish)

;; Customize the HTML output:
;; org-html-head is taken from the setup file for readtheorg theme of https://github.com/fniessen/org-html-themes/tree/master
;; In order to apply it for all html files, I added it here as general header

(defun ff/file-to-string (file)
  "File to string function.
FILE: file to be loaded and converted to string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defvar ff/theme-html-head
  (ff/file-to-string
   (expand-file-name "content/themes/simple.html" default-directory)))

(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head ff/theme-html-head
      org-html-htmlize-output-type 'css)

;; Define the publishing project
(defvar ff/base-dir "./content")
(defvar ff/public-dir "./public")
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory ff/base-dir
             :publishing-function 'org-html-publish-to-html
             :publishing-directory ff/public-dir
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil)))    ;; Don't include time stamp in file

;; Generate the site output
(org-publish-all t)

(message "Build complete!")

(provide 'build.el)
;;; build.el ends here
