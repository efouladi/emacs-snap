;;; site-start.el --- Make Emacs work correctly as a snap

;;; Commentary:

;; This file contains the various settings to allow Emacs to function
;; correctly as a strictly confined snap

;;; Code:

;; since the Emacs snap is under classic confinement, it runs in the host
;; systems mount namespace and hence will use the host system's PATH
;; etc. As such, we don't want subprocesses launched by Emacs to inherit
;; the snap specific GIO_MODULE_DIR, GDK_PIXBUF and FONTCONFIG environment
;; as they likely will be linked against different libraries than what the
;; Emacs snap base snap is using. So make sure they are effectively unset.
(dolist (env '("GIO_MODULE_DIR"
               "GDK_PIXBUF_MODULE_FILE"
               "GDK_PIXBUF_MODULEDIR"
               "FONTCONFIG_FILE"))
  (setenv env))

;; ensure the correct native-comp-driver-options are set - use
;; /snap/emacs/current if $SNAP is not set for some reason - we also patch
;; comp.el in when building the emacs snap but do it here too to try and
;; ensure this is always set no matter what
(when (require 'comp nil t)
  (let ((sysroot (file-name-as-directory (or (getenv "SNAP")
                                             "/snap/emacs/current"))))
    (dolist (opt (list (concat "--sysroot=" sysroot)
                       (concat "-B" sysroot "usr/lib/gcc/")))
      (add-to-list 'native-comp-driver-options opt t))))


;; now that we have accessed $SNAP we can unset it - and also unset *all* the
;; various SNAP environment variables so we don't confuse any other
;; applications that we launch (like say causing firefox to use the wrong
;; profile - we need to unset SNAP_NAME and SNAP_INSTANCE_NAME to stop that
;; - see https://github.com/alexmurray/emacs-snap/issues/36).
(dolist (env '("SNAP_REVISION"
               "SNAP_REAL_HOME"
               "SNAP_USER_COMMON"
               "SNAP_INSTANCE_KEY"
               "SNAP_CONTEXT"
               "SNAP_ARCH"
               "SNAP_INSTANCE_NAME"
               "SNAP_USER_DATA"
               "SNAP_REEXEC"
               "SNAP"
               "SNAP_COMMON"
               "SNAP_VERSION"
               "SNAP_LIBRARY_PATH"
               "SNAP_COOKIE"
               "SNAP_DATA"
               "SNAP_NAME"))
  (setenv env))


(provide 'site-start)
;;; site-start.el ends here
