;;; ff-direnv.el --- Per-buffer direnv/Nix environments -*- lexical-binding: t; -*-

;;; Commentary:
;; Buffers below a directory with an .envrc (e.g. a Nix flake dev shell
;; loaded through nix-direnv) get their own `process-environment' and
;; `exec-path'.  eglot, compile, flymake, apheleia, dape, magit, ... thus
;; run inside the project environment, while the rest of Emacs keeps the
;; host environment.
;;
;; Exceptions that intentionally keep the host environment:
;; - AI agents (agent-shell, copilot), which need host node/opencode
;; - vterm: zsh starts with the host environment and its own direnv hook
;;   switches to the project environment at the first prompt
;;
;; This module must be required last in init.el, so that
;; `envrc-global-mode' is enabled after all other global minor modes.

;;; Code:

(use-package inheritenv
  :demand t)

(use-package envrc
  :demand t
  :custom
  (envrc-show-summary-in-minibuffer t)
  :config
  ;; run late in after-init, i.e. after all other global minor modes
  (add-hook 'after-init-hook #'envrc-global-mode 90)
  :bind (:map envrc-mode-map
              ("C-c E" . envrc-command-map)))

;; -------------------------------------------------------------------
;; Propagate the buffer environment to processes started from temp buffers
(with-eval-after-load 'apheleia
  (when (fboundp 'apheleia--run-formatter-process)
    (advice-add 'apheleia--run-formatter-process :around #'envrc-propagate-environment)))

;; -------------------------------------------------------------------
;; Host environment for selected tools

(defun ff/direnv-with-global-env (orig &rest args)
  "Call ORIG with ARGS using the global (host) environment."
  (let ((process-environment (default-value 'process-environment))
        (exec-path (default-value 'exec-path)))
    (apply orig args)))

(defvar ff/direnv-excluded-modes '(agent-shell-mode vterm-mode)
  "Major modes in which `envrc-mode' is not enabled.")

(defun ff/direnv-maybe-skip (orig &rest args)
  "Do not enable `envrc-mode' (ORIG with ARGS) in `ff/direnv-excluded-modes'."
  (unless (and (apply #'derived-mode-p ff/direnv-excluded-modes)
               (not (eq (car args) -1)))
    (apply orig args)))

(with-eval-after-load 'envrc
  (advice-add 'envrc-mode :around #'ff/direnv-maybe-skip))

(with-eval-after-load 'copilot
  (advice-add 'copilot--start-agent :around #'ff/direnv-with-global-env))

(with-eval-after-load 'agent-shell
  (dolist (fn '(agent-shell
                agent-shell-opencode-start-agent
                agent-shell-goose-start-agent))
    (advice-add fn :around #'ff/direnv-with-global-env)))

(provide 'ff-direnv)

;;; ff-direnv.el ends here
