(setq secrets-file (locate-user-emacs-file "secrets.el"))
(load secrets-file :no-error-if-file-is-missing)

(setq custom-file (locate-user-emacs-file "custom.el"))
(add-hook 'elpaca-after-init-hook #'(lambda () (load custom-file :no-error-if-file-is-missing)))

(defvar elpaca-installer-version 0.8)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(defun ywy/display-startup-time ()
  (setq initial-scratch-message
        (concat ";; hiya answer !\n"
                (format ";; Emacs loaded in %.2f seconds with %d garbage collections."
                        (float-time
                         (time-subtract after-init-time before-init-time))
                        gcs-done))))

(add-hook 'elpaca-after-init-hook #'ywy/display-startup-time)

(setq emacs-backups-directory "~/.local/share/emacs/backups")
(setq emacs-saves-directory "~/.local/share/emacs/saves")

(setq backup-by-copying t
      backup-directory-alist `((".*" . ,emacs-backups-directory))
      auto-save-file-name-transforms `((".*" ,emacs-saves-directory t))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

(use-package delsel
  :ensure nil ; no need to install it as it is built-in
  :hook (after-init . delete-selection-mode))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
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

(define-key global-map (kbd "C-g") #'prot/keyboard-quit-dwim)

(let ((mono-spaced-font "Droid Sans Mono")
      (proportionately-spaced-font "Bookerly"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 100)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.2))

(setq-default org-adapt-indentation nil)

(use-package org-superstar
  :ensure t
  :hook (org-mode . org-superstar-mode))

(add-hook 'org-mode-hook 'visual-line-mode)

(use-package unicode-fonts
  :ensure t
  :config
  (unicode-fonts-setup))

(use-package emojify
  :ensure t
  :hook (after-init . global-emojify-mode))

(use-package color-theme-modern
  :ensure t)

(use-package moe-theme
  :ensure t)

(use-package standard-themes
  :ensure t)

(use-package auto-dark
  :ensure t
  :config
  (auto-dark-mode)
  :custom
  (auto-dark-themes '((standard-dark) (high-contrast))))

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
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package vertico
  :ensure t
  :config
  (vertico-mode))

(use-package marginalia
  :ensure t
  :config (marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 1)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package consult
  :ensure t
  :bind (("M-s M-s" . consult-line)
	 ("M-s M-i" . consult-imenu)
         ("M-s M-g" . consult-git-grep)
         ("C-x p i" . consult-imenu-multi)))

(use-package consult-project-extra
  :ensure t)

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package dired
  :ensure nil
  :custom ((dired-listing-switches "-alh --group-directories-first"))
  :commands (dired)
  :config
  (setq dired-dwim-target t)
  (setq wdired-allow-to-change-permissions t)
  (setq wdired-create-parent-directories t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (add-hook 'dired-mode-hook
	    (lambda ()
	      (setq truncate-lines t)
	      (visual-line-mode nil))))

(defun my/dired-home ()
  "Open dired at $HOME"
  (interactive)
  (dired (expand-file-name "~")))

(use-package diredfl
  :ensure t
  :after (dired)
  :config
  (diredfl-global-mode 1))

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

(use-package dired-git-info
  :ensure t
  :after dired)

(use-package trashed
  :ensure t
  :commands (trashed)
  :config
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :bind* (("M-m SPC e" . magit-status)
          ("M-m g b"   . magit-blame)))

(use-package forge
  :ensure t
  :after magit
  :init
  (setq auth-sources '("~/.authinfo")))

(use-package git-timemachine
  :ensure t
  :commands (git-timemachine-toggle
             git-timemachine-switch-branch)
  :bind* (("M-m g l" . git-timemachine-toggle)
          ("M-m g L" . git-timemachine-switch-branch)))

(use-package editorconfig
  :ensure t
  :demand t
  :config
  (editorconfig-mode 1))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(use-package markdown-mode
  :ensure t)

(use-package f
  :ensure t)

(use-package yasnippet
  :ensure t)

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t)
  (add-hook 'rust-ts-mode-hook 'eglot-ensure))

(setq major-mode-remap-alist '((javascript-mode . js-ts-mode)
                               (css-mode . css-ts-mode)
                               (rust-mode . rust-ts-mode)))

(use-package eglot-booster
  :after eglot
  :config (eglot-booster-mode))

;; Add extensions
(use-package cape
  :ensure t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  ;; ...
  )

(setq completion-category-overrides '((eglot (styles orderless))
                                      (eglot-capf (styles orderless))))

;; Enable cache busting, depending on if your server returns
;; sufficiently many candidates in the first place.
(advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)

(use-package tex
  :ensure auctex)

(use-package latex-preview-pane
  :ensure t)

(use-package gptel
  :ensure t
  :config
  (setq gptel-default-mode 'org-mode)
  (setq gptel-model   'google/gemini-flash-1.5-8b
        gptel-backend
        (gptel-make-openai "OpenRouter"
	  :host "openrouter.ai"
	  :endpoint "/api/v1/chat/completions"
	  :stream t
	  :key answer/openrouter-api-key
	  :models '(google/gemini-flash-1.5-8b
                    qwen/qwen-2.5-coder-32b-instruct
                    deepseek/deepseek-chat))))

(use-package aider
  :ensure (:host github :repo "tninja/aider.el")
  :bind
  (("C-c a" . 'aider-transient-menu))
  :config
  (require 'aider)
  (setq aider-args `("--model" "openrouter/qwen/qwen-2.5-coder-32b-instruct"))
  (setq aider-program (expand-file-name "~/.local/bin/aider")))

(use-package json-navigator
  :ensure t)

(add-hook 'prog-mode-hook 'electric-pair-local-mode)
(add-hook 'sly-mrepl-mode-hook 'electric-pair-local-mode)

(use-package prism
  :ensure t
  :hook (emacs-lisp-mode . prism-mode)
  :config
  (setq prism-parens t))

(use-package diff-hl
  :ensure t
  :hook (prog-mode . diff-hl-mode))

(setq indent-tabs-modes nil)

(use-package dtrt-indent
  :ensure t
  :hook (prog-mode . dtrt-indent-mode))

(use-package sly
  :ensure t)

(require 'ob-lisp)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(use-package mixed-pitch
  :ensure t
  :hook (org-mode . mixed-pitch-mode))

(use-package aggressive-indent
  :ensure t
  :hook (emacs-lisp-mode . aggressive-indent-mode))

(add-hook 'org-mode-hook
          #'(lambda nil
              (progn
                (setq left-margin-width 2)
                (setq right-margin-width 2)
                (set-window-buffer nil (current-buffer)))))

(use-package treemacs
  :ensure t
  :config
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

(use-package hide-mode-line
  :ensure t
  :hook (treemacs-mode . hide-mode-line-mode))

(use-package popper
  :ensure t
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode
          eshell-mode
          shell-mode))
  (popper-mode +1)
  (popper-echo-mode +1))

(use-package imenu-anywhere
  :ensure t)

(use-package iedit
  :ensure t)

(use-package atomic-chrome
  :ensure (:host github :repo "KarimAziev/atomic-chrome")
  :demand t
  :commands (atomic-chrome-start-server)
  :config (atomic-chrome-start-server))

(use-package meson-mode
  :ensure t)

(use-package olivetti
  :ensure t
  :config
  (defun answer/read-text ()
    "Format text buffers to become easier to read."
    (interactive)
    (read-only-mode 0)
    (let ((fill-column 10000))
      (fill-individual-paragraphs (point-min) (point-max)))
    (setq-local fill-column 80)
    (olivetti-mode 1)))


