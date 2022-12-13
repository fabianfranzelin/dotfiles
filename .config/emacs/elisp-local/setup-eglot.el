;;; setup-eglot.el --- Set up eglot

;;; Commentary:
;; Sets up eglot for Emacs

;;; Code:

(use-package eglot
  :hook ((c++-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (java-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (yaml-mode . eglot-ensure)
         (sh-mode . eglot-ensure)
         (cmake-mode . eglot-ensure)
         (dockerfile-mode . eglot-ensure)
         (rst-mode . eglot-ensure))
  :config
  (setq read-process-output-max (* 1024 1024))
  (setq eglot-events-buffer-size 10)

  ;; Python
  (add-to-list 'eglot-server-programs
               `(python-mode "python3" "-m" "pylsp"))

  ;; C++
  (add-to-list 'eglot-server-programs
               `((c++-mode c-mode) "clangd-12"))

  ;; Sphinx, rst-mode
  (defclass eglot-esbonio (eglot-lsp-server) ()
    :documentation "Esbonio Language Server.")
  (add-to-list 'eglot-server-programs
               `(rst-mode . (eglot-esbonio
                             ,(executable-find "python3")
                             "-m" "esbonio")))

  :bind (("C-c l w s" . eglot)
         ("C-c l w r" . eglot-reconnect)
         ("C-c l w k" . eglot-shutdown)
         ("C-c l f" . eglot-format)
         ("C-c l a" . eglot-code-actions)
         ("C-c l i" . eglot-code-action-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l d" . flymake-show-buffer-diagnostics)
         ("C-h ." . eldoc)
         ("C-c l e" . eglot-stderr-buffer)))

(use-package realgud
  :after (org)
  :custom ((realgud:pdb-command-name "python3 -m pdb")))

(provide 'setup-eglot)

;;; setup-eglot.el ends here
