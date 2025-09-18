;;; ff-version-control.el --- Magit and ediff setup  -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for magit and ediff

;;; Code:
(defun ff/stage-commit-push-all ()
  "Stage, commit, and push all changed files in a Git repo."
  (interactive)
  (magit-stage-modified)
  (magit-commit-create '("-m" "feat: update some stuff"))
  (magit-push-current-to-upstream nil))

(defun ff/vc-browse-remote (&optional current-line)
  "Open the repository's remote URL in the browser.
If CURRENT-LINE is non-nil, point to the current branch, file, and line.
Otherwise, open the repository's main page."
  (interactive "P")
  (let* ((remote-url (string-trim (vc-git--run-command-string nil "config" "--get" "remote.origin.url")))
	 (branch (string-trim (vc-git--run-command-string nil "rev-parse" "--abbrev-ref" "HEAD")))
	 (file (string-trim (file-relative-name (buffer-file-name) (vc-root-dir))))
	 (line (line-number-at-pos)))
    (message "Opening remote on browser: %s" remote-url)
    (if (and remote-url (string-match "\\(?:git@\\|https://\\)\\([^:/]+\\)[:/]\\(.+?\\)\\(?:\\.git\\)?$" remote-url))
	(let ((host (match-string 1 remote-url))
	      (path (match-string 2 remote-url)))
	  ;; Convert SSH URLs to HTTPS (e.g., git@github.com:user/repo.git -> https://github.com/user/repo)
	  (when (string-prefix-p "git@" host)
	    (setq host (replace-regexp-in-string "^git@" "" host)))
	  ;; Construct the appropriate URL based on CURRENT-LINE
	  (browse-url
	   (if current-line
	       (format "https://%s/%s/blob/%s/%s#L%d" host path branch file line)
	     (format "https://%s/%s" host path))))
      (message "Could not determine repository URL"))))

(global-set-key (kbd "C-x v B") 'ff/vc-browse-remote)

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  ;; Show word based diff
  (magit-diff-refine-hunk 'all)
  :bind
  (:map magit-mode-map
        ("C-c C-a" . ff/stage-commit-push-all)
        :map magit-section-mode-map
        ("C-<tab>" . nil)))

(use-package magit-lfs)

;; configure ediff

;; This is what you probably want if you are using a tiling window
;; manager under X, such as ratpoison.
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

;; save and restore window configuration when entering and quitting
;; ediff
;; https://www.emacswiki.org/emacs/EdiffMode
(add-hook 'ediff-load-hook
          (lambda ()

            (add-hook 'ediff-before-setup-hook
                      (lambda ()
                        (setq ediff-saved-window-configuration (current-window-configuration))))

            (let ((restore-window-configuration
                   (lambda ()
                     (set-window-configuration ediff-saved-window-configuration))))
              (add-hook 'ediff-quit-hook restore-window-configuration 'append)
              (add-hook 'ediff-suspend-hook restore-window-configuration 'append))))

;; diff of directories; diff of files via ediff
(use-package ztree
  :straight (ztree :type git :host codeberg :repo "fourier/ztree")
  :demand t
  :config
  (setq ztree-diff-additional-options '("-w" "-i"))
  :bind
  (:map ztree-mode-map
        ("C-<tab>" . nil)
        ("C-c C-c" . ztree-perform-action)
        ("C-c C-d" . ztree-diff)
        ;; define my default navigation keys for ztree-mode
        ("n" . ztree-next-line)
        ("p" . ztree-previous-line)
        ("f" . ztree-jump-side)
        ("b" . ztree-jump-side)
        ("TAB" . ztree-perform-action)
        ("l" . ztree-move-up-in-tree)))

;; Github integration via consult-gh
(use-package consult-gh
  :after consult savehist
  :custom
  (consult-gh-default-clone-directory "~/workspace")
  (consult-gh-show-preview t)
  (consult-gh-preview-key "C-o")
  (consult-gh-repo-action #'consult-gh--repo-browse-files-action)
  (consult-gh-large-file-warning-threshold 2500000)
  (consult-gh-confirm-name-before-fork nil)
  (consult-gh-confirm-before-clone t)
  (consult-gh-notifications-show-unread-only nil)
  (consult-gh-prioritize-local-folder nil)
  (consult-gh-group-dashboard-by :reason)
  (consult-gh-maxnum 400)
  ;;;; Optional
  (consult-gh-repo-preview-major-mode nil) ; show readmes in their original format
  (consult-gh-preview-major-mode 'org-mode) ; use 'org-mode for editing comments, commit messages, ...
  :config
  ;; Remember visited orgs and repos across sessions
  (add-to-list 'savehist-additional-variables 'consult-gh--known-orgs-list)
  (add-to-list 'savehist-additional-variables 'consult-gh--known-repos-list)
  ;; Enable default keybindings (e.g. for commenting on issues, prs, ...)
  (consult-gh-enable-default-keybindings)
  :bind
  (:map global-map
        ("C-x v H" . consult-gh)))


(with-eval-after-load 'consult-gh
  (require 'consult-gh-transient)
  (customize-set-variable 'consult-gh-default-interactive-command #'consult-gh-transient))

(use-package consult-gh-embark
  :after consult-gh
  :hook (after-init . consult-gh-embark-mode))

(provide 'ff-version-control)

;;; ff-version-control.el ends here
