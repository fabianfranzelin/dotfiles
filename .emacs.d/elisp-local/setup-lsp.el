;;; setup-lsp.el --- Set up lsp-mode

;;; Commentary:
;; Sets up lsp-mode for Emacs

;;; Code:

(use-package lsp-mode
  :commands lsp
  :init
  (defun my/orderless-dispatch-flex-first (_pattern index _total)
    (and (eq index 0) 'orderless-flex))

  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  ;; Optionally configure the first word as flex filtered.
  (add-hook 'orderless-style-dispatchers #'my/orderless-dispatch-flex-first nil 'local)

  ;; Optionally configure the cape-capf-buster.
  (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point)))
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (setq lsp-log-io nil ;; if set to true can cause a performance hit
        lsp-pyls-plugins-flake8-enabled nil
        lsp-pyls-plugins-pycodestyle-enabled t
        lsp-enable-snippet t
        ;; disable flymake
        lsp-prefer-flymake nil
        ;; increase watch threshold
        lsp-file-watch-threshold 100000
        lsp-headerline-breadcrumb-segments '(project file symbols)
        ;; Disable diagnostics provider of lsp. Use flycheck
        lsp-diagnostics-provider :none
        ;; increase threshold for lsp to run smoothly
        ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
        read-process-output-max (* 1024 1024) ;; 1mb
        ;; bigger number required for client-server communication
        gc-cons-threshold (* 100 1024 1024)
        ;; disable plists parsing and use hasmaps
        lsp-use-plists nil
        ;; switch off logging
        lsp-log-io nil ; if set to true can cause a performance hit
        ;; clangd is fast
        lsp-idle-delay 0.1
        ;; be more ide-ish
        lsp-headerline-breadcrumb-enable t
        ;; we use Corfu!
        lsp-completion-provider :none)

  (lsp-enable-which-key-integration)
  (lsp-headerline-breadcrumb-mode)

  ;; use lsp yaml schema validation
  (setq lsp-yaml-schemas nil)
  ;; to be specific, one could to it like
  ;; (push '(/home/frf2lr/.emacs.d/yaml/runnable\.schema\.json . ["*.runnable.yaml"]) lsp-yaml-schemas)

  :hook ((lsp-completion-mode . my/lsp-mode-setup-completion)
         (c++-mode . lsp-deferred)
         (c-mode . lsp-deferred)
         (java-mode . lsp-deferred)
         (python-mode . lsp-deferred)
         (typescript-mode . lsp-deferred)
         (json-mode . lsp-deferred)
         (yaml-mode . lsp-deferred)
         (sh-mode . lsp-deferred)
         (cmake-mode . lsp-deferred)
         (dockerfile-mode . lsp-deferred)
         (before-save-hook . lsp-format-buffer)))

(use-package lsp-ui
  :after (lsp-mode)
  :commands lsp-ui-mode
  :hook ((lsp-mode . lsp-ui-mode))
  :config
  (setq imenu-auto-rescan t
        imenu-auto-rescan-maxout (* 1024 1024)
        imenu--rescan-item '("" . -99)
        lsp-ui-doc-position 'top
        lsp-ui-doc-alignment 'window
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover nil
        lsp-ui-doc-include-signature nil  ; don't include type signature in the child frame
        lsp-ui-sideline-show-symbol nil)  ; don't show symbol on the right of info
  (lsp-ui-peek-enable t))

(with-eval-after-load 'lsp-mode
  ;; :global/:workspace/:file
  (setq lsp-modeline-diagnostics-scope :workspace))

(with-eval-after-load 'lsp-ui-mode
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

;; -------------------------------------------------------------------
;; LSP integration with treemacs
;; -------------------------------------------------------------------
(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :commands lsp-treemacs-errors-list
  :config
  (setq treemacs-space-between-root-nodes nil)
  ;; enables bidirectional sync
  (lsp-treemacs-sync-mode t))

;; -------------------------------------------------------------------
;; Enable dap
;; -------------------------------------------------------------------
(use-package dap-mode
  :after (lsp-mode)
  :init
  ;; use tooltips for mouse hover
  ;; if it is not enabled `dap-mode' will use the minibuffer.
  (tooltip-mode 1)
  ;; displays floating panel with debug buttons
  ;; requies emacs 26+
  (dap-ui-controls-mode 1)
  :config
  (dap-auto-configure-mode)
  :hook ((dap-stopped . (lambda (arg) (call-interactively #'dap-hydra))))
  :bind (("C-c d d" . dap-debug)
         ("C-c d h" . dap-hydra)
         ("C-c d t" . dap-breakpoint-toggle)
         ("C-c d r" . dap-ui-repl)))

(provide 'setup-lsp)

;;; setup-lsp.el ends here
