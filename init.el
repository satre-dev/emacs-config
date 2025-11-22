;; Package setup
(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(when (< emacs-major-version 29)
  (unless (package-installed-p 'use-package)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'use-package)))

(add-to-list 'display-buffer-alist
	     '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\`"
	       (display-buffer-no-window)
	       (allow-no-window . t)))

(use-package delsel
    :ensure nil
    :hook (after-init . delete-selection-mode))

(defun satre/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general 'keyboard-quit'.
The generic 'keyboard-quit' does not do the expected thing when
the minibuffer is open. Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- when the Completions buffer is selected, close it.
- In ever other case use the regular 'keyboard-quit'."
  (interactive)
  (cond
    ((region-active-p)
     (keyboard-quit))
    ((derived-mode-p 'completion-list-mode)
     (delete-completion-window))
    ((> (minibuffer-depth) 0)
     (abort-recursive-edit))
    (t
     (keyboard-quit))))

(define-key global-map (kbd "C-g") #'satre-keyboard-quit-dwim)

(menu-bar-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(let ((mono-spaced-font "JetBrains Mono")
      (proportionally-spaced-font "Adwaita Sans"))
  (set-face-attribute 'default nil :family "JetBrains Mono" :height 120)
  (set-face-attribute 'fixed-pitch nil :family "JetBrains Mono" :height 1.0)
  (set-face-attribute 'variable-pitch nil :family "Adwaita Sans" :height 1.0))

(load-theme 'modus-vivendi-tinted t)
 
(use-package nerd-icons
    :ensure t)

(use-package nerd-icons-completion
    :ensure t
    :after marginalia
    :config
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
    :ensure t
    :after corfu
    :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
    :ensure t
    :hook
    (dired-mode . nerd-icons-dired-mode))

(use-package vertico
    :ensure t
    :hook (after-init . vertico-mode))

(use-package marginalia
    :ensure t
    :hook (after-init . marginalia-mode))

(use-package savehist
    :ensure nil
    :hook (after-init . savehist-mode))

(use-package corfu
    :ensure t
    :hook (after-init . global-corfu-mode)
    :bind (:map corfu-map ("<tab>" . corfu-complete))
    :config
    (setq tab-always-indent 'complete)
    (setq corfu-preview-current nil)
    (setq corfu-min-width 20)

    (setq corfu-popupinfo-delay '(1.25 . 0.5))
    (corfu-popupinfo-mode 1)

    (with-eval-after-load 'save-hist
      (corfu-history-mode 1)
      (add-to-list 'save-hist-additional-variables 'corfu-history)))

(use-package dired
    :ensure nil
    :commands (dired)
    :hook
    ((dired-mode . dired-hide-details-mode)
     (dired-mode . hl-line-mode))
    :config
    (setq dired-recursive-copies 'always)
    (setq dired-recursive-deletes 'always)
    (setq delete-by-moving-to-trash t)
    (setq dired-dwim-target t))

(use-package dired-subtree
    :ensure t
    :after dired
    :bind
    ( :map dired-mode-map
      ("<tab>" . dired-subtree-toggle)
      ("TAB" . dired-subtree-toggle)
      ("<backtab>" . dired-subtree-remove)
      ("S-TAB" . dired-subtree-remove))
    :config
    (setq dired-subtree-use-backgrounds nil))

(use-package trashed
    :ensure t
    :commands (trashed)
    :config
    (setq trashed-action-confirmer 'y-or-n-p)
    (setq trashed-use-header-line t)
    (setq trashed-sort-key '("Date deleted" . t))
    (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package eglot
  :ensure t
  :hook (c-mode . eglot-ensure))

(use-package company
  :ensure t
  :config
  (global-company-mode))

;; Better C indentation
(setq c-default-style "linux"
      c-basic-offset 4)

;; Show matching parens
(show-paren-mode 1)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Compilation shortcuts
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c r") 'recompile)
