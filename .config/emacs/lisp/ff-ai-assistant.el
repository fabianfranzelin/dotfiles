;;; ff-ai-assistant.el --- Setup AI assistant

;;; Commentary:
;; Setup Chagpt as AI assistant

;;; Code:

(straight-use-package
 '(gptel
   :type git
   :host github
   :repo "karthink/gptel"))

(add-hook 'gptel-post-response-hook #'(lambda ()
                                        (org-forward-element)
                                        (org-end-of-line)))
(setq gptel-api-key (password-store-get "Tokens/OpenAI")
      gptel-default-mode 'org-mode)

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
