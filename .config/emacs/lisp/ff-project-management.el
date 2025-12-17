;;; ff-project-management.el --- Setup project.el, etc. -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for project.el and surrounding stuff

;;; Code:

;; -------------------------------------------------------------------
;; Tab bar: one tab per project
;; -------------------------------------------------------------------
(use-package tab-bar
  :straight (:type built-in)
  :hook
  (after-init . tab-bar-mode)
  :custom
  ;; Don't turn on tab-bar-mode when tabs are created
  (tab-bar-show nil)
  :bind
  (:map global-map
        ("C-x t n" . tab-new)
        ;; after a tab is closed, the *scratch* tab appears
        ;; automatically; Hence, we close that one as well after
        ;; closing the actually intended one to actually get to the
        ;; previous user tab.
        ("C-x t w" . tab-close)))

;; -------------------------------------------------------------------
;; Tasks
;; -------------------------------------------------------------------
(defun ff/run-command-runner-vterm (command-line buffer-base-name output-buffer)
  "Command runner based on `vterm-mode'.

Executes COMMAND-LINE in buffer OUTPUT-BUFFER.  Name the process
BUFFER-BASE-NAME.

COMMAND-LINE: command to run
BUFFER-BASE-NAME: name of the buffer
OUTPUT-BUFFER: buffer to run the command in"
  (require 'vterm)
  (let ((vterm-buffer-name (ff/vterm-buffer-name (substring (buffer-name output-buffer) 7 -1))))
    (with-current-buffer output-buffer
      (rename-buffer vterm-buffer-name)
      (vterm-mode)
      (vterm-send-string command-line)
      (vterm-send-return))))

;; define make tasks
(defun run-command-recipe-ff/cc ()
  "Define Make recipes for run command package."
  (list
   ;; make
   (when-let* ((project-dir (locate-dominating-file default-directory "build"))
               (build-dir (expand-file-name "build" project-dir)))
     (list :command-name "build:make"
           :command-line "make"
           :working-dir build-dir))
   ;; cmake from current directory
   (when-let ((cmake-lists-file (expand-file-name "CMakeLists.txt" default-directory)))
     (list :command-name "build:cmake"
           :command-line "mkdir -p build && cd build && cmake .."
           :working-dir default-directory))))

(use-package run-command
  :custom
  (run-command-default-runner #'run-command-runner-compile))

;; -------------------------------------------------------------------
;; Project (built in project handling mode; similar to projectile)
;; -------------------------------------------------------------------
(defun ff/project-root ()
  "Provide path to project root directory."
  (interactive "P")
  (expand-file-name (project-root (project-current t))))

(defun ff/tab-bar--names (&optional tabs frame)
  "Return the list of tabs sorted by name.
TABS: tabs as alist
FRAME: frame"
  (let* ((tabs (or tabs (funcall tab-bar-tabs-function frame))))
    (mapcar (lambda (tab) (alist-get 'name tab)) tabs)))

(defun ff/project-name (dir)
  "Define the name of a project as the name of the root directory.

DIR: root directory of project"
  (file-name-nondirectory (directory-file-name (file-name-directory dir))))

(defun ff/project-project-tab ()
  "Switch to a workspace with the project name."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
    (unless (member project-name (ff/tab-bar--names))
      (tab-bar-new-tab)
      (tab-rename project-name))
    (tab-bar-switch-to-tab project-name)))

(defun ff/project-switch-project (&optional project)
  "Switch to a workspace with the project name.
PROJECT: path to project"
  (interactive)
  (let* ((project-dir (or project (project-prompt-project-dir)))
         (project-name (ff/project-name project-dir)))
    (unless (member project-name (ff/tab-bar--names))
      (tab-bar-new-tab)
      (tab-rename project-name))
    (tab-bar-switch-to-tab project-name)
    (project-switch-project project-dir)))

(defun ff/project-magit ()
  "Show the Git status of the current project."
  (interactive)
  (magit-status (locate-dominating-file (project-root (project-current t)) ".git")))

(defun ff/project-vterm ()
  "Start a new vterm in project root.

PROJECT-ROOT: Path to the root directory of the current project."
  (interactive)
  (ff/start-vterm-in-dir (project-root (project-current t))))

(use-package project
  :straight (:type built-in)
  :custom
  (project-switch-commands '((project-find-file "Find file")
                             (project-find-dir "Find directory")
                             (ff/project-magit "Magit")
                             (project-dired "Dired")
                             (project-vc-dir "VC-Dir")
                             (affe-find "Fuzzy find")))
  (project-vc-extra-root-markers '(".project.el"))
  (project-vc-ignores '("build/" "install/" ".*cache/" "__pycache__"))
  :bind
  (:map project-prefix-map
        ("P" . ff/project-switch-project)
        ("g" . ff/project-magit)
        ("v" . project-vc-dir)
        ("t" . ff/project-project-tab)
        ("C" . run-command)))

(use-package time-zones
  :straight (:host github :repo "xenodium/time-zones" :branch "main"))

(provide 'ff-project-management)

;;; ff-project-management.el ends here
