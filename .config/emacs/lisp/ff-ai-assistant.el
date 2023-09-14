;;; ff-ai-assistant.el --- Setup AI assistant

;;; Commentary:
;; Setup Chagpt as AI assistant

;;; Code:

(straight-use-package
 '(gptel
   :type git
   :host github
   :repo "karthink/gptel"))

(defun ff/get-openai-token ()
  "Load and return the OpenAI token."
  (password-store-get "tokens/fabian.franzelin@openAI.com"))

(with-eval-after-load 'gptel
  ;; move cursor to next heading when response is posted
  (add-hook 'gptel-post-response-hook #'(lambda ()
                                          (when (derived-mode-p 'org-mode)
                                            (org-forward-element)
                                            (org-end-of-line))))

  ;; load the api key from password store and use org-mode as default
  (setq gptel-api-key #'ff/get-openai-token
        gptel-default-mode 'org-mode))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
