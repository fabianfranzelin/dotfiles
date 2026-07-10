;;; ff-multimedia.el --- Setup multimedia apps -*- lexical-binding: t; -*-

;;; Commentary:
;;

;;; Code:

;; Find radio streams: https://streamurl.link/
;; https://www.radio-browser.info/gui/#!/stations

(use-package emms
  :preface
  (ff/ensure-apt-package "mpv" "mpv")
  :custom
  (emms-source-file-default-directory (expand-file-name "Music" (getenv "HOME")))
  (emms-source-playlist-default-format 'm3u)
  (emms-playlist-mode-center-when-go t)
  (emms-playlist-default-major-mode 'emms-playlist-mode)
  (emms-show-format "NP: %s")
  (emms-player-list '(emms-player-mpv))
  (emms-player-mpv-environment '("PULSE_PROP_media.role=music"))
  (emms-player-mpv-parameters '("--quiet" "--really-quiet" "--no-audio-display" "--force-window=no" "--vo=null"))
  (emms-player-mpv-update-metadata t)
  (emms-info-functions '(emms-info-native))
  (emms-playlist-buffer-name "*Music*")
  (emms-repeat-playlist t)
  (emms-source-file-default-directory (expand-file-name "Music" (getenv "HOME")))
  :init
  (emms-all)
  :config
  ;; covers
  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async
        emms-browser-thumbnail-small-size 64
        emms-browser-thumbnail-medium-size 128)
  ;; display format
  (setq emms-browser-info-title-format "%T %a - %t"
        emms-browser-default-format "%n")
  ;; history
  (emms-history-load)
  ;; Add one default radio station (radiole)
  (defun ff/radiole ()
    "Radiole. These links might break now and then. For latest see"
    (interactive)
    (emms-play-streamlist
     "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIOLE_ASO_OSUNAAAC.aac"))

  (defvar-keymap ff/emms-key-map
    :doc "Bindings for managing emms, configured to be repeatable."
    :repeat t
    "r" 'ff/radiole
    "s" 'emms-start
    "q" 'emms-stop
    "SPC" 'emms-pause)
  (keymap-global-set "C-c e" ff/emms-key-map)
  :bind (:map global-map
              ("<XF86AudioPlay>" . emms-pause)
              ("<XF86AudioStop>" . emms-stop)))

(use-package tag-edit-mode
  :straight (tag-edit-mode :type git :host github :repo "defaultxr/tag-edit-mode")
  :bind (:map dired-mode-map
              ("E" . tag-edit-dired)))

(use-package ready-player
  :custom
  (ready-player-my-media-collection-location (expand-file-name "Music" (getenv "HOME")))
  :config
  ;; Recognize video files as audio.
  (setq ready-player-supported-audio (append ready-player-supported-audio
                                             ready-player-supported-video))
  ;; Don't recognize any file as video.
  (setq ready-player-supported-video nil)
  ;; Disable video stream playback (mpv player)
  (setq ready-player-open-playback-commands
        '(("mpv" "--audio-display=no" "--video=no" "--input-ipc-server=<<socket>>")))  :config
  (ready-player-mode t))

(provide 'ff-multimedia)

;;; ff-multimedia.el ends here
