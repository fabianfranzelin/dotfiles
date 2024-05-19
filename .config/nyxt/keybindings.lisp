(in-package #:nyxt-user)

(define-configuration :document-mode
    "Add basic keybindings."
  ((keyscheme-map
    (keymaps:define-keyscheme-map
        "custom" (list :import %slot-value%)
      nyxt/keyscheme:emacs
      (list "C-x p p" 'copy-password
            "C-x p u" 'copy-username
            "C-c y" 'autofill
            "M-_" 'redo
            "C-_" 'undo
            "C-c h" 'go-to-homepage)))))
