;;; package --- Set up Org-Mode
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
   (org-agenda-files '("~/workspace/org/todos.org"))
   (org-agenda-start-with-log-mode t)
   (org-log-done 'time)
   (org-log-into-drawer t)
   (org-babel-python-command "/usr/bin/python3")))

(with-eval-after-load 'org
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes)

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
     (shell . t))))


;; Allow drag and drop into Dired. For details, see enables
;; https://github.com/abo-abo/org-download
(use-package org-download)

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
              ("C-c C-j" . dw/org-present-next)
              ("C-c C-k" . dw/org-present-prev)))

(provide 'setup-org-mode)

;;; setup-org-mode.el ends here
