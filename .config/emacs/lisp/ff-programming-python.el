;;; ff-programming-python.el --- Python setup -*- lexical-binding: t; -*-

;;; Commentary:
;; all the configuration for Python projects

;;; Code:

;; Python mode setup
(require 'python)

;; install system dependencies
(require 'ff-ensure-system-packages)

(ff/ensure-python-package "python-lsp-server[all]" nil "pylsp")
(ff/ensure-python-package "ipython" nil "ipython")
(ff/ensure-python-package "pdb")
(ff/ensure-python-package "ipdb")
(ff/ensure-python-package "pylint")
(ff/ensure-python-package "mypy")
(ff/ensure-python-package "flake8")
(ff/ensure-python-package "black" nil "black")
(ff/ensure-python-package "isort" nil "isort")

;; use tree-sitter as default and overwrite python-mode
(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))

(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("SConstruct" . python-ts-mode))
(add-to-list 'auto-mode-alist '("SConstript" . python-ts-mode))

;; use ipython as default interpreter
(setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "--simple-prompt -i")

;; delete output buffer on buffer execution
(setq py-shell-switch-buffers-on-execute nil)

;; configure a few lsp server alternatives
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `(python-base-mode
                 . ,(eglot-alternatives '(("pylsp")
                                          ("basedpyright-langserver" "--stdio")
                                          ("ty" "server")
                                          ("pyright-langserver" "--stdio"))))))


;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'python-base-mode-hook 'apheleia-mode)
  (setf (alist-get 'black apheleia-formatters) '("black" "-"))
  (setf (alist-get 'isort apheleia-formatters) '("isort" "--stdout" "-"))
  (setf (alist-get 'python-base-mode apheleia-mode-alist) '(isort black)))

;; supports virtual environments. To be set with pyvenv-workon
(use-package pyvenv
  :hook
  (after-init . pyvenv-mode)
  (after-init . pyvenv-tracking-mode))

;; enable sphinx doc strings support
;; C-c M-d sphinx-doc
(use-package sphinx-doc
  :hook
  (python-base-mode . sphinx-doc-mode))

;; magit like interface to pytest
(use-package python-pytest
  :preface
  (ff/ensure-python-package "pytest" nil "pytest")
  :config
  ;; add option to increase verbosity after the "-x" option.
  (transient-append-suffix
    'python-pytest-dispatch
    "-x"
    '("-v" "increase verbosity" "-vvv"))
  :bind
  (:map python-base-mode-map
        ("C-c t d" . python-pytest-dispatch)
        ("C-c t l" . python-pytest-function)
        ("C-c t f" . python-pytest-file-dwim)
        ("C-c t e" . python-pytest-last-failed)))

;; flycheck
(flycheck-add-mode 'python-pylint 'python-base-mode)
(flycheck-add-mode 'python-mypy 'python-base-mode)

(provide 'ff-programming-python)

;;; ff-programming-python.el ends here
