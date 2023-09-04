;;; ff-setup-vterm --- Set up vterm
;;; Commentary:
;;; Sets up vterm config for Emacs.  Note that the features listed
;;; here, require a shell integration that is done in vterm.sh in the
;;; same repository.

;;; Code:

(require 'ff-shell-loader)

(defun ff/vterm-buffer-name-prefix ()
  "Create a prefix string for the name of a vterm buffer."
  (cond ((bound-and-true-p persp-mode)
         (concat "*vterm-" (persp-name (persp-curr))))
        ((fboundp 'tab-bar-mode)
         (let* ((current-tab (tab-bar--current-tab))
                (tab-index (tab-bar--current-tab-index))
                (explicit-name (alist-get 'explicit-name current-tab))
                (tab-name (if explicit-name (alist-get 'name current-tab) (+ 1 tab-index))))
           (concat "*vterm-" (format "%s" tab-name))))
        (t
         "*vterm")))

(defun ff/vterm-buffer-name (&optional postfix)
  "Create a defined buffer name for vterm.

POSTFIX postfix string to append to vterm buffer name"
  (let ((prefix (ff/vterm-buffer-name-prefix)))
    (if postfix
        (format "%s-%s*" prefix postfix)
      (format "%s*" prefix))))

(defun ff/start-vterm-in-dir (dir)
  "Start a new vterm in given directory.

DIR: Path to the root directory of the current project."
  (interactive)
  (ff/make-windows-visible-with-prefix (ff/vterm-buffer-name-prefix))
  (with-current-buffer (vterm (ff/vterm-buffer-name))
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

(defun ff/create-shell-buffer (_file-name buffer-name misc)
  "Create Shell buffer.

_FILE-NAME is nil.
BUFFER-NAME nil
MISC is the value returned by `ff/save-shell-buffer'."
  ;; create a vterm buffer in directory MISC
  (ff/start-vterm-in-dir misc))

(defun ff/show-all-vterm-windows ()
  "Show all vterm buffers."
  (interactive)
  (let* ((buffer-names (ff/load-buffers "*vterm"))
         (visible-buffers (ff/load-visible-buffers buffer-names)))
    (cond ((> (length visible-buffers) 0)
           ;; close all windows
           (ff/close-windows visible-buffers))
          ((> (length buffer-names) 0)
           ;; make hidden windows visible
           (ff/open-windows buffer-names))
          (t
           (message "No running vterm sessions.")))))

(defun ff/hide-all-vterm-windows ()
  "Show all vterm buffers."
  (interactive)
  (let* ((buffer-names (ff/load-buffers "*vterm"))
         (visible-buffers (ff/load-visible-buffers buffer-names)))
    (if (> (length visible-buffers) 0)
        ;; close all windows
        (ff/close-windows visible-buffers))))

(defun ff/read-last-command-from-shell-history ()
  "Read the last command that is listed in the shell's history file."
  (let* ((file-content (with-temp-buffer
                         (insert-file-contents (cdr (assoc "HISTFILE" (exec-path-from-shell-getenvs '("HISTFILE")))))
                         (buffer-string)))
         (lines (split-string file-content "\n"))
         (second-last-line (car (last lines 2))))
    second-last-line))

(defun ff/vterm-send-password ()
  "Use Emacs prompt to enter password for vterm.

This is required for a safe password input, see
https://github.com/akermu/emacs-libvterm/issues/518"
  (interactive)
  (let ((last-command (ff/read-last-command-from-shell-history)))
    (cond ((string-match ".*sudo.*" last-command)
           (vterm-send-string (password-store-get (format "passwords/sudo@%s" system-name))))
          (t
           (comint-send-invisible "Enter password: ")))
    (vterm-send-C-j)
    (clear-this-command-keys)))

(use-package vterm
  :custom ((vterm-shell "/bin/zsh")
           (vterm-max-scrollback 100000)
           (vterm-always-compile-module t)
           (vterm-kill-buffer-on-exit t))
  :init
  ;; ensure system packages
  (ff/ensure-apt-package "cmake" "cmake")
  (ff/ensure-python-package "cmake")
  (ff/ensure-apt-package "libtool-bin" "libtool")
  (ff/ensure-apt-package "zsh" "zsh")
  :config
  (add-hook 'vterm-exit-functions (lambda(_ _) (kill-buffer-and-window)))
  :bind (("C-x j" . ff/start-vterm)
         :map vterm-mode-map
         ("C-q" . vterm-send-next-key)
         ("C-y" . vterm-yank)
         ("C-x 2" . ff/open-vterm-below)
         ("C-x 3" . ff/open-vterm-right)
         ("C-M-p" . ff/vterm-send-password)
         ("C-c C-t" . vterm-copy-mode)
         ("C-c t" . (lambda()
                      (interactive)
                      (ff/start-vterm)
                      (ff/toggle-shell-vertical-alignment)
                      (ff/start-vterm)))))

(provide 'ff-setup-vterm)

;;; ff-setup-vterm.el ends here
