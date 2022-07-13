;;; package --- Set up vterm
;;; Commentary:
;;; Sets up vterm config for Emacs.  Note that the features listed
;;; here, require a shell integration that is done in vterm.sh in the
;;; same repository.

;;; Code:

(defun ff/vterm-buffer-name-prefix ()
  "Create a prefix string for the name of a vterm buffer."
  (if (bound-and-true-p persp-mode)
      (concat "*vterm-" (persp-name (persp-curr)))
    "*vterm"))

(defun ff/vterm-buffer-name (&optional postfix)
  (let ((prefix (ff/vterm-buffer-name-prefix)))
        (if (equal postfix nil)
            (concat prefix "*")
          (concat prefix "-" postfix "*"))))

(defun ff/run-in-vterm-kill (process event)
  "A process sentinel.  Kill PROCESS's buffer if it is live.
PROCESS:
EVENT:"
  (let ((b (process-buffer process)))
    (and (buffer-live-p b)
         (kill-buffer-and-window))))

(defun ff/run-in-vterm (command)
  "Execute string COMMAND in a new vterm.

Interactively, prompt for COMMAND with the current buffer's file
name supplied. When called from Dired, supply the name of the
file at point.

Like `async-shell-command`, but run in a vterm for full terminal features.

The new vterm buffer is named in the form `*foo bar.baz*`, the
command and its arguments in earmuffs.

When the command terminates, the shell remains open, but when the
shell exits, the buffer is killed.
COMMAND:"
  (interactive
   (list
    (let* ((f (cond (buffer-file-name)
                    ((eq major-mode 'dired-mode)
                     (dired-get-filename nil t))))
           (filename (concat " " (shell-quote-argument (and f (file-relative-name f))))))
      (read-shell-command "Terminal command: "
                          (cons filename 0)
                          (cons 'shell-command-history 1)
                          (list filename)))))
  (with-current-buffer (vterm (ff/vterm-buffer-name (command)))
    (set-process-sentinel vterm--process #'ff/run-in-vterm-kill)
    (vterm-send-string command)
    (vterm-send-return)))

(defun ff/start-vterm-in-dir (dir)
  "Start a new vterm in given directory.

DIR: Path to the root directory of the current project."
  (interactive)
  (ff/make-windows-visible-with-prefix (ff/vterm-buffer-name-prefix))
  (with-current-buffer (vterm (ff/vterm-buffer-name))
    (set-process-sentinel vterm--process #'ff/run-in-vterm-kill)
    (vterm-send-string (concat "cd " dir))
    (vterm-send-return)))

(defun ff/start-vterm ()
  "Start Vterm terminal emulator."
  (interactive)
  (ff/toggle-windows-with-prefix (ff/vterm-buffer-name-prefix) '(vterm (ff/vterm-buffer-name))))

(defun ff/open-vterm-below ()
  "Opens new v-term below of the current window."
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1)
  (vterm (ff/vterm-buffer-name)))

(defun ff/open-vterm-right ()
  "Opens new v-term right of the current window."
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1)
  (vterm (ff/vterm-buffer-name)))

(defun ff/term-exec-hook ()
  "Delete the buffer once the terminal session is terminated."
  (let* ((buff (current-buffer))
         (proc (get-buffer-process buff)))
    (set-process-sentinel
     proc
     #'ff/run-in-vterm-kill)))

;; Account for https://github.com/akermu/emacs-libvterm/issues/518
(defun vterm-send-password ()
  "Send password to vterm safely."
  (interactive)
  (comint-send-invisible "Enter password: ")
  (vterm-send-string "\n")
  (clear-this-command-keys))

(use-package vterm
  :commands vterm
  :hook ((vterm-mode . ff/term-exec-hook))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "cmake" "cmake")
  (ff/ensure-apt-package "libtool-bin" "libtool")
  (ff/ensure-apt-package "zsh" "zsh")

  :config
  (setq vterm-shell "/bin/zsh")
  (setq vterm-max-scrollback 100000)
  (setq explicit-shell-file-name "/bin/zsh")

  (define-key vterm-mode-map (kbd "<C-backspace>")
    (lambda () (interactive) (vterm-send-key (kbd "C-w"))))

  :bind (("C-x j" . ff/start-vterm)
         :map vterm-mode-map
         ("C-y" . vterm-yank)
         ("C-x 2" . ff/open-vterm-below)
         ("C-x 3" . ff/open-vterm-right)
         ("C-c C-t" . vterm-copy-mode)
         ("C-c t" . (lambda()
                      (interactive)
                      (ff/start-vterm)
                      (ff/toggle-shell-vertical-alignment)
                      (ff/start-vterm)))))

(provide 'setup-vterm)

;;; setup-vterm.el ends here
