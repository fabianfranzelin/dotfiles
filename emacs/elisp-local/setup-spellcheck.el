;;; setup-spellcheck.el --- Spellchecker setup

;;; Commentary:
;; Initialize generic spell checker for any type of files.

;;; Code:

;; --------------------------------------------------------
;; Static spell check with languagetool
;; --------------------------------------------------------
(use-package languagetool
  :init
  (setq langtool-version "5.4"
        langtool-name (concat "LanguageTool-" langtool-version)
        langtool-url (concat "https://languagetool.org/download/" langtool-name ".zip")
        langtool-extract-to (expand-file-name "~/opt/languageTool")
        langtool-expected-binary (concat langtool-extract-to "/" langtool-name "/languagetool-commandline.jar"))
  (ff/download-and-extract-zip-archive langtool-url
                                       langtool-name
                                       langtool-extract-to
                                       langtool-expected-binary
                                       "langtool")
  :config
  (setq languagetool-language-tool-jar langtool-expected-binary
        languagetool-java-arguments '("-Dfile.encoding=UTF-8")
        languagetool-default-language "en-US")

  :bind (("C-x 4 c" . languagetool-check)
         ("C-x 4 d" . languagetool-clear-buffer)
         ("C-x 4 p" . languagetool-correct-at-point)
         ("C-x 4 b" . languagetool-correct-buffer)))

(defun fd-switch-dictionary()
  "Switch dictionary from American English to German an vice versa."
  (interactive)
  (let* ((dic ispell-current-dictionary)
         (change (if (string= dic "de_DE") "en_US" "de_DE")))
    (ispell-change-dictionary change)
    (message "[ispell] Dictionary switched from %s to %s" dic change))
  (let* ((dic ispell-current-dictionary)
         (change (if (string= dic "de_DE") "de-DE" "en-US")))
    (languagetool-set-language change)
    (message "[languagetool] Dictionary switched to %s" change)))

;; --------------------------------------------------------
;; On the fly spell check with aspell and flyspell
;; --------------------------------------------------------
(use-package ispell
  :ensure-system-package (("/usr/bin/aspell" . aspell)
                          ("/usr/lib/aspell/en_US.multi" . aspell-en)
                          ("/usr/lib/aspell/de_DE.multi" . apsell-de)
                          ("/usr/bin/ispell" . ispell)
                          ("/usr/lib/ispell/american-insane.hash" . iamerican-insane)
                          ("/usr/lib/ispell/ngerman.hash" . ingerman))
  :init
  (setq ispell-dictionary "en_US"
        ispell-local-dictionary "en_US"
        ispell-program-name "/usr/bin/aspell"
        ispell-extra-args '("--dont-tex-check-comments")
        ispell-current-dictionary "en_US"
        ispell-silently-savep t)

  ;; alist leeren und für aspell /de_DE.UTF-8 richtig einstellen:
  (setq ispell-local-dictionary-alist nil)
  (add-to-list 'ispell-local-dictionary-alist
	           '("de_DE"
 	             "[[:alpha:]]" "[^[:alpha:]]"
	             "[']" t
	             ("-C" "-d" "de_DE")
 	             "~latin1" iso-8859-1)
 	           )
  :bind (("<f4>" . fd-switch-dictionary))
  :hook ((text-mode . flyspell-mode)
         (rst-mode . flyspell-mode)
         (htm-mode . flyspell-mode)
         (html-mode . flyspell-mode)))

;; flyspell mode
(require 'flyspell)

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
