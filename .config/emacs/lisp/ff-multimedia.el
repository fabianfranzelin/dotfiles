;;; ff-multimedia.el --- Setup multimedia apps

;;; Commentary:
;;

;;; Code:


;; Find radio streams: https://streamurl.link/
;; https://www.radio-browser.info/gui/#!/stations
;; https://playerservices.streamtheworld.com/api/livestream-redirect/RADIOLE_ASO_OSUNA.mp3

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
  :init
  (emms-all)
  :config
  ;; covers
  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async
        emms-browser-thumbnail-small-size 64
        emms-browser-thumbnail-medium-size 128)
  ;; history
  (emms-history-load))

(provide 'ff-multimedia)

;;; ff-multimedia.el ends here
