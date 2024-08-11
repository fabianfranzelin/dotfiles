;;; ff-elora.el --- Keyboard specific setups

;;; Commentary:
;; Configuration when using Elora keyboard

;;; Code:

;; Simply use the arrow keys for window movement. With a split
;; keyboard, this is feasible
(keymap-global-set "<right>" 'windmove-right)
(keymap-global-set "<left>" 'windmove-left)
(keymap-global-set "<up>" 'windmove-up)
(keymap-global-set "<down>" 'windmove-down)

(with-eval-after-load 'vterm
  ;; disable the arrow keys in vterm
  (define-key vterm-mode-map (kbd "<right>") 'ignore)
  (define-key vterm-mode-map (kbd "<left>") 'ignore)
  (define-key vterm-mode-map (kbd "<up>") 'ignore)
  (define-key vterm-mode-map (kbd "<down>") 'ignore))

(provide 'ff-elora)

;;; ff-elora.el ends here
