((nil . ((compile-command . "cd docs && ./build.el && ./publish.sh")
         (eval . (defun run-command-recipe-ff/docs ()
                   (list
                    (when-let* ((docs-dir (locate-dominating-file default-directory "build.el"))
                                (build-script (expand-file-name "build.el" docs-dir)))
                      (list :command-name "sh:build"
                            :command-line "./build.el"
                            :working-dir docs-dir))
                    (when-let* ((docs-dir (locate-dominating-file default-directory "build.el"))
                                (publish-script (expand-file-name "publish.sh" docs-dir)))
                      (list :command-name "sh:publish"
                            :command-line "./publish.sh"
                            :working-dir docs-dir))
                    (when-let* ((docs-dir (locate-dominating-file default-directory "build.el"))
                                (build-script (expand-file-name "build.el" docs-dir))
                                (publish-script (expand-file-name "publish.sh" docs-dir)))
                      (list :command-name "sh:build_and_publish"
                            :command-line "./build.el && ./publish.sh"
                            :working-dir docs-dir)))))
         (eval . (add-to-list 'run-command-recipes #'run-command-recipe-ff/docs)))))
