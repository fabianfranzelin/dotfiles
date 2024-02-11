;;; ff-ai-assistant.el --- Setup AI assistant

;;; Commentary:
;; Setup Chagpt as AI assistant

;;; Code:


;; Chagpt
(use-package gptel
  :straight (:host github :repo "karthink/gptel")
  :preface
  (defun ff/get-openai-token ()
    "Load and return the OpenAI token."
    (password-store-get "tokens/fabian.franzelin@openAI.com"))
  :custom
  (gptel-api-key #'ff/get-openai-token)
  (gptel-default-mode 'org-mode)
  (gptel-model "gpt-3.5-turbo")
  :config
  ;; auto scroll as ChatGPT provides new responses
  (add-hook 'gptel-post-stream 'gptel-auto-scroll)
  ;; move cursor to next heading when response is posted
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
  :bind (("C-c g" . gptel)))

;; GitHub copilot
(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :hook
  (python-ts-mode . copilot-mode)
  (c++-ts-mode . copilot-mode)
  (c-ts-mode . copilot-mode)
  (emacs-lisp-mode . copilot-mode)
  :config
  ;; fix indentation offset for emacs-lisp; the default depends on the
  ;; the length of the function name and cannot be set in general. I
  ;; only make it here explicit for copilot.
  (setq ff/lisp-indent-offset 2)
  (setf (alist-get 'emacs-lisp-mode copilot-indentation-alist) '(ff/lisp-indent-offset))
  (setf (alist-get 'lisp-mode copilot-indentation-alist) '(ff/lisp-indent-offset))
  :bind (:map copilot-completion-map
              ("C-e" . copilot-accept-completion)))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
