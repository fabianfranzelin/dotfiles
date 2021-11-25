;;; package --- Setup shell loader package
;;; Commentary:

;;; The shell loader package is designed to open all available shells
;;; on the right hand side of the current window.  The terminals will be
;;; vertically stacked.

;;; Code:

(defcustom ff/shell-vertical-alignment t
  "When non-nil, the terminals are aligned in a vertical manner on the right."
  :type 'boolean)

(defun ff/toggle-shell-vertical-alignment ()
  "Toggle whether the alignment of shells is vertical or horizontal."
  (interactive)
  (if ff/shell-vertical-alignment
      (customize-set-variable 'ff/shell-vertical-alignment nil)
    (customize-set-variable 'ff/shell-vertical-alignment t)))

(defun ff/load-buffers (prefix)
  "Filter all buffers that begin with the given prefix.
PREFIX: start string of buffer name"
  (let (filtered-buffers '())
    (dolist (name (mapcar #'buffer-name (buffer-list)))
      (if (string-match prefix name)
          (add-to-list 'filtered-buffers name)))
    ;; sort the buffers
    (cl-sort filtered-buffers 'string-lessp :key 'downcase)))

(defun ff/is-buffer-visible (buffer-name)
  "Check whether a buffer is visible or not.
BUFFER-NAME: string name of the buffer"
    (cond ((eq buffer-name (window-buffer (selected-window)))
           ;; Visible and focused
           t)
          ((get-buffer-window buffer-name)
           ;; Visible and unfocused
           t)
          (t
           nil)))

(defun ff/load-visible-buffers (buffer-list)
  "Filter all buffers that begin with the given prefix.
BUFFER-LIST: string list of buffer names"
  (let (filtered-buffers '())
    (dolist (next-buffer buffer-list)
      (if (ff/is-buffer-visible next-buffer)
          (add-to-list 'filtered-buffers next-buffer)))
    ;; sort the buffers
    (cl-sort filtered-buffers 'string-lessp :key 'downcase)))


(defun ff/is-any-buffer-visible (buffer-list)
  "Check whether any of the listed buffers is currently visible.
BUFFER-LIST: string list of buffer names"
  (setq is-visible nil)
  (dolist (next-buffer buffer-list)
    (if (ff/is-buffer-visible next-buffer)
        (setq is-visible t))
  (eval is-visible))

(defun ff/split-main-window ()
  "Split the main window in the direction indicated by ff/shell-vertical-alignment."
  (let* ((new-window (split-window (frame-root-window) nil (eval ff/shell-vertical-alignment)))
         ;; take up one half of the frame size
         (size (/ (if ff/shell-vertical-alignment (window-width) (window-height)) 2)))
    (save-excursion
      (select-window new-window)
      (enlarge-window size ff/shell-vertical-alignment))
    new-window))

(defun ff/open-windows (buffer-list)
  "Open windows of the given buffer list on the very right of the frame.
BUFFER-LIST: string list of buffer names"
  (ff/split-main-window)
  (while (> (length buffer-list) 1)
    ;; load the next buffer
    (switch-to-buffer (pop buffer-list))
    ;; and open a new window below the current one for the next buffer
    ;; in the list
    (if ff/shell-vertical-alignment (split-window-below) (split-window-right))
    (other-window 1))
  ;; there is one buffer remaining and one last window to be filled
  (switch-to-buffer (pop buffer-list))
  (balance-windows))

(defun ff/close-windows (buffer-list)
  "Close all windows that visualize buffers of the BUFFER-LIST.
BUFFER-LIST: string list of buffer names"
  (while (> (length buffer-list) 0)
    ;; switch to the next window and close it
    (delete-window (get-buffer-window (pop buffer-list))))
  (balance-windows))

(defun ff/toggle-windows-with-prefix (prefix start-cmd)
  "Toggle the visibility of buffers with the given prefix.
If none is available, START-CMD is executed in a new window.
PREFIX: start string of buffer name
START-CMD: list that is to be executed if no buffer with given prefix exists.
"
  (setq buffer-names (ff/load-buffers prefix))
  (cond ((= (length buffer-names) 0)
         ;; no buffers available -> create a new one
         (ff/split-main-window)
         ;; initiate whatever is given by the user
         (eval start-cmd)
         (balance-windows))
        (t
         (setq visible-buffers (ff/load-visible-buffers buffer-names))
         (if (> (length visible-buffers) 0)
             (ff/close-windows visible-buffers)
           (ff/open-windows buffer-names)))))

(provide 'shell-loader)

;;; shell-loader.el ends here
