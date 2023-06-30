;;; ff-organize-life --- Set up Org-Mode
;;; Commentary:
;;; Sets up org-mode for Emacs

;;; Code:
;; -------------------------------------------------------------------
;; Org
;; -------------------------------------------------------------------

(use-package org
  :hook (;; clocking
         (org-timer-set . org-clock-in))
  :custom
  ((org-directory "~/workspace/org")
   (org-agenda-files `(,(expand-file-name "notes" org-directory)
                       ,(expand-file-name "daily" org-directory)))
   (org-agenda-start-with-log-mode t)
   (org-log-done 'time)
   (org-log-into-drawer t)
   (org-babel-python-command "/usr/bin/python3")))

(with-eval-after-load 'org
  (require 'org-indent)
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("cc" . "src c++"))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)))
    (push '("conf-unix" . conf-unix) org-src-lang-modes))

;; Allow drag and drop into Dired. For details, see enables
;; https://github.com/abo-abo/org-download
(use-package org-download
  :after org
  :bind (:map org-mode-map
              (("s-Y" . org-download-screenshot)
               ("s-y" . org-download-yank))))

;; -------------------------------------------------------------------
;; Org modern: nice fonts, colors, etc.
;; -------------------------------------------------------------------
(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :custom
  (;; Edit settings
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
    "⭠ now ─────────────────────────────────────────────────")))

;; -------------------------------------------------------------------
;; org-present
;; -------------------------------------------------------------------
(defun dw/org-present-prepare-slide ()
  (org-overview)
  (org-show-entry)
  (org-show-children))

(defun dw/org-present-hook ()
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
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil)
  (org-present-small)
  (org-remove-inline-images)
  (org-appear-mode 1))

(defun dw/org-present-prev ()
  (interactive)
  (org-present-prev)
  (dw/org-present-prepare-slide))

(defun dw/org-present-next ()
  (interactive)
  (org-present-next)
  (dw/org-present-prepare-slide))

(use-package org-appear)

(use-package org-present
  :after org-appear
  :hook ((org-present-mode . dw/org-present-hook)
         (org-present-mode . visual-line-mode)
         (org-present-mode-quit . dw/org-present-quit-hook))
  :bind (:map org-present-mode-keymap
              ("C-c C-f" . dw/org-present-next)
              ("C-c C-b" . dw/org-present-prev)))

;; -------------------------------------------------------------------
;; Org-roam: Taking notes
;; -------------------------------------------------------------------
(use-package org-roam
  :after org
  :custom ((org-roam-directory (expand-file-name "notes" org-directory))
           (org-roam-node-display-template
            (concat "${title:*} "
                    (propertize "${tags:10}" 'face 'org-tag)))
           (org-roam-database-connector 'sqlite-builtin)
           (org-roam-completion-everywhere t)
           ;; org-roam-dailies
           (org-roam-dailies-directory "~/workspace/org/daily")
           (org-roam-db-gc-threshold most-positive-fixnum))
  :init
  (org-roam-db-autosync-mode t)
  :config
  ;; templates
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n"))))
  ;; display buffer
  (add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer))))


(with-eval-after-load 'org-roam
  ;; better support for roam files, when using org-export
  (require 'org-roam-export))


(use-package vulpea)

(with-eval-after-load 'vulpea
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12(vulpea-agenda-category)%?-12t% s")
          (todo . " %i %-12(vulpea-agenda-category) ")
          (tags . " %i %-12(vulpea-agenda-category) ")
          (search . " %i %-12(vulpea-agenda-category) ")))

  (defun vulpea-agenda-category (&optional len)
    "Get category of item at point for agenda.

Category is defined by one of the following items:

- CATEGORY property
- TITLE keyword
- TITLE property
- filename without directory and extension

When LEN is a number, resulting string is padded right with
spaces and then truncated with ... on the right if result is
longer than LEN.

Usage example:

  (setq org-agenda-prefix-format
        '((agenda . \" %(vulpea-agenda-category) %?-12t %12s\")))

Refer to `org-agenda-prefix-format' for more information."
    (let* ((file-name (when buffer-file-name
                        (file-name-sans-extension
                         (file-name-nondirectory buffer-file-name))))
           (title (vulpea-buffer-prop-get "title"))
           (category (org-get-category))
           (result
            (or (if (and
                     title
                     (string-equal category file-name))
                    title
                  category)
                "")))
      (if (numberp len)
          (s-truncate len (s-pad-right len " " result))
        result))))

(provide 'ff-organize-life)

;;; ff-organize-life.el ends here
