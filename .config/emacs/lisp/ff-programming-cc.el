;;; ff-programming-cc.el --- C/C++ setup

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

(defvar ff/cc-build-folder-container "/workspace"
  "Location of the build folder inside the container.")

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
  (let* ((workspace-folder (file-name-directory ff/cc-build-folder-container))
         (build-folder (file-name-nondirectory ff/cc-build-folder-container))
         (compile-commands-file-path (expand-file-name "compile_commands.json" (concat (ff/project-root) build-folder)))
         (build-folder-host (expand-file-name build-folder (ff/project-root))))
    ;; replace the build folder
    (message "Replacing %s by %s" ff/cc-build-folder-container build-folder-host)
    (ff/search-replace compile-commands-file-path
                       ff/cc-build-folder-container
                       build-folder-host)
    ;; replace the workspace folder
    (message "Replacing %s by %s" workspace-folder (ff/project-root))
    (ff/search-replace compile-commands-file-path
                       workspace-folder
                       (ff/project-root))
    (when (and ff/cc-conan-cache-container ff/cc-conan-cache-host)
      (let ((conan-cache-host (expand-file-name ".conan" (getenv "HOME"))))
        (message "Replacing %s by %s" ff/cc-conan-cache-container conan-cache-host)
        (ff/search-replace compile-commands-file-path
                           ff/cc-conan-cache-container
                           ff/cc-conan-cache-host)))))

(with-eval-after-load 'eglot
  ;; make sure that system packages are available
  (ff/ensure-apt-package "clangd" "clangd")
  (ff/ensure-apt-package "clang" "clang")

  ;; register clangd as default lsp server in eglot
  (add-to-list 'eglot-server-programs `(c-ts-mode "clangd"))
  (add-to-list 'eglot-server-programs `(c++-ts-mode "clangd")))

;; use tree-sitter as default and overwrite all C/C++ modes
(add-to-list 'major-mode-remap-alist '(c++-mode c++-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-mode c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-or-c++-mode c-or-c++-ts-mode))

;; set up file bindings
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.inl\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-ts-mode))

;; fix indentation style
(defun ff/indent-style()
  "Override the built-in BSD indentation style with some additional rules."
  `(;; Here are your custom rules
    ((node-is ")") parent-bol 0)
    ((match nil "argument_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
    ((parent-is "argument_list") prev-sibling 0)
    ((match nil "parameter_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
    ((parent-is "parameter_list") prev-sibling 0)

    ;; Append here the indent style you want as base
    ,@(alist-get 'bsd (c-ts-mode--indent-styles 'cpp))))

(setq c-ts-mode-indent-offset 4
      c-ts-mode-indent-style #'ff/indent-style)

;; configure auto format
(with-eval-after-load 'apheleia
  (ff/ensure-apt-package "clang-format" "clang-format")
  (add-hook 'c++-ts-mode-hook 'apheleia-mode)
  (add-hook 'c-ts-mode-hook 'apheleia-mode))

;; -----------------------------------------------------------------------------------
;; CMake
(ff/ensure-python-package "cmake_language_server" nil "cmake_language_server")
(add-to-list 'auto-mode-alist '("\\.cmake$" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("CMakeLists.txt" . cmake-ts-mode))

(provide 'ff-programming-cc)

;;; ff-programming-cc.el ends here
