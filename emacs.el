(add-to-list 'load-path "~/.emacs.d")

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;; You're expected to populate .emacs.d/local.el
;; with your own code. This file is under .gitignore
;; so it won't be version-controlled. The idea is to
;; make this file load other version-controlled files.
(load "local")


