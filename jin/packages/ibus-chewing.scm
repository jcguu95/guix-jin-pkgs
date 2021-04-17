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
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages cmake)
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
           ;; (commit "8e17848d3fe3bd7de052a1c26b4161092ba1df9f")
           (recursive? #t) ;; Does this help fetch cmake-fedora from as a git submodule? And if yes, how would it help?
           ))
     (file-name (git-file-name name version))
     (sha256 (base32 "06vmvkz7jvw2lf0q3qif9ava0kmsjc8jvhvf2ngp0l60b8bi5p03"))
     ;; (sha256 (base32 "1ygjygi4h8x94f6h6dm7gsxyshag1268ba5jr49q3mcwman270pn"))
     ))
   ;; Above are done.

   ;; Official Installation Guide
   ;; https://github.com/definite/ibus-chewing/blob/e221ddd14dcfc922900db92fd6d9cca0e358a0f8/INSTALL
   ;;
   ;; Hint - Might need cmake-fedora. But how?
   ;;
   (build-system cmake-build-system)
   ;; (arguments '(#:configure-flags '("." "-DCMAKE_INSTALL_PREFIX='/usr'" "-DLIBEXEC_DIR='/usr/libexec'")))
   (arguments '(#:configure-flags '("." "-DLIBEXEC_DIR='/usr/libexec'")))
   ;; (arguments (list #:configure-flags `("." (format #f "-DLIBEXEC_DIR='~a/libexec'" ,out))))
   (inputs
    `(
      ("glib" ,glib)
      ;; ("gob" ,gob) ; have no idea
      ("gtk" ,gtk+-2) ; have no idea
      ("ibus" ,ibus)
      ("libnotify" ,libnotify)
      ("libchewing" ,libchewing)
      ("libX11" ,libx11)
      ))
   (native-inputs
    `(
      ;; ("cmake" ,cmake)
      ;; ("extra-cmake-modules" ,extra-cmake-modules) ;; not sure if needed
      ("pkg-config" ,pkg-config)
      ))

   ;; Below are done.
   (home-page "https://github.com/definite/ibus-chewing")
   (synopsis "Chewing Input Method Engine for IBus")
   (description "IBus-Chewing is an IBus front-end of Chewing,
an intelligent Chinese input method for Zhuyin (BoPoMoFo)
users.")
   (license gpl3)))


;; this is only for when I am building..
;; `guix build -f this-file.scm`
ibus-chewing
