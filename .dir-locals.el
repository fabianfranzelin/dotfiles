;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . (;; Configure ;;;;;;;;;;;;;;;;;;;;;;;;;;;
         (eval . (defun run-command-recipe-ff/configure ()
                   (append
                    (when-let* ((project-dir (locate-dominating-file default-directory "configure")))
                      (list
                       (list :command-name "sh:configure"
                             :command-line "./configure"
                             :working-dir project-dir)
                       (list :command-name "sh:configure & install (skip Emacs and Qtile)"
                             :command-line "./configure -i --skip-emacs-build --skip-qtile-installation"
                             :working-dir project-dir
                             :runner 'ff/run-command-runner-vterm)
                       (list :command-name "sh:generate git credentials"
                             :command-line "./configure --update-git-credentials"
                             :working-dir project-dir))))))
         ;; Docs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         (eval . (defun run-command-recipe-ff/docs ()
                   (append
                    (when-let* ((project-dir (locate-dominating-file default-directory ".git"))
                                (docs-dir (expand-file-name "docs" project-dir))
                                (build-script (expand-file-name "build.el" project-dir))
                                (publish-script (expand-file-name "publish.sh" project-dir))
                                (serve-script (expand-file-name "serve.el" project-dir)))
                      (list (list :command-name "sh:install npm dependencies"
                                  :command-line "npm install"
                                  :working-dir docs-dir)
                            (list :command-name "sh:build"
                                  :command-line "./build.el"
                                  :working-dir docs-dir)
                            (list :command-name "sh:publish"
                                  :command-line "./publish.sh"
                                  :working-dir docs-dir)
                            (list :command-name "sh:build and publish"
                                  :command-line "./build.el && ./publish.sh"
                                  :working-dir docs-dir)
                            (list :command-name "sh:serve"
                                  :command-line "./serve.el"
                                  :working-dir docs-dir)
                            (list :command-name "sh:build and serve"
                                  :command-line "./build.el && ./serve.el"
                                  :working-dir docs-dir))))))
         (run-command-recipes . (run-command-recipe-ff/configure
                                 run-command-recipe-ff/docs))))
 (yaml-mode . ((eglot-workspace-configuration
                . (:yaml (:rules (:key-ordering nil
                                                :line-length nil)
                                 :schemas (:https://json.schemastore.org/github-action.json
                                           "/.github/workflows/.*"))))))
 (python-ts-mode . ((eval . (add-to-list 'flycheck-disabled-checkers 'python-flake8))
                    (eval . (add-to-list 'flycheck-disabled-checkers 'python-pylint))))
 ((bash-ts-mode sh-mode) . ((flycheck-add-next-checker . '(sh-shellcheck sh-zsh))
                            (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-dash))
                            (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-bash))
                            (eval . (add-to-list 'flycheck-disabled-checkers 'sh-bash))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;                 Docs                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ("docs"
  . ((nil . ((compile-command . "cd docs && ./build.el")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;                 Qtile               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (".config/qtile"
  . ((nil . ((python-interpreter . "~/.cache/qtile/python/bin/python3")
             (python-shell-interpreter . "~/.cache/qtile/python/bin/ipython3"))))))
