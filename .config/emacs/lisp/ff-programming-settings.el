;;; ff-programming-settings.el --- Setup all programming settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for all programming settings

;;; Code:

;; -------------------------------------------------------------------
;; LSP Client Eglot
;; -------------------------------------------------------------------
(use-package eglot
  :straight (:type built-in)
  :commands eglot-ensure
  :hook
  (c++-ts-mode . eglot-ensure)
  (c-ts-mode . eglot-ensure)
  (java-ts-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  (typescript-ts-mode . eglot-ensure)
  (tsx-ts-mode . eglot-ensure)
  (json-ts-mode . eglot-ensure)
  (yaml-ts-mode . eglot-ensure)
  (bash-ts-mode . eglot-ensure)
  (cmake-mode . eglot-ensure)
  (dockerfile-ts-mode . eglot-ensure)
  (rst-mode . eglot-ensure)
  (markdown-mode . eglot-ensure)
  (robot-mode . eglot-ensure)
  (bazel-mode . eglot-ensure)
  :custom
  (eglot-events-buffer-size 10)
  :config
  (setq read-process-output-max (* 1024 1024))
  :bind
  (:map global-map
        ("C-c l w s" . eglot)
        ("C-c l w r" . eglot-reconnect)
        ("C-c l w k" . eglot-shutdown)
        ("C-c l w a" . eglot-shutdown-all)
        ("C-c l f" . eglot-format)
        ("C-c l a" . eglot-code-actions)
        ("C-c l i" . eglot-code-action-organize-imports)
        ("C-c l r" . eglot-rename)
        ("C-c l d" . flymake-show-buffer-diagnostics)
        ("C-h ." . eldoc)
        ("C-c l e" . eglot-events-buffer)
        ("C-c l c" . eglot-show-workspace-configuration)))

(with-eval-after-load 'eglot

  (defun ff/find-all-parent-dirs-with-file (directory file-name)
    "List all parent directories that contain the given `file-name'.

The output contains the directories in descending order, starting
with the one closes to the current folder.

DIRECTORY: directory where to start the search.
FILE-NAME: file name that marks the directory to be collected.
"
    (append
     ;; add current folder if it contains the right file
     (when (file-exists-p (file-name-concat directory file-name))
       `(,directory))
     ;; there are more parent folders to be explored; stop at
     ;; the root folder of the repository
     (unless (f-directory-p (file-name-concat directory ".git"))
       (let ((parent (file-name-directory (directory-file-name directory))))
         (ff/find-all-parent-dirs-with-file parent file-name)))))

  (defun ff/eglot-find-local-project ()
    "Create a local project on-the-fly for specific modes.

This is required when one has a mono repository, where I do only
want to start my LSP server in a certain directory without
the need to update my project hierarchy."
    (let ((eglot-lsp-context t))
      (cond ((derived-mode-p 'rst-mode)
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

;; -------------------------------------------------------------
;; use built-in tree-sitter
;; -------------------------------------------------------------
(use-package treesit
  :straight (:type built-in)
  :preface
  (defun ff/treesit-install-grammars (&optional force)
    "Install Tree-sitter grammars if they are absent.
FORCE: force update of grammars"
    (interactive)
    (dolist (grammar
             '(
               (bash "https://github.com/tree-sitter/tree-sitter-bash")
               (cmake "https://github.com/uyha/tree-sitter-cmake")
               (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
               (c "https://github.com/tree-sitter/tree-sitter-c")
               (css "https://github.com/tree-sitter/tree-sitter-css")
               (elisp "https://github.com/Wilfred/tree-sitter-elisp")
               (html "https://github.com/tree-sitter/tree-sitter-html")
               (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
               (jsdoc "https://github.com/tree-sitter/tree-sitter-jsdoc")
               (json "https://github.com/tree-sitter/tree-sitter-json")
               (make "https://github.com/alemuller/tree-sitter-make")
               (markdown "https://github.com/ikatyang/tree-sitter-markdown")
               (python "https://github.com/tree-sitter/tree-sitter-python")
               (toml "https://github.com/tree-sitter/tree-sitter-toml")
               (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
               (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
               (yaml "https://github.com/ikatyang/tree-sitter-yaml")
               (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
               (rst "https://github.com/stsewd/tree-sitter-rst")
               ))

      (add-to-list 'treesit-language-source-alist grammar)
      ;; Only install `grammar' if we don't already have it
      ;; installed. However, if you want to *update* a grammar then
      ;; this obviously prevents that from happening.
      (when (or force (not (treesit-language-available-p (car grammar))))
        (message "Install tree sitter language grammar for %s" (car grammar))
        (treesit-install-language-grammar (car grammar)))))

  (defun ff/treesit-update-grammars ()
    (interactive)
    (ff/treesit-install-grammars t))
  :config
  (ff/treesit-install-grammars)
  (add-to-list 'treesit-extra-load-path
               (expand-file-name ".cache/emacs/tree-sitter" (getenv "HOME"))))

;; -------------------------------------------------------------------
;; Additionally to flymake, use flycheck as well for certain modes
(use-package flycheck
  :custom
  ;; bazel-buildifier in flycheck no longer working. Disable.
  ;; org-lint is also not working and I don't need it, so disable as well.
  (flycheck-disabled-checkers '(bazel-buildifier org-lint))
  ;; Override default flycheck triggers
  (flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (flycheck-idle-change-delay 0.8)
  :init
  (global-flycheck-mode))

(use-package flycheck-status-emoji
  :after flycheck
  :custom
  (flycheck-status-emoji-indicator-finished-error ?💀)
  (flycheck-status-emoji-indicator-finished-ok ?👍)
  (flycheck-status-emoji-indicator-finished-warning ?👎)
  :config
  (flycheck-status-emoji-mode t))

;; -------------------------------------------------------------------
;; Debugger
;; -------------------------------------------------------------------
(use-package realgud
  :after org
  :custom
  (realgud:pdb-command-name "python3 -m ipdb")
  (realgud-safe-mode nil))

(use-package dape
  :hook
  ;; Save breakpoints on quit
  (kill-emacs . dape-breakpoint-save)
  ;; Load breakpoints on startup
  (after-init . dape-breakpoint-load)
  ;; Save buffers on startup, useful for interpreted languages
  (dape-start . (lambda () (save-some-buffers t t)))
  ;; Pulse source line (performance hit)
  (dape-display-source . pulse-momentary-highlight-one-line)
  :custom
  ;; Turn on global bindings for setting breakpoints with mouse
  (dape-breakpoint-global-mode +1)
  ;; Info buffers to the right
  (dape-buffer-window-arrangement 'right))

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
  :preface
  ;; use background of my current theme
  (defface fancy-compilation-default-face
    (list (list t :background "282c34" :inherit 'ansi-color-grey))
    "Face used to render black color.")
  :hook
  (after-init . fancy-compilation-mode))

;; -------------------------------------------------------------------
;; Emacs lisp and common lisp
;; -------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.dir-locals\\.el$" . emacs-lisp-mode))

(with-eval-after-load 'apheleia
  (add-hook 'emacs-lisp-mode-hook 'apheleia-mode)
  (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist) 'lisp-indent))

;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook
  (emacs-lisp-mode . rainbow-delimiters-mode)
  (lisp-mode . rainbow-delimiters-mode))

;; define shortcut that launches ielm
(define-key emacs-lisp-mode-map
            (kbd "C-c C-p")
            #'(lambda ()
                (interactive)
                (split-window)
                (other-window 1)
                (ielm)))

;; -------------------------------------------------------------------
;; C/C++
;; -------------------------------------------------------------------
(require 'ff-programming-cc)

;; -------------------------------------------------------------------
;; CRAN R
;; -------------------------------------------------------------------
(use-package ess
  :custom
  (ess-use-eldoc nil)
  ;; ESS will not print the evaluated commands, also speeds up the
  ;; evaluation
  (ess-eval-visibly nil)
  ;; if you don't want to be prompted each time you start an
  ;; interactive R session
  (ess-ask-for-ess-directory nil))

;; use ESR for R package development
;; install from codeberg: https://codeberg.org/teoten/esr
;; (use-package esr
;;   :straight (:host codeberg :repo "teoten/esr" :branch "main"))

;; -------------------------------------------------------------------
;; Python
;; -------------------------------------------------------------------
(require 'ff-programming-python)

;; -------------------------------------------------------------------
;; Shell
;; -------------------------------------------------------------------
;; part of the lsp-mode configuration

;; use tree-sitter as default and overwrite sh-mode
(add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode))

;; Make sure that my preferred linter is installed
(ff/ensure-apt-package "shellcheck" "shellcheck")
(ff/ensure-npm-package "bash-language-server" "bash-language-server")
(ff/ensure-python-package "beautysh")

;; make shell script executable
(add-hook 'after-save-hook
          #'executable-make-buffer-file-executable-if-script-p)

;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'bash-ts-mode-hook 'apheleia-mode)
  (setf (alist-get 'beautysh apheleia-formatters) '("beautysh"
                                                    filepath
                                                    (when-let ((indent (bound-and-true-p sh-basic-offset)))
                                                      (list "--indent-size" (number-to-string indent)))
                                                    (when indent-tabs-mode "--tab")))
  (setf (alist-get 'bash-ts-mode apheleia-mode-alist) 'beautysh))

;; envrc files
(add-to-list 'auto-mode-alist '("\\.envrc\\'" . envrc-file-mode))
(add-to-list 'auto-mode-alist '("\\.envrc\\.\\'" . envrc-file-mode))

;; -------------------------------------------------------------------
;; yaml mode
;; -------------------------------------------------------------------
(use-package yaml-mode
  :preface
  ;; install system dependencies
  (ff/ensure-python-package "yamllint" nil "yamllint")
  (ff/ensure-npm-package "yaml-language-server" "yaml-language-server")
  :mode
  ("\\.yml$" . yaml-mode)
  ("\\.yaml$" . yaml-mode))
;; -------------------------------------------------------------------
;; Dockerfile
;; -------------------------------------------------------------------
(ff/ensure-npm-package "dockerfile-language-server-nodejs" "docker-langserver")
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-ts-mode))

(use-package docker
  :after setup-vterm
  :custom
  (docker-container-shell-file-name "/bin/bash")
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
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))

;; enable eslint for javascript
(ff/ensure-npm-package "eslint" "eslint")
(flycheck-add-mode 'javascript-eslint 'js-ts-mode)
(flycheck-add-mode 'javascript-eslint 'tsx-ts-mode)

(use-package js-comint
  :commands js-comint-repl)

;; -------------------------------------------------------------------
;; Groovy mode for Jenkins
;; -------------------------------------------------------------------
(use-package groovy-mode
  :mode
  (("\\.groovy$" . groovy-mode)))

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

;; -------------------------------------------------------------------
;; Robot Framework
;; -------------------------------------------------------------------
(use-package robot-mode
  :preface
  (ff/ensure-python-package "robotframework-robocop" "6.11.0" "robocop")
  :mode
  ("\\.robot" . robot-mode))

(defcustom ff/robotidy-config nil
  "Path to robotidy configuration file."
  :type 'string)

;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'robot-mode-hook 'apheleia-mode)
  (let* ((robotidy-cmd '("robocop" "format" filepath (when ff/robotidy-config `("--config" ,ff/robotidy-config)) "--silent")))
    (setf (alist-get 'robotidy apheleia-formatters) robotidy-cmd)
    (setf (alist-get 'robot-mode apheleia-mode-alist) 'robotidy)))

(with-eval-after-load 'eglot
  ;; make sure that system packages are available
  (ff/ensure-python-package "robotframework-lsp" nil "robotframework_ls")

  ;; register robotframework_ls as default lsp server in eglot
  (add-to-list 'eglot-server-programs `(robot-mode "robotframework_ls")))

;; -------------------------------------------------------------------
;; toml
;; -------------------------------------------------------------------
;; use tree-sitter as default and overwrite conf-toml-mode
(add-to-list 'major-mode-remap-alist '(conf-toml-mode . toml-ts-mode))

;; -------------------------------------------------------------------
;; Direnv: I am using the buffer local version and not the direnv
;; package
;; -------------------------------------------------------------------
(use-package envrc)

;; -------------------------------------------------------------------
;; HTML, CSS, etc.
;; -------------------------------------------------------------------
;; use tree-sitter as default and overwrite python-mode
(add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))
(add-to-list 'major-mode-remap-alist '(html-mode . html-ts-mode))
(add-to-list 'major-mode-remap-alist '(mhtml-mode . html-ts-mode))

;; -------------------------------------------------------------------
;; SQLite
;; -------------------------------------------------------------------
(use-package sqlite-mode-extras
  :hook ((sqlite-mode . sqlite-extras-minor-mode))
  :init
  ;; Open sqlite data bases with sqlite-open-file
  (defun ff/sqlite-view-file-magically ()
    "Run `sqlite-mode-open-file' on the file in the current buffer."
    (require 'sqlite-mode)
    (let ((file-name buffer-file-name))
      (kill-current-buffer)
      (sqlite-mode-open-file file-name)))

  ;; Load all files that start with "SQLite format 3" with sqlite-mode
  ;; and not in binary mode
  (add-to-list 'magic-mode-alist
               '("SQLite format 3\x00" . ff/sqlite-view-file-magically))
  :bind (:map
         sqlite-mode-map
         ("n" . next-line)
         ("p" . previous-line)
         ("b" . sqlite-mode-extras-backtab-dwim)
         ("f" . sqlite-mode-extras-tab-dwim)
         ("+" . sqlite-mode-extras-add-row)
         ("D" . sqlite-mode-extras-delete-row-dwim)
         ("C" . sqlite-mode-extras-compose-and-execute)
         ("E" . sqlite-mode-extras-execute)
         ("S" . sqlite-mode-extras-execute-and-display-select-query)
         ("DEL" . sqlite-mode-extras-delete-row-dwim)
         ("g" . sqlite-mode-extras-refresh)
         ("<backtab>" . sqlite-mode-extras-backtab-dwim)
         ("<tab>" . sqlite-mode-extras-tab-dwim)
         ("RET" . sqlite-mode-extras-ret-dwim)))

;; -------------------------------------------------------------------
;; Jinja mode
;; -------------------------------------------------------------------
(use-package jinja2-mode
  :mode
  ("\\.tpl$" . jinja2-mode)
  :bind
  (:map jinja2-mode-map
        ("M-o" . nil)))

;; -------------------------------------------------------------------
;; Use Emacs web server for providing static files
(use-package simple-httpd
  :custom
  (httpd-host 'local))

;; -----------------------------------------------------------------------------------
;; Bazel
;; for getting compile commands code: https://github.com/hedronvision/bazel-compile-commands-extractor

(use-package bazel
  :mode (("\\.bzl\\'" . bazel-mode)
         ("BUILD\\'" . bazel-mode)
         ("BUILD\\.bazel\\'" . bazel-mode)
         ("WORKSPACE\\'" . bazel-mode)
         ("WORKSPACE\\.bazel\\'" . bazel-mode))
  :bind (:map
         global-map
         ("C-c b b" . bazel-build)
         ("C-c b t" . bazel-test)
         ("C-c b r" . bazel-run)
         ("C-c b q" . bazel-query)
         ("C-c b c" . bazel-coverage)
         ("C-c b m" . ff/bazel-transient)))

;; use apheleia for formatting instead of bazel-buildifier package
(with-eval-after-load 'apheleia
  (add-hook 'bazel-mode-hook 'apheleia-mode)
  (setf (alist-get 'buildifier apheleia-formatters)
        '("buildifier" filepath))
  (setf (alist-get 'bazel-mode apheleia-mode-alist) 'buildifier))

(with-eval-after-load 'eglot
  ;; register starpls as lsp server for bazel-mode (starlark lsp)
  (add-to-list 'eglot-server-programs '(bazel-mode "starpls")))

;; Transient menu for Bazel (similar to VSCode command palette)
(transient-define-prefix ff/bazel-transient ()
  "Bazel commands."
  ["Bazel"
   ["Build/Test/Run"
    ("b" "Build" bazel-build)
    ("t" "Test" bazel-test)
    ("r" "Run" bazel-run)
    ("c" "Coverage" bazel-coverage)]
   ["Query"
    ("q" "Query" bazel-query)]
   ["Format"
    ("f" "Format file" (lambda () (interactive) (apheleia-format-buffer)))
    ("F" "Format all BUILD files" (lambda ()
                                    (interactive)
                                    (shell-command "find . -type f \\( -name BUILD -o -name BUILD.bazel \\) -exec buildifier {} +")))]])

;; -----------------------------------------------------------------------------------
;; CSV mode

(use-package csv-mode
  :mode (("\\.csv\\'" . csv-mode)
         ("\\.tsv\\'" . csv-mode))
  :hook (
         ;; auto detect separator
         (csv-mode . csv-guess-set-separator)
         ;; turn on field alignment
         (csv-mode . csv-align-mode)
         ;; disable line wrap
         (csv-mode .
                   (lambda ()
                     (visual-line-mode -1)
                     (toggle-truncate-lines 1)))))

(provide 'ff-programming-settings)

;;; ff-programming-settings.el ends here
