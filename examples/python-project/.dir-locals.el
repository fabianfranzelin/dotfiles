;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((eval . (defun run-command-recipe-ff/local ()
                   (list
                    (when-let* ((main-dir (locate-dominating-file default-directory "__main__.py")))
                      (list :command-name "python:run main"
                            :command-line "python3 __main__.py"
                            :display "python:run main"
                            :working-dir main-dir)))))
         (eval . (add-to-list 'run-command-recipes #'run-command-recipe-ff/local))))
 (python-ts-mode . ((eval . (when-let* ((main-dir (locate-dominating-file default-directory "__main__.py")))
                              (setq python-pytest-executable
                                    (concat "PYTHONPATH=" main-dir " " "pytest"))))
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
                                                           :autopep8 (:enabled :json-false))))))))
