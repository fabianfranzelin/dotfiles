;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((python-mode . ((flycheck-add-next-checker . ('python-pylint 'python-mypy))
                 (eval . (add-to-list 'flycheck-disabled-checkers 'python-flake8))))
 (sh-mode . ((flycheck-add-next-checker . '(sh-shellcheck sh-zsh))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-dash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-posix-bash))
             (eval . (add-to-list 'flycheck-disabled-checkers 'sh-bash)))))
