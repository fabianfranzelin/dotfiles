;;; package --- Setup shell loader package
;;; Commentary:

;;; The shell loader package is designed to open all available shells
;;; on the right hand side of the current window.  The terminals will be
;;; vertically stacked.

;;; Code:

(defun ff/load-buffers (prefix)
  "Filter all buffers that begin with the given prefix.
PREFIX: start string of buffer name"
  (setq filtered-buffers '())
  (dolist (name (mapcar #'buffer-name (buffer-list)))
    (if (string-match prefix name)
        (add-to-list 'filtered-buffers name)))
  ;; sort the buffers
  (cl-sort filtered-buffers 'string-lessp :key 'downcase))

(defun ff/is-any-buffer-visible (buffer-list)
  "Check whether any of the listed buffers is currently visible.
BUFFER-LIST: string list of buffer names"
  (setq is-visible nil)
  (while (> (length buffer-list) 0)
    (setq next-buffer (pop buffer-list))
    (cond ((eq next-buffer (window-buffer (selected-window)))
           ;; Visible and focused
           (setq is-visible t))
          ((get-buffer-window next-buffer)
           ;; Visible and unfocused
           (setq is-visible t))))
  (eval is-visible))

(defun ff/split-main-window (direction)
  "Split the main window in the DIRECTION.
DIRECTION: is a symbol with possible values of right, left, above or below."
  (let* ((new-window (split-window (frame-root-window) nil direction))
         (horizontal (member direction '(right left)))
         ;; take up one half of the frame size
         (size (/ (if horizontal (window-width) (window-height)) 2)))
    (save-excursion
      (select-window new-window)
      (enlarge-window size horizontal))
    new-window))

(defun ff/open-windows (buffer-list)
  "Open windows of the given buffer list on the very right of the frame.
BUFFER-LIST: string list of buffer names"
  (ff/split-main-window "right")
  (while (> (length buffer-list) 1)
    ;; load the next buffer
    (setq next-buffer (pop buffer-list))
    (switch-to-buffer next-buffer)
    ;; and open a new window below the current one for the next buffer
    ;; in the list
    (split-window-below)
    (other-window 1))
  ;; there is one buffer remaining and one last window to be filled
  (switch-to-buffer (pop buffer-list))
  (balance-windows))

(defun ff/close-windows (buffer-list)
  "Close all windows that visualize buffers of the BUFFER-LIST.
BUFFER-LIST: string list of buffer names"
  (while (> (length buffer-list) 0)
    ;; switch to the next window and close it
    (setq next-window (get-buffer-window (pop buffer-list)))
    (delete-window next-window))
  (balance-windows))

(defun ff/toggle-windows-with-prefix (prefix start-cmd)
  "Toggle the visibility of buffers with the given prefix.
If none is available, START-CMD is executed in a new window.
PREFIX: start string of buffer name START-CMD: list that is to be
executed if no buffer with given prefix exists."
  (setq buffer-names (ff/load-buffers prefix))
  (cond ((= (length buffer-names) 0)
         ;; no buffers available -> create a new one
         (ff/split-main-window "right")
         ;; initiate whatever is given by the user
         (eval start-cmd)
         (balance-windows))
        (t
         (if (ff/is-any-buffer-visible buffer-names)
             (ff/close-windows buffer-names)
           (ff/open-windows buffer-names)))))

(provide 'shell-loader)

;;; shell-loader.el ends here
