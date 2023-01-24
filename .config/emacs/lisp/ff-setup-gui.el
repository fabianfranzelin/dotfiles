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

(dolist (mode '(org-mode-hook
                rst-mode-hook
                markdown-mode-hook
                term-mode-hook
                vterm-mode-hook
                compilation-mode-hook
                pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; show column numbers on the modeline
(column-number-mode 1)

;; enable visual line mode to truncate long line
(global-visual-line-mode t)

;; -------------------------------------------------------------
;; present a nice dashboard on startup

(use-package page-break-lines)

(use-package dashboard
  :after (all-the-icons page-break-lines)
  :custom
  (;; Content is not centered by default. To center, set
   (dashboard-center-content t)
   ;; To disable shortcut "jump" indicators for each section, set
   (dashboard-show-shortcuts t)
   (dashboard-items '((projects . 5)
                      (agenda . 5)
                      (recents  . 5)))
   (dashboard-set-heading-icons t)
   (dashboard-set-file-icons t)
   (dashboard-set-init-info t)
   (dashboard-week-agenda t)
   (dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
   ;; Show dashboard for newly created frames
   (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
   ;; set the project backend to project.el
   (dashboard-projects-backend `project-el))
  :config
  (dashboard-setup-startup-hook))

(provide 'ff-setup-gui)

;;; ff-setup-gui.el ends here
