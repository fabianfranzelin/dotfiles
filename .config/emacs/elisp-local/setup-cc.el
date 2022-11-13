;;; setup-cc.el --- C/C++ setup

;;; Commentary:
;; all the configuration for C/C++ projects
;; https://github.com/MaskRay/Config/blob/master/home/.config/doom/modules/private/my-cc/config.el

;;; Code:

;; -----------------------------------------------------------------------------------
;; C/C++

;; -----------------------------------------------------------------------------------
;; Formatting and linting

;; Get to work with Docker mounted workspaces: Usually, the docker
;; container I am running does not contain a

(defvar cc-container-workspace "/workspace"
  "Location where the workspace is mounted in the container.")

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
  (ff/search-replace (expand-file-name "compile_commands.json" (concat (ff/project-root) "build"))
                     cc-container-workspace
                     (ff/project-root)))


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
;; Use package for CCLS and cc-mode

;; adds font-lock highlighting for modern C++ upto C++17
;; https://github.com/ludwigpacifici/modern-cpp-font-lock
(use-package modern-cpp-font-lock
  :hook ((c++-mode . modern-c++-font-lock-mode)))

(use-package cc-mode
  :after (clang-format+)
  :mode (("\\.cpp$" . c++-mode)
         ("\\.hpp$" . c++-mode)
         ("\\.inl$" . c++-mode)
         ("\\.c$" . c-mode)
         ("\\.h$" . c-mode))
  :custom (lsp-clients-clangd-args '("--header-insertion-decorators=0" "--clang-tidy"))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "clangd" "clangd")
  (ff/ensure-apt-package "clang" "clang")
  :bind (:map c++-mode-map
         ("C-c l r c" . ff/container-host-compile-commands-mapping)))

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

;; cmake-font-lock: emacs font lock rules for CMake
;; https://github.com/Lindydancer/cmake-font-lock
(use-package cmake-font-lock
  :hook ((cmake-mode . cmake-font-lock-activate))
  :config
  (autoload 'cmake-font-lock-activate "cmake-font-lock" nil t))

(provide 'setup-cc)

;;; setup-cc.el ends here
