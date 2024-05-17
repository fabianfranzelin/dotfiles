(in-package #:nyxt-user)

;;; Reset ASDF registries to allow loading Lisp systems from
;;; everywhere.
#+nyxt-3 (reset-asdf-registries)

(defvar *web-buffer-modes*
  '(:emacs-mode
    :blocker-mode :force-https-mode
    :reduce-tracking-mode
    :user-script-mode :bookmarklets-mode)
  "The modes to enable in any web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

;;; Loading files from the same directory.
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("keybindings"))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
(defmacro defextsystem (system &optional file)
  "Helper macro to load configuration for extensions.
Loads a newly-generated ASDF system depending on SYSTEM.
FILE, if provided, is loaded after the generated system successfully
loads."
  `(define-nyxt-user-system-and-load ,(gensym "NYXT-USER/")
     :depends-on (,system) ,@(when file
                               `(:components (,file)))))

(defextsystem :nx-search-engines "search-engines")

;;; Those are settings that every type of buffer should share.
(define-configuration (:modable-buffer :prompt-buffer :editor-buffer)
  "Set up Emacs keybindings everywhere possible."
  ((default-modes `(:emacs-mode ,@%slot-value%))))

(define-configuration :web-buffer
  "Basic modes setup for web-buffer."
  ((default-modes `(,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :browser
  "Set new buffer URL (a.k.a. start page, new tab page)."
  ((default-new-buffer-url (quri:uri "nyxt:nyxt/mode/repl:repl"))))
