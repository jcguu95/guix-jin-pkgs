;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2018, 2020 Leo Famulari <leo@famulari.name>
;;;
;;; This file is NOT part of GNU Guix, but is supposed to be used with GNU
;;; Guix and thus has the same license.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (jin packages ibus-chewing)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages ibus)
  #:use-module (gnu packages language)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xorg)
  )

(define-public gob2
  (package
   (name "gob2")
   (version "2.0.20")
   (source
    (origin
     (method url-fetch)
     (uri "http://ftp.5z.com/pub/gob/gob2-2.0.20.tar.xz")
     (sha256 (base32 "09l0pr83vpl53hyl610qsrlsml2dribijik0b9pfk2m8gk089vpp"))
     ))
   (build-system gnu-build-system)
   (inputs
    `(("glib" ,glib)))
   (native-inputs
    `(("pkg-config" ,pkg-config)))
   (home-page "https://www.jirka.org/gob.html")
   (synopsis "GTK Object Builder (GOB) is a simple
preprocessor for easily creating GTK objects.")
   (description "GOB (GOB2 anyway) is a preprocessor for making
GObjects with inline C code so that generated files are not
edited. Syntax is inspired by Java and Yacc or Lex. The
implementation is intentionally kept simple, and no C actual code
parsing is done.")
   (license gpl2))) ;; not sure

(define-public ibus-chewing
  (package
   (name "ibus-chewing")
   (version "1.6.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/definite/ibus-chewing")
           (commit version)
           (recursive? #t) ;; Does this help fetch cmake-fedora from as a git submodule? And if yes, how would it help?
           ))
     (file-name (git-file-name name version))
     (sha256 (base32 "06vmvkz7jvw2lf0q3qif9ava0kmsjc8jvhvf2ngp0l60b8bi5p03"))
     ))
   ;; Official Installation Guide
   ;; https://github.com/definite/ibus-chewing/blob/e221ddd14dcfc922900db92fd6d9cca0e358a0f8/INSTALL
   (build-system cmake-build-system)
   (arguments '(#:configure-flags '("." "-DLIBEXEC_DIR='/usr/libexec'")
                #:parallel-build? #f)) ;; Don't really know what this means but it makes the log saner.:w
   (inputs
    `(
      ("glib" ,glib)
      ("gob" ,gob2)
      ("gtk" ,gtk+-2)
      ("ibus" ,ibus)
      ("libnotify" ,libnotify)
      ("libchewing" ,libchewing)
      ("libX11" ,libx11)
      ))
   (native-inputs
    `(("gettext" ,gettext-minimal)
      ("pkg-config" ,pkg-config)
      ("glib-bin" ,glib "bin")
      ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
      ))
   (home-page "https://github.com/definite/ibus-chewing")
   (synopsis "Chewing Input Method Engine for IBus")
   (description "IBus-Chewing is an IBus front-end of Chewing,
an intelligent Chinese input method for Zhuyin (BoPoMoFo)
users.")
   (license gpl3)))

;; FIXME current crux
;; Settings schema 'org.freedesktop.IBus.Chewing' is not installed


;; this is only for when I am building..
;; `guix build -f this-file.scm`
ibus-chewing
