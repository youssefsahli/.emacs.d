(setq package-enable-at-startup nil)
(setq package-quickstart nil)

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
	(if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
						 ,@(when-let ((depth (plist-get order :depth)))
						     (list (format "--depth=%d" depth) "--no-single-branch"))
						 ,(plist-get order :repo) ,repo))))
		 ((zerop (call-process "git" nil buffer t "checkout"
				       (or (plist-get order :ref) "--"))))
		 (emacs (concat invocation-directory invocation-name))
		 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
				       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
		 ((require 'elpaca))
		 ((elpaca-generate-autoloads "elpaca" repo)))
	    (progn (message "%s" (buxffer-string)) (kill-buffer buffer))
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
(elpaca-wait)
(setq use-package-always-ensure t)

;; (setq use-package-compute-statistics t)
;; (add-hook after-init-hook #'use-package-report)

(setq use-package-always-defer nil)

(use-package gcmh
  :config (gcmh-mode 1))

(use-package f)
(elpaca-wait)

(defun cycle (var lst)
  "Cycle the value of VAR through the list LST."
  (set var
       (let ((next-index (1+ (cl-position (symbol-value var) lst))))
	 (nth (mod next-index (length lst)) lst))))

(set-language-environment "UTF-8")

(setq load-prefer-newer t)

(setq inhibit-compacting-font-caches t)
(setq global-text-scale-adjust-resizes-frames nil)

(setq auto-mode-case-fold nil)

(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

(advice-add #'display-startup-echo-area-message :override #'ignore)
(advice-add #'display-startup-screen :override #'ignore)
(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

(if (and (featurep 'native-compile)
	 (fboundp 'native-comp-available-p)
	 (native-comp-available-p))
    (setq native-comp-jit-compilation t
	  native-comp-deferred-compilation t
	  package-native-compile t)
  (setq features (delq 'native-compile features)))

(setq native-comp-async-report-warnings-errors 'silent)
(setq native-comp-warning-on-missing-source nil)
(setq debug-on-error nil
      jka-compr-verbose nil)
(setq byte-compile-warnings nil)
(setq byte-compile-verbose nil)
(setq ad-redefinition-action 'accept)
(setq warning-suppress-types '((lexical-binding)))

(setq ffap-machine-p-known 'reject)

(setq minibuffer-prompt-properties
	'(read-only t intangible t cursor-intangible t face
                    minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(setq idle-update-delay 1.0)

(if (boundp 'use-short-answers)
  (setq use-short-answers t)
(advice-add #'yes-or-no-p :override #'y-or-n-p))

(setq-default indicate-buffer-boundaries nil)
(setq-default indicate-empty-lines nil)
(setq-default word-wrap t)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)

(use-package emacs
  :ensure nil
  :preface
  (advice-add #'tool-bar-setup :override #'ignore)
  :bind
  ("C-c c o" . consult-outline)
  ("C-c c c" . consult-ripgrep)
  ("C-c f f" . (lambda () (interactive)(find-file user-init-file)))
  ("C-c f r" . recentf)
  :hook
  (prog-mode . electric-pair-mode)
  :config
  (modify-all-frames-parameters
   '((internal-border-width . 32)
     (undecorated . t)))
  (push '(menu-bar-lines . 0) default-frame-alist)
  (push '(tool-bar-lines . 0) default-frame-alist)
  (tooltip-mode -1)
  (global-auto-revert-mode)
  (load custom-file)
  :custom
  (frame-resize-pixelwise t)
  (window-resize-pixelwise nil)
  (fast-but-imprecise-scrolling t)
  (scroll-error-top-bottom t)
  (scroll-preserve-screen-position t)
  (scroll-conservatively 10000)
  (scroll-step 1)
  (auto-window-vscroll nil)
  (scroll-margin 0)
  (global-auto-revert-non-file-buffers t)
  (menu-bar-mode nil)
  (scroll-bar-mode nil)
  (use-file-dialog nil)
  (use-dialog-box nil)
  (scroll-preserve-screen-position 'always)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (text-mode-ispell-word-completion nil)
  (mode-line-format nil)
  (ring-bell-function 'ignore)
  (custom-file (expand-file-name "custom.el" user-emacs-directory))
  (backup-directory-alist `(("." . ,(expand-file-name "saves" user-emacs-directory))))
  (delete-old-versions t)
  (create-lockfiles nil)
  (make-backup-files nil)
  (delete-old-versions t)
  (kept-new-versions 10)
  (kept-old-versions 2)
  (version-control t)
  (gc-cons-threshold 402653184)
  (gc-cons-percentage 0.6)
  (lsp-warn-no-matched-clients nil))

(use-package ace-window
  :custom (aw-dispatch-always nil)
  :bind ("M-o" . ace-window))

(use-package bufler
:bind ("C-x C-b" . bufler)
:custom
(bufler-groups
 (bufler-defgroups
   (group
    ;; Subgroup collecting all `help-mode' and `info-mode' buffers.
    (group-or "*Help/Info*"
              (mode-match "*Help*" (rx bos "help-"))
              (mode-match "*Info*" (rx bos "info-"))))
   (group
    ;; Subgroup collecting all special buffers (i.e. ones that are not
    ;; file-backed), except `magit-status-mode' buffers (which are allowed to fall
    ;; through to other groups, so they end up grouped with their project buffers).
    (group-and "*Special*"
               (lambda (buffer)
                 (unless (or (funcall (mode-match "Magit" (rx bos "magit-status"))
                                      buffer)
                             (funcall (mode-match "Dired" (rx bos "dired"))
                                      buffer)
                             (funcall (auto-file) buffer))
                   "*Special*")))
    (group
     ;; Subgroup collecting these "special special" buffers
     ;; separately for convenience.
     (name-match "**Special**"
                 (rx bos "*" (or "Messages" "Warnings" "scratch" "Backtrace") "*")))
    (group
     ;; Subgroup collecting all other Magit buffers, grouped by directory.
     (mode-match "*Magit* (non-status)" (rx bos (or "magit" "forge") "-"))
     (auto-directory))
    ;; Subgroup for Helm buffers.
    (mode-match "*Helm*" (rx bos "helm-"))
    ;; Remaining special buffers are grouped automatically by mode.
    (auto-mode))
   (group
    ;; Subgroup collecting buffers in `org-directory' (or "~/org" if
    ;; `org-directory' is not yet defined).
    (dir (if (bound-and-true-p org-directory)
             org-directory
           "~/org"))
    (group
     ;; Subgroup collecting indirect Org buffers, grouping them by file.
     ;; This is very useful when used with `org-tree-to-indirect-buffer'.
     (auto-indirect)
     (auto-file))
    ;; Group remaining buffers by whether they're file backed, then by mode.
    (group-not "*special*" (auto-file))
    (auto-mode))
   (group
    ;; Subgroup collecting buffers in a projectile project.
    (auto-projectile))
   (group
    ;; Subgroup collecting buffers in a version-control project,
    ;; grouping them by directory.
    (auto-project))
   (dir user-emacs-directory)
   (auto-mode)))
(bufler-reverse t))

(use-package vertico
  :demand t
  :bind (:map vertico-map
	      ("<tab>" . vertico-insert))
  :config
  (vertico-mode)
  (vertico-mouse-mode))

(use-package vertico-posframe
  :after vertico
  :config (vertico-posframe-mode))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
		 nil
		 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
:custom
(corfu-auto t)
:init
(global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package lsp-bridge
  :after (markdown-mode yasnippet)
  :ensure 
  (:host github
	 :repo "manateelazycat/lsp-bridge"
         :branch "master"
         :files ("*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
         ;; do not perform byte compilation or native compilation for lsp-bridge
         :build (:not compile))
  :config
  (global-lsp-bridge-mode)
  :custom
  (lsp-bridge-enable-inlay-hint t)
  (lsp-bridge-enable-hover-diagnostic t)
  (lsp-bridge-enable-org-babel t))

(use-package all-the-icons
  :custom
  (all-the-icons-color-icons nil))
(use-package all-the-icons-completion
  :after (marginalia vertico all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init (all-the-icons-completion-mode))
(use-package nerd-icons)

;; (use-package catppuccin-theme
;;   :demand t
;;   :custom (catppuccin-flavor 'latte)
;;   :bind
;;   (("<f5>" . (lambda () (interactive)
;; 	       (cycle 'catppuccin-flavor '(latte mocha))
;; 	       (catppuccin-reload))))
;;   :config
;;   (load-theme 'catppuccin :no-confirm))

(use-package ef-themes
  :hook
  (elpaca-after-init . (lambda ()
			 (ef-themes-select 'ef-deuteranopia-dark)))
  :custom
  (ef-themes-to-toggle '(ef-owl  ef-eagle))
  :bind
  (("<f5>" . (lambda () (interactive) (ef-themes-load-random 'dark)))
   ("<f6>" . (lambda () (interactive) (ef-themes-load-random 'light)))))

;; (use-package doom-modeline
;;   :disabled
;;   :init (doom-modeline-mode 1))

(use-package spaceline
  :after ef-themes
  :custom-face
  (mode-line ((t (:font "Lekton Nerd Font Mono-14"))))
  :config
  (add-hook 'ef-themes-post-load-hook #'spaceline-spacemacs-theme))

(use-package solaire-mode
  :after (ef-themes)
  :hook
  (ef-themes-post-load . solaire-global-mode)
  :config
  (solaire-global-mode 1))

(use-package dimmer
  :custom
  (dimmer-adjustment-mode :foreground)
  (dimmer-fraction 0.5)
  (dimmer-use-colorspace :rgb)
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-helm)
  (dimmer-mode t))



(use-package org-variable-pitch
  :disabled
  :hook (org-mode . org-variable-pitch-minor-mode))

(use-package svg-tag-mode
  :after org
  :config
  (let* ((date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
	 (time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
	 (day-re "[A-Za-z]\\{3\\}")
	 (day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re)))

    (defun svg-progress-percent (value)
      (save-match-data
	(svg-image (svg-lib-concat
                    (svg-lib-progress-bar
		       (/ (string-to-number value) 100.0)
                       nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                    (svg-lib-tag (concat value "%")
				 nil :strok e 0 :margin 0)) :ascent 'center))) 

    (defun svg-progress-count (value)
      (save-match-data
	(let* ((seq (split-string value "/"))
               (count (if (stringp (car seq))
                          (float (string-to-number (car seq)))
			0))
               (total (if (stringp (cadr seq))
                          (float (string-to-number (cadr seq)))
			1000)))
          (svg-image (svg-lib-concat
                      (svg-lib-progress-bar (/ count total) nil
                                            :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                      (svg-lib-tag value nil
                                   :stroke 0 :margin 0)) :ascent 'center))))

    (setq svg-tag-tags
          `(;; Org tags
            (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
            (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))

            ;; Task priority
            ("\\[#[A-Z]\\]" . ((lambda (tag)
				 (svg-tag-make tag :face 'org-priority
                                               :beg 2 :end -1 :margin 0))))

            ;; TODO / DONE
            ("TODO" . ((lambda (tag) (svg-tag-make tag :face 'org-todo :inverse t :margin 0))))
            ("NEXT" . ((lambda (tag) (svg-tag-make tag :face 'org-todo :inverse t :margin 0))))
            ("ACTIVE" . ((lambda (tag) (svg-tag-make tag :face 'org-todo :inverse t :margin 0))))
            ("DONE" . ((lambda (tag) (svg-tag-make tag :face 'org-done :inverse t :margin 0))))


            ;; Citation of the form [cite:@Knuth:1984]
            ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                              (svg-tag-make tag
                                                            :inverse t
                                                            :beg 7 :end -1
                                                            :crop-right t))))
            ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                       (svg-tag-make tag
                                                                     :end -1
                                                                     :crop-left t))))

            ;; Active date (with or without day name, with or without time)
            (,(format "\\(<%s>\\)" date-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :end -1 :margin 0))))
            (,(format "\\(<%s \\)%s>" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
            (,(format "<%s \\(%s>\\)" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

            ;; Inactive date  (with or without day name, with or without time)
            (,(format "\\(\\[%s\\]\\)" date-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
            (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
            (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))

            ;; ;; Progress
            ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
						(svg-progress-percent (substring tag 1 -2)))))
            ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                              (svg-progress-count (substring tag 1 -1))))))))

  :hook (org-mode . svg-tag-mode))

(use-package org-margin
  :ensure (:host github :repo "rougier/org-margin")
  :custom
  (org-margin-headers-set 'H-svg)
  (org-margin-headers
   (list (cons 'stars (list (propertize "     #" 'face '(fixed-pitch default))
                            (propertize "    ##" 'face '(fixed-pitch default))
                            (propertize "   ###" 'face '(fixed-pitch default))
                            (propertize "  ####" 'face '(fixed-pitch default))
                            (propertize " #####" 'face '(fixed-pitch default))
                            (propertize "######" 'face '(fixed-pitch default))))
	 (cons 'H-txt (list (propertize "H1" 'face '(font-lock-comment-face default))
                            (propertize "H2" 'face '(font-lock-comment-face default))
                            (propertize "H3" 'face '(font-lock-comment-face default))
                            (propertize "H4" 'face '(font-lock-comment-face default))
                            (propertize "H5" 'face '(font-lock-comment-face default))
                            (propertize "H6" 'face '(font-lock-comment-face default))))
	 (cons 'H-svg (list (svg-lib-tag "H1" '(org-level-1))
                            (svg-lib-tag "H2" '(org-level-2))
                            (svg-lib-tag "H3" '(org-level-3))
                            (svg-lib-tag "H4" '(org-level-4))
                            (svg-lib-tag "H5" '(org-level-5))
                            (svg-lib-tag "H6" '(org-level-6)))))) 
  (org-margin-markers
   (list (cons "\\(#\\+begin_src\\)"
               (propertize "" 'face '(font-lock-comment-face bold)))
	 (cons "\\(#\\+begin_quote\\)"
               (propertize "󱀢" 'face '(font-lock-comment-face bold)))))

  :hook (org-mode . org-margin-mode))

(use-package info-colors
  :hook
  (Info-selection . info-colors-fontify-node))

(use-package highlight-thing
  :custom
  (highlight-thing-what-thing 'symbol)
  (highlight-thing-exclude-thing-under-point t)
  :custom-face
  (hi-yellow ((t (:background "unspecified" :foreground "unspecified" :box (:line-width (-1 . -1))))))
  :config
  (global-highlight-thing-mode))

(add-hook
 'elpaca-after-init-hook
 (lambda ()
   (setq show-paren-style 'parenthesis)
   (setq show-paren-delay 0.1
	 show-paren-highlight-openparen t
	 show-paren-when-point-inside-paren t
	 show-paren-when-point-in-periphery t)
   (set-face-attribute 'show-paren-match nil
		       :background "unspecified"
		       :box '(:line-width (-1 . -1)))))

;; (set-frame-font "Unifont-15")
(set-frame-font "Lilex Nerd Font-13")
;; (set-frame-font "DaddyTimeMono Nerd Font-15")
;; (set-frame-font "Lekton Nerd Font Mono-15")
;; (set-frame-font "Hurmit Nerd Font Mono-14")
;; (set-frame-font "ShureTechMono Nerd Font-16")

(use-package which-key
  :config
  (which-key-mode))

(use-package elpher)

(defvar-local gptkey
    (f-read-text (expand-file-name "openai.key" user-emacs-directory)))

  (use-package gptel
    :disabled
    :custom
    (gptel-api-key gptkey))

  (use-package org-ai
    :ensure t
    :custom
    (org-ai-openai-api-token gptkey)
    (org-ai-default-chat-model "gpt-4o")
    (org-ai-auto-fill t)
    :commands (org-ai-mode
               org-ai-global-mode)
    :init
    (add-hook 'org-mode-hook #'org-ai-mode) ; enable org-ai in org-mode
    (org-ai-global-mode) ; installs global keybindings on C-c M-a
    :config
    (org-ai-install-yasnippets))

(use-package dirvish
  :after nerd-icons
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-mode-line-height 10)
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (setq dirvish-subtree-state-style 'nerd)
  (setq delete-by-moving-to-trash t)
  (setq dirvish-path-separators (list
                                 (format "  %s " (nerd-icons-codicon "nf-cod-home"))
                                 (format "  %s " (nerd-icons-codicon "nf-cod-root_folder"))
                                 (format " %s " (nerd-icons-faicon "nf-fa-angle_right"))))
  (setq dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first --no-group")
  (dirvish-peek-mode) ; Preview files in minibuffer
  (dirvish-side-follow-mode) ; similar to `treemacs-follow-mode'
  )

(use-package djvu)
(use-package pdf-tools
  :config (pdf-tools-install))

(use-package nov
  :mode "\\.epub\\'")

(use-package calibredb
  :after (all-the-icons)
  :custom
  (calibredb-root-dir "~/Library")
  (calibredb-library-alist '(("~/Library")))
  (calibredb-format-all-the-icons t)
  (calibredb-db-dir (lambda () (expand-file-name "metadata.db" calibredb-root-dir))))

(use-package vterm
  :config
  (add-hook 'vterm-mode-hook
	    (lambda ()
	      (set (make-local-variable 'buffer-face-mode-face) '(:family "IosevkaTerm Nerd Font"))
              (buffer-face-mode t))))

(use-package eros
  :custom
  (eros-eval-result-prefix "▶ ")
  :init
  (eros-mode))

(let ((path (concat user-emacs-directory "bison.txt"))
      (url "https://gist.githubusercontent.com/youssefsahli/2402726af1c6bed415a190970a433cde/raw/2f4814ac8289c679364f3e500ded5ce1c89e5d03/bison.txt"))
  (unless (file-exists-p path)
    (url-copy-file url path t)))

(let ((fortune-path (concat user-emacs-directory "showerthoughts"))
      (fortune-url "https://raw.githubusercontent.com/JKirchartz/fortunes/refs/heads/master/showerthoughts"))
  (unless (file-exists-p fortune-path)
    (url-copy-file fortune-url fortune-path t))
  (setq cookie-file fortune-path))

(use-package dashboard
  :demand t
  :custom
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-banner-logo-title (cookie cookie-file))
  (dashboard-startup-banner "~/.emacs.d/bison.txt")
  (dashboard-week-agenda t)
  (dashboard-center-content t)
  (dashboard-items '((recents   . 5)
                     (bookmarks . 5)
                     (projects  . 5)
                     (agenda    . 5)
                     (registers . 5)))
  (dashboard-icon-type 'nerd-icons)
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook))

(use-package org
  :custom-face
  (org-block-begin-line ((t (:background "unspecified"))))
  (org-block-end-line ((t (:background "unspecified"))))
  (org-block ((t (:background "unspecified"))))
  :bind (:map org-mode-map
	      ("C-c b t" . org-fold-hide-block-toggle))
  :custom
  (org-export-with-todo-keywords nil)
  (org-md-footnote-format "<span class='footref'>%s</span>")
  (org-export-with-toc nil)
  (org-export-backends '(html md latex odt))
  (org-startup-indented nil)
  (org-pretty-entities t)
  (org-use-sub-superscripts "{}")
  (org-hide-emphasis-markers t)
  (org-ellipsis " ")
  (org-src-window-setup 'split-window-below)
  (org-footnote-section "Notes")
  :config
  (defun toggle-org-md-export-on-save ()
    (interactive)
    (if (memq 'org-md-export-to-markdown after-save-hook)
  	(progn
          (remove-hook 'after-save-hook 'org-md-export-to-markdown t)
          (message "Disabled org → md export on save for current buffer..."))
      (add-hook 'after-save-hook 'org-md-export-to-markdown nil t)
      (message "Enabled org → md export on save for current buffer..."))))

(use-package org-glossary
  :ensure (:host github :repo "tecosaur/org-glossary")
  :config
  (org-glossary-set-export-spec 'typst t
    :use                  "#link(label(\"gls%k\"))[%t] #label(\"glsr%K%r\")" 
    :first-use            "%u" 
    :definition           "/ %t: %v #label(\"gls%k\")"
    :backref              ""
    :definition-structure "#bold[%d] %v")
  
  :hook (org-mode . org-glossary-mode))

(use-package org-modern
  :after org
  :custom
  (org-modern-table nil)(org-hide-emphasis-markers t)
  (org-catch-invisible-edits 'show-and-error)
  (org-pretty-entities t)
  (org-modern-checkbox nil)
  (org-modern-todo nil)
  (org-modern-priority nil)
  (org-modern-tag nil)
  (org-modern-star nil)
  (org-modern-timestamp nil)
  (org-modern-horizontal-rule nil)
  (org-modern-table-vertical 1)
  :config
  (global-org-modern-mode))

(use-package org-appear
  :custom
  (org-appear-autolinks t)
  (org-appear-autoemphasis t)
  (org-appear-autoentities t)
  (org-appear-autosubmarkers t)
  (org-appear-autokeywords t)

  :hook (org-mode . org-appear-mode))

(use-package ox-gfm
  :after org
  :config
  (require 'ox-gfm nil t)
  (defun toggle-org-gfm-export-on-save ()
    (interactive)
    (if (memq 'org-gfm-export-to-markdown after-save-hook)
	(progn
          (remove-hook 'after-save-hook 'org-gfm-export-to-markdown t)
          (message "Disabled org → gfm export on save for current buffer..."))
      (add-hook 'after-save-hook 'org-gfm-export-to-markdown nil t)
      (message "Enabled org → gfm export on save for current buffer..."))))

(use-package citar
  :after oc
  :custom
  (citar-bibliography '("~/Projects/Thesis/bib/library.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :hook
  ((LaTeX-mode org-mode typst-ts-mode) . citar-capf-setup))

(use-package citar-embark
  :after (citar embark)
  :no-require
  :config (citar-embark-mode))

(use-package org-journal)

(use-package org-roam
  :bind 
  ("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n i" . org-roam-node-insert)
  :custom
  (org-roam-directory (file-truename "~/Projects/Roam"))
  :config
  (org-roam-db-autosync-mode))

(use-package ox-typst
  :after (org org-glossary)
  :demand t
  :ensure (ox-typst :host github :repo "youssefsahli/ox-typst"))

(use-package rainbow-delimiters
  :custom
  (rainbow-delimiters-max-face-count 5)
  :hook prog-mode)

(use-package rainbow-mode
  :hook prog-mode)

(use-package treemacs
  :bind
  (("C-c t"  . treemacs))
  :custom
  (treemacs--icon-size 24)
  :custom-face
  (treemacs-root-face
   ((t (:weight regular
		:underline nil
		:foreground "#aaaaaa")))))

(use-package treemacs-icons-dired)

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package transient)
(use-package magit :after transient)
(use-package gitconfig)

(use-package projectile
  :custom
  (projectile-project-search-path '("~/Projects"))
  :bind
  (:map projectile-mode-map
	("C-c p" . projectile-command-map)))

(use-package tree-sitter)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package yasnippet
  :config (yas-global-mode 1))

(defun autoindent-indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defvar autoindent-modes-list '(emacs-lisp-mode lisp-mode web-mode)
  "Modes on which to auto-indent after save.")

(defun autoindent-save-hook ()
  (when (member major-mode autoindent-modes-list)
    (autoindent-indent-whole-buffer)))

(add-hook 'before-save-hook #'autoindent-save-hook)

(use-package web-mode
  :mode ("\\.html?\\'" "\\.njk\\'")
  :custom (web-mode-extra-auto-pairs t))

(use-package json-mode
  :bind
  (:map json-mode-map
	("C-c i" . json-mode-beautify))
  :mode
  ("\\.\\(json\\)$" . json-mode))

(use-package yaml-mode
  :mode ("\\.\\(yml\\|yaml\\|\\config\\|sls\\)$" . yaml-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)))

(use-package polymode
  :config
  (define-hostmode poly-web-hostmode :mode 'web-mode)
  (define-innermode poly-yaml-web-innermode
    :mode 'yaml-mode
    :head-matcher "---"
    :tail-matcher "---"
    :head-mode 'host
    :tail-mode 'host)

  (define-polymode poly-web-mode
    :hostmode 'poly-web-hostmode
    :innermodes '(poly-yaml-web-innermode)))

(use-package npm-mode)

(use-package racket-mode)

(use-package typst-ts-mode
  :bind (:map typst-ts-mode-map
	      ("C-c C-c" . typst-ts-tmenu))
  :custom
  (typst-ts-watch-options "--open")
  (typst-ts-mode-enable-raw-blocks-highlight t)
  :ensure (:host codeberg :repo "meow_king/typst-ts-mode"
                 :files ("*.el")))

(setq comment-multi-line t)
(setq sentence-end-double-space nil)
(setq require-final-newline t)
(setq kill-do-not-save-duplicates t)
(setq comment-empty-lines t)
(setq lazy-highlight-initial-delay 0)

(use-package move-text :init (move-text-default-bindings))

(use-package smart-hungry-delete
  :bind (([remap backward-delete-char-untabify] .
	  smart-hungry-delete-backward-char)
	 ([remap delete-backward-char] .
	  smart-hungry-delete-backward-char)
	 ([remap delete-char] .
	  smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

;; (use-package flycheck)

(use-package helpful
  :custom
  (helpful-switch-buffer-function (lambda (buffer-or-name)
				    "Switch to a helpful buffer or create one"
				    (if (eq major-mode 'helpful-mode)
					(switch-to-buffer buffer-or-name)
				      (pop-to-buffer buffer-or-name))))
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command)
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)
  (global-set-key (kbd "C-h F") #'helpful-function))

(use-package devdocs)

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(use-package arxiv-mode)

(use-package pubmed)
