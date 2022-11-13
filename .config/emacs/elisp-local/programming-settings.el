;;; programming-settings.el --- Setup all programming settings

;;; Commentary:
;; Configuration for all programming settings

;;; Code:

;; -------------------------------------------------------------------
;; Simple text
;; -------------------------------------------------------------------
(defun ff/configure-text-mode ()
  "Configure text mode."
  (interactive)
  (set (make-local-variable 'completion-at-point-functions)
       '(cape-dabbrev
         cape-ispell)))

(use-package text-mode
  :straight nil
  :after (cape)
  :hook ((text-mode . ff/configure-text-mode)))

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
(use-package setup-cc
  :straight nil)

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

(use-package ess-smart-underscore)

;; -------------------------------------------------------------------
;; Latex
;; -------------------------------------------------------------------
(use-package setup-latex
  :straight nil)

;; -------------------------------------------------------------------
;; Python
;; -------------------------------------------------------------------
(use-package setup-python
  :straight nil)

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
               ("C-m" . newline-and-indent))))

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
        (set-process-sentinel vterm--process #'ff/run-in-vterm-kill)
        (vterm-send-string command)
        (vterm-send-return))))

  ;; add new entry to transient of docker package for my own vterm
  ;; startup function
  (transient-append-suffix
    'docker-container-shells
    "b"
    '("v" "vterm" ff/docker-container-vterm-selection))
  :bind ("C-x d" . docker))

;; -------------------------------------------------------------------
;; markdown mode
;; -------------------------------------------------------------------
(defun ff/configure-markdown-mode ()
  "Configure text mode."
  (interactive)
  (set-fill-column 100))

(defun ff/run-mdformat ()
  "Run mdformat on current buffer."
  (interactive)
  (when (string-match-p ".md\\'" (buffer-file-name))
    (shell-command (concat "mdformat " (buffer-file-name)))))

(use-package markdown-mode
  :commands markdown-mode
  :custom
  ;; The default command for markdown (~markdown~), doesn't support tables
  ;; (e.g. GitHub flavored markdown). Pandoc does, so let's use that.
  ((markdown-command "pandoc --from markdown --to html")
   (markdown-command-needs-filename t))
  :init
  (ff/ensure-apt-package "markdown" "markdown")
  (ff/ensure-apt-package "pandoc" "pandoc")
  (ff/ensure-python-package "mdformat" nil "mdformat")

  :hook ((markdown-mode . visual-line-mode)
         (markdown-mode . flyspell-mode)
         (markdown-mode . ff/configure-markdown-mode))
  :bind (:map markdown-mode-map
         ("C-c C-f" . ff/run-mdformat)))

;; -------------------------------------------------------------------
;; RST mode
;; -------------------------------------------------------------------
(use-package poly-rst
  :mode (("\\.rst$" . poly-rst-mode)
         ("\\.rest$" . poly-rst-mode))
  :init
  (set-default 'truncate-lines t))

;; C-c C-e r r (org-rst-export-to-rst)
;;    Export as a text file written in reStructured syntax.
;; C-c C-e r R (org-rst-export-as-rst)
;;    Export as a temporary buffer. Do not create a file.
(use-package ox-rst)

(defun ff/configure-rst-mode ()
  "Configure text mode."
  (interactive)
  (set (make-local-variable 'completion-at-point-functions)
       '(cape-dabbrev
         cape-ispell)))

(use-package rst
  :mode (("\\.rst$" . rst-mode)
         ("\\.rest$" . rst-mode))
  :hook ((rst-mode . pyvenv-mode) ;; enable support of virtualenvironments
         (text-mode . ff/configure-rst-mode)))

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
;; Plantuml mode
;; -------------------------------------------------------------------
(defun ff/plantuml-create-svg (source_filename)
  "Create SVG from current puml file.
SOURCE_FILENAME: filename to the puml file."
  (interactive)
  (message (concat "Converting " source_filename))
  (call-process-shell-command (concat
                               "java"
                               " -jar"
                               " " plantuml-jar-path
                               " " source_filename
                               " -DRELATIVE_INCLUDE=\".\""
                               " -Djava.awt.headless=true"
                               " -tsvg -charset utf-8"))
  (message "Conversion succeeded."))

(defun ff/plantum-preview ()
  "First, delete the preview window if present, then compile puml file."
  (interactive)
  ;; delete current preview window if visible
  (let (current-buffer (buffer-name))
    (when (ff/is-buffer-visible plantuml-preview-buffer)
      (delete-window (get-buffer-window plantuml-preview-buffer)))
    ;; run actual plantuml preview with 4=new frame setting
    (plantuml-preview 0)))

(use-package plantuml-mode
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  ;; install system dependencies
  (ff/ensure-apt-package "graphviz" "dot")
  (ff/ensure-apt-package "unzip" "unzip")

  ;; Consider using (plantuml-download-jar) as alternative
  (defvar plantuml-version "1.2022.8" "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-jar-asl-" plantuml-version) "Name of plantuml executable")
  (defvar plantuml-url
    (concat "https://sourceforge.net/projects/plantuml/files/" plantuml-version "/" plantuml-name ".zip/download")
    "URL to download plantuml from sourceforge.")
  (defvar plantuml-root (expand-file-name "plantuml" no-littering-var-directory))
  (defvar plantuml-extract-to (expand-file-name plantuml-name plantuml-root)
    "Destination of plantuml binaries")
  (defvar plantuml-expected-binary (expand-file-name "plantuml.jar" plantuml-extract-to)
    "Path to java archive of plantuml.")
  (ff/download-and-extract-zip-archive plantuml-url
                                       plantuml-name
                                       plantuml-extract-to
                                       plantuml-expected-binary
                                       "plantuml")
  :config
  ;; Sample jar configuration
  (setq plantuml-jar-path plantuml-expected-binary
        plantuml-jar-args (list "-charset" "UTF-8" "-DRELATIVE_INCLUDE=." "-Djava.awt.headless=true")
        plantuml-default-exec-mode 'jar
        plantuml-indent-level 4)
  ;; remap preview to personal function; for some reason, bind does
  ;; not accept it
  (define-key plantuml-mode-map [remap plantuml-preview] 'ff/plantum-preview)
  :bind (:map plantuml-mode-map
              ("C-M-i" . plantuml-complete-symbol)
              ("C-c C-e" . (lambda() (interactive) (ff/plantuml-create-svg (buffer-file-name))))))

(use-package flycheck-plantuml
  :after (plantuml-mode flycheck)
  :commands (flycheck-plantuml-setup))

;; -------------------------------------------------------------------
;; Groovy mode for Jenkins
;; -------------------------------------------------------------------
(use-package groovy-mode
  :mode (("\\.groovy$" . groovy-mode)))

;; -------------------------------------------------------------------
;; Java mode
;; -------------------------------------------------------------------

;; -------------------------------------------------------------------
;; Json
;; -------------------------------------------------------------------
(use-package json-mode
  :mode (("\\.json$" . json-mode))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "npm" "npm")
  (ff/ensure-npm-package "jsonlint" "jsonlint"))

;; -------------------------------------------------------------------
;; Robot Framework
;; -------------------------------------------------------------------
(use-package robot-mode
  :mode (("\\.robot" . robot-mode)))

(provide 'programming-settings)

;;; programming-settings.el ends here
