;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((eval . (pyvenv-deactivate))
         ;; Configure ;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
                             :runner 'ff/run-command-runner-vterm))))))
         ;; Docs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         (eval . (defun run-command-recipe-ff/docs ()
                   (append
                    (when-let* ((project-dir (locate-dominating-file default-directory ".git"))
                                (docs-dir (expand-file-name "docs" project-dir))
                                (build-script (expand-file-name "build.el" docs-dir)))
                      (list (list :command-name "sh:build"
                                  :command-line "./build.el"
                                  :working-dir docs-dir)))
                    (when-let* ((project-dir (locate-dominating-file default-directory ".git"))
                                (docs-dir (expand-file-name "docs" project-dir))
                                (publish-script (expand-file-name "publish.sh" docs-dir)))
                      (list (list :command-name "sh:publish"
                                  :command-line "./publish.sh"
                                  :working-dir docs-dir)
                            (list :command-name "sh:publish (dryrun)"
                                  :command-line "./publish.sh --dryrun"
                                  :working-dir docs-dir)))
                    (when-let* ((project-dir (locate-dominating-file default-directory ".git"))
                                (docs-dir (expand-file-name "docs" project-dir))
                                (build-script (expand-file-name "build.el" docs-dir))
                                (publish-script (expand-file-name "publish.sh" docs-dir)))
                      (list (list :command-name "sh:build_and_publish"
                                  :command-line "./build.el && ./publish.sh"
                                  :working-dir docs-dir))))))
         (run-command-recipes . (run-command-recipe-ff/configure
                                 run-command-recipe-ff/docs))))
 (yaml-mode . ((eglot-workspace-configuration
                . (:yaml (:rules (:key-ordering nil
                                                :line-length nil)
                                 :schemas (:https://json.schemastore.org/github-action.json
                                           "/.github/workflows/.*"))))))
 (python-ts-mode . ((flycheck-add-next-checker . ('python-pylint 'python-mypy))
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
