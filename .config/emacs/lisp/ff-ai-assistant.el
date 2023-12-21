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
  :commands (gptel gptel-mode)
  :bind (("C-c g" . gptel))
  :config
  ;; move cursor to next heading when response is posted
  (add-hook 'gptel-post-response-hook #'(lambda ()
                                          (when (derived-mode-p 'org-mode)
                                            (org-forward-element)
                                            (org-end-of-line))))

  (setq gptel-api-key #'ff/get-openai-token
        gptel-default-mode 'org-mode))

;; GitHub copilot
(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :hook ((python-ts-mode . copilot-mode)
         (c++-ts-mode . copilot-mode)
         (c-ts-mode . copilot-mode)
         (emacs-lisp-mode . copilot-mode))
  :bind (:map copilot-completion-map
              ("C-e" . copilot-accept-completion)))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
