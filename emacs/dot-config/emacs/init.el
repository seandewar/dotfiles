(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-split-window-below t
	evil-vsplit-window-right t
	evil-want-C-u-scroll t)
  :config
  (evil-mode))

(use-package evil-surround
  :requires evil
  :ensure t
  :config
  (global-evil-surround-mode))

(use-package evil-nerd-commenter
  :after evil ; Emacs hotkeys don't have a strict requirement for evil.
  :ensure t
  :config
  (evilnc-default-hotkeys t)
  (when (fboundp 'evil-mode)
    (define-key evil-normal-state-map "gcc" #'evilnc-comment-or-uncomment-lines)
    (define-key evil-normal-state-map "gc" #'evilnc-comment-operator)))

(load custom-file t)
