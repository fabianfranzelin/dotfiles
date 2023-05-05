;;; ff-project-management.el --- Setup project.el, etc.

;;; Commentary:
;; Configuration for project.el and surrounding stuff

;;; Code:

;; -------------------------------------------------------------------
;; Tab bar: one tab per project
;; -------------------------------------------------------------------
(defun ff/tab-bar-list ()
  "Provide string list of all tab names."
  (interactive)
  (mapcar #'(lambda (tab) (alist-get 'name tab))
		  (tab-bar-tabs)))

(defun ff/tab-bar-show-tab-list ()
  "Show list of all tab names."
  (interactive)
  (message (string-join (ff/tab-bar-list) " ")))

(defun ff/tab-bar-tab-exists (name)
  "Check whether the given tab-name exists already.
NAME: name of a tab"
  (member name (ff/tab-bar-list)))

(defun ff/tab-bar-new-tab (name)
  "Create a new tab with the given name.
NAME: name of a tab"
  (when (eq nil tab-bar-mode)
    (tab-bar-mode))
  (tab-bar-new-tab)
  (tab-bar-rename-tab name))

(defun ff/tab-bar-switch-or-create (name func)
  (if (ff/tab-bar-tab-exists name)
      (tab-bar-switch-to-tab name)
    (ff/tab-bar-new-tab name))
  (funcall func))

(defun ff/tab-bar-run-notes ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/notes.org"))))

(defun ff/tab-bar-run-aos-architecture ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/todos_aos_architecture.org"))))

(defun ff/tab-bar-run-aos-defect-handling ()
  (interactive)
  (ff/tab-bar-switch-or-create
   "org"
   #'(lambda ()
       (find-file "~/workspace/org/todos_aos_defect_handling_feature.org"))))

(use-package tab-bar
  :custom
  ;; Don't turn on tab-bar-mode when tabs are created
  ((tab-bar-show nil)
   (tab-bar-new-tab-choice "*scratch*"))
  :init
  (tab-bar-mode t)
  :bind (("C-x t n" . tab-new)
         ("C-x t w" . tab-close)
         ("C-<prior>" . tab-previous)
         ("C-<next>" . tab-next)
         ("C-x t h a" . ff/tab-bar-run-aos-architecture)
         ("C-x t h d" . ff/tab-bar-run-aos-defect-handling)
         ("C-x t h n" . ff/tab-bar-run-notes)
         ("C-x t l" . ff/tab-bar-show-tab-list)))

;; -------------------------------------------------------------------
;; Tasks
;; -------------------------------------------------------------------
(defun ff/run-command-runner-vterm (command-line buffer-base-name output-buffer)
  "Command runner based on `vterm-mode'.

Executes COMMAND-LINE in buffer OUTPUT-BUFFER.  Name the process BUFFER-BASE-NAME."
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
   (let ((cmake-lists-file (expand-file-name "CMakeLists.txt" default-directory)))
     (message (format "%s" cmake-lists-file))
     (when (f-file-p cmake-lists-file)
       (list :command-name "build:cmake"
             :command-line "mkdir -p build && cd build && cmake .."
             :working-dir default-directory)))))

;; define Python targets
(defun run-command-recipe-ff/python ()
  "Define Python recipes for run command package."
  (list
   ;; pytest project
   (when-let* ((project-dir (locate-dominating-file default-directory ".git")))
     (list :command-name "python:pytest (project)"
           :command-line "python3 -m pytest"
           :working-dir project-dir))
   ;; pytest project vterm
   (when-let* ((project-dir (locate-dominating-file default-directory ".git")))
     (list :command-name "python:pytest (project, vterm)"
           :command-line "python3 -m pytest -vvv -s --pdb"
           :display "python:pytest (project, vterm)"
           :working-dir project-dir
           :runner 'ff/run-command-runner-vterm))))

;; define Conan targets
(defun run-command-recipe-ff/conan ()
  "Define Conan recipes for run command package."
  (list
   (when-let* ((project-dir (locate-dominating-file default-directory "conanfile.py")))
     (list :command-name "conan:install"
           :command-line "conan install . -if=install -pr=ubuntu2004_x86_64_gcc8_debug --build=missing"
           :working-dir project-dir))
   (when-let* ((project-dir (locate-dominating-file default-directory "conanfile.py"))
               (build-dir (expand-file-name "install" project-dir)))
     (list :command-name "conan:build"
           :command-line "conan build . -if=install -bf=build"
           :working-dir project-dir))))

(use-package run-command
  :custom ((run-command-default-runner #'run-command-runner-compile))
  :config
  (add-to-list 'run-command-recipes #'run-command-recipe-ff/cc)
  (add-to-list 'run-command-recipes #'run-command-recipe-ff/python)
  (add-to-list 'run-command-recipes #'run-command-recipe-ff/conan))

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
      (tab-bar-new-tab project-name))
    (tab-bar-switch-to-tab project-name)))

(defun ff/project-switch-project ()
  "Switch to a workspace with the project name."
  (interactive)
  (let* ((project-dir (project-prompt-project-dir))
         (project-name (ff/project-name project-dir)))
    (unless (member project-name (ff/tab-bar--names))
      (tab-bar-new-tab project-name))
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
  :custom
  ((project-switch-commands '((project-find-file "Find file")
                              (project-find-dir "Find directory")
                              (ff/project-magit "Magit")
                              (project-dired "Dired")))
   (project-vc-extra-root-markers '(".project.el"))
   (project-vc-ignores '("build/" "install/" ".*cache/")))
  :bind (:map project-prefix-map
              ("P" . ff/project-switch-project)
              ("g" . ff/project-magit)
              ("v" . ff/project-vterm)
              ("a" . affe-find)
              ("r" . affe-grep)
              ("t" . ff/project-project-tab)
              ("C" . run-command)))

(provide 'ff-project-management)

;;; ff-project-management.el ends here
