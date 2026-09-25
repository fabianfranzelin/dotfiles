;;; ff-messaging.el --- Email and news setup -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Gnus + SMTP (Gmail) with GPG signing.
;;
;; Prerequisites (configured elsewhere):
;;   - `user-full-name' / `user-mail-address' -> ff-core
;;   - `auth-sources' via `auth-source-pass'  -> ff-core
;;     (credentials come from the password-store `authinfo.gpg' entry)
;;
;; Layout of this file:
;;   1. Gmail helpers        - move-to / archive / report-spam
;;   2. Summary keybindings  - hook installing `y' and `$'
;;   3. Security (mml-sec)   - PGP signing + encrypt-to-self
;;   4. Transport (smtpmail) - Gmail SMTP over STARTTLS
;;   5. Signatures           - language-aware mail signatures
;;   6. Contacts             - local encrypted EBDB address book
;;   7. Reader (gnus)        - IMAP account + basic behaviour
;;   8. Dired integration    - attach files from Dired

;;; Code:


;;;; 1. Gmail helpers ---------------------------------------------------------

(defconst ff/gmail-imap-prefix "nnimap+imap.gmail.com:[Gmail]/"
  "Prefix identifying Gmail system folders in nnimap.")

(defun ff/gmail-move-to (folder)
  "Move current or marked article(s) to Gmail FOLDER."
  (gnus-summary-move-article nil (concat ff/gmail-imap-prefix folder)))

;;;###autoload
(defun ff/gmail-archive ()
  "Archive current or marked mails into [Gmail]/All Mail."
  (interactive)
  (ff/gmail-move-to "All Mail"))

;;;###autoload
(defun ff/gmail-report-spam ()
  "Report current or marked mails as spam ([Gmail]/Spam)."
  (interactive)
  (ff/gmail-move-to "Spam"))

;;;; 2. Summary keybindings ---------------------------------------------------

(defun ff/gnus-summary-keys ()
  "Install Gmail keybindings in `gnus-summary-mode'."
  (local-set-key (kbd "y") #'ff/gmail-archive)
  (local-set-key (kbd "$") #'ff/gmail-report-spam))


;;;; 3. Security -- PGP signing -----------------------------------------------

(defun ff/openpgp-self-key ()
  "Return the fingerprint of the default OpenPGP secret key.
Look up the key associated with `user-mail-address' via EPG; fall back
to the first available secret key.  Returning nil lets gpg pick its own
`default-key' downstream."
  (require 'epg)
  (let* ((context (epg-make-context 'OpenPGP))
         (keys (or (epg-list-keys context user-mail-address 'secret)
                   (epg-list-keys context nil 'secret))))
    (when keys
      (epg-sub-key-fingerprint
       (car (epg-key-sub-key-list (car keys)))))))

(use-package mml-sec
  :straight (:type built-in)
  :custom
  ;; Leave `mml-secure-openpgp-signers' unset so gpg picks its own
  ;; `default-key' when signing outgoing mail.
  (mml-secure-openpgp-encrypt-to-self t))


;;;; 4. Transport -- Gmail SMTP -----------------------------------------------

(use-package smtpmail
  :straight (:type built-in)
  :custom
  (smtpmail-smtp-server "smtp.gmail.com")
  (smtpmail-smtp-service 587)
  (smtpmail-stream-type 'starttls)
  (send-mail-function 'smtpmail-send-it)
  (message-send-mail-function 'smtpmail-send-it))


;;;; 5. Signatures ------------------------------------------------------------

(defgroup ff-messaging nil
  "Email and news setup."
  :group 'mail)

(defcustom ff/message-signatures
  '(("en_US" . "Best regards,\nFabian")
    ("de_DE" . "Viele Grüße,\nFabian")
    ("es"    . "Saludos,\nFabian"))
  "Mail signatures keyed by jinx/aspell locale code."
  :type '(alist :key-type string :value-type string)
  :group 'ff-messaging)

(defun ff/message-signature-by-language ()
  "Return a signature string based on the message body language."
  (let* ((lang (when (fboundp 'ff/guess-language-of-body)
                 (ff/guess-language-of-body)))
         (code (and lang
                    (boundp 'guess-language-langcodes)
                    (car (alist-get lang guess-language-langcodes))))
         (sig (or (cdr (assoc code ff/message-signatures))
                  (cdr (assoc "en_US" ff/message-signatures)))))
    sig))

(defun ff/message-refresh-signature ()
  "Replace the signature in the current message buffer."
  (interactive)
  (when (derived-mode-p 'message-mode)
    (save-excursion
      (when (message-goto-signature)
        (forward-line -1)
        (delete-region (point) (point-max)))
      (goto-char (point-max))
      (message-insert-signature))))

(add-hook 'ff/language-switched-hook #'ff/message-refresh-signature)


;;;; 6. Contacts --------------------------------------------------------------

(defvar ff/password-store-directory
  (or (getenv "PASSWORD_STORE_DIR")
      (expand-file-name "~/.password-store"))
  "Password-store directory used for encrypted contact storage.")

(defvar ff/ebdb-file
  (expand-file-name "contacts/ebdb.gpg" ff/password-store-directory)
  "Encrypted EBDB database file stored inside the password-store tree.")

(defun ff/ebdb-set-encrypt-to ()
  "Ensure the EBDB database is encrypted to the default OpenPGP key.
Set as a buffer-local variable so EPA never prompts on save."
  (when (and buffer-file-name
             (string= (file-truename buffer-file-name)
                      (file-truename ff/ebdb-file)))
    (when-let* ((key (ff/openpgp-self-key)))
      (setq-local epa-file-encrypt-to (list key)))))

(add-hook 'find-file-hook #'ff/ebdb-set-encrypt-to)

(defun ff/ebdb-update-message-recipients ()
  "Create or update EBDB records for recipients of the current message,
then persist the database to disk so new contacts survive Emacs exit."
  (require 'ebdb)
  (let (touched)
    (dolist (header '("To" "Cc" "Bcc"))
      (when-let* ((value (message-fetch-field header))
                  (addresses (mail-extract-address-components value t)))
        (ebdb-update-records addresses 'create t)
        (setq touched t)))
    (when touched
      (ebdb-save-ebdb))))

;; Must be set before `ebdb-message' is loaded so that the CAPF branch
;; of `ebdb-insinuate-message' is chosen (see ebdb-message.el).  The
;; other legal values would rebind TAB in message-mode, which we do not
;; want since TAB is used for field cycling here.
(setq ebdb-complete-mail 'capf)

(defun ff/message-enable-ebdb-completion ()
  "Install EBDB's completion-at-point function in the current buffer.
Loads `ebdb-message' lazily on first use, tries to load the EBDB
database best-effort (a failure here -- e.g. GPG prompt cancelled --
must not prevent CAPF registration), and installs the buffer-local
completion hooks directly.  This mirrors the `capf' branch of
`ebdb-insinuate-message' without depending on `ebdb-load' succeeding."
  (require 'ebdb-message)
  (unless ebdb-db-list
    (condition-case err
        (ebdb-load)
      (error
       (message "ff/message-enable-ebdb-completion: ebdb-load failed: %s"
                (error-message-string err)))))
  (add-hook 'completion-at-point-functions
            #'ebdb-mail-dwim-completion-at-point-function nil t)
  (add-hook 'choose-completion-string-functions
            #'ebdb-message-complete-mail-cleanup nil t))

(use-package ebdb
  :defer t
  :commands (ebdb ebdb-create)
  :hook (message-mode . ff/message-enable-ebdb-completion)
  :init
  (make-directory (file-name-directory ff/ebdb-file) t)
  :custom
  (ebdb-sources (list ff/ebdb-file))
  (ebdb-default-window-size 0.25)
  (ebdb-mua-pop-up nil)
  (ebdb-mua-auto-update-p 'query))

;;;; 7. Reader -- Gnus over Gmail IMAP ----------------------------------------

(use-package gnus
  :straight (:type built-in)
  :commands (gnus)
  :hook (gnus-summary-mode . ff/gnus-summary-keys)
  :custom
  (gnus-select-method
   '(nnimap "gmail"
            (nnimap-address     "imap.gmail.com")
            (nnimap-server-port 993)
            (nnimap-stream      ssl)))
  ;; Gmail system labels are prefixed with "[Gmail]", which the default
  ;; value of `gnus-ignored-newsgroups' would hide.
  (gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")
  ;; The agent confuses nnimap; keep it off.
  (gnus-agent nil)
  ;; No local, unencrypted copies of outgoing mail.
  (gnus-message-archive-group nil)
  ;; Do not prompt "How many articles?" -- just fetch the newest 100.
  (gnus-large-newsgroup 100)
  (gnus-newsgroup-maximum-articles 100)
  ;; Cache read articles locally so re-opening is instant / offline-capable.
  (gnus-use-cache 'passive)
  (gnus-cache-enter-articles '(ticked dormant read))
  (gnus-cache-remove-articles '(read))
  (gnus-cache-directory (locate-user-emacs-file "gnus/cache/"))
  (gnus-cacheable-groups "^nnimap")
  ;; Sort summary buffers newest first: latest article/thread on top.
  (gnus-article-sort-functions '((not gnus-article-sort-by-date)))
  (gnus-thread-sort-functions  '((not gnus-thread-sort-by-most-recent-date))))

(defun ff/message-tab-next-field ()
  "Cycle forward through To -> Subject -> body in a compose buffer.
In the body, fall through to `indent-for-tab-command'. Completion is
handled by Corfu, so this command never triggers header completion."
  (interactive)
  (cond
   ((not (message-point-in-header-p))
    (indent-for-tab-command))
   ((save-excursion (beginning-of-line) (looking-at-p "^To:"))
    (message-goto-subject))
   ((save-excursion (beginning-of-line) (looking-at-p "^Subject:"))
    (message-goto-body))
   (t (message-goto-to))))

(defun ff/message-tab-previous-field ()
  "Cycle backward through body -> Subject -> To in a compose buffer."
  (interactive)
  (cond
   ((not (message-point-in-header-p))
    (message-goto-subject))
   ((save-excursion (beginning-of-line) (looking-at-p "^Subject:"))
    (message-goto-to))
   ((save-excursion (beginning-of-line) (looking-at-p "^To:"))
    (message-goto-body))
   (t (message-goto-to))))

(use-package message
  :straight (:type built-in)
  :hook (message-send . ff/ebdb-update-message-recipients)
  :custom
  (message-send-mail-function 'smtpmail-send-it)
  (message-kill-buffer-on-exit t)
  (message-auto-save-directory (locate-user-emacs-file "gnus/drafts/"))
  (message-directory (locate-user-emacs-file "gnus/"))
  (message-default-charset 'utf-8)
  (message-signature #'ff/message-signature-by-language)
  (message-citation-line-format "On %Y-%m-%d %H:%M, %N wrote:\n")
  (message-citation-line-function 'message-insert-formatted-citation-line)
  :bind
  (:map message-mode-map
        ("C-c C-s" . ff/message-refresh-signature)
        ("TAB"     . ff/message-tab-next-field)
        ("<backtab>" . ff/message-tab-previous-field)
        :map global-map
        ("C-c M" . message-mail-other-window)))

;;;; 8. Dired integration -----------------------------------------------------

(use-package gnus-dired
  :straight (:type built-in)
  :hook (dired-mode . turn-on-gnus-dired-mode))

(provide 'ff-messaging)

;;; ff-messaging.el ends here
