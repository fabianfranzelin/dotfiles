;;; package --- Set up helper functions
;;; Commentary:
;;; Provides simple helper functions

;;; Code:

(defun ff/random-alnum ()
  (let* ((alnum "abcdefghijklmnopqrstuvwxyz0123456789")
         (i (% (abs (random)) (length alnum))))
    (substring alnum i (1+ i))))

(defun ff/random-string (n)
  "Generate a slug of n random alphanumeric characters."
  (let ((ans ""))
    (while (<= 0 n)
      (setq ans (concat ans (ff/random-alnum)))
      (setq n (- n 1)))
    (eval ans)))

;; -------------------------------------------------------------

(defun ff/is-buffer-visible (buffer-name)
  "Check whether a buffer is visible or not.
BUFFER-NAME: string name of the buffer"
  (cond ((eq buffer-name (window-buffer (selected-window)))
         ;; Visible and focused
         t)
        ((get-buffer-window buffer-name)
         ;; Visible and unfocused
         t)
        (t
         nil)))

(defun ff/load-visible-buffers (buffer-list)
  "Filter all buffers that begin with the given prefix.
BUFFER-LIST: string list of buffer names"
  (let (filtered-buffers '())
    (dolist (next-buffer buffer-list)
      (if (ff/is-buffer-visible next-buffer)
          (add-to-list 'filtered-buffers next-buffer)))
    ;; sort the buffers
    (cl-sort filtered-buffers 'string-lessp :key 'downcase)))


(defun ff/is-any-buffer-visible (buffer-list)
  "Check whether any of the listed buffers is currently visible.
BUFFER-LIST: string list of buffer names"
  (setq is-visible nil)
  (dolist (next-buffer buffer-list)
    (if (ff/is-buffer-visible next-buffer)
        (setq is-visible t)))
  (eval is-visible))

;; -------------------------------------------------------------

(defun ff/download-and-extract-zip-archive (url name extract-to expected-binary-file package-name)
  "Download and install zip archives."
  (let* ((temporary-file (concat temporary-file-directory name ".zip")))
    (unless (file-directory-p extract-to) (make-directory extract-to t))
    (unless  (file-exists-p expected-binary-file)
      (unless (file-exists-p temporary-file)
        (message (concat "[" package-name "] Downloading " name " to " temporary-file))
        (url-copy-file url temporary-file))
      (message (concat "[" package-name "] Decompress " name " to " extract-to))
      (call-process-shell-command (concat "unzip " temporary-file " -d " extract-to) nil 0))))

(defun ff/python-interpreter-version ()
  "Provide version of python interpreter."
  (let* ((python-command (if (boundp 'python-shell-interpreter)
                             (eval python-shell-interpreter)
                           "python"))
         (python-interpreter-versions
          (split-string (car (cdr (split-string
                              (shell-command-to-string "python3 --version")
                              " "))) "\\.")))
    (concat (elt python-interpreter-versions 0) "." (elt python-interpreter-versions 1))))

(defun ff/python-local-site-packages-path (package-name)
  "Provide the path to the local site packages.

PACKAGE-NAME: name of the package to be checked."
  (concat (expand-file-name ".local/lib/python" (getenv "HOME"))
          (ff/python-interpreter-version)
          "/site-packages/" package-name))

(defun ff/ensure-python-package (package-name &optional version)
  "Provide the path to the local site packages.

PACKAGE-NAME: name of the package to be installed.
VERSION: version of the package to be installed"
  (let* ((python-pip-install-cmd "python3 -m pip install --upgrade")
         (package-path (ff/python-local-site-packages-path package-name))
         (package-path-with-version (concat package-path "-" version ".dist-info")))
    (if version
        (unless (file-directory-p package-path-with-version)
          (async-shell-command (concat python-pip-install-cmd " '" package-name "==" version "'")))
      (unless (file-directory-p package-path)
        (async-shell-command (concat python-pip-install-cmd " '" package-name "'"))))))

(defun ff/switch-to-last-window ()
  "Switch to last visible window."
  (interactive)
  (let ((win (get-mru-window t t t)))
    (unless win (error "Last window not found"))
    (let ((frame (window-frame win)))
      (select-frame-set-input-focus frame)
      (select-window win))))

(provide 'helpers)

;;; helpers.el ends here
