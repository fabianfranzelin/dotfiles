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
  (define-key text-mode-map (kbd "<tab>") 'company-indent-or-complete-common)
  (set (make-local-variable 'company-backends)
       '((company-abbrev
          company-dabbrev
          company-ispell
          company-files))))

(use-package text-mode
  :ensure nil
  :after company
  :hook (text-mode . ff/configure-text-mode))

;; -------------------------------------------------------------------
;; Emacs lisp
;; -------------------------------------------------------------------
;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

;; -------------------------------------------------------------------
;; C/C++
;; -------------------------------------------------------------------
(use-package setup-cc
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; CRAN R
;; -------------------------------------------------------------------
(use-package ess
  :init
  (setq ess-use-eldoc nil)
  ;; ESS will not print the evaluated commands, also speeds up the
  ;; evaluation
  (setq ess-eval-visibly nil)
  ;; if you don't want to be prompted each time you start an
  ;; interactive R session
  (setq ess-ask-for-ess-directory nil)
  :config
  (setq ess-nuke-trailing-whitespace-p t
        tab-always-indent t))

;; -------------------------------------------------------------------
;; Latex
;; -------------------------------------------------------------------
(use-package setup-latex
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Python
;; -------------------------------------------------------------------
(use-package setup-python
  :load-path local-load-path)

;; -------------------------------------------------------------------
;; Shell
;; -------------------------------------------------------------------
;; part of the lsp-mode configuration

;; -------------------------------------------------------------------
;; Swig-Mode
;; -------------------------------------------------------------------
(defun swig-switch-compile-command-auto ()
  "Switch compile command if a setup.py file is present in the current folder."
  (if (file-exists-p "setup.py")
      (setq compile-command "python setup.py install --install-lib=.")
    (setq compile-command "make -k"))
  (message compile-command))

;; compile command taking several compilation modes into account
(defun swig-compile()
  "Run compilation of swig interface."
  (interactive)
  (swig-switch-compile-command-auto)
  (compile compile-command))

(use-package swig-mode
  :load-path local-load-path
  :mode (("\\.i$" . swig-mode)))

;; -------------------------------------------------------------------
;; yaml mode
;; -------------------------------------------------------------------
(use-package yaml-mode
  :ensure-system-package ((pip3 . python3-pip)
                          (yamllint . "python3 -m pip install -U 'yamllint'"))
  :mode (("\\.yml$" . yaml-mode)
         ("\\.yaml$" . yaml-mode)))

;; -------------------------------------------------------------------
;; dockerfile mode
;; -------------------------------------------------------------------
(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode))
  :init
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package docker
  :bind ("C-x d" . docker)
  :config
  :custom (docker-run-default-args '("-i"
                                     "-t"
                                     "-e DEBIAN_FRONTEND=noninteractive"
                                     "-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY"
                                     "--shm-size=16g"
                                     "--entrypoint /bin/bash")))

;; -------------------------------------------------------------------
;; markdown mode
;; -------------------------------------------------------------------
(use-package markdown-mode
  :commands markdown-mode
  :ensure-system-package ((markdown . markdown)
                          (pandoc . pandoc))
  :init
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)
  :config
  ;; The default command for markdown (~markdown~), doesn't support tables
  ;; (e.g. GitHub flavored markdown). Pandoc does, so let's use that.
  (setq markdown-command "pandoc --from markdown --to html")
  (setq markdown-command-needs-filename t))

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

(use-package rst
  :mode (("\\.txtt$" . rst-mode)
         ("\\.rst$" . rst-mode)
         ("\\.rest$" . rst-mode))
  ;; enable support of virtualenvironments
  :hook ((rst-mode . pyvenv-mode)))

;; -------------------------------------------------------------------
;; Typescript
;; -------------------------------------------------------------------
(use-package tide
  :after (typescript-mode company)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package nvm)

(use-package typescript-mode
  :after (dap-node company)
  :config
  (setq typescript-indent-level 4)
  (dap-node-setup))

;; note, for some reason the mode directive does not work here, so I
;; added the typescript mode explicitly to tsx files.
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . typescript-mode))

(use-package json-snatcher
  :hook ((js-mode-hook . js-mode-bindings)
         (js2-mode-hook . js-mode-bindings))
  :bind (("C-C C-g" . jsons-print-path)))

;; -------------------------------------------------------------------
;; Plantuml mode
;; -------------------------------------------------------------------

(defun ff/plantuml-create-svg (source_filename)
  "Create SVG from current puml file.
SOURCE_FILENAME: filename to the puml file."
  (interactive)
  (message (concat "Converting " source_filename))
  (call-process-shell-command (concat
                               "java -jar "
                               plantuml-jar-path
                               source_filename
                               " -tsvg -charset utf-8"))
  (message "Conversion succeeded."))

(use-package plantuml-mode
  :ensure-system-package (dot . graphviz)
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  ;; Consider using (plantuml-download-jar) as alternative
  (defvar plantuml-version "1.2021.16" "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-jar-asl-" plantuml-version) "Name of plantuml executable")
  (defvar plantuml-url
    (concat "https://sourceforge.net/projects/plantuml/files/" plantuml-version "/" plantuml-name ".zip/download")
    "URL to download plantuml from sourceforge.")
  (defvar plantuml-extract-to (expand-file-name (concat "~/opt/plantuml/" plantuml-name))
    "DEstination of plantuml binaries")
  (defvar plantuml-expected-binary (concat plantuml-extract-to "/plantuml.jar")
    "Path to java archive of plantuml.")
  (ff/download-and-extract-zip-archive plantuml-url
                                       plantuml-name
                                       plantuml-extract-to
                                       plantuml-expected-binary
                                       "plantuml")
  :config
  ;; Sample jar configuration
  (setq plantuml-jar-path plantuml-expected-binary
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

(use-package groovy-imports)

;; -------------------------------------------------------------------
;; Java mode
;; -------------------------------------------------------------------
(use-package lsp-java
  :after lsp-mode
  :hook ((java-mode . lsp)))

;; -------------------------------------------------------------------
;; Json
;; -------------------------------------------------------------------
(use-package json-mode
  :ensure-system-package ((npm . npm)
                          (jsonlint . "sudo env \"PATH=$PATH\" npm install jsonlint -g"))
  :mode (("\\.json$" . json-mode)))

;; -------------------------------------------------------------------
;; Jinja2 mode for code generation
;; -------------------------------------------------------------------
(use-package jinja2-mode
  :mode ("\\.j2\\'" "\\.jinja2\\'"))

(provide 'programming-settings)

;;; programming-settings.el ends here
