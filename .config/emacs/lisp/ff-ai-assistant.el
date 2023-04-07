;;; ff-ai-assistant.el --- Setup AI assistant

;;; Commentary:
;; Setup Chagpt as AI assistant

;;; Code:

(straight-use-package
 '(gptel
   :type git
   :host github
   :repo "karthink/gptel"))

(provide 'ff-ai-assistant)

;;; ff-ai-assistant.el ends here
