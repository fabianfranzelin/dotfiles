;;; ff-ensure-system-packages --- Install system packages easily -*- lexical-binding: t; -*-
;;; Commentary:
;;; Provides simple helper functions to install system packages.

;;; Code:

(require 'compile)

;; always use a new buffer for `async-shell-command' (M-&) when one is busy
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

(defvar auth-source-pass-filename)

(defun ff/--sudo-password ()
  "Return the sudo password from the password store, or prompt for it.
The entry is looked up under passwords/sudo@`system-name'."
  (require 'auth-source-pass)
  (let* ((entry (format "passwords/sudo@%s" (system-name)))
         (file (expand-file-name (concat entry ".gpg") auth-source-pass-filename))
         (pwd (when (file-exists-p file)
                (ignore-errors (auth-source-pass-get 'secret entry)))))
    (if (and (stringp pwd) (not (string-empty-p pwd)))
        pwd
      (read-passwd (format "[sudo] password for %s: " user-login-name)))))

(defun ff/--compile-command (command &optional prefix stdin)
  "Run shell COMMAND asynchronously in a fresh, non-interactive compilation buffer.

PREFIX: buffer name prefix, defaults to \"install\"; the buffer is
named *PREFIX: COMMAND* (uniquified, one buffer per run).
STDIN: optional string sent to the process before closing its stdin.

The process uses a pipe (no pty), so STDIN is never echoed into the
buffer.  Stdin is always closed afterwards, so commands that prompt
get EOF instead of hanging.  Returns the compilation buffer."
  (let* ((name (generate-new-buffer-name
                (format "*%s: %s*" (or prefix "install") command)))
         (process-connection-type nil)
         (compilation-disable-input nil)
         (buf (compilation-start command 'compilation-mode
                                 (lambda (_mode) name)))
         (proc (get-buffer-process buf)))
    (when (process-live-p proc)
      (when stdin
        (process-send-string proc stdin))
      (ignore-errors (process-send-eof proc)))
    buf))

(defun ff/--async-sudo-shell-command (command &optional directory)
  "Run COMMAND asynchronously as root via sudo, without TRAMP.

The output is shown in a dedicated compilation buffer.  When Emacs
already runs as root, COMMAND is executed directly.  When sudo does
not need a password (cached credentials or NOPASSWD), no password is
sent.  Otherwise the password is taken from the password store or
prompted for, and fed to sudo via stdin.

DIRECTORY: working directory, defaults to `default-directory'."
  (let ((default-directory (or directory default-directory)))
    (cond
     ((zerop (user-uid))
      (ff/--compile-command command "sudo"))
     ((not (executable-find "sudo"))
      (user-error "Command `sudo' not found; cannot run: %s" command))
     ((zerop (call-process "sudo" nil nil nil "-n" "true"))
      (ff/--compile-command
       (format "sudo -n sh -c %s" (shell-quote-argument command))
       "sudo"))
     (t
      (ff/--compile-command
       (format "sudo -S -p '' sh -c %s" (shell-quote-argument command))
       "sudo"
       (concat (ff/--sudo-password) "\n"))))))

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
      (let ((cmd (format "%s %s" install-cmd package-name)))
        (if require-sudo
            (ff/--async-sudo-shell-command cmd)
          (ff/--compile-command cmd))))))

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
            (ff/--compile-command (concat python-pip-install-cmd " '" package-name "==" version "'")))
        (unless (file-directory-p package-path)
          (ff/--compile-command (concat python-pip-install-cmd " '" package-name "'"))))))))

(provide 'ff-ensure-system-packages)

;;; ff-ensure-system-packages.el ends here
