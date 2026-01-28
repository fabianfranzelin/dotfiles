;;; ff-ai-assistant.el --- Setup AI assistant  -*- lexical-binding: t; -*-

;;; Commentary:
;; Setup ChaGPT and Copilot as AI assistant

;;; Code:

(defun ff/get-openai-token ()
  "Load and return the OpenAI token."
  (password-store-get "tokens/fabian.franzelin@openAI.com"))
(defun ff/get-gemini-token ()
  "Load and return the Gemini token."
  (password-store-get "tokens/fabian.franzelin@gemini"))

;; ChaGPT
(use-package gptel
  :straight (:host github :repo "karthink/gptel")
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-model 'gemini-2.0-flash)
  :config
  ;; auto scroll as ChatGPT provides new responses
  (add-hook 'gptel-post-stream 'gptel-auto-scroll)
  ;; move cursor to next heading when response is posted
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
  ;; make copilot the default backend for gptel
  (setq gptel-model 'gpt-5-mini
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  ;; disable Gemini for now
  (when nil
    (setq gptel-backend (gptel-make-gemini "Gemini"
                          :key #'ff/get-gemini-token
                          :stream t)))
  :bind (("C-c g" . gptel)))

(use-package copilot
  :if (or (string= (system-name) "ABT-C-002NY")
          (string= (system-name) "pauline"))
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("dist" "*.el"))
  :hook
  (python-ts-mode . copilot-mode)
  (c++-ts-mode . copilot-mode)
  (c-ts-mode . copilot-mode)
  (emacs-lisp-mode . copilot-mode)
  (markdown-mode . copilot-mode)
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
  (setf (alist-get 'markdown-mode copilot-indentation-alist) '(ff/markdown-indent-offset))

  (setq ff/rst-indent-offset 2)
  (setf (alist-get 'rst-mode copilot-indentation-alist) '(ff/rst-indent-offset))

  (setq ff/bazel-indent-offset 4)
  (setf (alist-get 'bazel-mode copilot-indentation-alist) '(ff/bazel-indent-offset))

  :bind (:map copilot-completion-map
              ("C-e" . copilot-accept-completion)))

(use-package agent-shell
  :ensure-system-package
  ;; Add agent installation configs here
  ((opencode . "npm i -g opencode-ai")))
(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
