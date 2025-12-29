(load-theme 'modus-vivendi)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode)

;; Though many modes/settings have ways to enable them "globally", enable them
;; only for text/programming modes where it wouldn't make sense to do so for all
;; modes. (e.g: to exclude special buffers like about-emacs')
(defun sean/apply-text-prog-mode-settings ()
  "Apply settings intended just for text and programming modes."
  (auto-fill-mode)
  (display-fill-column-indicator-mode)
  (setq show-trailing-whitespace t))
(add-hook 'text-mode-hook #'sean/apply-text-prog-mode-settings)
(add-hook 'prog-mode-hook #'sean/apply-text-prog-mode-settings)

(setq-default fill-column 80)
(setq-default indicate-unused-lines t)

;; Use a single directory for backup/auto-save files, rather than cluttering the
;; file system. Also move state-like files into a XDG-like "share" directory.
(let* ((data-dir (expand-file-name "~/.local/share/emacs/"))
       (backup-dir (concat data-dir "backup/"))
       (autosave-dir (concat data-dir "autosave/")))
  (make-directory backup-dir t)
  (make-directory autosave-dir t)
  (setq backup-directory-alist `(("." . ,backup-dir))
	backup-by-copying t
	version-control t
	delete-old-versions t
	kept-new-versions 5
	kept-old-versions 0
	auto-save-file-name-transforms `((".*" ,autosave-dir t))
	auto-save-list-file-prefix (concat autosave-dir "auto-save-list/.saves-")
	project-list-file (concat data-dir "projects"))
  (setcar native-comp-eln-load-path (concat data-dir "eln-cache/")))
