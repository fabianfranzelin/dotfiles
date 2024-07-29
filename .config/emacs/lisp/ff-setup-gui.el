;;; ff-setup-gui.el --- Setup user interface -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for user interface

;;; Code:

;; set frame transparency and maximize frame by default
(set-frame-parameter (selected-frame) 'alpha '(100 . 100))
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; disable scrollbar
(scroll-bar-mode -1) ; disbale scrollbar
(menu-bar-mode -1) ; disable menu bar
(tool-bar-mode -1) ; disbale tool bar

;; set cursor style to filled bar
(customize-set-variable 'cursor-type 'box)

;; no splash screen
(customize-set-variable 'inhibit-startup-screen t)

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
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono")
  :config
  ;; For some reason, the scheme icons do not work and slow down Emacs
  ;; significantly. Hence, I just use the Emacs icons here for common
  ;; lisp files.
  (add-to-list 'nerd-icons-extension-icon-alist '("lisp" nerd-icons-sucicon "nf-custom-emacs" :face nerd-icons-purple)))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode t)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; -------------------------------------------------------------
;; present a nice dashboard on startup
(use-package grid
  :straight (:host github :repo "ichernyshovvv/grid.el"))

(use-package enlight
  :straight (:host github :repo "ichernyshovvv/enlight")
  :preface
  (defface ff/enlight-yellow-bold
    '((t (:foreground "#cabf00" :bold t)))
    "Yellow bold face")

  (defvar ff/enlight-guix
    (propertize
     " ..                             `.
 `--..```..`           `..```..--`
   .-:///-:::.       `-:::///:-.
      ````.:::`     `:::.````
           -//:`    -::-
            ://:   -::-
            `///- .:::`
             -+++-:::.
              :+/:::-
              `-....`                "
     'face 'ff/enlight-yellow-bold))

  (defun ff/enlight-menu-creator (entries fun)
    "Creates a menu of projects if available.
ENTRIES-LIST: list of entries that contains (name, path, shortcut), all as strings
FUN: function to be called on the entry's path"
    (delq nil
          (mapcar (lambda (entry)
                    (if (stringp entry)
                        entry
                      (let ((name (car entry))
                            (path (car (cdr entry)))
                            (shortcut (car (cdr (cdr entry)))))
                        (when (file-exists-p path)
                          `(,name (,fun ,path) ,shortcut)))))
                  entries)))
  :custom
  (initial-buffer-choice #'enlight)
  (enlight-content
   (concat
    (grid-get-box `(
                    :align center
                    :content ,ff/enlight-guix
                    :width 100))
    (grid-get-box `(
                    :align center
                    :content ,(concat
                               "\n\n\n"
                               (enlight-menu
                                `(("Org"
                                   ("Org-Agenda (dashboard)" (org-agenda nil "d") "A"))
                                  ,(ff/enlight-menu-creator
                                    '("Projects"
                                      ("Dotfiles" "~/workspace/dotfiles" "d")
                                      ("Org" "~/workspace/org" "o")
                                      ("Org (personal)" "~/workspace/org_personal" "p")
                                      ("AOS" "~/workspace/aos" "a"))
                                    #'ff/project-switch-project)
                                  ,(ff/enlight-menu-creator
                                    '("Folders"
                                      ("Home" "~" "h")
                                      ("Workspace" "~/workspace" "w")
                                      ("Downloads" "~/Downloads" "D"))
                                    #'dired))))
                    :width 100)))))

;; -------------------------------------------------------------------
;; Doom Color themes
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
;; Use doom modeline
(use-package doom-modeline
  :hook
  (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 15)
  (doom-modeline-bar-width 6)
  (doom-modeline-icon t)
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

;; -------------------------------------------------------------------
;; Define font size and methods to adjust it on the fly
(set-face-attribute 'default nil :height 100) ;; default = 100

;; Show number of lines in the left side of the buffer
(global-display-line-numbers-mode 1)

(dolist (mode '(term-mode-hook
                vterm-mode-hook
                dired-mode-hook
                compilation-mode-hook
                pdf-view-mode-hook
                enlight-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; show column numbers on the modeline
(column-number-mode 1)

;; enable visual line mode to truncate long line
(global-visual-line-mode t)

(dolist (mode '(proced-mode-hook))
  (add-hook mode (lambda () (visual-line-mode 0))))

;; Icons for corfu completion
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  ;; use nerd-icons
  (kind-icon-use-icons nil)
  (kind-icon-mapping
   `((array ,(nerd-icons-codicon "nf-cod-symbol_array") :face font-lock-type-face)
     (boolean ,(nerd-icons-codicon "nf-cod-symbol_boolean") :face font-lock-builtin-face)
     (class ,(nerd-icons-codicon "nf-cod-symbol_class") :face font-lock-type-face)
     (color ,(nerd-icons-codicon "nf-cod-symbol_color") :face success)
     (command ,(nerd-icons-codicon "nf-cod-terminal") :face default)
     (constant ,(nerd-icons-codicon "nf-cod-symbol_constant") :face font-lock-constant-face)
     (constructor ,(nerd-icons-codicon "nf-cod-triangle_right") :face font-lock-function-name-face)
     (enummember ,(nerd-icons-codicon "nf-cod-symbol_enum_member") :face font-lock-builtin-face)
     (enum-member ,(nerd-icons-codicon "nf-cod-symbol_enum_member") :face font-lock-builtin-face)
     (enum ,(nerd-icons-codicon "nf-cod-symbol_enum") :face font-lock-builtin-face)
     (event ,(nerd-icons-codicon "nf-cod-symbol_event") :face font-lock-warning-face)
     (field ,(nerd-icons-codicon "nf-cod-symbol_field") :face font-lock-variable-name-face)
     (file ,(nerd-icons-codicon "nf-cod-symbol_file") :face font-lock-string-face)
     (folder ,(nerd-icons-codicon "nf-cod-folder") :face font-lock-doc-face)
     (interface ,(nerd-icons-codicon "nf-cod-symbol_interface") :face font-lock-type-face)
     (keyword ,(nerd-icons-codicon "nf-cod-symbol_keyword") :face font-lock-keyword-face)
     (macro ,(nerd-icons-codicon "nf-cod-symbol_misc") :face font-lock-keyword-face)
     (magic ,(nerd-icons-codicon "nf-cod-wand") :face font-lock-builtin-face)
     (method ,(nerd-icons-codicon "nf-cod-symbol_method") :face font-lock-function-name-face)
     (function ,(nerd-icons-codicon "nf-cod-symbol_method") :face font-lock-function-name-face)
     (module ,(nerd-icons-codicon "nf-cod-file_submodule") :face font-lock-preprocessor-face)
     (numeric ,(nerd-icons-codicon "nf-cod-symbol_numeric") :face font-lock-builtin-face)
     (operator ,(nerd-icons-codicon "nf-cod-symbol_operator") :face font-lock-comment-delimiter-face)
     (param ,(nerd-icons-codicon "nf-cod-symbol_parameter") :face default)
     (property ,(nerd-icons-codicon "nf-cod-symbol_property") :face font-lock-variable-name-face)
     (reference ,(nerd-icons-codicon "nf-cod-references") :face font-lock-variable-name-face)
     (snippet ,(nerd-icons-codicon "nf-cod-symbol_snippet") :face font-lock-string-face)
     (string ,(nerd-icons-codicon "nf-cod-symbol_string") :face font-lock-string-face)
     (struct ,(nerd-icons-codicon "nf-cod-symbol_structure") :face font-lock-variable-name-face)
     (text ,(nerd-icons-codicon "nf-cod-text_size") :face font-lock-doc-face)
     (typeparameter ,(nerd-icons-codicon "nf-cod-list_unordered") :face font-lock-type-face)
     (type-parameter ,(nerd-icons-codicon "nf-cod-list_unordered") :face font-lock-type-face)
     (unit ,(nerd-icons-codicon "nf-cod-symbol_ruler") :face font-lock-constant-face)
     (value ,(nerd-icons-codicon "nf-cod-symbol_field") :face font-lock-builtin-face)
     (variable ,(nerd-icons-codicon "nf-cod-symbol_variable") :face font-lock-variable-name-face)
     (t ,(nerd-icons-codicon "nf-cod-code") :face font-lock-warning-face)))
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Proced
;; https://laurencewarne.github.io/emacs/programming/2022/12/26/exploring-proced.html
(require 'proced)

;; Add shortcut to copy PID from proced
(defun ff/proced-pid-at-point ()
  "Copy PID at point in proced."
  (interactive)
  (let ((pid (proced-pid-at-point)))
    (kill-new (format "%s" pid))
    (message "PID %s copied." pid)))

(define-key proced-mode-map "c" 'ff/proced-pid-at-point)

;; make the buffer auto-update every 5 seconds
(customize-set-variable 'proced-auto-update-flag nil)
(customize-set-variable 'proced-auto-update-interval 5)

;; alter the output format
(add-to-list
 'proced-format-alist
 '(custom user pid ppid sess tree pcpu pmem rss start time state (args comm)))
(customize-set-variable proced-format 'custom)

(customize-set-variable 'proced-goal-attribute nil)

;; enable coloring
(customize-set-variable 'proced-enable-color-flag t)

;; enable remote support via tramp
(customize-set-variable 'proced-show-remote-processes t)

(use-package proced-narrow
  :after proced
  :bind
  (:map proced-mode-map
        ("/" . proced-narrow)))

;; -------------------------------------------------------------
;; center the text for the corresponding modes; writing documentation
;; is easier with this setting.
(use-package olivetti
  :custom
  (olivetti-body-width 0.66)
  :hook
  (org-mode . olivetti-mode)
  (rst-mode . olivetti-mode)
  (markdown-mode . olivetti-mode)
  (LaTeX-mode . olivetti-mode)
  :bind
  (:map olivetti-mode-map
        ("C-c }" . nil)
        ("C-c {" . nil)))

(provide 'ff-setup-gui)

;;; ff-setup-gui.el ends here
