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
;; Corfu
;; -------------------------------------------------------------------
(use-package corfu
  :custom (corfu-cycle t)
  :init
  (corfu-global-mode)
  :bind(:map corfu-map
             ("C-j" . corfu-next)
             ("C-k" . corfu-previous)
             ("TAB" . corfu-insert)
             ("C-f" . corfu-insert)))

;; -------------------------------------------------------------------
;; Improved filtering
;; -------------------------------------------------------------------
(use-package orderless
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

;; -------------------------------------------------------------------
;; Consult
;; -------------------------------------------------------------------
(defun dw/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-project-root)))

(use-package consult
  :after (projectile vertico)
  :defines consult-buffer-sources
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
         ("M-y" . consult-yank-from-kill-ring)
         ("M-g g" . consult-goto-line)
         :map minibuffer-local-map
         ("M-y" . yank-pop)
         ("C-r" . consult-history)))

(use-package consult-dir
  :custom (consult-dir-project-list-function nil)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; -------------------------------------------------------------------
;; Embark: https://github.com/oantolin/embark
;; -------------------------------------------------------------------
(use-package marginalia
  :after projectile vertico
  :init
  (marginalia-mode)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy
                                marginalia-annotators-light
                                nil))
  (setq marginalia-command-categories
        (append '((projectile-find-file . project-file)
                  (projectile-find-dir . project-file)
                  (projectile-switch-project . file))
                marginalia-command-categories)))

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
  :after highlight-symbol
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  ;; Show Embark actions via which-key
  (setq embark-action-indicator
        (lambda (map)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)

  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings)
         ("C-c C-o" . occur-edit-mode)
         :map minibuffer-local-map
         ("C-." . embark-act)
         :map embark-region-map
         ("U" . 0x0-dwim)
         :map embark-file-map
         ("S" . sudo-find-file)
         :map embark-symbol-map
         ("h" . highlight-symbol)))

(use-package embark-consult
  :after (embark consult)
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(provide 'setup-completion)

;;; setup-completion.el ends here
