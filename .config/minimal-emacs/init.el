;;; init.el --- this file starts here

;;; Commentary:
;;; Code:

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)
;; (package-refresh-contents)

;; -------------------------------------------------------------------
;; Before we do anything, set up the no littering package
(package-install 'no-littering)

(use-package no-littering
  :custom
  (custom-file (no-littering-expand-etc-file-name "custom.el"))
  :init
  ;; setup a new custom file and load it
  (load custom-file t)
  :config
  ;; this sets the path right for undo-tree, auto-save and backup files
  (no-littering-theme-backups))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Core                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq user-full-name "Fabian Franzelin"
      user-mail-address "fabian.franzelin@de.bosch.com"
      inhibit-startup-echo-area-message (getenv "USER"))

;; enables local variables per default
(customize-set-variable 'enable-local-variables t)

;; dont warn for following symlinked files
(setq vc-follow-symlinks t)

;; disable lockfiles
(setq create-lockfiles nil)

;; define alias for yes-or-no decision
(defalias 'yes-or-no-p 'y-or-n-p)

;; Support wheel mouse scrolling
(mouse-wheel-mode t)

;; set unicode encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Iterate through CamelCase
(global-subword-mode t)

;; enable auto pair mode globally
(electric-pair-mode t)
(electric-indent-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

;; set cursor style to filled bar
(setq-default cursor-type 'box)

;; no splash screen
(setq inhibit-startup-screen t)

;; -------------------------------------------------------------------
(package-install 'doom-themes)
(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)    ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  ;; Global settings (defaults)
  (load-theme 'doom-palenight t)
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
(package-install 'vertico)
(use-package vertico
  :custom
  (vertico-count 10)
  (vertico-cycle t)
  :init
  (vertico-mode t)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  :config
  (custom-set-faces '(vertico-current ((t (:background "#3a3f5a")))))
  :bind (:map vertico-map
              ("C-f" . vertico-exit)
              ("C-j" . vertico-exit-input)
              :map minibuffer-local-map
              ("C-l" . ff/minibuffer-backward-kill)
              ("C-a" . (lambda() (interactive) (ff/minibuffer-move-to-dir "/")))
              ("C-o" . (lambda() (interactive) (ff/minibuffer-move-to-dir "~/")))))

;; -------------------------------------------------------------------
(use-package dired
  :ensure nil
  :custom
  (dired-auto-revert-buffer nil) ; Auto update when buffer is revisited
  (dired-dwim-target t)
  (dired-recursive-deletes 'always)
  (dired-recursive-copies 'always)
  (delete-by-moving-to-trash t)
  (dired-listing-switches "-agho --group-directories-first")
  (dired-hide-details-hide-symlink-targets nil)
  :init
  (require 'dired-x)
  (autoload 'dired-omit-mode "dired-x")
  :hook
  (dired-mode . auto-revert-mode)
  (dired-mode . dired-hide-details-mode)
  (dired-mode . hl-line-mode)
  ;; enables drag-and-drop in dired
  (dired-mode . org-download-enable)
  :bind
  (("C-x C-j" . dired-jump)
   :map dired-mode-map
   ("l" . dired-up-directory)
   ("TAB" . dired-find-file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Version control           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(package-install 'magit)
(use-package magit
  :commands magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  ;; Show word based diff
  (magit-diff-refine-hunk 'all))

;; -------------------------------------------------------------------

(provide 'init)

;;; init.el ends here
