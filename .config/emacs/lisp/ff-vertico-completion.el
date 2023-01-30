;;; ff-vertico-completion --- Set up completion system with Vertico, etc.
;;; Commentary:
;;; Sets up completion system for Emacs
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

(defun ff/minibuffer-move-beginning-of-line (arg)
  "Change default behavior of move to beginning of line.

Delete the complete minibuffer content and go the the root folder
when completing file names.  If not, move point to beginning of
line.

ARG: position"
  (interactive "p")
  (cond (minibuffer-completing-file-name
         (delete-minibuffer-contents)
         (insert (substitute-in-file-name "/")))
        (t
         (move-beginning-of-line 0))))

(use-package vertico
  :custom
  ((vertico-count 10)
   (vertico-cycle t))
  :init
  (vertico-mode t)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  :config
  (custom-set-faces '(vertico-current ((t (:background "#3a3f5a")))))
  :bind (:map vertico-map              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("C-l" . ff/minibuffer-backward-kill)
              ("C-a" . ff/minibuffer-move-beginning-of-line)))

;; Save history during sessions
(use-package savehist
  :init (savehist-mode t))

;; -------------------------------------------------------------------
;; Corfu, Cape and Orderless
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
  (corfu-preselect-first t)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
  (corfu-scroll-margin 5)        ;; Use scroll margin
  (corfu-auto-prefix 2)
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  (read-extended-command-predicate
   #'command-completion-default-include-p)
  :init
  ;; Recommended: Enable Corfu globally.
  (global-corfu-mode)
  :bind(:map corfu-map
             ("C-j" . corfu-next)
             ("C-p" . corfu-previous)
             ("TAB" . corfu-insert)
             ("C-f" . corfu-insert)))

;; enable corfu in terminal mode
(use-package corfu-terminal
  :init
  (when (not (display-graphic-p))
    (corfu-terminal-mode t)))

;; Optionally use the `orderless' completion style. See `+orderless-dispatch'
;; in the Consult wiki for an advanced Orderless style dispatcher.
;; Enable `partial-completion' for files to allow path expansion.
;; You may prefer to use `initials' instead of `partial-completion'.
(use-package orderless
  :custom
  (completion-styles '(orderless flex))
  (completion-category-overrides '((file (styles basic partial-completion))
                                   (eglot (styles . (orderless flex)))))
  :config
  (setq completion-category-defaults nil))

(use-package affe
  ;; search also in hidden and ignoreg files by git
  :custom ((affe-find-command
              (cond
               ((executable-find "rg") "rg --color=never --files -uu")
               (t "find -not ( -wholename */.* -prune ) -type f")))
           (affe-grep-command
            (cond
             ((executable-find "rg") "rg -uu --null --color=never --max-columns=1000 --no-heading --line-number -v ^$ .")
             (t "grep -I -r --exclude=.* --exclude-dir=.* --null --color=never --line-number -v ^$"))))
  :bind (("C-x a f" . affe-find)
         ("C-x a g" . affe-grep)))

;; Use dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand)))

;; Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  :bind (("C-c a p" . completion-at-point) ;; capf
         ("C-c a t" . complete-tag)        ;; etags
         ("C-c a d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c a f" . cape-file)
         ("C-c a k" . cape-keyword)
         ("C-c a s" . cape-symbol)
         ("C-c a a" . cape-abbrev)
         ("C-c a i" . cape-ispell)
         ("C-c a l" . cape-line)
         ("C-c a w" . cape-dict)
         ("C-c a \\" . cape-tex)
         ("C-c a _" . cape-tex)
         ("C-c a ^" . cape-tex)
         ("C-c a &" . cape-sgml)
         ("C-c a r" . cape-rfc1345))
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (add-to-list 'completion-at-point-functions #'cape-file)
  ;; (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;; (add-to-list 'completion-at-point-functions #'cape-sgml)
  ;; (add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;; (add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;; (add-to-list 'completion-at-point-functions #'cape-ispell)
  ;; (add-to-list 'completion-at-point-functions #'cape-dict)
  ;; (add-to-list 'completion-at-point-functions #'cape-line)
  (add-to-list 'completion-at-point-functions #'cape-symbol))

;; -------------------------------------------------------------------
;; Consult
;; -------------------------------------------------------------------
(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook ((completion-list-mode . consult-preview-at-point-mode))

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

  :bind (("C-s" . consult-line)
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
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; -------------------------------------------------------------------
;; Embark & Marginalia: https://github.com/oantolin/embark
;; -------------------------------------------------------------------
;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :after (vertico)
  :init
  (marginalia-mode)
  :bind (("M-A" . marginalia-cycle)))

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
               (concat "/sudo:root@localhost:" file))))

;; dev/null for online pages
(use-package 0x0)

(use-package embark
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  :bind (("C-." . embark-act)
         ("C-h b" . embark-bindings)
         :map minibuffer-local-map
         ("C-." . embark-act)
         :map embark-region-map
         ("U" . 0x0-dwim)
         :map embark-file-map
         ("S" . sudo-find-file)))

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

(use-package embark-consult
  :after (embark consult)
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook ((embark-collect-mode . consult-preview-at-point-mode)))

(provide 'ff-vertico-completion)

;;; ff-vertico-completion.el ends here
