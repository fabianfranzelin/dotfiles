(in-package #:nyxt-user)

;;; Workaround for Nyxt 4.0.0 bug: nyxt:new page calls generic functions on
;;; document-buffer that only have methods for modable-buffer/web-buffer.
;;; Provide stub methods to prevent fatal crashes on startup.
(defmethod nyxt::lisp-url-callbacks ((buffer nyxt:document-buffer))
  (make-hash-table :test 'equal))

(defmethod nyxt:keyscheme ((buffer nyxt:document-buffer))
  nyxt/keyscheme:emacs)

;;; Workaround: active-buffer is called on nil window during startup race.
(defmethod nyxt:active-buffer ((window null))
  nil)

(defvar *web-buffer-modes*
  '(:emacs-mode
    :blocker-mode
    :force-https-mode
    :reduce-tracking-mode
    :user-script-mode
    :bookmarklets-mode)
  "The modes to enable in any web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

;;; Loading files from the same directory.
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("keybindings" "status"))

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

(define-configuration :prompt-buffer
  "Make the attribute widths adjust to the content in them."
  ((dynamic-attribute-width-p t)))

(define-configuration :web-buffer
  ((download-engine
    :renderer
    :doc "Use WebKit download engine for better integration.")
   (search-always-auto-complete-p
    nil
    :doc "Disable search completion when not needed for snappier input.")
   (global-history-p
    t
    :doc "Use global history across all buffers.")))

(define-configuration :prompt-buffer
  ((hide-single-source-header-p
    t
    :doc "Hide the header when there's only one source.")))

(defmethod files:resolve ((profile nyxt:nyxt-profile) (file nyxt/mode/bookmark:bookmarks-file))
  "Reroute the bookmarks to the config directory."
  #p"~/.config/nyxt/bookmarks.lisp")

;;; Those are settings that every type of buffer should share.
(define-configuration (:modable-buffer :prompt-buffer :editor-buffer)
  "Set up Emacs keybindings everywhere possible."
  ((default-modes `(:emacs-mode ,@%slot-value%))))

(define-configuration :web-buffer
  "Basic modes setup for web-buffer."
  ((default-modes `(,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :browser
  "Set new buffer URL (a.k.a. start page, new tab page).
Reduce I/O overhead for better responsiveness."
  ((default-new-buffer-url (quri:uri "nyxt:new"))
   (session-restore-prompt :never-restore)))

;;; Disable separate panel/status window (Electron creates a second X window
;;; that tiling WMs like Qtile tile independently).
(define-configuration :window
  ((nyxt:panel-buffers nil)
   (nyxt:status-buffer-height 0)
   (nyxt:message-buffer-height 0)))

;;; custom auto-fills
(define-configuration :autofill-mode
    ((autofills
      (list (nyxt/mode/autofill:make-autofill :name "Name" :fill "Fabian")
            (nyxt/mode/autofill:make-autofill :name "Last Name" :fill "Franzelin")
            (nyxt/mode/autofill:make-autofill :name "E-mail" :fill "fabian.franzelin@gmail.com")
            (nyxt/mode/autofill:make-autofill :name "Current time: "
                                              :fill (lambda () (write-to-string (local-time:now))))))))

;;; Proxy settings (only enable manually via M-x proxy-mode when behind corporate proxy)
(define-configuration nyxt/mode/proxy:proxy-mode
  ((nyxt/mode/proxy:proxy (make-instance 'proxy
                                         :url (quri:uri "http://127.0.0.1:3128")
                                         :allowlist '("localhost" "bosch.com")
                                         :proxied-downloads-p t))))
