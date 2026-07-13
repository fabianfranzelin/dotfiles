;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((eval . (defun ff/bazel-debug ()
                   "Select a debuggable Bazel target and debug it with dape."
                   (interactive)
                   (let* ((project-dir (expand-file-name (locate-dominating-file default-directory "MODULE.bazel")))
                          (query "kind('cc_binary|cc_test', //...)")
                          (output (string-trim
                                   (shell-command-to-string
                                    (format "cd %s && bazel query \"%s\" 2>/dev/null"
                                            (shell-quote-argument project-dir) query))))
                          (targets (split-string output "\n" t))
                          (target (if (null targets)
                                      (error "No debuggable targets found")
                                    (completing-read "Bazel target: " targets nil t)))
                          (short-name (replace-regexp-in-string "//:" "" target)))
                     (setq dape-command
                           `(gdb command "gdb"
                                 command-args ("-i" "dap")
                                 :program ,(expand-file-name (concat "bazel-bin/" short-name) project-dir)
                                 :cwd ,project-dir
                                 compile ,(concat "cd " (shell-quote-argument project-dir)
                                                  " && bazel build --compilation_mode=dbg " target)))
                     (call-interactively #'dape))))
         (eval . (defun ff/bazel-debug-current-file ()
                   "Debug a Bazel target that depends on the current file."
                   (interactive)
                   (let* ((project-dir (expand-file-name (locate-dominating-file default-directory "MODULE.bazel")))
                          (relative-file (file-relative-name (buffer-file-name) project-dir))
                          (query (format "kind('cc_binary|cc_test', rdeps(//..., '%s'))" relative-file))
                          (output (string-trim
                                   (shell-command-to-string
                                    (format "cd %s && bazel query \"%s\" 2>/dev/null"
                                            (shell-quote-argument project-dir) query))))
                          (targets (split-string output "\n" t))
                          (target (if (null targets)
                                      (error "No debuggable targets depend on %s" relative-file)
                                    (if (cdr targets)
                                        (completing-read "Bazel target: " targets nil t)
                                      (car targets))))
                          (short-name (replace-regexp-in-string "//:" "" target)))
                     (setq dape-command
                           `(gdb command "gdb"
                                 command-args ("-i" "dap"
                                               "-iex" ,(concat "set substitute-path /proc/self/cwd " project-dir))
                                 :program ,(expand-file-name (concat "bazel-bin/" short-name) project-dir)
                                 :cwd ,project-dir
                                 compile ,(concat "cd " (shell-quote-argument project-dir)
                                                  " && bazel build --compilation_mode=dbg " target)))
                     (call-interactively #'dape))))
         (compile-command . "cd ./examples/cc-project && bazel build //:main && bazel run //:refresh_compile_commands")
         (eval . (defun run-command-recipe-ff/c++-example ()
                   (append
                    (when-let* ((project-dir (locate-dominating-file default-directory "MODULE.bazel")))
                      (list
                       (list :command-name "bazel:build //:main"
                             :command-line "bazel build //:main && bazel run //:refresh_compile_commands"
                             :working-dir project-dir)
                        (list :command-name "bazel:run //:main"
                              :command-line "bazel run //:main"
                              :working-dir project-dir)
                        (list :command-name "bazel:test //..."
                              :command-line "bazel test //..."
                              :working-dir project-dir)
                        (list :command-name "bazel:test //:network_utils_test"
                              :command-line "bazel test //:network_utils_test"
                              :working-dir project-dir)))
                    (when-let* ((project-dir (locate-dominating-file default-directory ".clangd")))
                      (list (list :command-name "cc:cmake main"
                                  :command-line "mkdir -p build && cd build && cmake .."
                                  :working-dir project-dir)))
                    (when-let* ((project-dir (locate-dominating-file default-directory "build"))
                                (build-dir (expand-file-name "build" project-dir)))
                      (list
                       (list :command-name "cc:make"
                             :command-line "make -j$(nproc)"
                             :working-dir build-dir)
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
                                       env-variables)))))
         ;; conan paths for container setup
         (eval . (setq-local ff/cc-workspace-folder-container nil))
         (eval . (setq-local ff/cc-conan-cache-container nil))
         (eval . (setq-local ff/cc-conan-cache-host nil))
         (eval . (setq-local ff/cc-build-folder-container "examples/cc-project/build")))))
