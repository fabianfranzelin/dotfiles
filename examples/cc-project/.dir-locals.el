;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((compile-command . "cd ./examples/cc-project/build && make")
         (eval . (defun run-command-recipe-ff/c++-example ()
                   (append
                    (when-let* ((project-dir (locate-dominating-file default-directory ".clangd")))
                      (list (list :command-name "cc:cmake main"
                                  :command-line "mkdir -p build && cd build && cmake .."
                                  :working-dir project-dir)))
                    (when-let* ((project-dir (locate-dominating-file default-directory "build"))
                                (build-dir (expand-file-name "build" project-dir)))
                      (list
                       (if (f-file-p (expand-file-name "main" build-dir))
                           (list :command-name "cc:run main"
                                 :command-line "./main"
                                 :working-dir build-dir)))))))
         (run-command-recipes . (run-command-recipe-ff/configure
                                 run-command-recipe-ff/docs
                                 run-command-recipe-ff/c++-example))
         ;; add some environment variables before compilation starts
         (eval . (add-hook 'compilation-mode-hook
                           (lambda ()
                             (let* ((github-user (password-store-get "usernames/public@github"))
                                    (env-variables `(("GITHUB_USER" . ,github-user))))
                               (mapcar (lambda (element)
                                         (let ((name (car element))
                                               (value (cdr element)))
                                           (add-to-list 'compilation-environment (format "%s=%s" name value))))
                                       env-variables)))))))
 (c++-ts-mode . ((eval . (setq-local ff/cc-build-folder-container nil))
                 (eval . (setq-local ff/cc-conan-cache-container nil))
                 (eval . (setq-local ff/cc-conan-cache-host nil)))))
