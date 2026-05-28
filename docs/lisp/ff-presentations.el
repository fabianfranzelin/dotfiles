;;; ff-presentations.el --- Reveal.js presentation publishing -*- lexical-binding: t; -*-
;;; Commentary:
;; Discovers org files with #+REVEAL_ROOT: in docs/content/, generates a
;; presentations.org index, and configures reveal.js export without site headers.
;;; Code:

(require 'ff-config)
(require 'ox-reveal)

(defun ff/publish-to-reveal-no-header (plist filename pub-dir)
  "Publish FILENAME as reveal.js without the website header/menu."
  (let ((org-html-head nil)
        (org-html-head-extra nil))
    (org-reveal-publish-to-reveal plist filename pub-dir)))

(defun ff/setup-presentations (project-alist)
  "Find presentations in content/, generate index, and configure PROJECT-ALIST."
  (let ((pres-files
         (cl-loop for f in (directory-files-recursively ff/base-dir "\\.org$")
                  when (with-temp-buffer
                         (insert-file-contents f)
                         (re-search-forward "^#\\+REVEAL_ROOT:" nil t))
                  collect (file-relative-name f ff/base-dir))))
    (when pres-files
      (message "Found %d presentation(s)" (length pres-files))
      ;; Generate presentations.org index
      (with-temp-file (expand-file-name "presentations.org" ff/base-dir)
        (insert "#+title: Presentations\n")
        (insert (format "#+AUTHOR: %s\n\n" ff/user-full-name))
        (insert "* Reveal.js Presentations\n\n")
        (dolist (f pres-files)
          (let ((title (with-temp-buffer
                         (insert-file-contents (expand-file-name f ff/base-dir))
                         (if (re-search-forward "^#\\+title:\\s-*\\(.+\\)" nil t)
                             (match-string 1)
                           (file-name-sans-extension f)))))
            (insert (format "+ [[file:%s][%s]]\n"
                            (concat (file-name-sans-extension f) ".html") title)))))
      ;; Configure project to only export these files
      (setf (plist-get (cdr (assoc "org:presentations" project-alist)) :include) pres-files
            (plist-get (cdr (assoc "org:presentations" project-alist)) :exclude) ".*")))
  project-alist)

(provide 'ff-presentations)
;;; ff-presentations.el ends here
