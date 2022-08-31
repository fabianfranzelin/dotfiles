;;; package --- Set up Org-Roam mode
;;; Commentary:
;;; Sets up org-roam mode for Emacs

;;; Code:

(defvar dw/org-roam-project-template
  '("p" "project" plain "** TODO %?"
    :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                           "#+title: ${title}\n#+category: ${title}\n#+filetags: Project\n"
                           ("Tasks"))))

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (push arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun dw/org-roam-goto-month ()
  (interactive)
  (org-roam-capture- :goto (when (org-roam-node-from-title-or-alias (format-time-string "%Y-%B")) '(4))
                     :node (org-roam-node-create)
                     :templates '(("m" "month" plain "\n* Goals\n\n%?* Summary\n\n"
                                   :if-new (file+head "%<%Y-%B>.org"
                                                      "#+title: %<%Y-%B>\n#+filetags: Project\n")
                                   :unnarrowed t))))

(defun dw/org-roam-goto-year ()
  (interactive)
  (org-roam-capture- :goto (when (org-roam-node-from-title-or-alias (format-time-string "%Y")) '(4))
                     :node (org-roam-node-create)
                     :templates '(("y" "year" plain "\n* Goals\n\n%?* Summary\n\n"
                                   :if-new (file+head "%<%Y>.org"
                                                      "#+title: %<%Y>\n#+filetags: Project\n")
                                   :unnarrowed t))))

(defun dw/org-roam-capture-task ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Capture the new task, creating the project file if necessary
  (org-roam-capture- :node (org-roam-node-read
                            nil
                            (my/org-roam-filter-by-tag "Project"))
                     :templates (list dw/org-roam-project-template)))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

(defhydra dw/org-roam-jump-menu (:hint nil)
  "
  ^Dailies^        ^Capture^       ^Jump^
  ^^^^^^^^-------------------------------------------------
  _t_: today       _T_: today       _m_: current month
  _r_: tomorrow    _R_: tomorrow    _e_: current year
  _y_: yesterday   _Y_: yesterday   ^ ^
  _d_: date        ^ ^              ^ ^
  "
  ("t" org-roam-dailies-goto-today)
  ("r" org-roam-dailies-goto-tomorrow)
  ("y" org-roam-dailies-goto-yesterday)
  ("d" org-roam-dailies-goto-date)
  ("T" org-roam-dailies-capture-today)
  ("R" org-roam-dailies-capture-tomorrow)
  ("Y" org-roam-dailies-capture-yesterday)
  ("m" dw/org-roam-goto-month)
  ("e" dw/org-roam-goto-year)
  ("c" nil "cancel"))

(use-package org-roam
  :init
  (org-roam-db-autosync-mode)
  (my/org-roam-refresh-agenda-list)
  :config
  (setq org-roam-v2-ack t)
  (setq dw/daily-note-filename "%<%Y-%m-%d>.org"
        dw/daily-note-header "#+title: %<%Y-%m-%d %a>\n\n[[roam:%<%Y-%B>]]\n\n")

  :custom
  (org-roam-directory "~/workspace/org/")
  (org-roam-dailies-directory "journal/")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
        '(("d" "default" plain "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)))
  (org-roam-dailies-capture-templates
   `(("d" "default" entry
      "* %?"
      :if-new (file+head ,dw/daily-note-filename
                         ,dw/daily-note-header))
     ("t" "task" entry
      "* TODO %?\n  %U\n  %a\n  %i"
      :if-new (file+head+olp ,dw/daily-note-filename
                             ,dw/daily-note-header
                             ("Tasks"))
      :empty-lines 1)
     ("l" "log entry" entry
      "* %<%I:%M %p> - %?"
      :if-new (file+head+olp ,dw/daily-note-filename
                             ,dw/daily-note-header
                             ("Log")))
     ("j" "journal" entry
      "* %<%I:%M %p> - Journal  :journal:\n\n%?\n\n"
      :if-new (file+head+olp ,dw/daily-note-filename
                             ,dw/daily-note-header
                             ("Log")))
     ("m" "meeting" entry
      "* %<%I:%M %p> - %^{Meeting Title}  :meetings:\n\n%?\n\n"
      :if-new (file+head+olp ,dw/daily-note-filename
                             ,dw/daily-note-header
                             ("Log")))))

  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n d" . dw/org-roam-jump-menu/body)
         ("C-c n c" . org-roam-dailies-capture-today)
         ("C-c n t" . dw/org-roam-capture-task)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n I" . org-roam-insert-immediate)))

(provide 'setup-org-roam)

;;; setup-org-roam.el ends here
