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
  :ensure-system-package ((pip3 . "sudo apt install python3-pip -y")
                          (pylsp . "python3 -m pip install -U 'python-lsp-server[all]'")
                          ;; both packages are required for debugging with dap
                          ((:eval ff/python-local-site-packages-path "epc") . "python3 -m pip install -U 'epc'")
                          ((:eval ff/python-local-site-packages-path "ptvsd") . "python3 -m pip install -U 'ptvsd>=4.2'"))
  :mode (("\\.py$" . python-mode)
         ("SConstruct" . python-mode)
         ("SConscript" . python-mode))
  :hook ((python-mode . annotate-pdb)
         (python-mode . (lambda ()
                          ;; debugging package for python using ptvsd
                          (require 'dap-python)
                          (lsp))))  ; or lsp-deferred
  :init
  ;; use ipython as default interpreter
  (setq python-shell-interpreter "ipython3"
        python-shell-interpreter-args "--simple-prompt -i"
        python-indent-offset 4
        python-indent-guess-indent-offset nil
        ;; default python interpreter for dap
        dap-python-executable "python3")
  :config
  ;; delete output buffer on buffer execution
  (setq py-shell-switch-buffers-on-execute nil))

;; install black and black-macchiato with pip3 install --user -U
;; black-macchiato black if black is not available as executable in
;; ~/.local/bin, provide a dummy one that runs black in library mode
;; python3 -m black "${@}"
(use-package python-black
  :ensure-system-package ((black . "python3 -m pip install --user -U black"))
  :hook ((python-mode . python-black-on-save-mode)))

;; supports virtual environments. To be set with pyvenv-workon
(use-package pyvenv
  :init (pyvenv-mode 1)
  :config (pyvenv-tracking-mode 1))

(use-package pipenv
  :ensure-system-package ((pipenv . "python3 -m pip install --user -U pipenv"))
  :hook ((python-mode . pipenv-mode))
  :init
  (setq pipenv-projectile-after-switch-function
        #'pipenv-projectile-after-switch-extended))

;; enable py-isort to resort imports on save
(use-package py-isort
  :ensure-system-package ((isort . "python3 -m pip install --user -U isort"))
  :hook ((python-mode . (lambda ()
                                (add-hook 'before-save-hook 'py-isort-before-save)))))

;; enable sphinx doc strings support
(use-package sphinx-doc
  :hook ((python-mode . sphinx-doc-mode))
  :bind (:map python-mode-map
         ("C-c C-d" . sphinx-doc)))

(provide 'setup-python)

;;; setup-python.el ends here
