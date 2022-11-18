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
  ;; C++
  (add-to-list 'eglot-server-programs
               `((c++-mode c-mode) "clangd"))
  ;; Sphinx, rst-mode
  (defclass eglot-esbonio (eglot-lsp-server) ()
    :documentation "Esbonio Language Server.")

  (cl-defmethod eglot-initialization-options ((server eglot-esbonio))
    "Passes the initializationOptions required to run the server."
    `(:sphinx (:confDir "${workspaceRoot}"
                        :srcDir "${confDir}")
              :server (:logLevel "debug")))

  (add-to-list 'eglot-server-programs
               `(rst-mode . (eglot-esbonio
                             ,(executable-find "python3")
                             "-m" "esbonio")))

  ;; disable flymake activation
  ;; (add-to-list 'eglot-stay-out-of 'flymake)
  :bind (("C-c l w s" . eglot)
         ("C-c l w r" . eglot-reconnect)
         ("C-c l w k" . eglot-shutdown)
         ("C-c l f" . eglot-format)
         ("C-c l a" . eglot-code-actions)
         ("C-c l i" . eglot-code-action-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l d" . flymake-show-buffer-diagnostics)
         ("C-h ." . eldoc)))

;; (use-package flymake-collection
;;   :hook ((c++-mode . flymake-mode)
;;          (c-mode . flymake-mode)
;;          (java-mode . flymake-mode)
;;          (python-mode . flymake-mode)
;;          (typescript-mode . flymake-mode)
;;          (json-mode . flymake-mode)
;;          (yaml-mode . flymake-mode)
;;          (sh-mode . flymake-mode)
;;          (cmake-mode . flymake-mode)
;;          (dockerfile-mode . flymake-mode))
;;   :init
;;   (setcdr (assoc `python-mode flymake-collection-config)
;;           '(flymake-collection-pylint
;;             flymake-collection-mypy
;;             (flymake-collection-pycodestyle :disabled t)
;;             (flymake-collection-flake8 :disabled t))))

(use-package realgud
  :after (org)
  :custom ((realgud:pdb-command-name "python3 -m pdb")))

(provide 'setup-eglot)

;;; setup-eglot.el ends here
