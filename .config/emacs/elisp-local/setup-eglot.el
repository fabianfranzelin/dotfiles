;;; setup-eglot.el --- Set up eglot

;;; Commentary:
;; Sets up eglot for Emacs

;;; Code:

(use-package eglot
  :hook ((c++-mode . eglot-ensure)
         (c-mode . eglot-ensure)))

(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))

(provide 'setup-eglot)

;;; setup-eglot.el ends here
