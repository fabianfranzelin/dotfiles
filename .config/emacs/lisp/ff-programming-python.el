;;; ff-programming-python.el --- Python setup -*- lexical-binding: t; -*-

;;; Commentary:
;; all the configuration for Python projects

;;; Code:

;; Python mode setup
(require 'python)

;; install system dependencies
(require 'ff-ensure-system-packages)

(ff/ensure-python-package "ipython" nil "ipython")
(ff/ensure-python-package "pdb")
(ff/ensure-python-package "ipdb")
(ff/ensure-python-package "ruff" nil "ruff")
(ff/ensure-python-package "basedpyright" nil "basedpyright-langserver")
(ff/ensure-python-package "mypy" nil "mypy")
(ff/ensure-python-package "pylint" nil "pylint")
;; python-lsp-server (pylsp) is the primary LSP server. It aggregates
;; mypy, pylint and ruff diagnostics behind a single eglot connection.
(ff/ensure-python-package "python-lsp-server" nil "pylsp")
(ff/ensure-python-package "pylsp-mypy")
(ff/ensure-python-package "python-lsp-ruff")

;; eglot hook
(add-hook 'python-ts-mode-hook #'eglot-ensure)

;; non-standard file associations
(add-to-list 'auto-mode-alist '("SConstruct" . python-ts-mode))
(add-to-list 'auto-mode-alist '("SConscript" . python-ts-mode))

;; use ipython as default interpreter
(setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "--simple-prompt -i")

;; delete output buffer on buffer execution
(setq py-shell-switch-buffers-on-execute nil)

;; configure lsp server alternatives.
;; pylsp is the primary server so that eglot surfaces mypy, pylint and
;; ruff-check diagnostics through flymake. basedpyright (and the other
;; servers) remain available as fallbacks via `M-x eglot' selection.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `(python-base-mode
                 . ,(eglot-alternatives '(("pylsp")
                                          ("basedpyright-langserver" "--stdio")
                                          ("ruff" "server")
                                          ("ty" "server")
                                          ("pyright-langserver" "--stdio"))))))

;; configure pylsp plugins: enable exactly mypy + pylint + ruff(check),
;; and disable every overlapping default linter/formatter so the stack
;; stays limited to the requested tools.
(setq-default eglot-workspace-configuration
              '(:pylsp
                (:plugins
                 (;; type checking via mypy (pylsp-mypy plugin)
                  :pylsp_mypy (:enabled t :live_mode t)
                  ;; linting via pylint
                  :pylint (:enabled t)
                  ;; linting via ruff check (python-lsp-ruff plugin).
                  ;; formatting is handled by apheleia, so keep it off here.
                  :ruff (:enabled t :formatEnabled :json-false)
                  ;; disable the default overlapping plugins
                  :pycodestyle (:enabled :json-false)
                  :pyflakes (:enabled :json-false)
                  :mccabe (:enabled :json-false)
                  :flake8 (:enabled :json-false)
                  :autopep8 (:enabled :json-false)
                  :yapf (:enabled :json-false)))))

;; configure auto format (ruff format + ruff import sorting)
(with-eval-after-load 'apheleia
  (add-hook 'python-base-mode-hook 'apheleia-mode)
  (setf (alist-get 'ruff-format apheleia-formatters) '("ruff" "format" "--stdin-filename" filepath "-"))
  (setf (alist-get 'ruff-isort apheleia-formatters) '("ruff" "check" "--select" "I" "--fix-only" "--unsafe-fixes" "--stdin-filename" filepath "-"))
  (setf (alist-get 'python-base-mode apheleia-mode-alist) '(ruff-format ruff-isort)))

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

(provide 'ff-programming-python)

;;; ff-programming-python.el ends here
