;;; funcs.el --- rogue Layer utility functions -*- lexical-binding: t -*-

(defun to-fish-find-file (candidate)
  "Run find file for given bookmark"
  (helm-find-files-1 (file-name-as-directory (f-canonical (f-join "~/.tofish" candidate)))))

(defun to-fish-jump ()
  "Jump to to-fish bookmarks"
  (interactive)
  (helm :sources (helm-build-sync-source "bookmarks"
                   :candidates (directory-files "~/.tofish")
                   :action '(("Jump to bookmark" . to-fish-find-file)))
        :buffer "*helm tofish jump*"
        :prompt "Jump to : "))

(defun delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the end of a word.
With argument, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

(defun delete-line ()
  "Delete current line without killing"
  (interactive)
  (delete-region (line-beginning-position) (line-end-position)))

(defun duplicate-line ()
  "Duplicate a line."
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (newline)
  (yank)
  (setq kill-ring (cdr kill-ring)))

(defun r-cycle-theme ()
  "Cycle between dark and light scheme"
  (interactive)
  (if (eq r-current-theme r-dark-theme)
      (progn
        (r-light)
        (setq r-current-theme r-light-theme))
    (progn
      (r-dark)
      (setq r-current-theme r-dark-theme))))

(defun r-light ()
  "Switch to light theme"
  (interactive)
  (setq doom-neotree-enable-variable-pitch nil
        doom-neotree-line-spacing 1)
  (disable-theme r-dark-theme)
  (spacemacs/load-theme r-light-theme)
  (setq org-bullets-bullet-list '(" "))
  (r-org-reset-buffers)
  (beacon-mode -1))

(defun r-dark ()
  "Switch to dark theme"
  (interactive)
  (setq doom-neotree-enable-variable-pitch t
        doom-neotree-line-spacing 4)
  (disable-theme r-light-theme)
  (spacemacs/load-theme r-dark-theme)
  (setq org-bullets-bullet-list '("› "))
  (r-org-reset-buffers)
  (beacon-mode +1))

(defun quack-quack (text)
  "Speak the given text"
  (start-process "quack" nil "quack" text))

(defun quack-unread-mail ()
  "Read unread emails"
  (interactive)
  (let ((subjects (mapcar
                   (lambda (mail) (plist-get mail :subject))
                   (r-mu4e-get-unread-mails))))
    (quack-quack (format "You have %s. %s"
                         (cond ((= (length subjects) 0) "no unread emails")
                               ((= (length subjects) 1) "1 unread email")
                               (t (format "%s unread emails" (length subjects))))
                         (s-join ". " subjects)))))

(defun magit-commit-generic-update (&optional args)
  (interactive (list (magit-commit-arguments)))
  (magit-commit '("-m" "Updates")))

(defun magit-deploy-site ()
  (interactive)
  (magit-status (concat user-project-dir "lepisma.github.io-deploy")))

(defun toggle-devanagari ()
  (interactive)
  (if (null current-input-method)
      (set-input-method "devanagari-itrans")
    (set-input-method nil)))

(with-eval-after-load 'magit
  (magit-define-popup-action
   'magit-commit-popup ?g "Commit with generic message" 'magit-commit-generic-update))
