;;; ff-spellcheck.el --- Spellchecker setup  -*- lexical-binding: t; -*-

;;; Commentary:
;; Initialize generic spell checker for any type of files.

;;; Code:

;; ----------------------
;; On the fly spell check
;; ----------------------
(use-package jinx
  :ensure-system-package aspell
  :preface
  (ff/ensure-apt-package "enchant-2" "enchant-2")
  (ff/ensure-apt-package "libenchant-2-dev" "/usr/include/enchant-2/enchant.h")
  (ff/ensure-apt-package "aspell-en" "/usr/lib/aspell/en_US.multi")
  (ff/ensure-apt-package "aspell-de" "/usr/lib/aspell/de_DE.multi")
  (ff/ensure-apt-package "aspell-es" "/usr/lib/aspell/es.multi")
  :hook
  (after-init . global-jinx-mode)
  :custom
  (jinx-save-languages nil)
  :bind
  (:map global-map
        ("M-$" . jinx-correct)
        ("C-M-$" . jinx-languages)))

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
  :preface
  ;; ensure system packages
  (ff/ensure-apt-package "unzip" "unzip")
  ;; Create directory for languagetool binaries
  (defvar langtool-version "6.6" "Version of language tool")
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
  (customize-set-variable 'languagetool-java-arguments '("-Dfile.encoding=UTF-8"))
  (customize-set-variable 'languagetool-default-language "en-US")
  (customize-set-variable 'languagetool-console-command langtool-commandline)
  (customize-set-variable 'languagetool-server-command langtool-server)

  :bind
  (:map global-map
        ("C-x 4 c" . languagetool-check)
        ("C-x 4 k" . languagetool-clear-suggestions)
        ("C-x 4 p" . languagetool-correct-at-point)
        ("C-x 4 b" . languagetool-correct-buffer)))


(with-eval-after-load 'jinx
  (defun ff/switch-dictionary(LANGS &optional GLOBAL)
    "Switch dictionary for non-jinx packages to currently selected by jinx.
This includes ispell and languagetool."
    (let* ((dic jinx-languages))
      (ispell-change-dictionary dic)
      (languagetool-set-language (replace-regexp-in-string "_" "-" dic))))

  (advice-add 'jinx-languages :after #'ff/switch-dictionary))

(provide 'ff-spellcheck)

;;; ff-spellcheck.el ends here
