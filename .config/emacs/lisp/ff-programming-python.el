;;; ff-programming-python.el --- Python setup

;;; Commentary:
;; all the configuration for Python projects

;;; Code:

;; Python mode setup

;; install system dependencies
(ff/ensure-python-package "python-lsp-server[all]" nil "pylsp")
(ff/ensure-python-package "ipython" nil "ipython")
(ff/ensure-python-package "pdb")
(ff/ensure-python-package "ipdb")
(ff/ensure-python-package "pylint")
(ff/ensure-python-package "mypy")
(ff/ensure-python-package "flake8")

;; use tree-sitter as default and overwrite python-mode
(add-to-list 'major-mode-remap-alist '(python-mode python-ts-mode))

;; use my personal hooks
(add-hook 'python-ts-mode-hook #'hs-minor-mode)

(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("SConstruct" . python-ts-mode))
(add-to-list 'auto-mode-alist '("SConstript" . python-ts-mode))

;; use ipython as default interpreter
(setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "--simple-prompt -i"
      python-indent-offset 4
      python-indent-guess-indent-offset nil)

;; delete output buffer on buffer execution
(setq py-shell-switch-buffers-on-execute nil)

;; install black and black-macchiato with pip3 install --user -U
;; black-macchiato black if black is not available as executable in
;; ~/.local/bin, provide a dummy one that runs black in library mode
;; python3 -m black "${@}"
(use-package python-black
  :init
  ;; install system dependencies
  (ff/ensure-python-package "black" nil "black")
  :hook ((python-ts-mode . python-black-on-save-mode)))

;; supports virtual environments. To be set with pyvenv-workon
(use-package pyvenv
  :init (pyvenv-mode 1)
  :config (pyvenv-tracking-mode 1))

;; enable py-isort to resort imports on save
(use-package py-isort
  :init
  ;; install system dependencies
  (ff/ensure-python-package "isort" nil "isort")
  (add-hook 'before-save-hook 'py-isort-before-save))

;; enable sphinx doc strings support
;; C-c M-d sphinx-doc
(use-package sphinx-doc
  :hook ((python-ts-mode . sphinx-doc-mode)))

(provide 'ff-programming-python)

;;; ff-programming-python.el ends here
