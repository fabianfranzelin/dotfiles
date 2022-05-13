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
  :ensure nil
  :after (cape)
  :hook ((text-mode . ff/configure-text-mode)))

;; -------------------------------------------------------------------
;; Emacs lisp
;; -------------------------------------------------------------------
;; enable rainbow delimiters for emacs lisp
(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)))

;; -------------------------------------------------------------------
;; C/C++
;; -------------------------------------------------------------------
(use-package setup-cc
  :load-path local-load-path)

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
  :ensure-system-package ((yamllint . "python3 -m pip install -U 'yamllint'"))
  :mode (("\\.yml$" . yaml-mode)
         ("\\.yaml$" . yaml-mode))
  :bind ((:map yaml-mode-map
               ("C-m" . newline-and-indent))))

;; -------------------------------------------------------------------
;; dockerfile mode
;; -------------------------------------------------------------------
(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode))
  :init
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

  ;; add new entry to transient of docker package
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
  :ensure-system-package ((markdown . "sudo apt install markdown -y")
                          (pandoc . "sudo apt install pandoc -y")
                          (mdformat . "python3 -m pip install mdformat"))
  :custom
  ;; The default command for markdown (~markdown~), doesn't support tables
  ;; (e.g. GitHub flavored markdown). Pandoc does, so let's use that.
  ((markdown-command "pandoc --from markdown --to html")
   (markdown-command-needs-filename t))
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
  :after (dap-node)
  :config
  (setq typescript-indent-level 4)
  (dap-node-setup))

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
  :ensure-system-package ((dot . "sudo apt install graphviz -y")
                          (unzip . "sudo apt install unzip -y"))
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  ;; Consider using (plantuml-download-jar) as alternative
  (defvar plantuml-version "1.2022.2" "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-jar-asl-" plantuml-version) "Name of plantuml executable")
  (defvar plantuml-url
    (concat "https://sourceforge.net/projects/plantuml/files/" plantuml-version "/" plantuml-name ".zip/download")
    "URL to download plantuml from sourceforge.")
  (defvar plantuml-root (expand-file-name "opt/plantuml" (getenv "HOME")))
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
(use-package lsp-java
  :after (lsp-mode)
  :hook ((java-mode . lsp)))

(use-package dap-java
  :ensure nil)

;; -------------------------------------------------------------------
;; Json
;; -------------------------------------------------------------------
(use-package json-mode
  :ensure-system-package ((npm . "sudo apt install npm -y")
                          (jsonlint . "npm install jsonlint -g"))
  :mode (("\\.json$" . json-mode)))

;; -------------------------------------------------------------------
;; Jinja2 mode for code generation
;; -------------------------------------------------------------------
(use-package jinja2-mode
  :mode ("\\.j2\\'" "\\.jinja2\\'"))

(provide 'programming-settings)

;;; programming-settings.el ends here
