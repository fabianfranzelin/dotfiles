;;; ff-ai-assistant.el --- Setup AI assistant  -*- lexical-binding: t; -*-

;;; Commentary:
;; Setup ChaGPT and Copilot as AI assistant

;;; Code:

(use-package copilot
  :if (or (string= (system-name) "FEWI-C-0007J")
          (string= (system-name) "pauline"))
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("dist" "*.el"))
  :hook
  (python-ts-mode . copilot-mode)
  (c++-ts-mode . copilot-mode)
  (c-ts-mode . copilot-mode)
  (emacs-lisp-mode . copilot-mode)
  (markdown-ts-mode . copilot-mode)
  (rst-mode . copilot-mode)
  (bazel-mode . copilot-mode)
  :custom
  (copilot-max-char 100000000)
  :config
  ;; fix indentation offset for emacs-lisp; the default depends on the
  ;; the length of the function name and cannot be set in general. I
  ;; only make it here explicit for copilot.
  (setq ff/lisp-indent-offset 2)
  (setf (alist-get 'emacs-lisp-mode copilot-indentation-alist) '(ff/lisp-indent-offset))
  (setf (alist-get 'lisp-mode copilot-indentation-alist) '(ff/lisp-indent-offset))

  (setq ff/markdown-indent-offset 2)
  (setf (alist-get 'markdown-ts-mode copilot-indentation-alist) '(ff/markdown-indent-offset))

  (setq ff/rst-indent-offset 2)
  (setf (alist-get 'rst-mode copilot-indentation-alist) '(ff/rst-indent-offset))

  (setq ff/bazel-indent-offset 4)
  (setf (alist-get 'bazel-mode copilot-indentation-alist) '(ff/bazel-indent-offset))

  :bind (:map copilot-completion-map
              ("C-e" . copilot-accept-completion)))

(use-package agent-shell
  :ensure-system-package
  ;; Add agent installation configs here
  ((opencode . "npm i -g opencode-ai"))
  ((copilot . "npm install -g @github/copilot"))
  :custom
  (agent-shell-preferred-agent-config 'opencode)
  (agent-shell-goose-authentication
   (agent-shell-make-goose-authentication :none t))
  :config
  (setopt agent-shell-show-cost-indicator t)
  (setopt agent-shell-opencode-default-config-options
          `(("model" . ,(if (string= (system-name) "FEWI-C-0007J")
                            "github-copilot/claude-opus-4.7"
                          "github-copilot/gpt-5-mini"))
            ("effort" . "high")
            ("mode" . "plan")))

  :bind (:map global-map
              ("C-x a a" . agent-shell)
              ("C-x a g" . agent-shell-goose-start-agent)
              ("C-x a o" . agent-shell-opencode-start-agent)))

(use-package agent-shell-tramp
  :straight (:host github :repo "junyi-hou/agent-shell-tramp")
  :after agent-shell
  :config
  (agent-shell-tramp-mode 1))

(use-package agent-review
  :straight (agent-review :type git :host github :repo "nineluj/agent-review")
  :bind (:map global-map
              ("C-c r" . agent-review)))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
