;;; ff-write-documents.el --- Latex setup and other document writing tools -*- lexical-binding: t; -*-

;;; Commentary:
;; All the configuration for writing documents.  This includes Latex,
;; Restructured text, regular text, org, Markdown, etc.

;;; Code:

;; -------------------------------------------------------------------
;; markdown mode
;; -------------------------------------------------------------------
(use-package markdown-mode
  :custom
  ;; The default command for markdown (~markdown~), doesn't support tables
  ;; (e.g. GitHub flavored markdown). Pandoc does, so let's use that.
  (markdown-command "pandoc --from markdown --to html")
  (markdown-command-needs-filename t)
  :hook
  (markdown-mode . flyspell-mode))

;; configure auto format
(with-eval-after-load 'apheleia
  (add-hook 'markdown-mode-hook 'apheleia-mode)
  (setf (alist-get 'mdformat apheleia-formatters) '("mdformat" filepath))
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'mdformat))

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
  :mode
  ("\\.rst$" . rst-mode)
  ("\\.rest$" . rst-mode)
  ("\\.inc$" . rst-mode)
  :hook
  (rst-mode . pyvenv-mode) ;; enable support of virtual environments
  (rst-mode . ff/configure-rst-mode))

;; Check documentation
;; https://docs.esbon.io/en/release/lsp/reference/configuration.html#lsp-configuration
;; https://docs.esbon.io/en/esbonio-language-server-v0.16.4/lsp/getting-started.html?package-manager=conda
(with-eval-after-load 'eglot
  ;; Sphinx, rst-mode
  ;; make esbonio the default lsp server for rst-mode
  ;; currently only version 0.15 works
  (ff/ensure-python-package "esbonio==0.16.4" nil "esbonio")

  (defclass eglot-esbonio (eglot-lsp-server) ()
    :documentation "Esbonio Language Server.")

  (cl-defmethod eglot-initialization-options ((server eglot-esbonio))
    "Passes the initializationOptions required to run the server."
    `(:sphinx (:confDir "${workspaceRoot}"
                        :buildDir "${workspaceRoot}/build"
                        :srcDir "${confDir}" )
              :server (:logLevel "debug" :enableLivePreview t :enableScrollSync t)))

  (add-to-list 'eglot-server-programs
               `(rst-mode . (eglot-esbonio
                             "python3" "-m" "esbonio"))))

;; RST backend for org-export
(use-package ox-rst
  :after org)

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
  :after org
  :commands plantuml-preview
  :preface
  ;; install system dependencies
  (ff/ensure-apt-package "graphviz" "dot")
  ;; Consider using (plantuml-download-jar) as alternative
  :mode (("\\.puml" . plantuml-mode)
         ("\\.iuml" . plantuml-mode)
         ("\\.uml" . plantuml-mode))
  :init
  (defvar plantuml-version "1.2024.5"
    "Version number of plantuml binary")
  (defvar plantuml-name (concat "plantuml-" plantuml-version ".jar")
    "Name of plantuml executable")
  (defvar plantuml-url
    (format "https://github.com/plantuml/plantuml/releases/download/v%s/%s" plantuml-version plantuml-name)
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

  ;; plantuml setup for org-babel
  (customize-set-variable 'org-plantuml-jar-path plantuml-jar-path)
  (customize-set-variable 'org-plantuml-args plantuml-jar-args)

  :bind (:map plantuml-mode-map
              ("C-M-i" . plantuml-complete-symbol)
              ("C-c C-e" . (lambda() (interactive) (ff/plantuml-create-svg (buffer-file-name))))))

(use-package flycheck-plantuml
  :after (plantuml-mode flycheck)
  :commands (flycheck-plantuml-setup))

;; Graphviz mode
(use-package graphviz-dot-mode
  :preface
  (ff/ensure-apt-package "graphviz" "dot")
  :custom
  (graphviz-dot-indent-width 4))

;; -------------------------------------------------------------------
;; Latex
;; -------------------------------------------------------------------
(defun ff/straight--auctex-compile ()
  "Compile auctex package after it is cloned.

This is actually related to straight that downloads the sources directly
from github where generated Emacs Lisp libraries are not checked in but
rather generated on the fly.  See for details
https://github.com/radian-software/straight.el/issues/240"
  (let* ((auctex-package-dir (expand-file-name "straight/repos/auctex" straight-base-dir))
         (autogen-file (expand-file-name "autogen.sh" auctex-package-dir))
         (commands `(,autogen-file "make")))
    (when (file-exists-p autogen-file)
      (set-file-modes autogen-file #o755)
      (ff/straight--package-compile "auctex" commands))))

(use-package auctex
  :straight (:pre-build (ff/straight--auctex-compile))
  :commands LaTeX-mode
  :hook
  (LaTeX-mode . TeX-fold-mode)
  (LaTeX-mode . outline-minor-mode)
  :init
  ;; Let auctex open pdf files with pdf-tools
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t))

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
  :hook
  (reftex-mode . imenu-add-menubar-index)
  (LaTeX-mode . turn-on-reftex)
  (latex-mode . turn-on-reftex)
  (LaTeX-mode . reftex-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . TeX-PDF-mode)
  ;; Set index on document
  (with-eval-after-load . imenu-add-menubar-index))

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
            ;; define key for foward pdf search
            (define-key LaTeX-mode-map (kbd "C-c C-s") 'pdf-sync-forward-search)
            ;; Run C-Mouse 1 for inverse search in pdf buffer (pdf-view-mode)

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

(use-package texinfo
  :defines texinfo-section-list
  :commands texinfo-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.texi$" . texinfo-mode)))

;; -------------------------------------------------------------------
;; PDF-tools: Mainly used to display PDFs and to inverse and forward
;; jumps for Latex documents
;; -------------------------------------------------------------------
(defun ff/org-roam-capture-pdf-note ()
  (interactive)
  ;; make sure that citar-org-roam-mode is enabled
  (citar-org-roam-mode)
  (when (derived-mode-p 'pdf-view-mode)
    (let ((file-name-pdf (buffer-file-name)))
      ;; check whether there is an entry in the bibliography that
      ;; links to this file
      (if-let ((citekey (ff/find-citekey-for-pdf-file-name file-name-pdf)))
          ;; load a note with given citekey
          (progn
            (ff/citar-capture-org-roam-literature-note-for-entry citekey file-name-pdf (pdf-view-current-page)))
        ;; else: continue with a simple note
        (let* ((file-name-pdf (buffer-file-name))
               (file-name-pdf-relative (file-relative-name file-name-pdf (ff/citar-reference-notes-absolute-path)))
               (page (pdf-view-current-page))
               (author (read-string "Author: "))
               (title (read-string "Title: "))
               (citekey (read-string "Citation key: "))
               (bibtex-file (car citar-bibliography)))
          ;; write entry in global bibtex file
          (with-temp-buffer
            (goto-char (point-max))
            (insert (format "
@unpublished{%s,
  author = {%s},
  title  = {%s},
  file   = {:%s:PDF}
}" citekey author title (file-relative-name file-name-pdf (file-name-directory bibtex-file))))
            (write-region (point-min) (point-max) bibtex-file t))
          ;; then open org capture
          (ff/citar-capture-org-roam-literature-note-for-entry citekey file-name-pdf page))))))

(defun ff/org-roam-open-pdf-note ()
  (interactive)
  ;; make sure that citar-org-roam-mode is enabled
  (citar-org-roam-mode)
  (when (derived-mode-p 'pdf-view-mode)
    (let* ((file-name-pdf (file-relative-name (buffer-file-name) (ff/citar-reference-notes-absolute-path)))
           (note-filename (expand-file-name (format "%s.org" (file-name-base file-name-pdf))
                                            (ff/citar-reference-notes-absolute-path))))
      (if (file-exists-p note-filename)
          (org-open-file note-filename)
        (ff/org-roam-capture-pdf-note)))))

(use-package pdf-tools
  :custom
  (pdf-view-display-size 'fit-width)
  :init
  (pdf-tools-install t)  ; Standard activation command
  ;; With a recent auctex installation, you might want to put the
  ;; following somewhere in your dotemacs, which will revert the
  ;; PDF-buffer after the TeX compilation has finished.
  ;; https://github.com/politza/pdf-tools
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
  ;; set pdf-view-mode as default for pdf files
  (add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))
  (add-hook 'pdf-view-mode-hook #'pdf-isearch-minor-mode)
  (add-hook 'pdf-view-mode-hook #'pdf-sync-minor-mode)
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward)
              ("c c" . ff/org-roam-capture-pdf-note)
              ("c o" . ff/org-roam-open-pdf-note)))

;; restore positions of pdfs when reopened
(use-package pdf-view-restore
  :after pdf-tools
  :config
  (add-hook 'pdf-view-mode-hook 'pdf-view-restore-mode))

(provide 'ff-write-documents)

;;; ff-write-documents.el ends here
