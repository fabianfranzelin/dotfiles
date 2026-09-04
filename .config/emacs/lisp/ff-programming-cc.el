;;; ff-programming-cc.el --- C/C++ setup -*- lexical-binding: t; -*-

;;; Commentary:
;; all the configuration for C/C++ projects
;; https://github.com/MaskRay/Config/blob/master/home/.config/doom/modules/private/my-cc/config.el

;; To specify a non-default build folder, place a .clangd file in your
;; projects root directory with the following content

;; CompileFlags:
;;   CompilationDatabase: ./<your specific build folder>


;;; Code:

;; -----------------------------------------------------------------------------------
;; C/C++

;; install system dependencies
(require 'ff-ensure-system-packages)

;; -----------------------------------------------------------------------------------
;; Container handling

;; Get to work with Docker mounted workspaces: Usually, the docker
;; container I am running does not contain a

(defvar ff/cc-build-folder-container nil
  "Location of the folder where the compile_commands.json is located inside the container.")

(defvar ff/cc-workspace-container "/workspace"
  "Location of the workspace inside the container.")

(defvar ff/cc-conan-cache-container nil
  "Location of the conan cache folder inside the container.")

(defvar ff/cc-conan-cache-host nil
  "Location of the conan cache folder on the host.")

(defun ff/search-replace (file-path regex-str replace-str)
  "Replace content in file.
FILE-PATH: file to be changed
REGEX-STR: regular expression to be replaced
REPLACE-STR: string that replaces all regex matches"
  (interactive "P")
  (with-temp-file file-path
    (insert-file-contents file-path)
    (goto-char (point-min))
    (while (re-search-forward regex-str nil t)
      (replace-match replace-str))))

(defun ff/container-host-compile-commands-mapping ()
  "Adjust the compile commands of CMake to match the host systems paths."
  (interactive)
  (let* ((workspace-folder-host (substring (ff/project-root) 0 (1- (length (ff/project-root)))))
         (build-folder-host
          (if ff/cc-build-folder-container
              (expand-file-name ff/cc-build-folder-container workspace-folder-host)
            (locate-dominating-file default-directory "build")))
         (compile-commands-file-path (expand-file-name "compile_commands.json" build-folder-host)))
    ;; replace the workspace folder
    (message "Replacing %s by %s" ff/cc-workspace-folder-container workspace-folder-host)
    (ff/search-replace compile-commands-file-path
                       ff/cc-workspace-folder-container
                       workspace-folder-host)
    ;; replace the conan cache folder
    (message "Replacing %s by %s" ff/cc-conan-cache-container ff/cc-conan-cache-host)
    (ff/search-replace compile-commands-file-path
                       ff/cc-conan-cache-container
                       ff/cc-conan-cache-host)))

(with-eval-after-load 'project
  ;; make sure that the compile commands are adjusted to the host system
  (define-key project-prefix-map "m" 'ff/container-host-compile-commands-mapping))

;; eglot hooks
(add-hook 'c++-ts-mode-hook #'eglot-ensure)
(add-hook 'c-ts-mode-hook #'eglot-ensure)

;; default indentation size
(setq c-ts-mode-indent-offset 4)

(with-eval-after-load 'eglot
  ;; make sure that system packages are available
  (ff/ensure-apt-package "clangd" "clangd")
  (ff/ensure-apt-package "clang" "clang")

  ;; register clangd as default lsp server in eglot
  (add-to-list 'eglot-server-programs `((c++-ts-mode c-ts-mode)
                                        . ("clangd"
                                           "-j=8"
                                           "--log=error"
                                           "--malloc-trim"
                                           "--background-index"
                                           "--clang-tidy"
                                           "--cross-file-rename"
                                           "--completion-style=detailed"
                                           "--pch-storage=memory"
                                           "--header-insertion=never"
                                           "--header-insertion-decorators=0"
                                           "--query-driver=**"))))

;; non-standard file extension
(add-to-list 'auto-mode-alist '("\\.inl\\'" . c++-ts-mode))

;; configure auto format
(with-eval-after-load 'apheleia
  (ff/ensure-apt-package "clang-format" "clang-format")
  (add-hook 'c++-ts-mode-hook 'apheleia-mode)
  (add-hook 'c-ts-mode-hook 'apheleia-mode))

;; -----------------------------------------------------------------------------------
;; CMake
(add-hook 'cmake-ts-mode-hook #'eglot-ensure)

(use-package cmake-ts-mode
  :straight (:type built-in)
  :preface
  ;; install system dependencies
  (ff/ensure-python-package "cmake_language_server" nil "cmake_language_server")
  :mode (("\\.cmake$" . cmake-ts-mode)
         ("CMakeLists\\.txt" . cmake-ts-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                    Bazel                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ff/bazel--runfiles-lib-path (project-dir bin-path)
  "Compute LD_LIBRARY_PATH from the runfiles tree of a Bazel binary.
PROJECT-DIR is the workspace root, BIN-PATH is the relative path
under bazel-bin/ (e.g. \"drain/aosbag/tests/unit_tests_aosbag\").
Returns a colon-separated string of directories containing .so files."
  (let* ((runfiles-dir (expand-file-name
                        (concat "bazel-bin/" bin-path ".runfiles/_main")
                        project-dir))
         (output (string-trim
                  (shell-command-to-string
                   (format "find %s -name '*.so' -exec dirname {} \\; 2>/dev/null | sort -u | tr '\\n' ':'"
                           (shell-quote-argument runfiles-dir))))))
    (string-trim-right output ":")))

(defun ff/bazel-debug ()
  "Select a debuggable Bazel target and debug it with dape."
  (interactive)
  (let* ((project-dir (expand-file-name (locate-dominating-file default-directory "MODULE.bazel")))
         (query "kind('cc_binary|cc_test', //...)")
         (output (string-trim
                  (shell-command-to-string
                   (format "cd %s && bazel query --keep_going \"%s\" 2>/dev/null"
                           (shell-quote-argument project-dir) query))))
         (all-targets (split-string output "\n" t))
         (targets (seq-remove (lambda (t) (string-suffix-p ".so" t)) all-targets))
         (target (if (null targets)
                     (error "No debuggable targets found")
                   (completing-read "Bazel target: " targets nil t)))
         (bin-path (replace-regexp-in-string
                    ":" "/"
                    (replace-regexp-in-string "^//" "" target)))
         (lib-path (ff/bazel--runfiles-lib-path project-dir bin-path))
         (env-args (when (not (string-empty-p lib-path))
                     (list "-iex" (format "set environment LD_LIBRARY_PATH=%s" lib-path)))))
    (setq dape-command
          `(gdb command "gdb"
                command-args ("-i" "dap"
                              "-iex" ,(concat "set substitute-path /proc/self/cwd " project-dir)
                              ,@env-args)
                :program ,(expand-file-name (concat "bazel-bin/" bin-path) project-dir)
                :cwd ,project-dir
                compile ,(concat "cd " (shell-quote-argument project-dir)
                                 " && bazel build --compilation_mode=dbg " target)))
    (call-interactively #'dape)))

(defun ff/bazel--file-label (project-dir relative-file)
  "Compute the Bazel label for RELATIVE-FILE within PROJECT-DIR.
Finds the nearest BUILD/BUILD.bazel to determine the package, then
returns a label like //pkg:path/to/file."
  (let* ((abs-file (expand-file-name relative-file project-dir))
         (file-dir (file-name-directory abs-file))
         (pkg-dir (or (locate-dominating-file file-dir
                                              (lambda (dir)
                                                (or (file-exists-p (expand-file-name "BUILD" dir))
                                                    (file-exists-p (expand-file-name "BUILD.bazel" dir)))))
                      project-dir))
         (pkg (file-relative-name pkg-dir project-dir))
         (pkg-label (if (or (string= pkg "./") (string= pkg "."))
                        ""
                      (directory-file-name pkg)))
         (file-in-pkg (file-relative-name abs-file pkg-dir)))
    (format "//%s:%s" pkg-label file-in-pkg)))

(defun ff/bazel--rdeps-universe (project-dir relative-file)
  "Return a scoped universe pattern for rdeps queries.
Uses the Bazel package containing RELATIVE-FILE to avoid loading
unrelated broken packages.  Falls back to //... for root packages."
  (let* ((abs-file (expand-file-name relative-file project-dir))
         (file-dir (file-name-directory abs-file))
         (pkg-dir (or (locate-dominating-file file-dir
                                              (lambda (dir)
                                                (or (file-exists-p (expand-file-name "BUILD" dir))
                                                    (file-exists-p (expand-file-name "BUILD.bazel" dir)))))
                      project-dir))
         (pkg (file-relative-name pkg-dir project-dir))
         (pkg-label (if (or (string= pkg "./") (string= pkg "."))
                        ""
                      (directory-file-name pkg))))
    (if (string-empty-p pkg-label)
        "//..."
      (format "//%s/..." pkg-label))))

(defun ff/bazel-debug-current-file ()
  "Debug a Bazel target that depends on the current file."
  (interactive)
  (let* ((project-dir (expand-file-name (locate-dominating-file default-directory "MODULE.bazel")))
         (relative-file (file-relative-name (buffer-file-name) project-dir))
         (label (ff/bazel--file-label project-dir relative-file))
         (universe (ff/bazel--rdeps-universe project-dir relative-file))
         (query (format "kind('cc_binary|cc_test', rdeps(%s, '%s'))" universe label))
         (output (string-trim
                  (shell-command-to-string
                   (format "cd %s && bazel query --keep_going \"%s\" 2>/dev/null"
                           (shell-quote-argument project-dir) query))))
         (all-targets (split-string output "\n" t))
         (targets (seq-remove (lambda (t) (string-suffix-p ".so" t)) all-targets))
         (target (if (null targets)
                     (error "No debuggable targets depend on %s" relative-file)
                   (if (cdr targets)
                       (completing-read "Bazel target: " targets nil t)
                     (car targets))))
         (bin-path (replace-regexp-in-string
                    ":" "/"
                    (replace-regexp-in-string "^//" "" target)))
         (lib-path (ff/bazel--runfiles-lib-path project-dir bin-path))
         (env-args (when (not (string-empty-p lib-path))
                     (list "-iex" (format "set environment LD_LIBRARY_PATH=%s" lib-path)))))
    (setq dape-command
          `(gdb command "gdb"
                command-args ("-i" "dap"
                              "-iex" ,(concat "set substitute-path /proc/self/cwd " project-dir)
                              ,@env-args)
                :program ,(expand-file-name (concat "bazel-bin/" bin-path) project-dir)
                :cwd ,project-dir
                compile ,(concat "cd " (shell-quote-argument project-dir)
                                 " && bazel build --compilation_mode=dbg " target)))
    (call-interactively #'dape)))

(provide 'ff-programming-cc)

;;; ff-programming-cc.el ends here
