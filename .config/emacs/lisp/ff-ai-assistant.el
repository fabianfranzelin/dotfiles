;;; ff-ai-assistant.el --- Setup AI assistant

;;; Commentary:
;; Setup Chagpt as AI assistant

;;; Code:

(straight-use-package
 '(gptel
   :type git
   :host github
   :repo "karthink/gptel")
 :config
 (setq gptel-api-key (password-store-get "Tokens/OpenAI")))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
