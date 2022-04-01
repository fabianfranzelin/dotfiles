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

(defvar +ccls-container-workspace "/workspace"
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
  "Adjusts the compile commands json of CMake to match the host
system and not the containers."
  (interactive)
  (ff/search-replace (concat (plist-get ccls-initialization-options :compilationDatabaseDirectory) "/compile_commands.json")
                     +ccls-container-workspace
                     (projectile-project-root)))

(defun ff/clang-format-buffer-smart ()
  "Reformat buffer if .clang-format exists in the projectile root."
  (interactive)
  (when (f-exists? (expand-file-name ".clang-format" (projectile-project-root)))
    (clang-format-buffer)))

(use-package clang-format+
  :ensure-system-package (clang-format . "sudo apt install clang-format clang-format-10 -y")
  :hook (((c-mode c++-mode) . clang-format+-mode))
         ((c-mode c++-mode) . (lambda ()
                                (add-hook 'before-save-hook 'ff/clang-format-buffer-smart nil t)))
  :config
  (setq clang-format-executable "/usr/bin/clang-format"))


(use-package flycheck-clang-tidy
  :ensure-system-package ((clang-tidy . "sudo apt install clang-tidy -y"))
  :after flycheck
  :hook (flycheck-mode . flycheck-clang-tidy-setup))

;; ----------------------------------------------------------------------------------
;; Autloads for CCLS and cc-mode

;;;###autoload
(defvar +ccls-path-mappings [])

;;;###autoload
(defvar +ccls-initial-blacklist [])

;;;###autoload
(defvar +ccls-cache-dir (concat (getenv "HOME") "/.cache/ccls"))

;;;###autoload
(defvar +lsp-blacklist nil)


(defun ccls/callee ()
  (interactive)
  (lsp-ui-peek-find-custom "$ccls/call" '(:callee t)))
(defun ccls/caller ()
  (interactive)
  (lsp-ui-peek-find-custom "$ccls/call"))
(defun ccls/vars (kind)
  (lsp-ui-peek-find-custom "$ccls/vars" `(:kind ,kind)))
(defun ccls/base (levels)
  (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels)))
(defun ccls/derived (levels)
  (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels :derived t)))
(defun ccls/member (kind)
  (lsp-ui-peek-find-custom "$ccls/member" `(:kind ,kind)))

;; The meaning of :role corresponds to https://github.com/maskray/ccls/blob/master/src/symbol.h

;; References w/ Role::Address bit (e.g. variables explicitly being taken addresses)
(defun ccls/references-address ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
                           (plist-put (lsp--text-document-position-params) :role 128)))

;; References w/ Role::Dynamic bit (macro expansions)
(defun ccls/references-macro ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
                           (plist-put (lsp--text-document-position-params) :role 64)))

;; References w/o Role::Call bit (e.g. where functions are taken addresses)
(defun ccls/references-not-call ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
                           (plist-put (lsp--text-document-position-params) :excludeRole 32)))

;; References w/ Role::Read
(defun ccls/references-read ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
                           (plist-put (lsp--text-document-position-params) :role 8)))

;; References w/ Role::Write
(defun ccls/references-write ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
                           (plist-put (lsp--text-document-position-params) :role 16)))

;; xref-find-apropos (workspace/symbol)
(defun my/highlight-pattern-in-text (pattern line)
  (when (> (length pattern) 0)
    (let ((i 0))
      (while (string-match pattern line i)
        (setq i (match-end 0))
        (add-face-text-property (match-beginning 0) (match-end 0) 'isearch t line))
      line)))

(with-eval-after-load 'lsp-methods
  ;;; Override
  ;; This deviated from the original in that it highlights pattern appeared in symbol
  (defun lsp--symbol-information-to-xref (pattern symbol)
    "Return a `xref-item' from SYMBOL information."
    (let* ((location (gethash "location" symbol))
           (uri (gethash "uri" location))
           (range (gethash "range" location))
           (start (gethash "start" range))
           (name (gethash "name" symbol)))
      (xref-make (format "[%s] %s"
                         (alist-get (gethash "kind" symbol) lsp--symbol-kind)
                         (my/highlight-pattern-in-text (regexp-quote pattern) name))
                 (xref-make-file-location (string-remove-prefix "file://" uri)
                                          (1+ (gethash "line" start))
                                          (gethash "character" start)))))

  (cl-defmethod xref-backend-apropos ((_backend (eql xref-lsp)) pattern)
    (let ((symbols (lsp--send-request (lsp--make-request
                                       "workspace/symbol"
                                       `(:query ,pattern)))))
      (mapcar (lambda (x) (lsp--symbol-information-to-xref pattern x)) symbols))))

;; ----------------------------------------------------------------------------------
;; Use package for CCLS and cc-mode

;; adds font-lock highlighting for modern C++ upto C++17
;; https://github.com/ludwigpacifici/modern-cpp-font-lock
(use-package modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode))

;; ccls: Emacs client for ccls, a C/C++ language server
;; https://github.com/MaskRay/emacs-ccls
(use-package ccls
  :ensure-system-package (ccls . "sudo snap install ccls --classic")
  :init
  (setq ccls-executable (executable-find "ccls"))

  :config
  ;; https://github.com/maskray/ccls/blob/master/src/config.h
  ;; make sure that the cache directory exists
  (make-directory (eval +ccls-cache-dir) :parents)

  ;; set initialization ooptions for ccls (equal to .ccls)
  (setq ccls-initialization-options
   `(:clang
     (:excludeArgs
      ;; Linux's gcc options. See ccls/wiki
      ["-falign-jumps=1" "-falign-loops=1" "-fconserve-stack" "-fmerge-constants" "-fno-code-hoisting" "-fno-schedule-insns" "-fno-var-tracking-assignments" "-fsched-pressure"
       "-mhard-float" "-mindirect-branch-register" "-mindirect-branch=thunk-inline" "-mpreferred-stack-boundary=2" "-mpreferred-stack-boundary=3" "-mpreferred-stack-boundary=4" "-mrecord-mcount" "-mindirect-branch=thunk-extern" "-mno-fp-ret-in-387" "-mskip-rax-setup"
       "--param=allow-store-data-races=0" "-Wa arch/x86/kernel/macros.s" "-Wa -"]
      :extraArgs []
      :pathMappings ,+ccls-path-mappings)
     :completion
     (:include
      (:blacklist
       ["^/usr/(local/)?include/c\\+\\+/[0-9\\.]+/(bits|tr1|tr2|profile|ext|debug)/"
        "^/usr/(local/)?include/c\\+\\+/v1/"
        ]))
     :index (:initialBlacklist ,+ccls-initial-blacklist :parametersInDeclarations :json-false :trackDependency 1)
     :cache (:directory ,+ccls-cache-dir)
     :compilationDatabaseDirectory "")))

(defun +ccls|enable ()
  "Enable lsp-ccls."
  (when (and buffer-file-name (--all? (not (string-match-p it buffer-file-name)) +lsp-blacklist))
    (require 'ccls)
    (require 'lsp-headerline)
    (require 'lsp-modeline)
    (setq-local lsp-ui-sideline-show-symbol nil)
    (when (string-match-p "/llvm" buffer-file-name)
      (setq-local lsp-enable-file-watchers nil))))

(use-package cc-mode
  :after clang-format+
  :ensure-system-package ((clangd . "sudo apt install clangd clangd-10 -y")
                          (clang . "sudo apt install clang clang-10 -y"))
  :hook (((c++-mode c-mode) . (lambda ()
                                (+ccls|enable)
                                (+cc-fontify-constants-h))))
  :custom (lsp-clients-clangd-args '("--header-insertion-decorators=0" "--clang-tidy"))
  :init
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
  (push '(c++-mode . "my-cc") c-default-style)
  (push '(c-mode . "my-cc") c-default-style)

  :config
  ;;;###autoload
  (defun +cc-fontify-constants-h ()
    "Better fontification for preprocessor constants"
    (when (memq major-mode '(c-mode c++-mode))
      (font-lock-add-keywords
       nil '(("\\<[A-Z]*_[0-9A-Z_]+\\>" . font-lock-constant-face)
             ("\\<[A-Z]\\{3,\\}\\>"  . font-lock-constant-face))
       t)))
  :bind (;; TODO this is a hack for now. It should only be enabled in C++ mode
         ("C-c p r" . ff/container-host-compile-commands-mapping)))

;; Major mode for editing QT Declarative (QML) code.
;; https://github.com/coldnew/qml-mode
(use-package qml-mode
  :mode ("\\.qml$" . qml-mode))

;; dap debugging for c++
(require 'dap-cpptools)
(dap-cpptools-setup)

;; -----------------------------------------------------------------------------------
;; Cmake

;; cmake-mode: major mode for cmake files
;; https://gitlab.kitware.com/cmake/cmake/blob/master/Auxiliary/cmake-mode.el
(use-package cmake-mode
  :ensure-system-package (("~/.local/lib/python3.8/site-packages/cmake_language_server" . "python3 -m pip install -U 'cmake_language_server'"))
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
