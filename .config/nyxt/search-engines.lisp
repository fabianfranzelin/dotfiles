(in-package #:nyxt-user)

;; Define buffer search-engines slot to be a list of several
;; nx-search-engines-provided ones.
(define-configuration (buffer web-buffer)
  ((search-engines (list (engines:google :shortcut "g"
                                         :safe-search nil)
                         (engines:duckduckgo :shortcut "d"
                                             :help-improve-duckduckgo nil
                                             :homepage-privacy-tips nil
                                             :privacy-newsletter nil
                                             :newsletter-reminders nil
                                             :install-reminders nil
                                             :install-duckduckgo nil)))))
