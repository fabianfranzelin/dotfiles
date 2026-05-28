;;; ff-org-config.el --- Org-mode and babel configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Configures org-mode settings, babel languages, and related options.
;;; Code:

(require 'ff-config)
(require 'org)
(require 'pyvenv)

;; User identity
(customize-set-variable 'user-full-name ff/user-full-name)
(customize-set-variable 'user-mail-address ff/user-mail-address)
(customize-set-variable 'inhibit-startup-echo-area-message (getenv "USER"))

;; Python virtualenv
(pyvenv-workon "org")

;; Org export settings
(customize-set-variable 'org-confirm-babel-evaluate nil)
(customize-set-variable 'org-time-stamp-custom-formats '("<%d-%b-%y>" . "<%-l:%M %p, %a %d-%B '%y>"))
(customize-set-variable 'org-display-custom-times t)
(customize-set-variable 'org-use-sub-superscripts '{})
(customize-set-variable 'org-attach-dir-relative t)
(customize-set-variable 'org-link-file-path-type 'adaptive)

;; Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (shell . t)
   (R . t)
   (org . t)
   (latex . t)
   (dot . t)
   (gnuplot . t)
   (plantuml . t)))

(customize-set-variable 'org-plantuml-jar-path
                        (expand-file-name ".cache/emacs/var/plantuml/plantuml-1.2026.2.jar" "~"))

(provide 'ff-org-config)
;;; ff-org-config.el ends here
