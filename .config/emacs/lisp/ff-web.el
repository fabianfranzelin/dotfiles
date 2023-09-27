;;; ff-web.el --- Browser setup

;;; Commentary:
;; Configuration for eww and firefox
;; Inspired by https://github.com/dakrone/eos/blob/master/eos-web.org

;;; Code:

(use-package eww
  :custom
  ;; (shr-external-browser 'browse-url-generic)
  (browse-url-generic-program (or (executable-find "firefox")
                                  (executable-find "xdg-browser")))
  (browse-url-browser-function '((".*google.*maps.*" . browse-url-generic)
                                 ;; Github goes to firefox, but not gist
                                 ("http.*\/\/github.com" . browse-url-generic)
                                 ("groups.google.com" . browse-url-generic)
                                 ("docs.google.com" . browse-url-generic)
                                 ("melpa.org" . browse-url-generic)
                                 ("build.*\.elastic.co" . browse-url-generic)
                                 (".*-ci\.elastic.co" . browse-url-generic)
                                 ("gradle-enterprise.elastic.co" . browse-url-generic)
                                 ("internal-ci\.elastic\.co" . browse-url-generic)
                                 ("zendesk\.com" . browse-url-generic)
                                 ("salesforce\.com" . browse-url-generic)
                                 ("stackoverflow\.com" . browse-url-generic)
                                 ("apache\.org\/jira" . browse-url-generic)
                                 ("thepoachedegg\.net" . browse-url-generic)
                                 ("zoom.us" . browse-url-generic)
                                 ("t.co" . browse-url-generic)
                                 ("twitter.com" . browse-url-generic)
                                 ("\/\/a.co" . browse-url-generic)
                                 ("youtube.com" . browse-url-generic)
                                 ("amazon.com" . browse-url-generic)
                                 ("slideshare.net" . browse-url-generic)
                                 ("." . eww-browse-url)))
  :hook
  (eww-mode . toggle-word-wrap)
  (eww-mode . visual-line-mode)
  :bind (:map eww-mode-map
              ("o" . eww)
              ("O" . eww-browse-with-external-browser)
              ("C-n" . next-line)
              ("C-p" . previous-line)))

(use-package s
  :after eww)

(use-package eww-lnum
  :after eww
  :bind (:map eww-mode-map
              ("f" . eww-lnum-follow eww-mode-map)
              ("U" . eww-lnum-universal eww-mode-map)))

(use-package link-hint
  :ensure t
  :bind ("C-c f" . link-hint-open-link))

(defun browse-last-url-in-brower ()
  (interactive)
  (save-excursion
    (ffap-next-url t t)))

(global-set-key (kbd "C-c u") 'browse-last-url-in-brower)

(provide 'ff-web)

;;; ff-web.el ends here
