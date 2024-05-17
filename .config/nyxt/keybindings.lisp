(in-package #:nyxt-user)

(define-configuration :document-mode
  "Add basic keybindings."
  ((keyscheme-map
    (keymaps:define-keyscheme-map
     "custom" (list :import %slot-value%)
     ;; If you want to have VI bindings overriden, just use
     ;; `scheme:vi-normal' or `scheme:vi-insert' instead of
     ;; `scheme:emacs'.
     nyxt/keyscheme:emacs
     (list "C-c p" 'copy-password
           "C-c y" 'autofill
           "C-f" :history-forwards-maybe-query
           "C-i" :input-edit-mode
           "M-:" 'eval-expression
           "C-s" :search-buffer
           "C-x 3" 'hsplit
           "C-x 1" 'close-all-panels)))))
