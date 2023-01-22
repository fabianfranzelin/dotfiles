;;; ff-ensure-system-packages --- Install system packages
;;; Commentary:
;;; Provides simple helper functions to install system packages.

;;; Code:

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

(defun ff/ensure-system-package (install-cmd package-name &optional executable)
  "Ensure that the provided system package is installed.

INSTALL-CMD: command to be executed
PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist."
  (if (or (null executable)
              (and
               (null (executable-find executable))
               (not (file-exists-p executable))))
    (async-shell-command (concat install-cmd " " package-name))))

(defun ff/ensure-apt-package (package-name &optional executable)
  "Ensure that the provided apt package is installed.

PACKAGE-NAME: name of the package to be installed.
EXECUTABLE: just install if the executable does not exist."
  (ff/ensure-system-package "sudo apt install -y" package-name executable))

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
    (unless (or (null executable) (not (null (executable-find executable))))
      (if version
          (unless (file-directory-p package-path-with-version)
            (async-shell-command (concat python-pip-install-cmd " '" package-name "==" version "'")))
        (unless (file-directory-p package-path)
          (async-shell-command (concat python-pip-install-cmd " '" package-name "'")))))))

(provide 'ff-ensure-system-packages)

;;; ff-ensure-system-packages.el ends here
