#!/usr/bin/emacs -x

;;; serve.el --- Serve the built docs via a local web server
;;; Commentary:
;;  Starts a simple HTTP server on port 8080 serving the docs/public directory.
;;  Usage: emacs -Q --script serve.el

;;; Code:

(require 'simple-httpd nil t)

;; Install simple-httpd if not available
(unless (featurep 'simple-httpd)
  (require 'package)
  (setq package-user-dir (expand-file-name ".packages-org-html-export" (temporary-file-directory)))
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install 'simple-httpd)
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
