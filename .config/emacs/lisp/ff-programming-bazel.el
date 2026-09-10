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

(defun ff/bazel-build-current-package ()
  "Run `bazel build' on the Bazel package containing the current buffer's file."
  (interactive)
  (let* ((file (or buffer-file-name
                   (user-error "Current buffer is not visiting a file")))
         (project-dir (or (ff/bazel--project-root)
                          (user-error "Not inside a Bazel workspace (no MODULE.bazel)")))
         (pkg-dir (locate-dominating-file
                   file
                   (lambda (dir)
                     (or (file-exists-p (expand-file-name "BUILD" dir))
                         (file-exists-p (expand-file-name "BUILD.bazel" dir))))))
         (_ (unless pkg-dir
              (user-error "No BUILD file found above %s" file)))
         (rel (file-relative-name (expand-file-name pkg-dir)
                                  (expand-file-name project-dir)))
         (pkg (directory-file-name (if (string= rel "./") "" rel)))
         (target (format "//%s:all" (if (string= pkg ".") "" pkg)))
         (default-directory project-dir))
    (compile (format "bazel build %s" (shell-quote-argument target)))))

;; When completing Bazel targets (e.g. via `bazel-build'), automatically append
;; a "/" after completing a package name so the user can immediately keep
;; descending into subpackages with TAB (mimicking file-name completion).
;; We wrap the inner package-name completion table so that its candidates
;; already carry the trailing slash.  This works with all completion styles
;; (basic, orderless, ...) because the "/" is part of the candidate itself.
(defun ff/bazel--package-completion-add-slash (orig-fun &rest args)
  "Wrap ORIG-FUN's package completion table so candidates end with \"/\"."
  (let ((table (apply orig-fun args)))
    (lambda (string predicate action)
      (cond
       ;; all-completions: append "/" to every returned candidate.
       ((eq action t)
        (mapcar (lambda (c) (if (string-suffix-p "/" c) c (concat c "/")))
                (all-completions string table predicate)))
       ;; try-completion: if a unique exact package matches, return it with "/".
       ((null action)
        (let* ((bare (try-completion string table predicate)))
          (cond
           ((eq bare t) (concat string "/"))
           ((and (stringp bare)
                 (eq (try-completion bare table predicate) t))
            (concat bare "/"))
           ;; If try-completion returned a partial match that itself is also a
           ;; valid full candidate (bazel's table strips slashes, hiding the
           ;; exact-match signal), accept it as complete when it appears in
           ;; all-completions.
           ((and (stringp bare)
                 (member bare (all-completions bare table predicate)))
            (concat bare "/"))
           (t bare))))
       ;; test-completion: accept both "foo" and "foo/" forms.
       ((eq action 'lambda)
        (or (test-completion string table predicate)
            (and (string-suffix-p "/" string)
                 (test-completion (substring string 0 -1) table predicate))))
       (t (complete-with-action action table string predicate))))))

(advice-add 'bazel--target-package-completion-table-1 :around
            #'ff/bazel--package-completion-add-slash)

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
         ("C-c b o" . ff/bazel-target-output-files)
         ("C-c b f" . ff/bazel-build-current-package)))

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
