;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((python-mode . ((eglot-workspace-configuration
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
                                                        :autopep8 (:enabled :json-false))))))))
