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

(use-package cmake-mode
  :preface
  ;; install system dependencies
  (ff/ensure-python-package "cmake_language_server" nil "cmake_language_server")
  :mode (("\\.cmake$" . cmake-mode)
         ("CMakeLists\\.txt" . cmake-mode)))

(provide 'ff-programming-cc)

;;; ff-programming-cc.el ends here
