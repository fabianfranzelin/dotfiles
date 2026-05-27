#!/usr/bin/emacs -x

;;; build.el --- Build the org notes into HTML files
;;; Commentary:

;;; Code:

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name ".packages-org-html-export" (temporary-file-directory)))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)
(package-install 'pyvenv)

(require 'pyvenv)
(pyvenv-workon "org")

;; always confirm org-babel evaluation
(require 'org)
(customize-set-variable 'org-confirm-babel-evaluate nil)
(customize-set-variable 'org-time-stamp-custom-formats '("<%d-%b-%y>" . "<%-l:%M %p, %a %d-%B '%y>"))
(customize-set-variable 'org-display-custom-times t)
;; do not visualize subscripts in org-mode buffers
(customize-set-variable 'org-use-sub-superscripts '{})
(customize-set-variable 'org-attach-dir-relative t)
(customize-set-variable 'org-link-file-path-type 'adaptive)

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

(customize-set-variable 'org-plantuml-jar-path
                        (expand-file-name ".cache/emacs/var/plantuml/plantuml-1.2026.2.jar" "~"))

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

(defvar ff/theme-html-head (ff/file-to-string (expand-file-name "content/themes/simple.html" default-directory)))
(defvar ff/menu-html (ff/file-to-string (expand-file-name "content/themes/simple_menu.html" default-directory)))

(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head ff/theme-html-head
      org-html-head-extra ff/menu-html
      org-html-htmlize-output-type 'css)

;; Define the publishing project
(defvar ff/base-dir "./content")
(defvar ff/public-dir "./public")

(setq org-publish-project-alist
      `(("org:main"
         :recursive t
         :base-directory ,ff/base-dir
         :base-extension "org",
         :publishing-function org-html-publish-to-html
         :publishing-directory ,ff/public-dir
         :with-author t
         :with-email t
         :with-creator nil
         :with-toc nil
         :section-numbers nil
         :time-stamp-file t)
        ("org:static"
         :base-directory ,ff/base-dir
         :base-extension "js\\|json\\|html\\|css\\|txt\\|jpg\\|gif\\|png\\|pdf\\|svg\\|epub"
         :recursive t
         :publishing-directory ,ff/public-dir
         :publishing-function org-publish-attachment)
        ("org" :components ("org:main" "org:static"))))

(setq org-export-with-broken-links 'mark)

;; Generate the site output
(org-publish "org" t)

;; Install node dependencies and build the search index
(message "Building search index...")
(let ((result (shell-command-to-string
               (format "node %s %s"
                       (expand-file-name "build-search-index.js" default-directory)
                       (expand-file-name ff/public-dir)))))
  (message result))

(message "Build complete!")

(provide 'build.el)
;;; build.el ends here
