;;; setup-spellcheck.el --- Spellchecker setup

;;; Commentary:
;; Initialize generic spell checker for any type of files.

;;; Code:

;; --------------------------------------------------------
;; Static spell check with languagetool
;; --------------------------------------------------------

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
  (defvar langtool-version "5.8")
  (defvar langtool-name (concat "LanguageTool-" langtool-version))
  (defvar langtool-url (concat "https://languagetool.org/download/" langtool-name ".zip"))
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
         ("C-x 4 d" . languagetool-clear-suggestions)
         ("C-x 4 p" . languagetool-correct-at-point)
         ("C-x 4 b" . languagetool-correct-buffer)))

(defun fd-switch-dictionary()
  "Switch dictionary from American English to German an vice versa."
  (interactive)
  (let* ((dic ispell-current-dictionary)
         (change (if (string= dic "de_DE") "en_US" "de_DE")))
    (ispell-change-dictionary change)
    (languagetool-set-language (replace-regexp-in-string "_" "-" change))
    (message "[languagetool, ispell] Dictionary switched from %s to %s" dic change)))

;; --------------------------------------------------------
;; On the fly spell check with aspell and flyspell
;; --------------------------------------------------------
(defun flyspell-buffer-after-pdict-save (&rest _)
  (flyspell-buffer))

(use-package ispell
  :init
  (ff/ensure-apt-package "aspell" "aspell")
  (ff/ensure-apt-package "aspell-en" "/usr/lib/aspell/en_US.multi")
  (ff/ensure-apt-package "aspell-de" "/usr/lib/aspell/de_DE.multi")

  (setq ispell-dictionary "en_US"
        ispell-local-dictionary "en_US"
        ispell-program-name "/usr/bin/aspell"
        ispell-extra-args '("--dont-tex-check-comments")
        ispell-current-dictionary "en_US"
        ispell-silently-savep t
        ispell-list-command "--list")

  ;; Run flyspell-buffer after change to dictionary
  (advice-add 'ispell-pdict-save :after #'flyspell-buffer-after-pdict-save)

  ;; alist leeren und für aspell /de_DE.UTF-8 richtig einstellen:
  (setq ispell-local-dictionary-alist nil)
  (add-to-list 'ispell-local-dictionary-alist
	           '("de_DE"
 	             "[[:alpha:]]" "[^[:alpha:]]"
	             "[']" t
	             ("-C" "-d" "de_DE")
 	             "~latin1" iso-8859-1))

  ;; skip code blocks in org
  (add-to-list 'ispell-skip-region-alist '("^#+BEGIN_SRC" . "^#+END_SRC"))

  :bind (("<f4>" . fd-switch-dictionary)))

;; flyspell mode

(defun ff/flyspell-on-for-buffer-type ()
  "Enable Flyspell appropriately for the major mode of the current
buffer.  Uses `flyspell-prog-mode' for modes derived from
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
  "Turn Flyspell on if it is off, or off if it is on.  When turning
on, it uses `flyspell-on-for-buffer-type' so code-vs-text is
handled appropriately."
  (interactive)
  (if (symbol-value flyspell-mode)
	  (progn ; flyspell is on, turn it off
	    (message "Flyspell off")
	    (flyspell-mode -1))
    ;; else - flyspell is off, turn it on
	(ff/flyspell-on-for-buffer-type)))

(use-package flyspell
  :hook ((prog-mode . flyspell-prog-mode)
         (text-mode . flyspell-mode)
         (latex-mode . flyspell-mode)
         (rst-mode . flyspell-mode)
         (htm-mode . flyspell-mode)
         (html-mode . flyspell-mode)
         (org-mode . flyspell-mode))
  :bind (("C-c f" . ff/flyspell-toggle)))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-." . flyspell-correct-wrapper)))

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

(provide 'setup-spellcheck)

;;; setup-spellcheck.el ends here
