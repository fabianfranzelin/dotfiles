;;; ff-organize-life --- Set up Org-Mode for Emacs -*- lexical-binding: t; -*-
;;; Commentary:
;;; Sets up org-mode for Emacs

;;; Code:
;; -------------------------------------------------------------------
;; Org
;; -------------------------------------------------------------------
(defun ff/create-folder-and-return (dir)
  "Create folder if it does not exist and return its name.
DIR: directory path"
  (unless (file-exists-p dir) (make-directory dir t))
  (expand-file-name dir))

(defun ff/org-switch-directory ()
  "Switch between personal and work org directory."
  (interactive)
  (when-let ((ff/org-directory
              (if (string= (f-filename org-directory) "org")
                  (expand-file-name "~/workspace/org_personal")
                (expand-file-name "~/workspace/org"))))
    (when (file-exists-p ff/org-directory)
      (customize-set-variable 'org-directory ff/org-directory)
      (customize-set-variable 'org-agenda-files `(,(expand-file-name "notes" org-directory)
                                                  ,(expand-file-name "notes/journal" org-directory)))
      (customize-set-variable 'org-roam-directory (expand-file-name "notes" org-directory))
      (customize-set-variable 'org-roam-dailies-directory (expand-file-name "journal" org-roam-directory))
      (customize-set-variable 'org-roam-db-location (expand-file-name "org-roam.db" org-roam-directory))
      (customize-set-variable 'org-cite-global-bibliography `(,(file-truename (expand-file-name "notes/bib/references.bib" org-directory))))
      (customize-set-variable 'citar-bibliography `(,(file-truename (expand-file-name "notes/bib/references.bib" org-directory))))
      (customize-set-variable 'citar-notes-paths `(,org-roam-directory))

      (customize-set-variable
       'org-agenda-custom-commands
       `(("d" "Dashboard"
          ((agenda "" ((org-deadline-warning-days 14)))
           (todo "NEXT"
                 ((org-agenda-overriding-header "Next Actions")
                  (org-agenda-max-todos nil)))
           (todo "WAIT"
                 ((org-agenda-overriding-header "Waiting for Action")
                  (org-agenda-max-todos nil)))
           (todo "TODO"
                 ((org-agenda-overriding-header "Unprocessed Inbox Tasks")
                  (org-agenda-files '(,(expand-file-name "inbox.org" org-roam-dailies-directory)))
                  (org-agenda-text-search-extra-files nil)))
           (alltodo "")))
         ("n" "Next Tasks"
          ((agenda "" ((org-deadline-warning-days 7)))
           (todo "NEXT"
                 ((org-agenda-overriding-header "Next Tasks")))))
         ("A" "Agenda and all TODOs"
          ((agenda "")
           (alltodo "")))))

      (org-roam-db-sync)
      (message "Update main org folder to %s" ff/org-directory))))

(use-package org
  :demand t
  :preface
  ;; for some reason, this is needed to make org-mode work
  (setq org-directory (ff/create-folder-and-return "~/workspace/org"))
  :hook
  ;; clocking
  (org-timer-set . org-clock-in)
  (org-babel-after-execute . org-display-inline-images)
  :custom
  (org-directory (ff/create-folder-and-return "~/workspace/org"))
  (org-agenda-files `(,(ff/create-folder-and-return (expand-file-name "notes" org-directory))
                      ,(ff/create-folder-and-return (expand-file-name "notes/journal" org-directory))))
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  ;; disable isearch when using org-goto
  (org-goto-auto-isearch nil)
  ;; use relative paths for links
  (org-link-file-path-type 'relative)
  ;; highlight latex
  (org-highlight-latex-and-related '(latex))
  :config
  (require 'org-indent)
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (customize-set-variable 'org-habit-graph-column 60)

  ;; org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (R . t)
     (org . t)
     (latex . t)
     (dot . t)
     (gnuplot . t)
     (plantuml . t)))
  (push '("conf-unix" . conf-unix) org-src-lang-modes)

  ;; do not ask each time whether a source block should be evaluated
  (customize-set-variable 'org-confirm-babel-evaluate nil)

  ;; yas-snippet
  (define-key org-mode-map (kbd "C-c C-y") 'yas-insert-snippet)
  :bind
  (:map global-map
        ("C-c C-x b" . ff/org-switch-directory)
        :map org-mode-map
        ;; disable these two keys since they are taken by zoom-frm
        ("C-c +" . nil)
        ("C-c -" . nil)))

;; use pdf-tools for org links
(use-package org-pdfview
  :after org
  :config
  (add-to-list 'org-file-apps
               '("\\.pdf\\'" . (lambda (file link)
                                 (org-pdfview-open link)))))

;; Allow drag and drop into Dired. For details, see enables
;; https://github.com/abo-abo/org-download
(use-package org-download
  :after org
  :hook
  ;; enables drag-and-drop in dired
  (dired-mode . org-download-enable)
  :custom
  (org-download-method 'directory)
  (org-download-image-org-width 600)
  :bind
  (:map org-mode-map
        ("C-c C-x Y" . org-download-screenshot)
        ("C-c C-x y" . org-download-yank)))

(use-package toc-org
  :after (org markdown-mode)
  :hook
  (org-mode . toc-org-mode)
  (markdown-mode . toc-org-mode))

;; -------------------------------------------------------------------
;; Org modern: nice fonts, colors, etc.
;; -------------------------------------------------------------------
(use-package org-modern
  :hook
  (org-agenda-finalize . org-modern-agenda)
  :custom
  ;; Edit settings
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)

  ;; Org styling, hide markup etc.
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis "…")

  ;; Agenda styling
  (org-agenda-block-separator ?─)
  (org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
  (org-agenda-current-time-string
   "⭠ now ─────────────────────────────────────────────────"))

;; -------------------------------------------------------------------
;; org-present
;; -------------------------------------------------------------------
(defun dw/org-present-prepare-slide ()
  "Present and prepare slide."
  (org-overview)
  (org-show-entry)
  (org-show-children))

(defun dw/org-present-hook ()
  "Hook for org-present-mode."
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 4.5) variable-pitch)
                                     (org-document-title (:height 1.75) org-document-title)
                                     (org-code (:height 1.55) org-code)
                                     (org-verbatim (:height 1.55) org-verbatim)
                                     (org-block (:height 1.25) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))
  (setq header-line-format " ")
  (org-appear-mode -1)
  (org-display-inline-images)
  (dw/org-present-prepare-slide))

(defun dw/org-present-quit-hook ()
  "Undo change made by `dw/org-present-hook'."
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil)
  (org-present-small)
  (org-remove-inline-images)
  (org-appear-mode 1))

(defun dw/org-present-prev ()
  "Go to previous slide."
  (interactive)
  (org-present-prev)
  (dw/org-present-prepare-slide))

(defun dw/org-present-next ()
  "Go to next slide."
  (interactive)
  (org-present-next)
  (dw/org-present-prepare-slide))

(use-package org-appear
  :after org)

(use-package org-present
  :after org-appear
  :hook
  (org-present-mode . dw/org-present-hook)
  (org-present-mode . visual-line-mode)
  (org-present-mode-quit . dw/org-present-quit-hook)
  :bind
  (:map org-present-mode-keymap
        ("C-c C-f" . dw/org-present-next)
        ("C-c C-b" . dw/org-present-prev)))

;; -------------------------------------------------------------------
;; Org-roam: Taking notes
;; -------------------------------------------------------------------
(defun ff/configure-org-roam-mode ()
  "Configure org-roam-mode."
  (set (make-local-variable 'completion-at-point-functions)
       '(citar-capf
         pcomplete-completions-at-point
         cape-dabbrev
         cape-dict)))

(use-package org-roam
  :after org
  :demand t
  :preface
  (setq org-roam-directory (expand-file-name "notes" org-directory))
  (setq org-roam-dailies-directory (expand-file-name "journal" org-roam-directory))
  :hook
  (org-mode . ff/configure-org-roam-mode)
  :custom
  (org-roam-directory (expand-file-name "notes" org-directory))
  (org-roam-db-location (expand-file-name "org-roam.db" org-roam-directory))
  (org-roam-node-display-template
   (concat "${title:80}"
           (propertize "${tags:20}" 'face 'org-tag)
           "${category:15}"
           "${backlinkscount:6}"))
  (org-roam-database-connector 'sqlite-builtin)
  (org-roam-db-gc-threshold most-positive-fixnum)
  (org-roam-capture-templates
   '(("d" "default" plain
      "\n\n%?"
      :target (file+head "%<%Y%m%d%H%M>-${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t)
     ("l" "log entry" entry
      "\n\n* %<%I:%M %p> - Log\n %U\n %a\n %i\n%?"
      :target (file+head "%<%Y%m%d%H%M>-log.org"
                         "#+title: ${title}\n")
      :unarrowed t)
     ("s" "link notes" entry
      "\n\n* %<%I:%M %p> - Links\n %U\n %a\n %i\n** Description\n\n%?\n** Log Entries\n\n"
      :target (file+head "%<%Y%m%d%H%M>-link.org"
                         "#+title: ${title}\n")
      :unarrowed t)
     ("p" "project note" entry
      "\n\n* %?"
      :target (file+head "%<%Y%m%d%H%M>-${slug}.org"
                         "#+title: ${title}\n\n#+CATEGORY: Project\n#+filetags: :%^{project}:\n\n")
      :unarrowed t)
     ("t" "task" plain
      "* TODO ${title}\n%U\n\n%?"
      :target (file+head "journal/%<%Y%m%d%H%M>-${slug}.org"
                         "#+title: ${title} (%<%Y-%m-%d %a>)\n#+CATEGORY: Task\n\n")
      :unnarrowed t)
     ("m" "meeting" plain
      "* Participants\n\n+ Fabian Franzelin\n\n* Notes\n\n%?\n\n* Todos"
      :target (file+head "journal/%<%Y%m%d%H%M>-${slug}.org"
                         "#+title: ${title} (%<%Y-%m-%d %a>)\n#+CATEGORY: Meeting\n\n")

      :unarrowed t)))
  ;; org-roam-dailies
  (org-roam-dailies-directory (expand-file-name "journal" org-roam-directory))
  (org-roam-dailies-capture-templates
   '(("f" "fleeting note" plain
      "** TODO %^{Note title}\n %U\n %i\n%?"
      :target (file+head+olp "inbox.org"
                             "#+title: Inbox\n\n"
                             ("%(format-time-string \"%B, %d.%m\")"))
      :unarrowed t)
     ("w" "workday" plain
      "** %<[w%V] %a (%d.%m)> \n\n%?"
      :target (file+head+olp "clocking.org"
                             "#+title: Clocking\n\n"
                             ("%(format-time-string \"%B, %Y\")"))
      :unarrowed t)))
  :config
  ;; better support for roam files, when using org-export
  (require 'org-roam-export)
  ;; make sure that dailies are available
  (require 'org-roam-dailies)
  ;; enable autosync
  (org-roam-db-autosync-mode t)
  ;; display buffer
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.33)
                 (window-height . fit-window-to-buffer)))

  ;; show number of backlinks when searching for notes
  ;; https://github.com/org-roam/org-roam/wiki/User-contributed-Tricks
  (cl-defmethod org-roam-node-backlinkscount ((node org-roam-node))
    (let* ((count (caar (org-roam-db-query
                         [:select (funcall count source)
                                  :from links
                                  :where (= dest $s1)
                                  :and (= type "id")]
                         (org-roam-node-id node)))))
      (format "[%d]" count)))

  ;; use marginalia when searchinf for notes
  (with-eval-after-load 'marginalia
    (customize-set-variable 'org-roam-node-annotation-function (lambda (node) (marginalia--time (org-roam-node-file-mtime node)))))
  ;; create inbox file if it does not already exist
  (dolist (file-name `(,(expand-file-name "inbox.org" org-roam-dailies-directory)))
    (unless (file-exists-p file-name)
      (make-directory (file-name-directory file-name) t)
      (with-temp-buffer
        (write-file file-name))))
  :bind
  (:map global-map
        ("C-x n i" . org-roam-node-insert)
        ("C-x n c" . org-roam-capture)
        ("C-x n C" . org-roam-dailies-capture-today)
        ("C-x n f" . org-roam-node-find)
        ("C-x n t" . org-roam-buffer-toggle)
        ("C-x n a" . org-agenda)
        :map org-mode-map
        ("C-M-i" . completion-at-point)
        ("C-c C-x t" . org-roam-tag-add)))

(use-package org-roam-ui
  :custom
  (org-roam-ui-sync-theme t)
  (rg-roam-ui-follow-mode t)
  (org-roam-ui-browser-function 'browse-url-xdg-open)
  (org-roam-ui-open-on-start nil)
  (org-roam-ui-update-on-save t)
  :bind
  (:map global-map
        ("C-x n u" . org-roam-ui-open)))


(use-package consult-org-roam
  :after org-roam
  :custom
  ;; Use `ripgrep' for searching with `consult-org-roam-search'
  (consult-org-roam-grep-func #'consult-ripgrep)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers nil)
  :init
  ;; Activate the minor mode
  (consult-org-roam-mode 1)
  :bind
  (:map global-map
        ("C-x n g" . consult-org-roam-search)
        :map org-mode-map
        ("C-x n n" . consult-org-roam-backlinks)
        ("C-x n p" . consult-org-roam-forward-links)))

;; -------------------------------------------------------------------
;; Citations for org-files
;; -------------------------------------------------------------------
(use-package citeproc
  :after org)

(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("scrartcl"
                 "\\documentclass[letterpaper]{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(defun ff/citar-reference-notes-absolute-path ()
  "Load the absolute path to all literature notes."
  (concat org-roam-directory "/references"))

(use-package citar
  :after org-roam org
  :demand t
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup)
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (org-cite-global-bibliography `(,(file-truename (expand-file-name "notes/bib/references.bib" org-directory))))
  (citar-bibliography `(,(file-truename (expand-file-name "notes/bib/references.bib" org-directory))))
  (citar-notes-paths `(,org-roam-directory))
  (citar-at-point-function 'embark-act)
  :config
  (dolist (file-name (append citar-bibliography org-cite-global-bibliography))
    (unless (file-exists-p file-name)
      (make-directory (file-name-directory file-name) t)
      (with-temp-buffer
        (write-file file-name))))
  ;; optional: org-cite-insert is also bound to C-c C-x C-@
  :bind
  (:map global-map
        ("C-c c o" . citar-open)
        ("C-c c e" . citar-open-entry)
        ("C-c c f" . citar-open-files)
        :map org-mode-map :package org
        ("C-c c i" . org-cite-insert)))

(use-package citar-embark
  :after citar
  :hook
  (after-init . citar-embark-mode))

(defun ff/load-all-bibliography-pdf-file-entries ()
  "Load all bibliography entries that contain a pdf file as file link."
  (let ((all-entries-alist nil))
    (maphash (lambda (citekey files)
               (mapcar (lambda (file)
                         (when (string-equal (file-name-extension file) "pdf")
                           (add-to-list 'all-entries-alist `(,(file-name-nondirectory file) . ,citekey))))

                       files))
             (citar-get-files))
    all-entries-alist))

(defun ff/find-citekey-for-pdf-file-name (file-name)
  "Find the first citation key to which the current file is linked.
FILE-NAME: file name"
  (if file-name
      (cdr (assoc (file-name-nondirectory file-name)
                  (ff/load-all-bibliography-pdf-file-entries)))))

(defun ff/citar-get-pdf-file-name (&optional citekey)
  "Lookup a linked pdf file in the bibliography, if a citeky is given.
CITEKEY: citation key in bibliography"
  (let ((file-name-pdf nil))
    (cond ((derived-mode-p 'pdf-view-mode)
           (setq-local file-name-pdf (buffer-file-name)))
          (t
           ;; check whether the bibliography entry links to a pdf file
           (let ((citekey (or citekey
                              (citar-select-ref))))
             (maphash (lambda (key value)
                        (let ((file-name (car value)))
                          (when (string-equal (file-name-extension file-name) "pdf")
                            (setq-local file-name-pdf (car value)))))
                      (citar-get-files citekey)))))
    file-name-pdf))

(defun ff/citar-get-pdf-page-number ()
  "Get the page number to which the note refers."
  (if (derived-mode-p 'pdf-view-mode)
      (pdf-view-current-page))
  (read-number "Page: "))

(defun ff/citar-capture-org-roam-literature-note-for-entry (citekey &optional file-name-pdf file-page)
  "Capture a literature note with org-roam using citar as subsystem.
CITEKEY: citation key in bibtex
FILE-NAME-PDF: absolute path to the file to be annotated
FILE-PAGE: page at which the annotation refers to"
  (interactive)
  ;; load citation key and open capture buffer
  (let* ((file-name-pdf (or file-name-pdf (ff/citar-get-pdf-file-name citekey)))
         (file-page (or file-page (if file-name-pdf (ff/citar-get-pdf-page-number))))
         (file-name-pdf-relative (if file-name-pdf (file-relative-name file-name-pdf (ff/citar-reference-notes-absolute-path))))
         (heading (if (and file-name-pdf (file-exists-p file-name-pdf) file-page)
                      ;; make sure to have pdf-tools installed to make this work
                      (format "[[pdfview:%s::%d][Note (p. %03d)]]" file-name-pdf-relative file-page file-page)
                    (if file-page
                        ;; an actual page is available
                        (format "Note (p. %03d)" file-page)
                      ;; No pdf file at all is linked to the entry,
                      ;; so no further linking possible as of now
                      "Note")))
         (capture-heading (concat "\n* " heading "\n#+created: %U\n\n\%?"))
         (note-filename (expand-file-name (format "%s.org" citekey) (ff/citar-reference-notes-absolute-path)))
         (citekey-citar-entry (citar-get-entry citekey))
         (title (format "%s :: %s"
                        (cdr (assoc "author" citekey-citar-entry))
                        (cdr (assoc "title" citekey-citar-entry))))
         (note-header (concat "#+title: " title "\n"
                              (if file-name-pdf-relative
                                  (concat "#+document: " (format "[[file:%s]]\n" file-name-pdf-relative)))
                              "#+category: Literature\n"
                              "#+created: %U\n"
                              "#+last_modified: %U\n"
                              "\n")))
    (org-roam-capture- :node (org-roam-node-create)
                       :templates '(("n" "literature note" entry
                                     "${capture-heading}"
                                     :target (file+head
                                              "${note-filename}"
                                              "${note-header}")
                                     :empty-lines 1
                                     :unnarrowed t))
                       :info (list :capture-heading capture-heading
                                   :note-filename note-filename
                                   :note-header note-header
                                   :ref (format "@%s" citekey)))))

(defun ff/org-roam-capture-literature-note ()
  "Capture a literature note for a specific document."
  (interactive)
  ;; load citation key and open capture buffer
  (let* ((citekey (or (ff/find-citekey-for-pdf-file-name (buffer-file-name))
                      (citar-select-ref))))
    (ff/citar-capture-org-roam-literature-note-for-entry citekey)))

(defun ff/org-roam-open-literature-note ()
  "Open a literature note for a specific document."
  (interactive)
  ;; load citation key and open capture buffer
  (let* ((citekey (or (ff/find-citekey-for-pdf-file-name (buffer-file-name))
                      (citar-select-ref)))
         (note-filename (expand-file-name (format "%s.org" citekey)
                                          (ff/citar-reference-notes-absolute-path))))
    (if (file-exists-p note-filename)
        (org-open-file note-filename)
      (ff/citar-capture-org-roam-literature-note-for-entry citekey))))

(use-package citar-org-roam
  :after org-roam
  :commands citar-org-roam-mode
  :hook
  (after-init . citar-org-roam-mode)
  :bind
  (:map global-map
        ("C-x n l" . ff/org-roam-capture-literature-note)
        ("C-x n o" . ff/org-roam-open-literature-note)))

;; -------------------------------------------------------------------
;; Organizing tasks and agenda
;; https://config.daviwil.com/workflow
;; -------------------------------------------------------------------

(with-eval-after-load 'org-roam
  ;; Todo types
  ;;     TODO - A task that should be done at some point
  ;;     NEXT - This task should be done next (in the Getting Things Done sense)
  ;;     WAIT - Waiting for someone else to be actionable again
  ;;     DONE - It's done!
  (customize-set-variable
   'org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d!)" "DISCARD(c)")))

  (customize-set-variable
   'org-todo-keyword-faces
   '(("NEXT" . (:foreground "orange red" :weight bold))
     ("WAIT" . (:foreground "HotPink2" :weight bold))))

  ;; Customize org-agenda
  (customize-set-variable 'org-agenda-window-setup 'current-window)
  (customize-set-variable 'org-agenda-span 'week)
  (customize-set-variable 'org-agenda-start-with-log-mode t)

  ;; Make done tasks show up in the agenda log
  (customize-set-variable 'org-log-done 'time)
  (customize-set-variable 'org-log-into-drawer t)

  (customize-set-variable
   'org-columns-default-format
   "%20CATEGORY(Category) %65ITEM(Task) %TODO %6Effort(Estim){:}  %6CLOCKSUM(Clock) %TAGS")

  (customize-set-variable
   'org-agenda-custom-commands
   `(("d" "Dashboard"
      ((agenda "" ((org-deadline-warning-days 14)))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Actions")
              (org-agenda-max-todos nil)))
       (todo "WAIT"
             ((org-agenda-overriding-header "Waiting for Action")
              (org-agenda-max-todos nil)))
       (todo "TODO"
             ((org-agenda-overriding-header "Unprocessed Inbox Tasks")
              (org-agenda-files '(,(expand-file-name "inbox.org" org-roam-dailies-directory)))
              (org-agenda-text-search-extra-files nil)))
       (alltodo "")))
     ("n" "Next Tasks"
      ((agenda "" ((org-deadline-warning-days 7)))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Tasks")))))
     ("A" "Agenda and all TODOs"
      ((agenda "")
       (alltodo ""))))))

(provide 'ff-organize-life)

;;; ff-organize-life.el ends here
