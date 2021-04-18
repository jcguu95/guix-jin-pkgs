;; It compiles successfully and passes the test!
;; But how would I make it working?
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
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xorg)

  #:use-module (guix build-system glib-or-gtk)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages flex)
  )

(define-public gob
  (package
    (name "gob")
    (version "2.0.20")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "http://ftp.5z.com/pub/gob/gob2-" version ".tar.xz"))
       (sha256
        (base32 "09l0pr83vpl53hyl610qsrlsml2dribijik0b9pfk2m8gk089vpp"))))
    (build-system glib-or-gtk-build-system)
    (inputs
     `(("glib" ,glib)
       ("gtk+" ,gtk+)))
    (native-inputs
     `(("bison" ,bison)
       ("flex" ,flex)
       ("perl" ,perl)
       ("pkg-config" ,pkg-config)))
    (home-page "https://www.jirka.org/gob.html")
    (synopsis "GObject Builder")
    (description "GOB is a preprocessor for making GObjects with inline C code so
that generated files are not edited.  Syntax is inspired by Java and Yacc or
Lex.  The implementation is intentionally kept simple, and no C actual code
parsing is done.")
    (license gpl2+)))

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
             ;; To pull CMake-Fedora.
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06vmvkz7jvw2lf0q3qif9ava0kmsjc8jvhvf2ngp0l60b8bi5p03"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags
       (list
        (string-append "-DLIBEXEC_DIR="
                       (assoc-ref %outputs "out")
                       "/libexec"))
       #:imported-modules
       (,@%cmake-build-system-modules
        (guix build glib-or-gtk-build-system))
       #:modules
       ((guix build cmake-build-system)
        ((guix build glib-or-gtk-build-system)
         #:prefix glib-or-gtk:)
        (guix build utils))
       #:phases
       (modify-phases %standard-phases
         (delete 'check)
         (add-after 'install 'wrap-env
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (for-each
                (lambda (name)
                  (let ((file (string-append out "/libexec/" name))
                        (out (assoc-ref outputs "out")))
                    (wrap-program file
                      `("GI_TYPELIB_PATH" ":" prefix
                        (,(string-append (assoc-ref inputs "ibus")
                                         "/lib/girepository-1.0")))
                      `("XDG_DATA_DIRS" ":" prefix
                        (,(string-append out "/share"))))))
                '("ibus-engine-chewing" "ibus-setup-chewing")))))
         (add-after 'wrap-env 'glib-or-gtk-compile-schemas
           (assoc-ref glib-or-gtk:%standard-phases 'glib-or-gtk-compile-schemas))
         (add-after 'glib-or-gtk-compile-schemas 'glib-or-gtk-wrap
           (assoc-ref glib-or-gtk:%standard-phases 'glib-or-gtk-wrap))
         (add-after 'glib-or-gtk-wrap 'custom-check
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Tests write to $HOME.
             (setenv "HOME" (getcwd))
             ;; Tests look for $XDG_RUNTIME_DIR.
             (setenv "XDG_RUNTIME_DIR" (getcwd))
             ;; Tests look for $XDG_DATA_DIRS.
             (setenv "XDG_DATA_DIRS"
                     (string-append (getenv "XDG_DATA_DIRS")
                                    ":" (assoc-ref outputs "out") "/share"))
             ;; For missing '/etc/machine-id'.
             (setenv "DBUS_FATAL_WARNINGS" "0")
             ;; Tests require a running X server.
             (system "Xvfb :1 +extension GLX &")
             (setenv "DISPLAY" ":1")
             ;; Tests require running iBus daemon.
             (system "ibus-daemon --daemonize")
             (with-directory-excursion "test-bin"
               (for-each (lambda (test)
                           (invoke test))
                         (list
                          "./IBusChewingPreEdit-test"
                          "./ibus-chewing-engine-test"
                          "./MakerDialogUtil-test"
                          "./IBusChewingUtil-test"
                          "./MakerDialogBackend-test"))))))))
    (inputs
     `(("glib" ,glib)
       ("gob" ,gob)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
       ("gtk" ,gtk+-2)
       ("ibus" ,ibus)
       ("libnotify" ,libnotify)
       ("libchewing" ,libchewing)
       ("libx11" ,libx11)
       ("libxtst" ,libxtst)
       ("rpm" ,rpm)))
    (native-inputs
     `(("gettext" ,gettext-minimal)
       ("glib-bin" ,glib "bin")
       ("perl" ,perl)
       ("pkg-config" ,pkg-config)
       ("xorg-server" ,xorg-server-for-tests)))
    (home-page "https://github.com/definite/ibus-chewing")
    (synopsis "Chewing engine for IBus")
    (description "IBus-Chewing is an IBus front-end of Chewing,
an intelligent Chinese input method for Zhuyin (BoPoMoFo) users.")
    (license
     (list
      ;; CMake-Fedora.
      expat
      ;; Others.
      gpl2+))))

ibus-chewing
