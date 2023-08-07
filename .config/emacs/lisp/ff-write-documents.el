;;; ff-write-documents.el --- Latex setup

;;; Commentary:
;; All the configuration for writing documents.  This includes Latex,
;; Restructured text, regular text, org, Markdown, etc.

;;; Code:

;; -------------------------------------------------------------------
;; markdown mode
;; -------------------------------------------------------------------
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

  :hook ((markdown-mode . flyspell-mode))
  :bind (:map markdown-mode-map
              ("C-c C-f" . ff/run-mdformat)))

;; -------------------------------------------------------------------
;; Simple text
;; -------------------------------------------------------------------
(defun ff/configure-text-mode ()
  "Configure text mode."
  (interactive)
  (set (make-local-variable 'completion-at-point-functions)
       '(cape-dabbrev
         cape-dict)))

(add-hook 'text-mode #'ff/configure-text-mode)

;; -------------------------------------------------------------------
;; RST mode
;; -------------------------------------------------------------------
(defun ff/configure-rst-mode ()
  "Configure rst mode."
  (interactive)
  (set (make-local-variable 'completion-at-point-functions)
       '(cape-dabbrev
         cape-dict)))

(use-package rst
  :mode (("\\.rst$" . rst-mode)
         ("\\.rest$" . rst-mode)
         ("\\.inc$" . rst-mode))
  :init
  (ff/ensure-python-package "esbonio")
  :hook ((rst-mode . pyvenv-mode) ;; enable support of virtualenvironments
         (rst-mode . ff/configure-rst-mode)))

;; -------------------------------------------------------------------
;; Plantuml & Graphviz mode
;; -------------------------------------------------------------------
(defun ff/plantuml-create-svg (source_filename)
  "Create SVG from current puml file.
SOURCE_FILENAME: filename to the puml file."
  (interactive)
  (message "Converting %s" source_filename)
  (call-process-shell-command (concat
                               "java "
                               "-jar "
                               plantuml-jar-path " "
                               source_filename " "
                               (string-join plantuml-jar-args " ") " "
                               "-tsvg"))
  (message "Conversion succeeded."))

(defun ff/plantum-preview ()
  "First, delete the preview window if present, then compile puml file."
  (interactive)
  ;; delete current preview window if visible
  (when (get-buffer-window plantuml-preview-buffer)
    (delete-window (get-buffer-window plantuml-preview-buffer)))
  ;; run actual plantuml preview with 4=new frame setting
  (plantuml-preview 0))

(require 'url)
(defun ff/plantuml-download (url jar-path)
  "Download and install zip archives.

URL: download URL
JAR-PATH: expected binary file in the extracted folder."
  (let* ((jar-path-dir (file-name-directory jar-path)))
    (unless (file-directory-p jar-path-dir) (make-directory jar-path-dir t))
    (unless  (file-exists-p jar-path)
      (message (concat "[plantuml] Downloading to " jar-path))
      (url-copy-file url jar-path))))

(use-package plantuml-mode
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  ;; install system dependencies
  (ff/ensure-apt-package "graphviz" "dot")

  ;; Consider using (plantuml-download-jar) as alternative
  (defvar plantuml-version "1.2023.10"
    "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-" plantuml-version ".jar")
    "Name of plantuml executable")
  (defvar plantuml-url
    (concat "https://github.com/plantuml/plantuml/releases/download/v" plantuml-version "/" plantuml-name)
    "URL to download plantuml from github.")
  (defvar plantuml-path (expand-file-name "plantuml" no-littering-var-directory)
    "Directory where the plantuml jar file should be stored")
  (defvar plantuml-expected-binary (expand-file-name plantuml-name plantuml-path)
    "Path to java archive of plantuml.")
  (ff/plantuml-download plantuml-url plantuml-expected-binary)
  :config
  ;; Sample jar configuration
  (setq plantuml-jar-path plantuml-expected-binary
        plantuml-jar-args (list "-charset" "UTF-8" "-DRELATIVE_INCLUDE=\".\"" "-Djava.awt.headless=true")
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

;; Graphviz mode
(use-package graphviz-dot-mode
  :custom ((graphviz-dot-indent-width 4))
  :init (ff/ensure-apt-package "graphviz" "dot"))

;; -------------------------------------------------------------------
;; Latex
;; -------------------------------------------------------------------
(use-package auctex
  :hook ((LaTeX-mode . TeX-fold-mode)
         (LaTeX-mode . outline-minor-mode)))

(use-package reftex
  :config
  (setq reftex-enable-partial-scans t)
  (setq reftex-use-multiple-selection-buffers t)
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-save-parse-info t)
  (setq reftex-use-external-file-finders t)
  (setq reftex-external-file-finders
        '(("tex" . "kpsewhich -format=.tex %f")
          ("bib" . "kpsewhich -format=.bib %f")))

  (setq LaTeX-command "latex -synctex=1") ;; enable synctex
  :hook ((reftex-mode . imenu-add-menubar-index)
         (LaTeX-mode . turn-on-reftex)
         (latex-mode . turn-on-reftex)
         (LaTeX-mode . reftex-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . TeX-PDF-mode)
         ;; Set index on document
         (with-eval-after-load . imenu-add-menubar-index)
         ))

;; emacs RefTeX
;; (setq reftex-ref-macro-prompt nil) ; skips picking the reference style

(eval-after-load 'reftex-vars
  '(progn
     ;; (also some other reftex-related customizations)
     (setq reftex-cite-format
           '((?\C-m . "\\cite[]{%l}")
             (?a . "\\citeauthor[]{%l}") ;; Franzelin
             (?f . "\\footcite[][]{%l}") ;; \footnote{[FR05]}
             (?t . "\\textcite[]{%l}")   ;; Franzelin [FR05] (without link)
             (?o . "\\citet[]{%l}")      ;; Franzelin [FR05] (with link)
             (?p . "\\parencite[]{%l}")  ;; [Franzelin, 2015] (without link)
             (?o . "\\citep[]{%l}")      ;; [Franzelin, 2015] (with link)
             (?n . "\\nocite{%l}")))))

(eval-after-load
    "latex"
  '(TeX-add-style-hook
    "cleveref"
    (lambda ()
      (if (boundp 'reftex-ref-style-alist)
          (add-to-list
           'reftex-ref-style-alist
           '("Cleveref" "cleveref"
             (("\\cref" ?c) ("\\Cref" ?C) ("\\cpageref" ?d) ("\\Cpageref" ?D)))))
      (reftex-ref-style-activate "Cleveref")
      (TeX-add-symbols
       '("cref" TeX-arg-ref)
       '("Cref" TeX-arg-ref)
       '("cpageref" TeX-arg-ref)
       '("Cpageref" TeX-arg-ref)))))

;; Do not ask to save before compile
(setq compilation-ask-about-save nil)

;; Always scroll the compilation output buffer until the first error
;; appears
(setq compilation-scroll-output 'firsterror)

;; add make, scons and latexmk commands as tex build commands
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (add-to-list 'TeX-command-list
                         '("Make" "make" TeX-run-TeX nil t :help "Runs make") t)
            (add-to-list 'TeX-command-list
                         '("Scons" "scons" TeX-run-TeX nil t :help "Runs scons") t)
            (add-to-list 'TeX-command-list
                         '("latexmk" "latexmk -pdf" TeX-run-TeX nil t :help "Runs latexmk") t)))
;; -------------------------------------------------------------------
;; add new environment types to auctex
;; http://www.gnu.org/software/auctex/manual/auctex/Adding-Environments.html
;; -------------------------------------------------------------------

;; -------------------------------------------------------------------
;; PDF-tools: Mainly used to display PDFs and to inverse and forward
;; jumps for Latex documents
;; -------------------------------------------------------------------
(use-package pdf-tools
  :after (auctex)
  :custom
  (pdf-view-display-size 'fit-width)
  :init
  (pdf-tools-install)  ; Standard activation command
  (pdf-loader-install) ; On demand loading, leads to faster startup time
  ;; With a recent auctex installation, you might want to put the
  ;; following somewhere in your dotemacs, which will revert the
  ;; PDF-buffer after the TeX compilation has finished.
  ;; https://github.com/politza/pdf-tools
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
  ;; Let auctex open pdf files with pdf-tools
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t)

  (add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))
  :hook
  (pdf-view-mode . pdf-isearch-minor-mode)
  :bind (:map LaTeX-mode-map
              ("C-c C-a" . pdf-sync-forward-search)
              :map tex-mode-map
              ("C-c C-a" . pdf-sync-forward-search)
              ;; Run C-Mouse 1 for inverse search in pdf buffer
              :map pdf-view-mode-map
              ("C-s" . isearch-forward)))

(provide 'ff-write-documents)

;;; ff-write-documents.el ends here
