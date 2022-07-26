;;; setup-python.el --- Python setup

;;; Commentary:
;; all the configuration for Python projects


;;; how to configure .dir-locals.el for flycheck
;;
;; ((python-mode . ((pyvenv-workon . <name>)
;;                  (flycheck-add-next-checker . ('python-pylint 'python-mypy))
;;                  (flycheck-disabled-checkers . 'python-flake8))))

;;; Code:

;; pdb debugger
(defun annotate-pdb ()
  "Colors the background if pdb is active."
  (interactive)
  (highlight-lines-matching-regexp "import ipdb")
  (highlight-lines-matching-regexp "ipdb.set_trace()")
  (highlight-lines-matching-regexp "import pdb")
  (highlight-lines-matching-regexp "pdb.set_trace()"))

(use-package python-mode
  :mode (("\\.py$" . python-mode)
         ("SConstruct" . python-mode)
         ("SConscript" . python-mode))
  :hook ((python-mode . annotate-pdb)
         (python-mode . (lambda ()
                          ;; debugging package for python using ptvsd
                          (require 'dap-python)
                          (lsp))))  ; or lsp-deferred
  :init
  ;; install system dependencies
  (ff/ensure-python-package "python-lsp-server[all]" nil "pylsp")

  ;; use ipython as default interpreter
  (setq python-shell-interpreter "ipython3"
        python-shell-interpreter-args "--simple-prompt -i"
        python-indent-offset 4
        python-indent-guess-indent-offset nil
        ;; default python interpreter for dap
        dap-python-executable "python3")

  ;; both packages are required for debugging with dap
  (ff/ensure-python-package "epc")
  (ff/ensure-python-package "ptvsd" "4.2.0")
  (ff/ensure-python-package "pylint")
  (ff/ensure-python-package "mypy")
  (ff/ensure-python-package "flake8")
  :config
  ;; delete output buffer on buffer execution
  (setq py-shell-switch-buffers-on-execute nil))

;; install black and black-macchiato with pip3 install --user -U
;; black-macchiato black if black is not available as executable in
;; ~/.local/bin, provide a dummy one that runs black in library mode
;; python3 -m black "${@}"
(use-package python-black
  :init
  ;; install system dependencies
  (ff/ensure-python-package "black" nil "black")

  :hook ((python-mode . python-black-on-save-mode)))

;; supports virtual environments. To be set with pyvenv-workon
(use-package pyvenv
  :init (pyvenv-mode 1)
  :config (pyvenv-tracking-mode 1))

;; enable py-isort to resort imports on save
(use-package py-isort
  :init
  ;; install system dependencies
  (ff/ensure-python-package "isort" nil "isort")
  :hook ((python-mode . (lambda ()
                                (add-hook 'before-save-hook 'py-isort-before-save)))))

;; enable sphinx doc strings support
(use-package sphinx-doc
  :hook ((python-mode . sphinx-doc-mode))
  :bind (:map python-mode-map
              ("C-c C-d" . sphinx-doc)))

(provide 'setup-python)

;;; setup-python.el ends here
