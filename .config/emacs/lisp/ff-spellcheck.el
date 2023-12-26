;;; ff-spellcheck.el --- Spellchecker setup

;;; Commentary:
;; Initialize generic spell checker for any type of files.

;;; Code:

;; --------------------------------------------------------
;; Static spell check with languagetool
;; --------------------------------------------------------

;; this is required for several, non-officially supported binaries
(require 'url)
(defun ff/download-and-extract-zip-archive (url name extract-to expected-binary-file package-name)
  "Download and install zip archives.

URL: download URL
NAME: file name (without extension)
EXTRACT-TO: path where archive should be extracted
EXPECTED-BINARY-FILE: expected binary file in the extracted folder
PACKAGE-NAME: log message context"
  (let* ((temporary-file (concat temporary-file-directory name ".zip")))
    (unless (file-directory-p extract-to) (make-directory extract-to t))
    (unless  (file-exists-p expected-binary-file)
      (unless (file-exists-p temporary-file)
        (message (concat "[" package-name "] Downloading " name " to " temporary-file))
        (url-copy-file url temporary-file))
      (message (concat "[" package-name "] Decompress " name " to " extract-to))
      (call-process-shell-command (concat "unzip " temporary-file " -d " extract-to) nil 0))))

(use-package languagetool
  :commands (languagetool-check
             languagetool-clear-suggestions
             languagetool-correct-at-point
             languagetool-correct-buffer
             languagetool-set-language
             languagetool-server-mode
             languagetool-server-start
             languagetool-server-stop)
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "unzip" "unzip")

  ;; Create directory for languagetool binaries
  (defvar langtool-version "6.3" "Version of language tool")
  (defvar langtool-name (format "LanguageTool-%s" langtool-version))
  (defvar langtool-url (format "https://languagetool.org/download/%s.zip" langtool-name))
  (defvar langtool-extract-to (expand-file-name "language-tool" no-littering-var-directory))
  (defvar langtool-path (expand-file-name langtool-name langtool-extract-to))
  (defvar langtool-server (expand-file-name "languagetool-server.jar" langtool-path))
  (defvar langtool-commandline (expand-file-name "languagetool-commandline.jar" langtool-path))
  (ff/download-and-extract-zip-archive langtool-url
                                       langtool-name
                                       langtool-extract-to
                                       langtool-commandline
                                       "langtool")
  :config
  (setq languagetool-java-arguments '("-Dfile.encoding=UTF-8")
        languagetool-default-language "en-US"
        languagetool-console-command langtool-commandline
        languagetool-server-command langtool-server)

  :bind (("C-x 4 c" . languagetool-check)
         ("C-x 4 k" . languagetool-clear-suggestions)
         ("C-x 4 p" . languagetool-correct-at-point)
         ("C-x 4 b" . languagetool-correct-buffer)))

(defun ff/switch-dictionary()
  "Switch dictionary from American English to German an vice versa."
  (interactive)
  (let* ((dic ispell-current-dictionary)
         (change (cond ((string= dic "de_DE") "en_US")
                       ((string= dic "en_US") "es")
                       ((string= dic "es") "de_DE"))))
    (ispell-change-dictionary change)
    (languagetool-set-language (replace-regexp-in-string "_" "-" change))
    (message "[languagetool, ispell] Dictionary switched from %s to %s" dic change)))

;; --------------------------------------------------------
;; On the fly spell check with aspell and flyspell
;; --------------------------------------------------------
(defun flyspell-buffer-after-pdict-save (&rest _)
  "Ignore parameters for `ispell-pdict-save'.

_: ignored parameters"
  (flyspell-buffer))

(use-package ispell
  :init
  (ff/ensure-apt-package "aspell" "aspell")
  (ff/ensure-apt-package "aspell-en" "/usr/lib/aspell/en_US.multi")
  (ff/ensure-apt-package "aspell-de" "/usr/lib/aspell/de_DE.multi")
  (ff/ensure-apt-package "aspell-es" "/usr/lib/aspell/es.multi")

  (setq ispell-dictionary "en_US"
        ispell-local-dictionary "en_US"
        ispell-program-name "/usr/bin/aspell"
        ispell-extra-args '("--dont-tex-check-comments")
        ispell-current-dictionary "en_US"
        ispell-silently-savep t
        ispell-list-command "--list")

  ;; Run flyspell-buffer after change to dictionary
  (advice-add 'ispell-pdict-save :after #'flyspell-buffer-after-pdict-save)

  ;; clear local dictionary list and set it up properly for /de_DE.UTF-8 richtig
  (setq ispell-local-dictionary-alist nil)
  (add-to-list 'ispell-local-dictionary-alist
	       '("de_DE"
 	         "[[:alpha:]]" "[^[:alpha:]]"
	         "[']" t
	         ("-C" "-d" "de_DE")
 	         "~latin1" iso-8859-1))

  ;; skip code blocks in org
  (add-to-list 'ispell-skip-region-alist '("^#+BEGIN_SRC" . "^#+END_SRC"))
  :bind (("C-c d" . ff/switch-dictionary)))

;; flyspell mode
(defun ff/flyspell-on-for-buffer-type ()
  "Enable Flyspell appropriately for the major mode of the current buffer.

  Uses `flyspell-prog-mode' for modes derived from
`prog-mode', so only strings and comments get checked.  All other
buffers get `flyspell-mode' to check all text.  If flyspell is
already enabled, does nothing."
  (interactive)
  (when (not (symbol-value flyspell-mode)) ; if not already on
    (if (derived-mode-p 'prog-mode)
        (progn
	  (message "Flyspell on (code)")
	  (flyspell-prog-mode))
      (progn
	(message "Flyspell on (text)")
	(flyspell-mode t)))))

(defun ff/flyspell-toggle ()
  "Turn Flyspell on if it is off, or off if it is on.

  When turning on, it uses `flyspell-on-for-buffer-type' so
code-vs-text is handled appropriately."
  (interactive)
  (if (symbol-value flyspell-mode)
      (progn ; flyspell is on, turn it off
	(message "Flyspell off")
	(flyspell-mode -1))
    ;; else - flyspell is off, turn it on
    (ff/flyspell-on-for-buffer-type)))

(use-package flyspell
  :hook
  (prog-mode . flyspell-prog-mode)
  (text-mode . flyspell-mode)
  (latex-mode . flyspell-mode)
  (rst-mode . flyspell-mode)
  (htm-mode . flyspell-mode)
  (html-mode . flyspell-mode)
  (org-mode . flyspell-mode)
  (emacs-lisp-mode . flyspell-mode)
  :bind
  (("C-c f" . ff/flyspell-toggle)
   ;; disable default key since it is used by embark
   :map flyspell-mode-map
   ("C-." . nil)
   ;; disable this one because it is used otherwise in org-mode
   ("M-TAB" . nil)))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-#" . flyspell-correct-wrapper)))

(use-package flyspell-correct-popup
  :after flyspell-correct)

(put 'LaTeX-mode 'flyspell-mode-predicate 'auctex-mode-flyspell-verify)
(defun auctex-mode-flyspell-verify ()
  "Function used for `flyspell-generic-check-word-predicate' in auctex mode."
  (save-excursion
    (forward-word -2)
    (not (looking-at "bibliographystyle{"))))

(add-hook 'LaTeX-mode-hook
          (lambda () (setq flyspell-generic-check-word-predicate
                           'auctex-mode-flyspell-verify)))

(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checking" t)
(autoload 'global-flyspell-mode "flyspell" "On-the-fly spelling" t)

(provide 'ff-spellcheck)

;;; ff-spellcheck.el ends here
