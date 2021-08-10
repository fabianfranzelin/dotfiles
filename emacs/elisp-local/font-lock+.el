;;; font-lock+.el --- Enhancements to standard library `font-lock.el'.
;;
;; Filename: font-lock+.el
;; Description: Enhancements to standard library `font-lock.el'.
;; Author: Drew Adams
;; Maintainer: Drew Adams (concat "drew.adams" "@" "oracle" ".com")
;; Copyright (C) 2007-2018, Drew Adams, all rights reserved.
;; Created: Sun Mar 25 15:21:07 2007
;; Version: 0
;; Package-Requires: ()
;; Last-Updated: Mon Jan  1 11:39:08 2018 (-0800)
;;           By: dradams
;;     Update #: 218
;; URL: https://www.emacswiki.org/emacs/download/font-lock%2b.el
;; Doc URL: https://www.emacswiki.org/emacs/HighlightLibrary
;; Keywords: languages, faces, highlighting
;; Compatibility: GNU Emacs: 22.x, 23.x, 24.x, 25.x, 26.x
;;
;; Features that might be required by this library:
;;
;;   `font-lock', `syntax'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;    Enhancements to standard library `font-lock.el'.
;;
;;  This library tells font lock to ignore any text that has the text
;;  property `font-lock-ignore'.  This means, in particular, that font
;;  lock will not erase or otherwise interfere with highlighting that
;;  you apply using library `highlight.el'.
;;
;;  Load this library after standard library `font-lock.el' (which
;;  should be preloaded).  Put this in your Emacs init file (~/.emacs):
;;
;;    (require 'font-lock+)
;;
;;
;;  Non-interactive functions defined here:
;;
;;    `put-text-property-unless-ignore'.
;;
;;
;;  ***** NOTE: The following functions defined in `font-lock.el'
;;              have been REDEFINED HERE:
;;
;;    `font-lock-append-text-property', `font-lock-apply-highlight',
;;    `font-lock-apply-syntactic-highlight',
;;    `font-lock-default-unfontify-region',
;;    `font-lock-fillin-text-property',
;;    `font-lock-fontify-anchored-keywords',
;;    `font-lock-fontify-keywords-region',
;;    `font-lock-fontify-syntactically-region',
;;    `font-lock-prepend-text-property'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change Log:
;;
;; 2014/08/30 dadams
;;     Require cl.el when compile, for incf.
;;     Load font-lock.el[c] when compile, for macro save-buffer-state.
;;     font-lock-(prepend|append)-text-property:
;;       Update for Emacs 24: Canonicalize old forms.
;;     font-lock-fontify-syntactically-region: Updated for Emacs 24.
;; 2014/08/28 dadams
;;     put-text-property-unless-ignore: Use next-single-property-change.
;; 2007/03/25 dadams
;;     Created.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

