;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((compile-command . "cd ./examples/cc-project/build && make")
         (eval . (defun run-command-recipe-ff/local ()
                   (list
                    (when-let* ((project-dir (locate-dominating-file default-directory "build"))
                                (build-dir (expand-file-name "build" project-dir)))
                      (if (f-file-p (expand-file-name "main" build-dir))
                          (list :command-name "cc:run main"
                                :command-line "./main"
                                :working-dir build-dir))))))
         (eval . (add-to-list 'run-command-recipes #'run-command-recipe-ff/local))))
 (c++-mode . ((eval . (setq-local ff/cc-build-folder-container nil))
              (eval . (setq-local ff/cc-conan-cache-container nil))
              (eval . (setq-local ff/cc-conan-cache-host nil)))))
