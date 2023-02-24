;;; ff-programming-settings.el --- Setup all programming settings

;;; Commentary:
;; Configuration for all programming settings

;;; Code:

;; -------------------------------------------------------------------
;; LSP Client Eglot
;; -------------------------------------------------------------------
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
  :custom ((eglot-events-buffer-size 10))
  :config
  (setq read-process-output-max (* 1024 1024))

  ;; Python
  (add-to-list 'eglot-server-programs
               `(python-mode "python3" "-m" "pylsp"))

  ;; C/C++
  (add-to-list 'eglot-server-programs
               `(c-mode "clangd-12"))
  (add-to-list 'eglot-server-programs
               `(c++-mode "clangd-12"))

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

;; -------------------------------------------------------------------
;; Additionally to flymake, use flycheck as well for certain modes
(use-package flycheck
  :init (global-flycheck-mode))

;; -------------------------------------------------------------------
;; Deugger
;; -------------------------------------------------------------------
(use-package realgud
  :after (org)
  :custom ((realgud:pdb-command-name "python3 -m pdb")
           (realgud-save-mode nil)))

;; -------------------------------------------------------------------
;; Emacs lisp
;; -------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.dir-locals\\.el$" . emacs-lisp-mode))

;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)))

;; -------------------------------------------------------------------
;; C/C++
;; -------------------------------------------------------------------
(require 'ff-programming-cc)

;; -------------------------------------------------------------------
;; CRAN R
;; -------------------------------------------------------------------
(use-package ess
  :custom
  ((ess-use-eldoc nil)
   ;; ESS will not print the evaluated commands, also speeds up the
   ;; evaluation
   (ess-eval-visibly nil)
   ;; if you don't want to be prompted each time you start an
   ;; interactive R session
   (ess-ask-for-ess-directory nil)))

;; -------------------------------------------------------------------
;; Python
;; -------------------------------------------------------------------
(require 'ff-programming-python)

;; -------------------------------------------------------------------
;; Shell
;; -------------------------------------------------------------------
;; part of the lsp-mode configuration

;; Make sure that my preferred linter is installed
(ff/ensure-apt-package "shellcheck" "shellcheck")
(ff/ensure-npm-package "bash-language-server" "bash-language-server")

;; There is a keybinding defined in sh-mode that overwrites parts of
;; my configuration. I disable it here manually
(use-package sh-script
  :straight nil)

;; -------------------------------------------------------------------
;; yaml mode
;; -------------------------------------------------------------------
(use-package yaml-mode
  :mode (("\\.yml$" . yaml-mode)
         ("\\.yaml$" . yaml-mode))
  :init
  ;; install system dependencies
  (ff/ensure-python-package "yamllint" nil "yamllint")
  (ff/ensure-npm-package "yaml-language-server" "yaml-language-server")
  :bind ((:map yaml-mode-map
               ("C-j" . newline-and-indent))))

;; -------------------------------------------------------------------
;; dockerfile mode
;; -------------------------------------------------------------------
(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode))
  :init
  (ff/ensure-npm-package "dockerfile-language-server-nodejs" "docker-langserver")
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package docker
  :after (setup-vterm)
  :custom
  (docker-run-default-args '("-i"
                             "-t"
                             "-e DEBIAN_FRONTEND=noninteractive"
                             "-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY"
                             "--shm-size=16g"
                             "--entrypoint /bin/bash"))
  :config
  (defun ff/docker-container-vterm-selection (prefix)
    "Run `docker-container-vterm' on the containers selection."
    (interactive "P")
    (docker-utils-ensure-items)
    (--each (docker-utils-get-marked-items-ids)
      (ff/docker-container-vterm it)))

  (defun ff/docker-container-vterm (container)
    "Open `vterm' in CONTAINER."
    (interactive "P")
    (ff/make-windows-visible-with-prefix (ff/vterm-buffer-name-prefix))
    (let* ((command (concat "docker exec -it -e "
                            "\"DEBIAN_FRONTEND=noninteractive\" "
                            "-e \"DISPLAY=$DISPLAY\" "
                            container " "
                            "\"/bin/bash\"")))
      (with-current-buffer (vterm (ff/vterm-buffer-name))
        (vterm-send-string command)
        (vterm-send-return))))

  ;; add new entry to transient of docker package for my own vterm
  ;; startup function
  (transient-append-suffix
    'docker-container-shells
    "b"
    '("v" "vterm" ff/docker-container-vterm-selection)))

;; -------------------------------------------------------------------
;; Typescript
;; -------------------------------------------------------------------
(use-package tide
  :after (typescript-mode)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package typescript-mode
  :custom ((typescript-indent-level 4))
  :init
  (ff/ensure-npm-package "typescript-language-server" "typescript-language-server"))

;; note, for some reason the mode directive does not work here, so I
;; added the typescript mode explicitly to tsx files.
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . typescript-mode))

;; -------------------------------------------------------------------
;; Groovy mode for Jenkins
;; -------------------------------------------------------------------
(use-package groovy-mode
  :mode (("\\.groovy$" . groovy-mode)))

;; -------------------------------------------------------------------
;; Java mode
;; -------------------------------------------------------------------
;; nothing to be done. Everything is currently handled by Eglot.

;; -------------------------------------------------------------------
;; Json
;; -------------------------------------------------------------------
(use-package json-mode
  :mode (("\\.json$" . json-mode)
         ("\\.inst$" . json-mode))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "npm" "npm")
  (ff/ensure-npm-package "jsonlint" "jsonlint"))

;; -------------------------------------------------------------------
;; Robot Framework
;; -------------------------------------------------------------------
(use-package robot-mode
  :mode (("\\.robot" . robot-mode))
  :init
  (ff/ensure-python-package "robotframework-tidy" nil "robotidy"))

;; -------------------------------------------------------------------
;; Direnv: I am using the buffer local version and not the direnv
;; package
;; -------------------------------------------------------------------
(use-package envrc)

(provide 'ff-programming-settings)

;;; ff-programming-settings.el ends here
