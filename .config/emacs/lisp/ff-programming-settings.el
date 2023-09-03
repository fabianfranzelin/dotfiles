;;; ff-programming-settings.el --- Setup all programming settings

;;; Commentary:
;; Configuration for all programming settings

;;; Code:

;; -------------------------------------------------------------------
;; LSP Client Eglot
;; -------------------------------------------------------------------
(use-package eglot
  :hook ((c++-ts-mode . eglot-ensure)
         (c-ts-mode . eglot-ensure)
         (java-ts-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (json-ts-mode . eglot-ensure)
         (yaml-ts-mode . eglot-ensure)
         (bash-ts-mode . eglot-ensure)
         (bash-ts-mode . eglot-ensure)
         (sh-mode . englot-ensure)
         (cmake-ts-mode . eglot-ensure)
         (dockerfile-ts-mode . eglot-ensure)
         (rst-mode . eglot-ensure))
  :custom ((eglot-events-buffer-size 10))
  :config
  (setq read-process-output-max (* 1024 1024))

  ;; C/C++
  (add-to-list 'eglot-server-programs `(c-ts-mode "clangd"))
  (add-to-list 'eglot-server-programs `(c++-ts-mode "clangd"))
  ;; Sphinx, rst-mode
  ;; make esbonio the default lsp server for rst-mode
  ;; currently only version 0.15 works
  (add-to-list 'eglot-server-programs `(rst-mode . ("python3" "-m" "esbonio")))

  :bind (("C-c l w s" . eglot)
         ("C-c l w r" . eglot-reconnect)
         ("C-c l w k" . eglot-shutdown)
         ("C-c l w a" . eglot-shutdown-all)
         ("C-c l f" . eglot-format)
         ("C-c l a" . eglot-code-actions)
         ("C-c l i" . eglot-code-action-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l d" . flymake-show-buffer-diagnostics)
         ("C-h ." . eldoc)
         ("C-c l e" . eglot-stderr-buffer)
         ("C-c l c" . eglot-show-workspace-configuration)))

(with-eval-after-load 'eglot

  (defun ff/find-all-parent-dirs-with-file (directory file-name)
    "List all parent directories that contain the given `file-name'.

The output contains the directories in ascending order, starting
with the one closes to the root directory.

DIRECTORY: directory where to start the search.
FILE-NAME: file name that marks the directory to be collected.
"
    (append
     ;; there are more parent folders to be explored; stop at
     ;; the root folder of the repository
     (unless (f-directory-p (file-name-concat directory ".git"))
       (let ((parent (file-name-directory (directory-file-name directory))))
         (ff/find-all-parent-dirs-with-file parent file-name)))
     ;; add current folder if it contains the right file
     (when (file-exists-p (file-name-concat directory file-name))
       `(,directory))))

  (defun ff/eglot-find-local-project ()
    "Create a local project on-the-fly for specific modes.

This is required when one has a mono repository, where I do only
want to start my LSP server in a certain directory without
the need to update my project hierarchy."
    (let ((eglot-lsp-context t))
      (cond ((string= major-mode "rst-mode")
             ;; TODO: search for multiple conf.py files in all parent
             ;; folders. Until reaching the project root. If multiple
             ;; are found, offer the user the one he wants to select
             ;; via `completing-read'. But make sure that the
             ;; `completion-read' is only called once.

             ;; I always want to start esbonio at the same level
             ;; directory the conf.py file is located.
             (when-let ((roots (ff/find-all-parent-dirs-with-file (buffer-file-name) "conf.py"))
                        (root (car roots)))
               (list 'vc nil root)))
            ;; in all other cases, let the original function handle
            ;; the project folder.
            (t
             nil))))

  (advice-add 'eglot--current-project :before-until
              #'ff/eglot-find-local-project))

(use-package consult-eglot)

;; -------------------------------------------------------------
;; use built-in tree-sitter
;; -------------------------------------------------------------
(use-package treesit
  :straight nil
  :preface
  (defun ff/setup-install-grammars ()
    "Install Tree-sitter grammars if they are absent."
    (interactive)
    (dolist (grammar
             '((bash "https://github.com/tree-sitter/tree-sitter-bash")
               (cmake "https://github.com/uyha/tree-sitter-cmake")
               (css "https://github.com/tree-sitter/tree-sitter-css")
               (elisp "https://github.com/Wilfred/tree-sitter-elisp")
               (html "https://github.com/tree-sitter/tree-sitter-html")
               (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
               (json "https://github.com/tree-sitter/tree-sitter-json")
               (make "https://github.com/alemuller/tree-sitter-make")
               (markdown "https://github.com/ikatyang/tree-sitter-markdown")
               (python "https://github.com/tree-sitter/tree-sitter-python")
               (toml "https://github.com/tree-sitter/tree-sitter-toml")
               (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
               (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
               (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
      (add-to-list 'treesit-language-source-alist grammar)
      ;; Only install `grammar' if we don't already have it
      ;; installed. However, if you want to *update* a grammar then
      ;; this obviously prevents that from happening.
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))
  :config
  (ff/setup-install-grammars)
  (add-to-list 'treesit-extra-load-path (expand-file-name ".cache/emacs/tree-sitter" (getenv "HOME"))))

(use-package combobulate
  :preface
  ;; You can customize Combobulate's key prefix here.
  ;; Note that you may have to restart Emacs for this to take effect!
  (setq combobulate-key-prefix "C-c o")

  ;; Optional, but recommended.
  ;;
  ;; You can manually enable Combobulate with `M-x
  ;; combobulate-mode'.
  :hook ((python-ts-mode . combobulate-mode)
         (js-ts-mode . combobulate-mode)
         (css-ts-mode . combobulate-mode)
         (yaml-ts-mode . combobulate-mode)
         (typescript-ts-mode . combobulate-mode)
         (tsx-ts-mode . combobulate-mode)))

;; this package is required for refactoring with multiple cursors in
;; combobulate
(use-package multiple-cursors)

;; -------------------------------------------------------------------
;; Additionally to flymake, use flycheck as well for certain modes
(use-package flycheck
  :init (global-flycheck-mode))

;; -------------------------------------------------------------------
;; Debugger
;; -------------------------------------------------------------------
(use-package realgud
  :after (org)
  :custom ((realgud:pdb-command-name "python3 -m pdb")
           (realgud-safe-mode nil)))

;; -------------------------------------------------------------------
;; Aphelia: auto-format different source code files extremely
;; intelligently
;; -------------------------------------------------------------------
(use-package apheleia
  :custom
  (apheleia-log-only-errors nil))

;; -------------------------------------------------------------------
;; Colorful compilation buffer
;; -------------------------------------------------------------------
(use-package fancy-compilation
  :init
  ;; use background of my current theme
  (defface fancy-compilation-default-face
    (list (list t :background "282c34" :inherit 'ansi-color-grey))
    "Face used to render black color.")
  ;; enable minor mode
  (fancy-compilation-mode 1))

;; -------------------------------------------------------------------
;; Emacs lisp
;; -------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.dir-locals\\.el$" . emacs-lisp-mode))

(with-eval-after-load 'apheleia
  (add-hook 'emacs-lisp-mode-hook 'apheleia-mode)
  (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist) 'lisp-indent))

;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)))

;; define shortcut that launches ielm
(define-key emacs-lisp-mode-map (kbd "C-c C-r") 'ielm)

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

;; -------------------------------------------------------------------
;; yaml mode
;; -------------------------------------------------------------------
(use-package yaml-mode
  :mode (("\\.yml$" . yaml-mode)
         ("\\.yaml$" . yaml-mode))
  :init
  ;; install system dependencies
  (ff/ensure-python-package "yamllint" nil "yamllint")
  (ff/ensure-npm-package "yaml-language-server" "yaml-language-server"))

;; -------------------------------------------------------------------
;; Dockerfile
;; -------------------------------------------------------------------
(ff/ensure-npm-package "dockerfile-language-server-nodejs" "docker-langserver")
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-ts-mode))

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
;; Typescript, TSX and Javascript
;; -------------------------------------------------------------------
(ff/ensure-npm-package "typescript-language-server" "typescript-language-server")

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))

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
;; ensure system packages
(ff/ensure-npm-package "jsonlint" "jsonlint")
(ff/ensure-npm-package "prettier-json" "prettier-json")

(add-to-list 'auto-mode-alist '("\\.json$" . json-ts-mode))
(add-to-list 'auto-mode-alist '("\\.inst$" . json-ts-mode))

;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'json-ts-mode-hook 'apheleia-mode)
  (setf (alist-get 'prettier-json apheleia-formatters) '("prettier-json" filepath))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'prettier-json))

;; enable eslint for javascript
(ff/ensure-npm-package "eslint" "eslint")
(flycheck-add-mode 'javascript-eslint 'js-ts-mode)

;; -------------------------------------------------------------------
;; Robot Framework
;; -------------------------------------------------------------------
(use-package robot-mode
  :mode (("\\.robot" . robot-mode))
  :init
  (ff/ensure-python-package "robotframework-tidy" nil "robotidy"))

(defcustom ff/robotidy-config nil
  "Path to robotidy configuration file."
  :type 'string)

;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'robot-mode-hook 'apheleia-mode)
  (let* ((robotidy-base-cmd '("robotidy" filepath))
         (robotidy-args (when ff/robotidy-config '("--config" ff/robotidy-config)))
         (robotidy-cmd (append robotidy-base-cmd robotidy-args)))
    (setf (alist-get 'robotidy apheleia-formatters) robotidy-cmd)
    (setf (alist-get 'robot-mode apheleia-mode-alist) 'robotidy)))

;; -------------------------------------------------------------------
;; toml
;; -------------------------------------------------------------------
;; use tree-sitter as default and overwrite conf-toml-mode
(add-to-list 'major-mode-remap-alist '(conf-toml-mode toml-ts-mode))

;; -------------------------------------------------------------------
;; Direnv: I am using the buffer local version and not the direnv
;; package
;; -------------------------------------------------------------------
(use-package envrc)

;; -------------------------------------------------------------------
;; HTML, CSS, etc.
;; -------------------------------------------------------------------
;; use tree-sitter as default and overwrite python-mode
(add-to-list 'major-mode-remap-alist '(css-mode css-ts-mode))

;; -------------------------------------------------------------------
;; SQLite
;; -------------------------------------------------------------------
(require 'sqlite-mode-extras)

(define-key sqlite-mode-map "n" 'next-line)
(define-key sqlite-mode-map "p" 'previous-line)
(define-key sqlite-mode-map "f" 'sqlite-mode-extras-next-column)
(define-key sqlite-mode-map "b" 'sqlite-mode-extras-previous-column)
(define-key sqlite-mode-map "d" 'sqlite-mode-delete)
(define-key sqlite-mode-map "e" 'sqlite-mode-extras-edit-row-field)
(define-key sqlite-mode-map (kbd "<backtab>") 'sqlite-mode-extras-backtab-dwim)
(define-key sqlite-mode-map (kbd "<tab>") 'sqlite-mode-extras-tab-dwim)
(define-key sqlite-mode-map (kbd "RET") 'sqlite-mode-extras-ret-dwim)

(provide 'ff-programming-settings)

;;; ff-programming-settings.el ends here
