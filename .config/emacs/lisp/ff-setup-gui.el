;;; ff-setup-gui.el --- Setup user interface

;;; Commentary:
;; Configuration for user interface

;;; Code:

;; set frame transparency and maximize frame by default
(set-frame-parameter (selected-frame) 'alpha '(98 . 98))
(add-to-list 'default-frame-alist '(alpha . (98 . 98)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

;; set cursor style to filled bar
(setq-default cursor-type 'box)

;; no splash screen
(setq inhibit-startup-screen t)

;; I want the current user name, the emacs version and the name of the
;; file I'm editing to be displayed in the title-bar.
(setq frame-title-format
      (list (getenv "USER") "@Emacs " emacs-version ": "
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; -------------------------------------------------------------------
;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; NOTE: The first time you load your configuration on a new machine,
;; you’ll need to run `M-x nerd-icons-install-fonts` so that mode
;; line icons display correctly.
(use-package nerd-icons
  :custom ((nerd-icons-font-family "Symbols Nerd Fonts Mono")))

(use-package nerd-icons-dired
  :hook
  ((dired-mode . nerd-icons-dired-mode)))

;; -------------------------------------------------------------------
;; Doom Color themes
(use-package doom-themes
  :custom
  ((doom-themes-enable-bold t)    ; if nil, bold is universally disabled
   (doom-themes-enable-italic t)) ; if nil, italics is universally disabled
  :config
  ;; Global settings (defaults)
  (load-theme 'doom-palenight t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  ;; Add frame borders and window dividers
  (modify-all-frames-parameters
   '((right-divider-width . 0)
     (internal-border-width . 0)))
  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background)))

;; -------------------------------------------------------------------
;; Use doom modeline
(use-package doom-modeline
  :custom
  ((doom-modeline-height 15)
   (doom-modeline-bar-width 6)
   (doom-modeline-modal-icon t)
   (doom-modeline-lsp t)
   (doom-modeline-github nil)
   (doom-modeline-mu4e nil)
   (doom-modeline-irc nil)
   (doom-modeline-minor-modes nil)
   (doom-modeline-persp-name nil)
   (doom-modeline-display-default-persp-name nil)
   (doom-modeline-persp-icon nil)
   (doom-modeline-buffer-file-name-style 'truncate-except-project)
   (doom-modeline-buffer-modification-icon t)
   (doom-modeline-major-mode-icon t)
   (doom-modeline-buffer-encoding nil)
   (doom-modeline-vcs-max-length 48))
  :init
  (doom-modeline-mode 1))

;; -------------------------------------------------------------------
;; Define font size and methods to adjust it on the fly
(set-face-attribute 'default nil :height 110) ;; default = 110

;; define functions that increase and decrease the font-size for the
;; whole frame globally
(defun ff/adjust-font-size-per-frame (increment)
  "Adjust the font size for all buffers in the current frame.
INCREMENT: Value of which the current font-size is changed"
  (interactive "P")
  (let ((current-height (face-attribute 'default :height)))
    (set-face-attribute 'default nil :height (+ current-height increment))))

(global-set-key (kbd "C-c +") #'(lambda() (interactive) (ff/adjust-font-size-per-frame 10)))
(global-set-key (kbd "C-c -") #'(lambda() (interactive) (ff/adjust-font-size-per-frame -10)))


;; Show number of lines in the left side of the buffer
(global-display-line-numbers-mode 1)

(dolist (mode '(term-mode-hook
                vterm-mode-hook
                compilation-mode-hook
                pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; show column numbers on the modeline
(column-number-mode 1)

;; enable visual line mode to truncate long line
(global-visual-line-mode t)

(dolist (mode '(proced-mode-hook))
  (add-hook mode (lambda () (visual-line-mode 0))))

;; -------------------------------------------------------------
;; present a nice dashboard on startup

(use-package page-break-lines)

(use-package dashboard
  :after (nerd-icons page-break-lines)
  :custom
  (;; Content is not centered by default. To center, set
   (dashboard-center-content t)
   ;; To disable shortcut "jump" indicators for each section, set
   (dashboard-show-shortcuts t)
   (dashboard-items '((projects . 5)
                      (agenda . 10)
                      (recents  . 5)))
   (dashboard-set-heading-icons t)
   (dashboard-set-file-icons t)
   (dashboard-set-init-info t)
   (dashboard-week-agenda t)
   (dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
   ;; Show dashboard for newly created frames
   (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
   ;; set the project backend to project.el
   (dashboard-projects-backend `project-el)
   (dashboard-icon-type `nerd-icons)
   ;; filter agenda entries
   (dashboard-match-agenda-entry "TODO=\"TODO\"|TODO=\"IN-PROGRESS\""))
  :config
  (dashboard-setup-startup-hook))

;; overwrite the agenda entry format so that the category gets
;; extracted from the title of the org file using my own function
;; instead of the builtin.
;;
;; Advice: Try to replace this by using
;; flet https://www.emacswiki.org/emacs/LocalFunctions
;; advices https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Functions.html
(defun dashboard-agenda-entry-format ()
  "Format agenda entry to show it on dashboard.
Also,it set text properties that latter are used to sort entries and perform different actions."
  (let* ((scheduled-time (org-get-scheduled-time (point)))
         (deadline-time (org-get-deadline-time (point)))
         (entry-timestamp (dashboard-agenda--entry-timestamp (point)))
         (entry-time (or scheduled-time deadline-time entry-timestamp))
         (item (org-agenda-format-item
                (dashboard-agenda--formatted-time)
                (dashboard-agenda--formatted-headline)
                (org-outline-level)
                (vulpea-agenda-category)
                (dashboard-agenda--formatted-tags)))
         (todo-state (org-get-todo-state))
         (item-priority (org-get-priority (org-get-heading t t t t)))
         (todo-index (and todo-state
                          (length (member todo-state org-todo-keywords-1))))
         (entry-data (list 'dashboard-agenda-file (buffer-file-name)
                           'dashboard-agenda-loc (point)
                           'dashboard-agenda-priority item-priority
                           'dashboard-agenda-todo-index todo-index
                           'dashboard-agenda-time entry-time)))
    (add-text-properties 0 (length item) entry-data item)
    item))

(provide 'ff-setup-gui)

;;; ff-setup-gui.el ends here
