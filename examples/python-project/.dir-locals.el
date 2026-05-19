;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((eval . (defun run-command-recipe-ff/python-example ()
                   (append
                    (when-let* ((main-dir (locate-dominating-file default-directory "__main__.py")))
                      (list (list :command-name "python:run main"
                                  :command-line "python3 __main__.py"
                                  :display "python:run main"
                                  :working-dir main-dir))))))
         (run-command-recipes . (run-command-recipe-ff/configure
                                 run-command-recipe-ff/docs
                                 run-command-recipe-ff/python-example))))
 (python-ts-mode . ((eval . (when-let* ((main-dir (locate-dominating-file default-directory "__main__.py")))
                              (setq python-pytest-executable
                                    (format "PYTHONPATH=%s pytest" main-dir)))))))

