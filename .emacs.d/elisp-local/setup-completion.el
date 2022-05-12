;;; package --- Set up completion system with Vertico, etc.
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
        (when (string-match-p "~/$" (minibuffer-contents))
          (delete-minibuffer-contents)
          (insert (substitute-in-file-name "$HOME/")))

        ;; Borrowed from
        ;; https://github.com/raxod502/selectrum/issues/498#issuecomment-803283608
        (if (string-match-p ".*/$" (minibuffer-contents))
              (zap-up-to-char (- arg) ?/)
          (delete-char -1)))
    (delete-char -1)))

(use-package vertico
  :custom (vertico-cycle t)
  :init
  (vertico-mode)
  :config
  (custom-set-faces '(vertico-current ((t (:background "#3a3f5a")))))
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("DEL" . ff/minibuffer-backward-kill)
              ("C-<backspace>" . (lambda(arg) (interactive "p") (backward-word) (kill-word 1)))))

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
  (corfu-auto-prefix 1)
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete)

  ;; Recommended: Enable Corfu globally.
  (global-corfu-mode)
  :bind(:map corfu-map
             ("C-j" . corfu-next)
             ("C-k" . corfu-previous)
             ("TAB" . corfu-insert)
             ("C-f" . corfu-insert)))

;; Optionally use the `orderless' completion style. See `+orderless-dispatch'
;; in the Consult wiki for an advanced Orderless style dispatcher.
;; Enable `partial-completion' for files to allow path expansion.
;; You may prefer to use `initials' instead of `partial-completion'.
(use-package orderless
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))


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
(defun dw/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-project-root)))

(use-package consult
  :after (projectile vertico)
  :defines consult-buffer-sources
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook ((completion-list-mode . consult-preview-at-point-mode))
  :config
  (setq consult-project-root-function #'dw/get-project-root
        completion-in-region-function #'consult-completion-in-region)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; add projectile projects to consult
  (projectile-load-known-projects)
  (setq my-consult-source-projectile-projects
        `(:name "Projectile projects"
                :narrow   ?P
                :category project
                :action   ,#'projectile-switch-project-by-name
                :items    ,projectile-known-projects))
  (add-to-list 'consult-buffer-sources my-consult-source-projectile-projects 'append)

  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args)))

  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c i" . consult-imenu)
         ("C-M-j" . persp-switch-to-buffer*)
         ("M-y" . consult-yank-replace)
         ("M-g g" . consult-goto-line)
         :map minibuffer-local-map
         ("M-y" . yank-pop)
         ("C-s" . consult-history)))

(use-package consult-dir
  :custom (consult-dir-project-list-function nil)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; -------------------------------------------------------------------
;; Embark & Marginalia: https://github.com/oantolin/embark
;; -------------------------------------------------------------------
;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :after (projectile vertico)
  :init
  (marginalia-mode)
  :config
  (setq marginalia-command-categories
        (append '((projectile-find-file . project-file)
                  (projectile-find-dir . project-file)
                  (projectile-switch-project . file))
                marginalia-command-categories))
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

;; highlight symbol and replace
(use-package highlight-symbol)
;; dev/null for online pages
(use-package 0x0)

(use-package embark
  :after (highlight-symbol)
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
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings)
         :map minibuffer-local-map
         ("C-." . embark-act)
         :map embark-region-map
         ("U" . 0x0-dwim)
         :map embark-file-map
         ("S" . sudo-find-file)
         :map embark-symbol-map
         ("h" . highlight-symbol)))

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

(provide 'setup-completion)

;;; setup-completion.el ends here
