;;; ff-common.el --- Common functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Common functions that are used throughout the configuration.

;;; Code:

(defun ff/search-replace (file-path regex-str replace-str)
  "Replace content in file.
FILE-PATH: file to be changed
REGEX-STR: regular expression to be replaced
REPLACE-STR: string that replaces all regex matches"
  (interactive "P")
  (with-temp-file file-path
    (insert-file-contents file-path)
    (goto-char (point-min))
    (while (re-search-forward regex-str nil t)
      (replace-match replace-str))))

(provide 'ff-common)

;;; ff-common.el ends here
