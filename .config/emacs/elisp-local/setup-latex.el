;;; setup-latex.el --- Latex setup

;;; Commentary:
;; all the configuration for Latex projects

;;; Code:

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
  :magic ("%PDF" . pdf-view-mode)
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
  :hook (pdf-view-mode . pdf-isearch-minor-mode)
  :bind (:map LaTeX-mode-map
              ("C-c C-a" . pdf-sync-forward-search)
              :map tex-mode-map
              ("C-c C-a" . pdf-sync-forward-search)
              ;; Run C-Mouse 1 for inverse search in pdf buffer
              :map pdf-view-mode-map
              ("C-s" . isearch-forward)))

(provide 'setup-latex)

;;; setup-latex.el ends here
