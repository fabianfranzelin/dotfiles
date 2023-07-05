;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ())
 (org-mode . ((eval . (progn
                        (when-let* ((org-example-dir (locate-dominating-file default-directory "README.org")))
                          (setq-local org-roam-directory (expand-file-name "notes" org-example-dir))
                          (setq-local org-roam-dailies-directory (expand-file-name "notes" org-example-dir))
                          (setq-local org-roam-db-location (expand-file-name org-roam-directory "org-roam.db"))
                          ))))))
