;;; setup-eaf.el --- Emacs application framework

;;; Commentary:
;; Configuration for Emacs application framework

;;; Code:

(defvar eaf-load-path (concat emacs-config-home "/site-lisp/emacs-application-framework")
  "Load path for EAF.")
(add-to-list 'load-path eaf-load-path)

(use-package eaf
  :load-path eaf-load-path)

(use-package eaf-browser
  :ensure nil
  :after (eaf)
  :custom
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  (browse-url-browser-function 'eaf-open-browser)
  (defalias 'browse-web #'eaf-open-browser))

(use-package eaf-pdf-viewer
  :ensure nil
  :after (eaf)
  :custom
  (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
  (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding))

(provide 'setup-eaf)

;;; setup-eaf.el ends here
