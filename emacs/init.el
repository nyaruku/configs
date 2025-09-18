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

(defun my-unindent ()
  "Un-indent current line or selection by tab-width."
  (interactive)
  (if (use-region-p)
      (indent-rigidly (region-beginning) (region-end) (- tab-width))
    (indent-rigidly (line-beginning-position) (line-end-position) (- tab-width))))

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
;; Theme
;; -------------------------------
(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;; -------------------------------
;; Ensure Evil starts on startup
;; -------------------------------

;; Disable auto-save files (those ending with ~ or #)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)


