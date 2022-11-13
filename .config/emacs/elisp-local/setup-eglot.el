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
         (dockerfile-mode . eglot-ensure))
  :config
  (setq read-process-output-max (* 1024 1024))
  (setq eglot-events-buffer-size 10)
  (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd")))

;; (use-package realgud)

(provide 'setup-eglot)

;;; setup-eglot.el ends here
