;;; ff-ensure-system-packages --- Install system packages easily -*- lexical-binding: t; -*-
;;; Commentary:
;;; Provides simple helper functions to install system packages.

;;; Code:

;; run async command without displaying the output
(setq async-shell-command-buffer 'new-buffer)

(defmacro ff/with-global-env (&rest body)
  "Run BODY with the global (host) environment.
Buffers managed by `envrc-mode' have a buffer-local, possibly pure
environment (e.g. a Nix dev shell).  System package checks must always
look at the host, otherwise opening a project would trigger installs."
  (declare (indent 0))
  `(let ((process-environment (default-value 'process-environment))
         (exec-path (default-value 'exec-path)))
     (with-temp-buffer
       ,@body)))

(defun ff/python-interpreter-version ()
  "Provide version of python interpreter."
  (let* ((python-interpreter-versions
          (split-string (car (cdr (split-string
                                   (ff/with-global-env
                                     (shell-command-to-string "python3 --version"))
                                   " "))) "\\.")))
    (concat (elt python-interpreter-versions 0) "." (elt python-interpreter-versions 1))))

(defun ff/python-local-site-packages-path (package-name)
  "Provide the path to the local site packages.

PACKAGE-NAME: name of the package to be checked."
  (concat (expand-file-name ".local/lib/python" (getenv "HOME"))
          (ff/python-interpreter-version)
          "/site-packages/" package-name))

(defun ff/ensure-system-package (install-cmd package-name &optional executable require-sudo)
  "Ensure that the provided system package is installed.

INSTALL-CMD: command to be executed
PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist.
REQUIRE-SUDO: launch it as sudo"
  (ff/with-global-env
    (when (or (null executable)
              (and
               (null (executable-find executable))
               (not (file-exists-p executable))))
      (when require-sudo
        (cd "/sudo::/"))
      (async-shell-command (format "%s %s" install-cmd package-name)))))

(defun ff/ensure-apt-package (package-name &optional executable)
  "Ensure that the provided apt package is installed.

PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist."
  (ff/ensure-system-package "apt install -y" package-name executable t))

(defun ff/ensure-snap-package (package-name &optional executable)
  "Ensure that the provided snap package is installed.

PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist."
  (ff/ensure-system-package "snap install" package-name executable t))

(defun ff/ensure-npm-package (package-name &optional executable)
  "Ensure that the provided apt package is installed.

PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist."
  (ff/ensure-system-package "npm install -g" package-name executable))

(defun ff/ensure-python-package (package-name &optional version executable)
  "Ensure that the provided python package is installed.

PACKAGE-NAME: name of the package to be installed.
VERSION: version of the package to be installed
EXECUTABLE: just install if the executable does not exist."
  (let* ((python-pip-install-cmd "python3 -m pip install --upgrade")
         (package-folder-name (car (split-string package-name "\\[")))
         (package-path (ff/python-local-site-packages-path package-folder-name))
         (package-path-with-version (concat package-path "-" version ".dist-info")))
    ;; just install the package when the provided executable does not exist
    (ff/with-global-env
     (unless (or (null executable) (not (null (executable-find executable))))
      (if version
          (unless (file-directory-p package-path-with-version)
            (async-shell-command (concat python-pip-install-cmd " '" package-name "==" version "'")))
        (unless (file-directory-p package-path)
          (async-shell-command (concat python-pip-install-cmd " '" package-name "'"))))))))

(provide 'ff-ensure-system-packages)

;;; ff-ensure-system-packages.el ends here
