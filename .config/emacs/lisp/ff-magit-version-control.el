;;; ff-magit-version-control.el --- Magit setup

;;; Commentary:
;; Configuration for magit

;;; Code:
(use-package magit
  :custom
  ((magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
   ;; Show word based diff
   (magit-diff-refine-hunk 'all)))

(use-package magit-lfs)

;; configure ediff

;; This is what you probably want if you are using a tiling window
;; manager under X, such as ratpoison.
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

(provide 'ff-magit-version-control)

;;; ff-magit-version-control.el ends here
