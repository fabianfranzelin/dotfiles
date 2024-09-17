;;; ff-vertical-completion --- Set up vertical completion system with Vertico.  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Sets up vertical completion system for Emacs
;;; https://github.com/daviwil/dotfiles/blob/master/Emacs.org#completion-system

;;; Code:

;; -------------------------------------------------------------------
;; Vertico
;; -------------------------------------------------------------------

(defun ff/minibuffer-backward-kill (arg)
  "Delete parent folder completely when hitting it with the cursor.
ARG: position"
  (interactive "p")
  (if minibuffer-completing-file-name
      (progn
        ;; Expand the home path when hitting ~/ and continue
        (when (string-match-p "^~/$" (minibuffer-contents))
          (delete-minibuffer-contents)
          (insert (expand-file-name "~/")))

        ;; Expand home path when hitting tilde with tramp
        (when (string-match-p "^/.*:.*:~/$" (minibuffer-contents))
          (zap-up-to-char (- arg) ?~)
          (delete-char -1)
          (insert (expand-file-name "~/")))

        ;; Continue
        (cond ((string-match-p "^/.*:.*:.*/.*/$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?/))
              ((string-match-p "^/.*:.*:.*/$" (minibuffer-contents))
               (zap-up-to-char (- (+ arg 1)) ?:))
              ((string-match-p "^/.*:.*:.*/$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?:))
              ((string-match-p "^/.*:$" (minibuffer-contents))
               (zap-up-to-char (- arg) ?/))
              ((or (string-match-p "^/.*/$" (minibuffer-contents))
                   (string-match-p "^~/.*/$" (minibuffer-contents)))
               (zap-up-to-char (- arg) ?/))
              (t ;; default
               (delete-char -1))))
    (delete-char -1)))

(defun ff/minibuffer-move-to-dir (dir)
  "Go the the specified directory when completing file names.
DIR: directory"
  (interactive "p")
  (cond (minibuffer-completing-file-name
         (delete-minibuffer-contents)
         (insert (substitute-in-file-name dir)))
        (t
         (move-beginning-of-line 0))))

(use-package vertico
  :hook
  (after-init . vertico-mode)
  :custom
  (vertico-count 10)
  (vertico-cycle t)
  (enable-recursive-minibuffers t)
  :config
  (custom-set-faces '(vertico-current ((t (:background "#3a3f5a")))))
  :bind
  (:map vertico-map
        ("C-q" . vertico-exit)
        ("C-j" . vertico-exit-input)
        :map minibuffer-local-map
        ("C-l" . ff/minibuffer-backward-kill)
        ("C-a" . (lambda() (interactive) (ff/minibuffer-move-to-dir "/")))
        ("C-o" . (lambda() (interactive) (ff/minibuffer-move-to-dir "~/")))
        ;; disable arrow keys, we are in Emacs
        ("<left>" . nil)
        ("<right>" . nil)
        ("<up>" . nil)
        ("<down>" . nil)))

;; install some vertico extensions
(with-eval-after-load 'vertico
  (let ((vertico-extensions-dir (expand-file-name
                                 "straight/build/vertico/extensions"
                                 straight-base-dir)))
    (add-to-list 'load-path vertico-extensions-dir)
    (require 'vertico-repeat)
    (keymap-global-set "M-R" #'vertico-repeat)
    (add-hook 'minibuffer-setup-hook #'vertico-repeat-save)))

;; fuzzy completion
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Save history during sessions so that vertico can pick up the latest
;; used ones
(use-package savehist
  :hook
  (after-init . savehist-mode))

;; -------------------------------------------------------------------
;; Corfu and Cape
;; -------------------------------------------------------------------
(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'first)    ;; Preselect the first candidate in the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
  (corfu-scroll-margin 5)        ;; Use scroll margin
  (corfu-auto-prefix 3)
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)
  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  (read-extended-command-predicate #'command-completion-default-include-p)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  (text-mode-ispell-word-completion nil)
  :init
  ;; Recommended: Enable Corfu globally.
  (global-corfu-mode t)
  (corfu-history-mode t)
  :config
  (setq global-corfu-minibuffer
        (lambda ()
          (not (or (bound-and-true-p mct--active)
                   (bound-and-true-p vertico--input)
                   (eq (current-local-map) read-passwd-map)))))
  ;; move candidates to minibuffer
  (defun corfu-move-to-minibuffer ()
    (interactive)
    (pcase completion-in-region--data
      (`(,beg ,end ,table ,pred ,extras)
       (let ((completion-extra-properties extras)
             completion-cycle-threshold completion-cycling)
         (consult-completion-in-region beg end table pred)))))
  (keymap-set corfu-map "M-m" #'corfu-move-to-minibuffer)
  (add-to-list 'corfu-continue-commands #'corfu-move-to-minibuffer)
  :bind(:map corfu-map
             ("C-j" . corfu-next)
             ("C-p" . corfu-previous)
             ("TAB" . corfu-insert)
             ("C-f" . corfu-insert)))
;; Use this and enable corfu-separator for fuzzy function finding
;; ("SPC" . corfu-insert-separator)))

;; enable corfu in terminal mode
(use-package corfu-terminal
  :init
  (when (not (display-graphic-p))
    (corfu-terminal-mode t)))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

;; Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  :bind (("C-c a p" . completion-at-point) ;; capf
         ("C-c a t" . complete-tag)        ;; etags
         ("C-c a d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c a h" . cape-history)
         ("C-c a f" . cape-file)
         ("C-c a k" . cape-keyword)
         ("C-c a s" . cape-elisp-symbol)
         ("C-c a e" . cape-elisp-block)
         ("C-c a a" . cape-abbrev)
         ("C-c a l" . cape-line)
         ("C-c a w" . cape-dict)
         ("C-c a :" . cape-emoji)
         ("C-c a \\" . cape-tex)
         ("C-c a _" . cape-tex)
         ("C-c a ^" . cape-tex)
         ("C-c a &" . cape-sgml)
         ("C-c a r" . cape-rfc1345))
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

;; -------------------------------------------------------------------
;; Consult
;; -------------------------------------------------------------------
(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :bind
  (:map global-map
	("C-s" . consult-line)
        ("C-c i" . consult-imenu)
        ("M-y" . consult-yank-replace)
        ;; C-x bindings (ctl-x-map)
        ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
        ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
        ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
        ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
        ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
        ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
        ;; M-g bindings (goto-map)
        ("M-g e" . consult-compile-error)
        ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
        ;; ("M-g g" . consult-goto-line)             ;; orig. goto-line
        ;; ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
        ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
        ("M-g m" . consult-mark)
        ("M-g k" . consult-global-mark)
        ("M-g i" . consult-imenu)
        ("M-g I" . consult-imenu-multi)
        ;; M-s bindings (search-map)
        ("M-s d" . consult-find)
        ("M-s D" . consult-locate)
        ("M-s g" . consult-grep)
        ("M-s G" . consult-git-grep)
        ("M-s r" . consult-ripgrep)
        ("M-s l" . consult-line)
        ("M-s L" . consult-line-multi)
        ("M-s k" . consult-keep-lines)
        ("M-s u" . consult-focus-lines)
        :map minibuffer-local-map
        ("M-y" . yank-pop)
        ("C-s" . consult-history)))

(use-package consult-dir
  :commands consult-dir
  :config
  (add-to-list 'consult-dir-sources 'consult-dir--source-tramp-ssh t)
  ;; this works also with bookmarks; set them with C-x r m
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; -------------------------------------------------------------------
;; Embark & Marginalia: https://github.com/oantolin/embark
;; -------------------------------------------------------------------
;; Enable richer annotations using the Marginalia package
(use-package marginalia
  ;; There is not space for marginalia on small screens, hence, I
  ;; disable it there
  :if (not (ff/is-mobile))
  :after vertico
  :hook
  (vertico-mode . marginalia-mode))

(defun sudo-find-file (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (when (file-writable-p file)
    (user-error "File is user writeable, aborting sudo"))
  (find-file (if (file-remote-p file)
                 (concat "/" (file-remote-p file 'method) ":"
                         (file-remote-p file 'user) "@" (file-remote-p file 'host)
                         "|sudo:root@"
                         (file-remote-p file 'host) ":" (file-remote-p file 'localname))
               (concat "/sudo:root@localhost:" (expand-file-name file)))))

(use-package embark
  :ensure t
  :config
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  ;; Nice which key integration that allows to list the which-key
  ;; options via C-h. See
  ;; https://github.com/oantolin/embark/wiki/Additional-Configuration#use-which-key-like-a-key-menu-prompt
  ;; for details
  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
        (which-key--show-keymap
         (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
         (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
         nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator)
  :bind
  (:map global-map
        ("C-." . embark-act)
        ("C-," . embark-act-all)
        ("C-h B" . embark-bindings)
        :map minibuffer-local-map
        ("C-." . embark-act)
        ("C-," . embark-act-all)
        :map embark-file-map
        ("S" . sudo-find-file)))

(use-package embark-consult
  :after (embark consult)
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode)
  :bind
  (:map embark-file-map
        ("g" . consult-grep)))


(provide 'ff-vertical-completion)

;;; ff-vertical-completion.el ends here
