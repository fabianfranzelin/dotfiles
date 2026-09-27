;;; ff-straight.el --- bootstrap straight.el -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Skip file modification checks for faster startup
(customize-set-variable 'straight-check-for-modifications nil)

;; use latest develop for straight itself; check
;; https://github.com/radian-software/straight.el/issues/1059
(customize-set-variable 'straight-repository-branch "develop")

;; set actual repository user from github, so that pull straight works
;; with given recipe from
;; https://github.com/radian-software/straight.el#overriding-recipes
(customize-set-variable 'straight-repository-user "radian-software")

;; Download straight directly from github
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; replace builtin use-package by straights version
(straight-use-package 'use-package)

;; Enable use-package statistics for profiling startup
;; Run M-x use-package-report after startup to see results
(customize-set-variable 'use-package-compute-statistics t)

;; ensure all packages to be installed
(customize-set-variable 'straight-use-package-by-default t)

(defun ff/straight--package-compile (package commands)
  "Execute a set of commands to compile a package.

This is currently only required for auctex.

PACKAGE: name of the package
COMMANDS: commands to be executed to compile the package"
  (let* ((straight-repos-dir (expand-file-name "straight/repos" straight-base-dir))
         (package-dir (expand-file-name package straight-repos-dir)))
    (with-current-buffer (get-buffer-create (format "*%s package compilation*" package))
      (let ((inhibit-read-only t)
            (default-directory package-dir))
        (erase-buffer)
        (compilation-mode)
        (dolist (command commands)
          (insert (concat command "\n"))
          (if (equal 0 (apply #'call-process command nil (current-buffer) t nil))
              (insert (message (format "[%s] command %s was successful\n" package command)))
            (let ((msg (format "[%s] command %s has failed\n" package command)))
              (insert msg)
              (pop-to-buffer (current-buffer))
              (error msg))))))))

(provide 'ff-straight)
;;; ff-straight.el ends here
