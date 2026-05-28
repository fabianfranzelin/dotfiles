;;; ff-html-theme.el --- HTML export theming -*- lexical-binding: t; -*-
;;; Commentary:
;; Loads the HTML theme (head, menu) and configures org-html export styling.
;;; Code:

(defun ff/file-to-string (file)
  "Read FILE contents and return as string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defvar ff/theme-html-head
  (ff/file-to-string (expand-file-name "content/themes/simple.html" default-directory))
  "HTML head content for the site theme.")

(defvar ff/menu-html
  (ff/file-to-string (expand-file-name "content/themes/simple_menu.html" default-directory))
  "HTML menu content inserted into every page.")

(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head ff/theme-html-head
      org-html-head-extra ff/menu-html
      org-html-htmlize-output-type 'css)

(provide 'ff-html-theme)
;;; ff-html-theme.el ends here
