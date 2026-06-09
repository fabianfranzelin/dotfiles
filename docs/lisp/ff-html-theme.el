;;; ff-html-theme.el --- HTML export theming -*- lexical-binding: t; -*-
;;; Commentary:
;; Loads the HTML theme (head, menu) and configures org-html export styling.
;; Resolves %ROOT_PATH% placeholders to the correct relative path per file.
;;; Code:

(require 'ff-config)

(defun ff/file-to-string (file)
  "Read FILE contents and return as string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defvar ff/theme-html-head-template
  (ff/file-to-string (expand-file-name "content/themes/simple.html" default-directory))
  "HTML head template with %ROOT_PATH% placeholders.")

(defvar ff/menu-html-template
  (ff/file-to-string (expand-file-name "content/themes/simple_menu.html" default-directory))
  "HTML menu template with %ROOT_PATH% placeholders.")

(defun ff/root-path (filename)
  "Return the relative path from FILENAME back to the content root."
  (let ((rel (file-relative-name
              (expand-file-name ff/base-dir)
              (file-name-directory (expand-file-name filename)))))
    (if (string= rel ".")
        ""
      (file-name-as-directory rel))))

(defun ff/set-theme-for-file (orig-fun plist filename pub-dir)
  "Advice around `org-html-publish-to-html' to resolve %ROOT_PATH% per file."
  (let* ((root (ff/root-path filename))
         (org-html-head (string-replace "%ROOT_PATH%" root ff/theme-html-head-template))
         (org-html-preamble (string-replace "%ROOT_PATH%" root ff/menu-html-template)))
    (funcall orig-fun plist filename pub-dir)))

(advice-add 'org-html-publish-to-html :around #'ff/set-theme-for-file)

(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head ff/theme-html-head-template
      org-html-preamble ff/menu-html-template
      org-html-htmlize-output-type 'css)

(provide 'ff-html-theme)
;;; ff-html-theme.el ends here
