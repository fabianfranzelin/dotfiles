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

;; -----------------------------------------------------------------------------------
;; Formatting and linting

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
  "Adjusts the compile commands json of CMake to match the host system and not the containers."
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

(defun ff/clang-format-buffer-smart ()
  "Reformat buffer if .clang-format exists in the project.el root."
  (interactive)
  (when (f-exists? (expand-file-name ".clang-format" (ff/project-root)))
    (clang-format-buffer)))

(use-package clang-format+
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "clang-format" "clang-format")

  :hook (((c-mode c++-mode) . clang-format+-mode))
         ((c-mode c++-mode) . (lambda ()
                                (add-hook 'before-save-hook 'ff/clang-format-buffer-smart nil t)))
  :config
  (setq clang-format-executable "/usr/bin/clang-format"))

;; ----------------------------------------------------------------------------------
;; Use package for cc-mode
(use-package cc-mode
  :after (clang-format+)
  :mode (("\\.cpp$" . c++-mode)
         ("\\.hpp$" . c++-mode)
         ("\\.inl$" . c++-mode)
         ("\\.c$" . c-mode)
         ("\\.h$" . c-mode))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "clangd" "clangd")
  (ff/ensure-apt-package "clang" "clang")
  ;; configure style
  (c-add-style "my-cc"
               '("user"
                 (c-basic-offset . 4)
                 (indent-tabs-mode . nil)
                 (c-offsets-alist . ((innamespace . 0)
                                     (access-label . -)
                                     (case-label . 0)
                                     (member-init-intro . +)
                                     (topmost-intro . 0)
                                     (arglist-cont-nonempty . +)))))

  (add-to-list 'c-default-style `(c++-mode . "user"))
  (add-to-list 'c-default-style `(c-mode . "user")))

;; -----------------------------------------------------------------------------------
;; Cmake

;; cmake-mode: major mode for cmake files
;; https://gitlab.kitware.com/cmake/cmake/blob/master/Auxiliary/cmake-mode.el
(use-package cmake-mode
  :init
  ;; install system dependencies
  (ff/ensure-python-package "cmake_language_server" nil "cmake_language_server")

  :mode (("\\.cmake$" . cmake-mode)
         ("CMakeLists.txt" . cmake-mode)))

(provide 'ff-programming-cc)

;;; ff-programming-cc.el ends here
