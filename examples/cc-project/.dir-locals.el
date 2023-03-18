;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((compile-command . "cd ./build && make")
         (compile-multi-config . ((t
                                   ("cmake:init" . "mkdir -p build && cd build && cmake ..")
                                   ("make:build" . "cd ./build && make"))))))
 (c++-mode . ((eval . (setq-local ff/cc-build-folder-container nil))
              (eval . (setq-local ff/cc-conan-cache-container nil))
              (eval . (setq-local ff/cc-conan-cache-host nil)))))
