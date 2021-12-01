;;; setup-magit.el --- Magit setup

;;; Commentary:
;; Configuration for magit

;;; Code:
(use-package magit
  :commands (magit-status magit-get-current-branch)
  :bind (("C-c m h" . magit-log-buffer-file))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  ; Show word based diff
  (setq magit-diff-refine-hunk 'all))

(use-package git-timemachine)

(use-package git-gutter-fringe)

(use-package git-gutter
  :after git-gutter-fringe
  :diminish
  :hook ((text-mode . git-gutter-mode)
         (prog-mode . git-gutter-mode))
  :config
  (setq git-gutter:update-interval 2)
  (set-face-foreground 'git-gutter-fr:added "LightGreen")
  (fringe-helper-define 'git-gutter-fr:added nil
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX")

  (set-face-foreground 'git-gutter-fr:modified "LightGoldenrod")
  (fringe-helper-define 'git-gutter-fr:modified nil
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX")

  (set-face-foreground 'git-gutter-fr:deleted "LightCoral")
  (fringe-helper-define 'git-gutter-fr:deleted nil
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        ".........."
                        ".........."
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX")

  ;; These characters are used in terminal mode
  (setq git-gutter:modified-sign "≡")
  (setq git-gutter:added-sign "≡")
  (setq git-gutter:deleted-sign "≡")
  (set-face-foreground 'git-gutter:added "LightGreen")
  (set-face-foreground 'git-gutter:modified "LightGoldenrod")
  (set-face-foreground 'git-gutter:deleted "LightCoral"))

(use-package magit-lfs)

(provide 'setup-magit)

;;; setup-magit.el ends here
