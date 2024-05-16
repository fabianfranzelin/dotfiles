;; prompt-buffer
(define-configuration prompt-buffer
  ((hide-single-source-header-p t)))

;; emacs keybindings
(define-configuration (buffer web-buffer)
  ((default-modes
    (pushnew 'nyxt/mode/emacs:emacs-mode %slot-value%))))

;; Adblocking
(define-configuration web-buffer
  ((default-modes
    (pushnew 'nyxt/mode/blocker:blocker-mode %slot-value%))))

;; reduce tracking mode
(define-configuration web-buffer
  ((default-modes
    (pushnew 'nyxt/mode/reduce-tracking:reduce-tracking-mode %slot-value%))))

;; (define-configuration buffer
;;     ((default-modes (append '(auto-mode) %slot-default))))
