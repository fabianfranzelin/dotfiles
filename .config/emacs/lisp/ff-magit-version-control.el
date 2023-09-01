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

(provide 'ff-magit-version-control)

;;; ff-magit-version-control.el ends here
