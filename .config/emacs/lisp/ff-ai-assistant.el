;;; ff-ai-assistant.el --- Setup AI assistant  -*- lexical-binding: t; -*-

;;; Commentary:
;; Setup ChaGPT and Copilot as AI assistant

;;; Code:

;; ChaGPT
(use-package gptel
  :straight (:host github :repo "karthink/gptel")
  :preface
  (defun ff/get-openai-token ()
    "Load and return the OpenAI token."
    (password-store-get "tokens/fabian.franzelin@openAI.com"))
  (defun ff/get-gemini-token ()
    "Load and return the OpenAI token."
    (password-store-get "tokens/fabian.franzelin@gemini"))
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-model 'gemini-2.0-flash)
  :config
  ;; auto scroll as ChatGPT provides new responses
  (add-hook 'gptel-post-stream 'gptel-auto-scroll)
  ;; move cursor to next heading when response is posted
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
  ;; make copilot the default backend for gptel when on ABT C-002NY
  (if (string= (system-name) "ABT-C-002NY")
      (setq gptel-model 'claude-3.5-sonnet
            gptel-backend (gptel-make-gh-copilot "Copilot"))
    ;; otherwise use gemini
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

  :bind (:map copilot-completion-map
              ("C-e" . copilot-accept-completion)))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
