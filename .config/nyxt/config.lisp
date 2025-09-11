(in-package #:nyxt-user)

(setf (uiop/os:getenv "WEBKIT_DISABLE_COMPOSITING_MODE") "1")

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

(defextsystem :nx-search-engines "search-engines")

(define-configuration :prompt-buffer
  "Make the attribute widths adjust to the content in them.

It's not exactly necessary on master, because there are more or less
intuitive default widths, but these are sometimes inefficient (and
note that I made this feature so I want to have it :P)."
  ((dynamic-attribute-width-p t)))

(define-configuration :web-buffer
  ((download-engine
    :renderer
    :doc "This overrides download engine to use WebKit instead of Nyxt-native
Dexador-based download engine. I don't remember why I switched,
though.")
   (search-always-auto-complete-p
    nil
    :doc "I don't like search completion when I don't need it.")
   (global-history-p
    t
    :doc "It was disabled after 2.2.4, while being a useful feature.
I'm forcing it here, because I'm getting lost in buffer-local
histories otherwise...")))

(define-configuration :prompt-buffer
  ((hide-single-source-header-p
    t
    :doc "This is to hide the header is there's only one source.
There also used to be other settings to make prompt-buffer a bit
more minimalist, but those are internal APIs :(")))

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
  "Set new buffer URL (a.k.a. start page, new tab page)."
  ((default-new-buffer-url (quri:uri "nyxt:new"))))

;;; custom auto-fills
(define-configuration :autofill-mode
    ((autofills
      (list (nyxt/mode/autofill:make-autofill :name "Name" :fill "Fabian")
            (nyxt/mode/autofill:make-autofill :name "Last Name" :fill "Franzelin")
            (nyxt/mode/autofill:make-autofill :name "E-mail" :fill "fabian.franzelin@gmail.com")
            (nyxt/mode/autofill:make-autofill :name "Current time: "
                                              :fill (lambda () (write-to-string (local-time:now))))))))

;;; Proxy settings
(define-configuration nyxt/mode/proxy:proxy-mode
  ((nyxt/mode/proxy:proxy (make-instance 'proxy
                                         :url (quri:uri "http://127.0.0.1:3128")
                                         :allowlist '("localhost" "bosch.com")
                                         :proxied-downloads-p t))))
(define-configuration web-buffer
  ((default-modes (append '(proxy-mode) %slot-value%))))
