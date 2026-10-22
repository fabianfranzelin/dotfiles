;;; ff-spellcheck.el --- Spellchecker setup  -*- lexical-binding: t; -*-

;;; Commentary:
;; Initialize generic spell checker for any type of files.

;;; Code:

;; --------------------------------------------
;; Linting prose with proselint and codespell
;; --------------------------------------------
;; Prose linting is provided by native flymake backends (proselint and
;; codespell via flymake-collection)
(ff/ensure-python-package "proselint" nil "proselint")
(ff/ensure-python-package "codespell" nil "codespell")

(use-package flymake-collection
  :commands (flymake-collection-proselint flymake-collection-codespell))

(defun ff/prose-flymake-english-p ()
  "Return non-nil when the current buffer's spell language is English.

`proselint' and `codespell' are English-only tools that ignore the
ispell/jinx/languagetool language entirely, so they must not run on
buffers detected as another language."
  (let ((lang (or (and (bound-and-true-p jinx-languages)
                       (stringp jinx-languages)
                       jinx-languages)
                  (bound-and-true-p ispell-local-dictionary)
                  (bound-and-true-p ispell-dictionary))))
    ;; When no language is known yet, default to enabling (English docs
    ;; are the common case and detection may not have run yet).
    (or (null lang)
        (and (stringp lang) (string-prefix-p "en" lang)))))

(defun ff/sync-prose-flymake (&rest _)
  "Enable English-only prose checkers only for English buffers.

Added to `ff/language-switched-hook' so the backends toggle whenever the
detected language changes."
  (when (derived-mode-p 'text-mode 'org-mode 'markdown-ts-mode 'rst-mode)
    (if (ff/prose-flymake-english-p)
        (progn
          (add-hook 'flymake-diagnostic-functions #'flymake-collection-proselint nil t)
          (add-hook 'flymake-diagnostic-functions #'flymake-collection-codespell nil t))
      (remove-hook 'flymake-diagnostic-functions #'flymake-collection-proselint t)
      (remove-hook 'flymake-diagnostic-functions #'flymake-collection-codespell t))
    (when (bound-and-true-p flymake-mode)
      (flymake-start))))

(defun ff/configure-prose-flymake ()
  "Enable native flymake prose checkers (proselint and codespell).

Only registers the English-only checkers when the buffer language is
English; see `ff/prose-flymake-english-p'."
  (ff/sync-prose-flymake)
  (flymake-mode 1))

;; Re-evaluate the English-only checkers whenever language detection
;; changes the active dictionary.
(add-hook 'ff/language-switched-hook #'ff/sync-prose-flymake)

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

(defvar ff/language-switched-hook nil
  "Hook run after `jinx-languages' changes and downstream dictionaries sync.")

(with-eval-after-load 'jinx
  (defun ff/switch-dictionary (&optional _langs _global)
    "Sync ispell and flymake-languagetool with the current `jinx-languages'."
    (let ((dic jinx-languages))
      (when (and dic (stringp dic))
        (ispell-change-dictionary dic)
        (setq-local flymake-languagetool-language
                    (replace-regexp-in-string "_" "-" dic))
        (when (bound-and-true-p flymake-mode)
          (flymake-start))
        (run-hooks 'ff/language-switched-hook))))

  (advice-add 'jinx-languages :after #'ff/switch-dictionary))

;; ----------------------------------------------------
;; Auto-detect buffer language and configure jinx
;; ----------------------------------------------------
(use-package guess-language
  :after jinx
  :custom
  (guess-language-languages '(en de es))
  (guess-language-min-paragraph-length 20)
  (guess-language-langcodes
   '((en . ("en_US" nil "🇬🇧" "English"))
     (de . ("de_DE" nil "🇩🇪" "German"))
     (es . ("es"    nil "🇪🇸" "Spanish"))))
  :config
  (defun ff/guess-language-of-body ()
    "Detect language of the current buffer's prose content.
In `message-mode', narrow to the body so headers do not skew detection,
and exclude the signature block so a foreign-language signature does not
mislead detection."
    (save-restriction
      (let ((beg (point-min))
            (end (point-max)))
        (when (derived-mode-p 'message-mode)
          (save-excursion
            (goto-char (point-min))
            (when (search-forward mail-header-separator nil t)
              (setq beg (line-beginning-position 2))))
          (save-excursion
            (goto-char (point-max))
            (when (re-search-backward "^-- $" beg t)
              (setq end (point)))))
        (narrow-to-region beg end))
      (ignore-errors (guess-language-buffer))))

  (defun ff/jinx-guess-buffer-language ()
    "Detect buffer language and set `jinx-languages' accordingly."
    (interactive)
    (when (and (bound-and-true-p jinx-mode)
               (not (bound-and-true-p ff/jinx-language-guessed)))
      (if (<= (buffer-size) 200)
          (when (called-interactively-p 'interactive)
            (message "[jinx-guess] Buffer too small (%d chars, need > 200) to detect language"
                     (buffer-size)))
        (condition-case err
            (let* ((lang (ff/guess-language-of-body))
                   (code (car (alist-get lang guess-language-langcodes))))
              (when code
                (setq-local jinx-languages code)
                (setq-local ff/jinx-language-guessed t)
                (jinx--load-dicts)
                (jinx--cleanup)
                (ff/switch-dictionary)))
          (error (message "[jinx-guess] %s" (error-message-string err)))))))

  (dolist (hook '(text-mode-hook
                  org-mode-hook
                  markdown-mode-hook
                  latex-mode-hook
                  message-setup-hook))
    (add-hook hook #'ff/jinx-guess-buffer-language))
  :bind
  (:map global-map
        ("C-x 4 l" . ff/jinx-guess-buffer-language)))

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

(use-package flymake-languagetool
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
  (ff/download-and-extract-zip-archive langtool-url
                                       langtool-name
                                       langtool-extract-to
                                       langtool-server
                                       "langtool")
  :init
  ;; Local server started automatically from the downloaded jar.
  (setq flymake-languagetool-server-jar langtool-server)
  ;; Spelling is handled by jinx; keep LanguageTool to grammar/style only.
  (setq flymake-languagetool-check-spelling nil)
  (setq flymake-languagetool-language "en-US")
  ;; Keep grammar checks out of the hot typing path: only check when idle.
  (setq flymake-no-changes-timeout 3)
  :hook
  (text-mode . flymake-languagetool-load)
  (org-mode . flymake-languagetool-load)
  (markdown-mode . flymake-languagetool-load)
  (latex-mode . flymake-languagetool-load)
  (message-mode . flymake-languagetool-load)
  :bind
  (:map global-map
        ("C-x 4 c" . flymake-languagetool-correct)
        ("C-x 4 p" . flymake-languagetool-correct-at-point)
        ("C-x 4 b" . flymake-show-buffer-diagnostics)))

(provide 'ff-spellcheck)

;;; ff-spellcheck.el ends here
