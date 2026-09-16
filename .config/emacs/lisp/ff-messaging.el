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
;;   5. Reader (gnus)        - IMAP account + basic behaviour
;;   6. Dired integration    - attach files from Dired

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

(use-package mml-sec
  :straight (:type built-in)
  :defer t
  :custom
  (mml-secure-openpgp-encrypt-to-self t)
  (mml-secure-openpgp-signers
   '("EEC6A7D5C16FDA0479702E3A9A93162835076A72")))


;;;; 4. Transport -- Gmail SMTP -----------------------------------------------

(use-package smtpmail
  :straight (:type built-in)
  :defer t
  :custom
  (smtpmail-smtp-server      "smtp.gmail.com")
  (smtpmail-smtp-service     587)
  (smtpmail-stream-type      'starttls)
  (send-mail-function        'smtpmail-send-it)
  (message-send-mail-function 'smtpmail-send-it))


;;;; 5. Reader -- Gnus over Gmail IMAP ----------------------------------------

(use-package gnus
  :straight (:type built-in)
  :defer t
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


;;;; 6. Dired integration -----------------------------------------------------

(use-package gnus-dired
  :straight (:type built-in)
  :hook (dired-mode . turn-on-gnus-dired-mode))


(provide 'ff-messaging)

;;; ff-messaging.el ends here
