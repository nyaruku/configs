;; -------------------------------
;; Basic package setup
;; -------------------------------
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; Ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(message "init.el loaded!")

;; -------------------------------
;; Evil for Vim users
;; -------------------------------
;; Must be set BEFORE loading evil or evil-collection
(setq evil-want-C-u-scroll t)
(setq evil-want-keybinding nil)

(use-package evil
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; -------------------------------
;; Indentation
;; -------------------------------
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default c-basic-offset 2)
(setq js-indent-level 2)
(setq python-indent-offset 2)

;; Smart TAB / Shift-TAB
(defun my-indent-or-complete ()
  "Indent or complete using company if at end of symbol."
  (interactive)
  (if (looking-at "\\_>")
      (company-complete-common)
    (indent-for-tab-command)))

(define-key evil-insert-state-map (kbd "TAB") 'my-indent-or-complete)

(defun my-unindent ()
  "Un-indent current line or selection by tab-width."
  (interactive)
  (if (use-region-p)
      (indent-rigidly (region-beginning) (region-end) (- tab-width))
    (indent-rigidly (line-beginning-position) (line-end-position) (- tab-width))))

(define-key evil-insert-state-map (kbd "<backtab>") 'my-unindent)
(define-key evil-visual-state-map (kbd "<backtab>") 'my-unindent)

;; -------------------------------
;; Line numbers
;; -------------------------------
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; -------------------------------
;; Autocomplete
;; -------------------------------
(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode))

;; -------------------------------
;; Clipboard integration
;; -------------------------------
(setq select-enable-clipboard t)

;; -------------------------------
;; Handy line moving functions
;; -------------------------------
(defun my-move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun my-move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

;; -------------------------------
;; Keybindings
;; -------------------------------
(define-key evil-visual-state-map (kbd "M-c") "y")

(define-key evil-normal-state-map (kbd "M-v")
  (lambda () (interactive) (insert (current-kill 0))))
(define-key evil-insert-state-map (kbd "M-v")
  (lambda () (interactive) (insert (current-kill 0))))

(define-key evil-normal-state-map (kbd "M-<up>") 'my-move-line-up)
(define-key evil-normal-state-map (kbd "M-<down>") 'my-move-line-down)

(define-key evil-visual-state-map (kbd "M-<up>")
  (lambda ()
    (interactive)
    (evil-exit-visual-state)
    (my-move-line-up)))
(define-key evil-visual-state-map (kbd "M-<down>")
  (lambda ()
    (interactive)
    (evil-exit-visual-state)
    (my-move-line-down)))

;; -------------------------------
;; Mode line
;; -------------------------------
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

;; -------------------------------
;; Theme
;; -------------------------------
(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;; -------------------------------
;; Ensure Evil starts on startup
;; -------------------------------
(add-hook 'emacs-startup-hook #'evil-mode)


;; Disable auto-save files (those ending with ~ or #)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)


