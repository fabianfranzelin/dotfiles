#!/usr/bin/emacs -x

;;; serve.el --- Serve the built docs via a local web server
;;; Commentary:
;;  Starts a simple HTTP server on port 8080 serving the docs/public directory.
;;  Usage: emacs -Q --script serve.el

;;; Code:

(require 'simple-httpd nil t)

;; Install simple-httpd if not available
;; TODO: Pinned to pre-compat-31 commit because simple-httpd now requires
;; compat 31 which needs Emacs 31+. Remove the :rev pin once Emacs is updated.
(unless (featurep 'simple-httpd)
  (require 'package)
  (setq package-user-dir (expand-file-name ".packages-org-html-export" (temporary-file-directory)))
  (setq package-archives nil)
  (package-initialize)
  (let ((dir (expand-file-name "simple-httpd" package-user-dir)))
    (when (file-directory-p dir)
      (delete-directory dir t)))
  (package-vc-install
   '(simple-httpd :url "https://github.com/skeeto/emacs-http-server"
                  :rev "1d29a7839c66a365dfae26c9f91dc01ced7e860b"))
  (require 'simple-httpd))

(setq httpd-root (expand-file-name "public" default-directory))
(setq httpd-port 8080)
(setq httpd-host "0.0.0.0")

;; Ensure JSON files are served with correct MIME type
(add-to-list 'httpd-mime-types '("json" . "application/json"))

;; Kill any existing process on the port
(let ((kill-cmd (format "fuser -k %d/tcp 2>/dev/null" httpd-port)))
  (shell-command kill-cmd)
  (sleep-for 0.5))

(httpd-start)
(message "Serving docs at http://localhost:%d" httpd-port)
(message "Document root: %s" httpd-root)

;; Keep the process alive
(while t
  (sleep-for 1))

(provide 'serve)
;;; serve.el ends here
