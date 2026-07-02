;;; ff-config.el --- Shared configuration variables -*- lexical-binding: t; -*-
;;; Commentary:
;; Central place for directory paths and user identity used across build modules.
;;; Code:

(defvar ff/user-full-name "Fabian Franzelin"
  "Author name used in exports.")

(defvar ff/user-mail-address "fabian.franzelin@gmail.com"
  "Author email used in exports.")

(defvar ff/base-dir (expand-file-name "./content")
  "Source directory for org content.")

(defvar ff/public-dir "./public"
  "Output directory for published files.")

(provide 'ff-config)
;;; ff-config.el ends here
