;;; ff-programming-bazel.el --- Bazel setup -*- lexical-binding: t; -*-

;;; Commentary:
;; all the configuration for Bazel projects

;;; Code:

;; -----------------------------------------------------------------------------------
;; Bazel helpers
;; -----------------------------------------------------------------------------------
(defun ff/bazel--project-root ()
  "Return the absolute path of the enclosing Bazel workspace, or nil."
  (let ((root (locate-dominating-file default-directory "MODULE.bazel")))
    (and root (expand-file-name root))))

(defvar ff/bazel--output-path-cache (make-hash-table :test 'equal)
  "Cache mapping Bazel project roots to their `bazel info output_path'.")

(defun ff/bazel--output-path (project-dir)
  "Return `bazel info output_path' for PROJECT-DIR, cached."
  (or (gethash project-dir ff/bazel--output-path-cache)
      (puthash project-dir
               (string-trim
                (shell-command-to-string
                 (format "cd %s && bazel info output_path 2>/dev/null"
                         (shell-quote-argument project-dir))))
               ff/bazel--output-path-cache)))

(defun ff/bazel-target-output-files ()
  "Fuzzy-select a Bazel target and show the paths of its output files.
Lists all targets under //... via `bazel query', prompts with
`completing-read' (works with vertico + orderless as a fuzzy find),
then uses `bazel cquery --output=files' to resolve the target's actual
output artifacts.  The resulting absolute paths are shown in a
dedicated buffer and copied to the kill ring."
  (interactive)
  (let* ((project-dir (or (ff/bazel--project-root)
                          (user-error "Not inside a Bazel workspace (no MODULE.bazel)")))
         (default-directory project-dir)
         (_ (message "Querying Bazel targets..."))
         (targets-raw (string-trim
                       (shell-command-to-string
                        (format "cd %s && bazel query --keep_going \"//...\" 2>/dev/null"
                                (shell-quote-argument project-dir)))))
         (targets (split-string targets-raw "\n" t))
         (_ (unless targets (user-error "No Bazel targets found")))
         (target (completing-read "Bazel target: " targets nil t))
         (_ (message "Building %s..." target))
         (_ (shell-command-to-string
             (format "cd %s && bazel build %s 2>/dev/null"
                     (shell-quote-argument project-dir)
                     (shell-quote-argument target))))
         (_ (message "Resolving output files for %s..." target))
         (files-raw (string-trim
                     (shell-command-to-string
                      (format "cd %s && bazel cquery %s --output=files 2>/dev/null"
                              (shell-quote-argument project-dir)
                              (shell-quote-argument target)))))
         (rel-files (split-string files-raw "\n" t))
         (output-path (ff/bazel--output-path project-dir))
         (abs-files
          (mapcar (lambda (f)
                    (cond
                     ((file-name-absolute-p f) f)
                     ((string-prefix-p "bazel-out/" f)
                      ;; bazel-out/<cfg>/bin/... -> <output_path>/<cfg>/bin/...
                      (expand-file-name (substring f (length "bazel-out/"))
                                        output-path))
                     (t (expand-file-name f project-dir))))
                  rel-files)))
    (cond
     ((null abs-files)
      (message "Target %s has no output files" target))
     ((= (length abs-files) 1)
      (kill-new (car abs-files))
      (if (not (file-exists-p (car abs-files)))
          (user-error "Output file does not exist (path copied to kill ring): %s"
                      (car abs-files))
        (minibuffer-with-setup-hook
            (lambda () (insert (car abs-files)))
          (call-interactively #'find-file))))
     (t
      (with-current-buffer (get-buffer-create "*bazel outputs*")
        (let ((inhibit-read-only t))
          (erase-buffer)
          (dolist (f abs-files)
            (insert (format "%s:1:\n" f))))
        (goto-char (point-min))
        (grep-mode)
        (display-buffer (current-buffer)))
      (message "%d output file(s) for %s" (length abs-files) target)))
    abs-files))

(use-package bazel
  :mode (("\\.bzl\\'" . bazel-mode)
         ("BUILD\\'" . bazel-mode)
         ("BUILD\\.bazel\\'" . bazel-mode)
         ("WORKSPACE\\'" . bazel-mode)
         ("WORKSPACE\\.bazel\\'" . bazel-mode))
  :bind (:map
         global-map
         ("C-c b b" . bazel-build)
         ("C-c b t" . bazel-test)
         ("C-c b r" . bazel-run)
         ("C-c b q" . bazel-query)
         ("C-c b c" . bazel-coverage)
         ("C-c b m" . ff/bazel-transient)
         ("C-c b o" . ff/bazel-target-output-files)))

;; use apheleia for formatting instead of bazel-buildifier package
(with-eval-after-load 'apheleia
  (add-hook 'bazel-mode-hook 'apheleia-mode)
  (setf (alist-get 'buildifier apheleia-formatters)
        '("buildifier" filepath))
  (setf (alist-get 'bazel-mode apheleia-mode-alist) 'buildifier))

;; eglot setup
(add-hook 'bazel-mode-hook #'eglot-ensure)

(with-eval-after-load 'eglot
  ;; register starpls as lsp server for bazel-mode (starlark lsp)
  (add-to-list 'eglot-server-programs
               '(bazel-mode .
                            ("starpls" "server"
                             "--experimental_infer_ctx_attributes"
                             "--experimental_use_code_flow_analysis"
                             "--experimental_enable_label_completions"))))

;; Transient menu for Bazel (similar to VSCode command palette)
(transient-define-prefix ff/bazel-transient ()
  "Bazel commands."
  ["Bazel"
   ["Build/Test/Run"
    ("b" "Build" bazel-build)
    ("t" "Test" bazel-test)
    ("r" "Run" bazel-run)
    ("c" "Coverage" bazel-coverage)]
   ["Query"
    ("q" "Query" bazel-query)]
   ["Format"
    ("f" "Format file" (lambda () (interactive) (apheleia-format-buffer)))
    ("F" "Format all BUILD files" (lambda ()
                                    (interactive)
                                    (shell-command "find . -type f \\( -name BUILD -o -name BUILD.bazel \\) -exec buildifier {} +")))]])

(provide 'ff-programming-bazel)

;;; ff-programming-bazel.el ends here
