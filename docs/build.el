#!/usr/bin/emacs -x

;;; build.el --- Build the org notes into HTML files -*- lexical-binding: t; -*-
;;; Commentary:
;; Entrypoint script. Loads modules from lisp/ and runs the build.
;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" default-directory))

(require 'ff-packages)
(require 'ff-org-config)
(require 'ff-html-theme)
(require 'ff-publish-locally)

(ff/publish-locally)

;;; build.el ends here
