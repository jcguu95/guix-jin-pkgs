;; DONE

(define-module (jin packages gob2)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

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

gob2
