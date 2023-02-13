;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((tags-table-list . '("./examples/cc-project"))))
 (python-mode . ((eval . (pyvenv-deactivate))
                 (flycheck-add-next-checker . ('python-pylint 'python-mypy))
                 (eval . (add-to-list 'flycheck-disabled-checkers 'python-flake8))
                 (eglot-workspace-configuration
                  . (:pylsp (:plugins (:jedi_completion (:include_params t
                                                                         :fuzzy t)
                                                        :pylint (:enabled t)
                                                        :mypy (:enabled t)
                                                        :pycodestyle (:enabled :json-false)))))))
 (sh-mode . ((flycheck-add-next-checker . '(sh-shellcheck sh-zsh))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-dash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-bash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-bash)))))
