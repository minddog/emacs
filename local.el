(load "defunkt.el")

(eval-after-load "color-theme"
  '(progn
     (color-theme-twilight)))
;; initial buffer choice
(custom-set-variables
 '(initial-buffer-choice t))

(normal-erase-is-backspace-mode 1)
;;(normal-erase-is-backspace-mode 0)
(global-font-lock-mode 1)
(transient-mark-mode 1)
(delete-selection-mode 1)
(setq make-backup-files nil)
(menu-bar-mode -1)

;; blinken lights
;;(blink-cursor-mode 2)
;;(setq blink-cursor-alist 1)

;;backup and autosave prefs
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))


;; tab preferences
(defun make-tab-stop-list (width max)
  "Build a tab stop list for a given tab width and maximum line width"
  (labels ((aux (i) (if (<= i max) (cons i (aux (+ i width))))))
    (aux width)))

(defun set-tabs-local (width use-tabs)
  "Set local tab width and whether or not tab characters should be used"
  (setq c-basic-offset width)
  (setq sgml-basic-offset width)
  (setq javascript-indent-level width)
  (setq cssm-indent-level width)  (setq indent-tabs-mode use-tabs)  (setq tab-stop-list (make-tab-stop-list width 80))
  (setq tab-width width))

(defun make-tabs-global ()
  "Make current local tab settings the default"
  (interactive)
  (setq-default indent-tabs-mode indent-tabs-mode)
  (setq-default tab-stop-list tab-stop-list)
  (setq-default tab-width tab-width))

(defun set-tabs ()
  "Configure tab settings for this buffer"
  (interactive)
  (set-tabs-local
   (- (read-char "Tab width: ") ?0)
   (y-or-n-p "Use tab character? "))
  (if (y-or-n-p "Make settings global? ")
      (make-tabs-global))
  (message nil))

(defun build-css ()
  "Builds CSS"
  (progn
	(message "Running...")
	(shell-command "sh /usr/local/twilio/src/php/scripts/build/combine-css")))


(set-tabs-local 4 1)
(make-tabs-global)

(global-set-key
 "\C-H"
 '(lambda ()
    "Insert HTPL block"
    (interactive)
    (let ((name (read-string "Name: "))
          (start (min (region-beginning) (region-end)))
          (end (max (region-beginning) (region-end))))
      (save-excursion
        (goto-char end)
        (back-to-indentation)
        (insert "<!--- END: " name " --->")
        (newline-and-indent)
        (previous-line)
        (indent-according-to-mode)
        (goto-char start)
        (back-to-indentation)
        (insert "<!--- BEGIN: " name " --->")
        (newline-and-indent)))))


(defun mark-line (arg)
  (interactive "p")
  (beginning-of-line nil)
  (set-mark-command nil)
  (forward-line arg))

(global-set-key "\C-V" 'mark-line)

(add-hook 'c-mode-common-hook
          (lambda ()
            (c-set-style "java")
            (c-set-offset 'case-label '+)
            (c-set-offset 'substatement-open 0)
            (setq c-basic-offset tab-width)
            (define-key c-mode-map "\C-m" 'newline-and-indent)
            (when (fboundp 'c-subword-mode)
              (c-subword-mode 1))))

;; (setq browse-url-browser-function 'browse-url-lynx-emacs)

(defun comment-line ()
  (interactive)
  (if (= (line-beginning-position) (line-end-position))
      (next-line 1)
    (progn
      (back-to-indentation)
      (set-mark-command nil)
      (end-of-line nil)
      (comment-dwim nil)
      (back-to-indentation)
      (next-line 1))))

(global-set-key "\M-#" 'comment-line)

(global-set-key "\M-\C-\T" 'bs-show)
(global-set-key "\M-n" 'bs-cycle-next)
(global-set-key "\M-p" 'bs-cycle-prev)


;; css-mode settings
(autoload 'css-mode "css-mode")
(setq auto-mode-alist
      (cons '("\\.css\\'" . css-mode) auto-mode-alist))

(setq auto-mode-alist
      (cons '("\\.hx\\'" . haxe-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.json\\'" . javascript-mode) auto-mode-alist))
(setq cssm-indent-function #'cssm-c-style-indenter)
(add-hook 'css-mode-hook
          (lambda ()
            (define-key cssm-mode-map "}" 'self-insert-command)
            (cssm-leave-mirror-mode)))

;; Ruby and Rails
(add-to-list 'auto-mode-alist '("\\.builder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))

;; Add markdown alist
(add-to-list 'auto-mode-alist '("\\.text" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown" . markdown-mode))

;; Python settings
(add-hook 'python-mode-hook
     (lambda ()
	  (set-tabs-local (4 nil))
      (define-key python-mode-map "\"" 'electric-pair)
      (define-key python-mode-map "\'" 'electric-pair)
      (define-key python-mode-map "(" 'electric-pair)
      (define-key python-mode-map "[" 'electric-pair)
      (define-key python-mode-map "{" 'electric-pair)))

;; PHP settings
(add-hook 'php-mode-hook
	 (lambda ()
	   (set-tabs-local (4 t))))

;; Java settings
(add-hook 'java-mode-hook
	 (lambda ()
	   (set-tabs-local (4 t))))

;; XML settings
(add-hook 'html-mode-hook
	 (lambda ()
	   (set-tabs-local (4 nil))))


(defun electric-pair ()
  "Insert character pair without surrounding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))

;;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook '(lambda ()
     (define-key python-mode-map "\C-m" 'newline-and-indent)))


;; (defun kill-region-tabify ()
  ;; (interactive)
  ;; (if indent-tabs-mode
      ;; (tabify (region-beginning) (region-end))
    ;; (untabify (region-beginning) (region-end)))
  ;; (kill-region))

