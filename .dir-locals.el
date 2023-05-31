;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((pyvenv-workon . nil)
         (run-command-recipes . (list run-command-recipe-ff/cc
                                      run-command-recipe-ff/python))))
 (yaml-mode . ((eglot-workspace-configuration
                . (:yaml (:rules (:key-ordering nil
                                                :line-length nil)
                                 :schemas (:https://json.schemastore.org/github-action.json "/.github/workflows/.*"))))))
 (python-mode . ((flycheck-add-next-checker . ('python-pylint 'python-mypy))
                 (eval . (add-to-list 'flycheck-disabled-checkers 'python-flake8))
                 (eglot-workspace-configuration
                  . (:pylsp (:plugins (:jedi_completion (:include_params t
                                                                         :fuzzy t)
                                                        :pylint (:enabled t)
                                                        :mypy (:enabled t)
                                                        :pydocstyle (:enabled t
                                                                              :convention "google")
                                                        :black (:enabled t
                                                                         :cache_config t)
                                                        :pycodestyle (:enabled :json-false)
                                                        :maccabe (:enabled :json-false)
                                                        :pyflakes (:enabled :json-false)
                                                        :ruff (:enabled :json-false)
                                                        :yapf (:enabled :json-false)
                                                        :autopep8 (:enabled :json-false)))))))
 (sh-mode . ((flycheck-add-next-checker . '(sh-shellcheck sh-zsh))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-dash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-bash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-bash)))))
