;;; ff-org-config.el --- Org-mode and babel configuration -*- lexical-binding: t; -*-
;;; Code:

(require 'ff-config)
(require 'org)
(require 'org-attach)
(require 'pyvenv)

(setq user-full-name ff/user-full-name
      user-mail-address ff/user-mail-address
      inhibit-startup-echo-area-message (getenv "USER")
      org-export-allow-bind-keywords t
      org-confirm-babel-evaluate nil
      org-time-stamp-custom-formats '("<%d-%b-%y>" . "<%-l:%M %p, %a %d-%B '%y>")
      org-display-custom-times t
      org-use-sub-superscripts '{}
      org-attach-dir-relative t
      org-link-file-path-type 'adaptive
      org-plantuml-jar-path (expand-file-name ".cache/emacs/var/plantuml/plantuml-1.2026.2.jar" "~"))

;; Python virtualenv
(pyvenv-workon "org")

;; Replace attachment: links with relative file: links for publishing.
(remove-hook 'org-export-before-parsing-functions 'org-attach-expand-links)

(defun ff/attachment-expand-links (_backend)
  "Replace attachment: links with relative file: links for publishing."
  (let ((file-dir (file-name-directory (buffer-file-name)))
        (data-dir (expand-file-name "data" ff/base-dir))
        (attach-root (expand-file-name org-attach-id-dir
                                       (file-name-directory (file-truename (buffer-file-name))))))
    ;; Collect links first, then replace in reverse order to preserve positions.
    (let ((links (org-element-map (org-element-parse-buffer) 'link
                   (lambda (link)
                     (when (string-equal "attachment" (org-element-property :type link))
                       link)))))
      (dolist (link (nreverse links))
        (goto-char (org-element-begin link))
        (when-let* ((attach-dir (org-attach-dir))
                    (file (org-element-property :path link))
                    (id-subpath (file-relative-name attach-dir attach-root))
                    (target (expand-file-name file
                                              (expand-file-name id-subpath data-dir)))
                    (rel-path (file-relative-name target file-dir)))
          (let ((desc (and (org-element-contents-begin link)
                           (buffer-substring-no-properties
                            (org-element-contents-begin link)
                            (org-element-contents-end link))))
                (end (progn (goto-char (org-element-end link))
                            (skip-chars-backward " \t")
                            (point))))
            (delete-region (org-element-begin link) end)
            (insert (org-link-make-string (concat "file:" rel-path) desc))))))))

(add-hook 'org-export-before-parsing-functions #'ff/attachment-expand-links)

;; Babel languages
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

(provide 'ff-org-config)
;;; ff-org-config.el ends here
