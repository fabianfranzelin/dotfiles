;;; ff-version-control.el --- Magit and ediff setup

;;; Commentary:
;; Configuration for magit and ediff

;;; Code:
(defun ff/stage-commit-push-all ()
  "Stage, commit, and push all changed files in a Git repo."
  (interactive)
  (magit-stage-modified)
  (magit-commit-create '("-m" "update some stuff"))
  (magit-push-current-to-upstream nil))

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
(straight-use-package
 '(ztree
   :type git
   :host codeberg
   :repo "fourier/ztree"))

(require 'ztree)
(setq ztree-diff-additional-options '("-w" "-i"))

;; define my default navigation keys for ztree-mode
(define-key ztree-mode-map "n" 'ztree-next-line)
(define-key ztree-mode-map "p" 'ztree-previous-line)
(define-key ztree-mode-map "f" 'ztree-jump-side)
(define-key ztree-mode-map "b" 'ztree-jump-side)
(define-key ztree-mode-map (kbd "<tab>") 'ztree-perform-action)
(define-key ztree-mode-map "l" 'ztree-move-up-in-tree)

(provide 'ff-version-control)

;;; ff-version-control.el ends here
