;;; ff-publish-locally.el --- Local publish: project definition and execution -*- lexical-binding: t; -*-
;;; Commentary:
;; Defines the org-publish project alist and orchestrates the local build.
;;; Code:

(require 'ff-config)
(require 'ff-presentations)
(require 'ox-publish)

(setq org-publish-project-alist
      `(("org:main"
         :recursive t
         :base-directory ,ff/base-dir
         :base-extension "org"
         :exclude "examples/org-project/\\(content\\|preamble\\)/"
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
         :exclude "node_modules/\\|^data/"
         :recursive t
         :publishing-directory ,ff/public-dir
         :publishing-function org-publish-attachment)
        ("org:attachments"
         :base-directory ,(expand-file-name "data" ff/base-dir)
         :base-extension "pdf\\|jpg\\|png\\|gif\\|svg\\|epub\\|docx\\|xlsx\\|pptx\\|zip"
         :recursive t
         :publishing-directory ,(expand-file-name "data" ff/public-dir)
         :publishing-function org-publish-attachment)
        ("org" :components ("org:main" "org:static" "org:attachments"))))

(setq org-export-with-broken-links 'mark)

(defun ff/publish-locally ()
  "Run the full local site build."
  ;; Discover and set up presentations
  (ff/setup-presentations org-publish-project-alist)
  ;; Publish all components
  (org-publish "org" t)
  ;; Build search index
  (message "Building search index...")
  (let ((result (shell-command-to-string
                 (format "node %s %s"
                         (expand-file-name "build-search-index.js" default-directory)
                         (expand-file-name ff/public-dir)))))
    (message result))
  (message "Build complete!"))

(provide 'ff-publish-locally)
;;; ff-publish-locally.el ends here
