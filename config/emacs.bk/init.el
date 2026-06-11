;;;;;; EMACS CONFIG ;;;;;;

;;; ---------------------------------------------------------------------------
;;; BASIC UI AND BEHAVIOR
;;; ---------------------------------------------------------------------------

(message "1")

(setq mac-option-modifier 'alt)   ;; Option = Alt (A-)

;; Use relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Disable startup screen and visual bell
(setq inhibit-startup-message t)
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; Turn off unnecessary UI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)

(message "2")

;; Font setup (Victor Mono Medium, 17pt)
(set-face-attribute 'default nil
		    :family "Victor Mono"
		    :weight 'medium
		    :height 170)

;; Display line numbers by default
(global-display-line-numbers-mode 1)

;; Disable line numbers in specific modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Keep a margin when scrolling (like Vim scrolloff)
(setq scroll-margin 8)

;;; ---------------------------------------------------------------------------
;;; FILE HANDLING, HISTORY, AND BACKUPS
;;; ---------------------------------------------------------------------------

;; Track recently opened files
(recentf-mode 1)

;; Save minibuffer history
(setq history-length 25)
(savehist-mode 1)

;; Remember cursor position in files
(save-place-mode 1)

;; Auto-revert files changed on disk
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Move customization variables to a separate file
(setq custom-file "~/.config/emacs/custom-vars.el")
(load custom-file 'noerror 'nomessage)

;; Disable GUI prompts
(setq set-dialog-box nil)

;; Disable auto-save and backup files
(setq auto-save-file-name-transforms nil)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)
(setq make-backup-files nil)

;;; ---------------------------------------------------------------------------
;;; PACKAGE MANAGEMENT
;;; ---------------------------------------------------------------------------

(defvar my/local-packages-dir "~/.config/emacs/packages/"
  "Directory where local Emacs packages (.el files) are stored.")

(message "3")
(defun my/load-local-package (feature)
  "Install and require a local package FEATURE from `my/local-packages-dir`.
Looks for FEATURE.el in that directory."
  (let* ((file (expand-file-name
                (concat (symbol-name feature) ".el")
                my/local-packages-dir)))
    (when (file-exists-p file)
      (unless (require feature nil 'noerror)
        (package-install-file file)
        (require feature)))))

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(message "4")

;;; ---------------------------------------------------------------------------
;;; COMPLETION & SEARCH: IVY / COUNSEL
;;; ---------------------------------------------------------------------------

(use-package ivy
  :diminish
  :bind (("M-/" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         :map ivy-switch-buffer-map
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package counsel
  :after ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ;; remove C-SPC conflict here
         ("C-M-j" . counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-history))
  :config
  ;; Ensure that minibuffer keymaps work
  (counsel-mode 1))

(use-package flx)
(setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)))
(setq ivy-initial-inputs-alist nil)

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(message "5")
;;; ---------------------------------------------------------------------------
;;; UI ENHANCEMENTS
;;; ---------------------------------------------------------------------------

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;;; ---------------------------------------------------------------------------
;;; HELP SYSTEM
;;; ---------------------------------------------------------------------------

(message "6")
(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;;; ---------------------------------------------------------------------------
;;; THEME
;;; ---------------------------------------------------------------------------

(use-package catppuccin-theme
  :init
  (setq catppuccin-flavor 'macchiato)
  :config
  (load-theme 'catppuccin :no-confirm)
  (catppuccin-reload))

(add-to-list 'default-frame-alist '(alpha . (90 85)))
(message "7")

;;; ---------------------------------------------------------------------------
;;; SESSION MANAGEMENT
;;; ---------------------------------------------------------------------------

;; (desktop-save-mode 1)
;; (setq desktop-save t
;;       desktop-restore-frames t
;;       desktop-load-locked-desktop t)

;;; ---------------------------------------------------------------------------
;;; KEYBINDINGS WITH GENERAL
;;; ---------------------------------------------------------------------------

(use-package general
  :config
  ;; Leader key
  (general-create-definer my/leader-keys
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Eval commands
  (my/leader-keys
    "e x" '(my/eval-region-or-last-sexp :which-key "eval")))

(defun my/eval-region-or-last-sexp ()
  "Evaluate region if active, otherwise last sexp.
After evaluation, return to normal mode if Evil is active."
  (interactive)
  (if (use-region-p)
      (eval-region (region-beginning) (region-end))
    (eval-last-sexp nil))
  ;; Go back to normal mode if Evil is loaded
  (when (bound-and-true-p evil-mode)
    (evil-normal-state)))

(message "7")

(defun my/save-buffer()
  "Save the buffer even if it is not modified."
  (interactive)
  (set-buffer-modified-p t)
  (save-buffer))

(general-define-key
 :keymaps 'override
 "M-s" 'my/save-buffer
 "M-q" 'save-buffers-kill-emacs
 "M-w" 'kill-this-buffer
 "M-p" 'counsel-recentf)

(use-package apheleia
  :config
  (apheleia-global-mode +1))

(defun my/save-without-hooks ()
  "Save current buffer without running `before-save-hook`."
  (interactive)
  (let ((after-save-hook nil)) ;; temporarily disable hooks
    (my/save-buffer)))

(general-define-key
 "M-S" 'my/save-without-hooks)

(message "8")

;; Global bindings
(general-define-key
 "<escape>" 'keyboard-escape-quit
 "C-M-j" 'counsel-switch-buffer
 :keymaps 'minibuffer-local-map
 "C-r" 'counsel-minibuffer-history)

(require 'general)

(general-define-key
 :states 'normal
 :keymaps 'emacs-lisp-mode-map
 "K" 'helpful-at-point)


;;; ---------------------------------------------------------------------------
;;; EVIL MODE (VIM EMULATION)
;;; ---------------------------------------------------------------------------

(message "9")
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-vsplit-window-right t
        evil-split-window-below t)
  :config
  (evil-mode 1)
  ;; https://emacs.stackexchange.com/questions/33287/how-to-prevent-a-key-binding-from-registering-as-an-evil-mode-operator
  ;; Persist repeat (.) action on save
  (evil-declare-abort-repeat 'my/save-buffer)  
  (evil-declare-abort-repeat 'my/save-without-hooks))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(message "10")
;; Add a blank line below on RET in normal mode
(general-define-key
 :states 'normal
 "RET" (lambda ()
         (interactive)
         (evil-open-below 1)
         (evil-normal-state)))

;; Remap H and L in Evil normal/visual/operator states
(general-define-key
 :states '(normal visual operator)
 "H" 'evil-beginning-of-line
 "L" 'evil-end-of-line)

;; Enable redo
;; (evil-set-undo-system 'undo-redo)
(use-package undo-fu
  :config
  ;; Tell Evil to use undo-fu instead of built-in or undo-tree
  (evil-set-undo-system 'undo-fu))

(message "11")
(use-package undo-fu-session
  :after undo-fu
  :hook (after-init . undo-fu-session-global-mode)
  :config
  ;; Do not save undo history for files like commit messages
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'"))
  (setq undo-fu-session-linear t)
  (setq undo-fu-session-file-limit 30))

;; Use visual line motions even outside of visual-line-mode buffers
(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)

(setq evil-goggles-enable-delete nil)
(setq evil-goggles-blocking-duration 0.100) ;; default is nil, i.e. use `evil-goggles-duration'

(use-package evil-goggles
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

(message "12")

(my/load-local-package 'evil-little-word)

(with-eval-after-load 'evil
  ;; Little-word motions using g SPC w / g SPC b etc.
  (define-key evil-motion-state-map (kbd "g SPC w") 'evil-forward-little-word-begin)
  (define-key evil-motion-state-map (kbd "g SPC b") 'evil-backward-little-word-begin)
  (define-key evil-motion-state-map (kbd "g SPC W") 'evil-forward-little-word-end)
  (define-key evil-motion-state-map (kbd "g SPC B") 'evil-backward-little-word-end)

  ;; Text objects: i SPC w / a SPC w
  (define-key evil-outer-text-objects-map (kbd "SPC w") 'evil-a-little-word)
  (define-key evil-inner-text-objects-map (kbd "SPC w") 'evil-inner-little-word))


(my/load-local-package 'simpleclip)
(simpleclip-mode 1)

(general-define-key
 :keymaps 'override
 "M-c" 'simpleclip-copy
 "M-v" 'simpleclip-paste)

(message "13")
(my/leader-keys
  "p" '(simpleclip-paste :which-key "paste from clipboard")
  "y" '(simpleclip-copy  :which-key "yank/copy to clipboard")
  "d" '(simpleclip-cut   :which-key "cut to clipboard")
  "x" '(simpleclip-cut   :which-key "cut to clipboard"))


(general-define-key
 :states 'insert
 "A-p" 'yank)

(defun my/comment-line-stay ()
  "Comment or uncomment current line and keep cursor on the same line."
  (interactive)
  (let ((pos (point)))
    (comment-line 1)
    (goto-char pos)))

(my/leader-keys
  "/" '(my/comment-line-stay :which-key "toggle comment"))

(message "14")
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package avy
  :config
  ;; Global binding
  (general-define-key
   "C-s" 'avy-goto-char-2)
  ;; Evil normal-state binding (like vim-easymotion)
  (general-define-key
   :states '(normal visual emacs)
   "s" 'avy-goto-char-2))

(use-package evil-exchange
  :config
  (evil-exchange-install))

(message "15")

(defun my/open-dired ()
  "Open Dired in the current window at the current file's directory."
  (interactive)
  (let ((dir (if-let ((file (buffer-file-name)))
                 (file-name-directory file)
               default-directory)))
    (dirvish dir)))

;; Bind globally
(global-set-key (kbd "M-e") #'my/open-dired)
(setq dired-kill-when-opening-new-dired-buffer t)

(use-package treemacs
  :defer t
  :config
  ;; Recommended: follow the current file in Treemacs
  (treemacs-create-theme "simple"
			 :config
			 (progn
			   (treemacs-create-icon :icon "▼ " :extensions (root-open)   :fallback 'same-as-icon)
			   (treemacs-create-icon :icon "▶ " :extensions (root-closed) :fallback 'same-as-icon)
			   (treemacs-create-icon :icon "▾ " :extensions (dir-open)    :fallback 'same-as-icon)
			   (treemacs-create-icon :icon "▸ " :extensions (dir-closed)  :fallback 'same-as-icon)
			   (treemacs-create-icon :icon "  " :extensions (fallback)    :fallback 'same-as-icon)))
  (treemacs-load-theme "simple")

  (setq treemacs-default-visit-action 'treemacs-visit-node-close-treemacs)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (setq treemacs-position 'right)

  ;; Set width of the treemacs sidebar
  (setq treemacs-width 35))

(message "16")

(use-package treemacs-evil
  :after (treemacs evil))

(global-set-key (kbd "M-e") 'treemacs)


(defun my/buffer-count ()
  "Return the total number of live buffers."
  (number-to-string
   (length (cl-remove-if-not #'buffer-file-name (buffer-list)))))


(setq-default mode-line-format
              (append mode-line-format
                      '((:eval (format "  B:%s" (my/buffer-count))))))

(use-package corfu
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode) ;; enable documentation popup

  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)   ;; wait 200ms
  (corfu-auto-prefix 1)
  (corfu-preselect 'prompt) ;; Always preselect the prompt
  
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  )

(global-set-key (kbd "C-SPC") #'completion-at-point)

(message "17")

;; Load simpleclip from local packages
(my/load-local-package 'copilot)
(setq copilot-indent-offset-warning-disable t)


(with-eval-after-load 'copilot
  ;; Step 1: Create a real prefix map
  (define-prefix-command 'my/copilot-prefix-map)

  ;; Step 2: Bind C-e globally (not just in insert state)
  (define-key global-map (kbd "C-e") 'my/copilot-prefix-map)

  ;; Step 3: Still bind C-l when a Copilot popup is active
  (general-define-key
   :keymaps 'copilot-completion-map
   "C-l" #'copilot-accept-completion)

  ;; Step 4: Bind keys inside the prefix map
  (general-define-key
   :keymaps 'my/copilot-prefix-map
   ;; Trigger/completion cycle
   "C-e"   #'copilot-complete
   "C-n"   #'copilot-next-completion
   "C-p"   #'copilot-previous-completion

   "C-l"   #'copilot-accept-completion-by-line
   "C-w"   #'copilot-accept-completion-by-word

   ;; Cancel
   "C-c"   #'copilot-clear-overlay))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'project)
(defun my/project-name ()
  "Return the name of the current project, or \"NoProj\"."
  (if-let ((proj (project-current)))
      (file-name-nondirectory (directory-file-name (project-root proj)))
    "NoProj"))

(message "18")

(setq project-mode-line t)


(use-package perspective
  :init
  (setq persp-suppress-no-prefix-key-warning t)
  (persp-mode)
  :config

  (setq persp-state-default-file "~/.emacs.d/persp-state")

  ;; Save state on exit
  (add-hook 'kill-emacs-hook #'persp-state-save)

  ;; Load state at startup (specify file explicitly)
  (add-hook 'emacs-startup-hook
            (lambda ()
              (when (file-exists-p persp-state-default-file)
                (persp-state-load persp-state-default-file)))))

(message "19")
(my/leader-keys
  "O" '(perspective-map :which-key "workspace"))

(message "20")
(setq insert-directory-program "gls")
(message "21")

(defun my/startup-select-project ()
  "On Emacs startup, prompt for a directory from ~/Projects, 
create a perspective for it, and open it as a project."
  (interactive)
  (let* ((project-root (expand-file-name "~/Projects"))
         (projects (seq-filter
                    (lambda (f)
                      (file-directory-p (expand-file-name f project-root)))
                    (directory-files project-root nil "^[^.]" t)))
         (choice (completing-read "Select project: " projects))
         (full-path (expand-file-name choice project-root)))
    ;; Enable perspective mode if not already
    (unless (bound-and-true-p persp-mode)
      (persp-mode 1))
    ;; Switch perspective
    (persp-switch choice)
    ;; Register this folder as a project in project.el
    (project-remember-project full-path)
    ;; Open Dired in the folder
    (dired full-path)))

(message "22")
(add-hook 'emacs-startup-hook #'my/startup-select-project)
(message "23")

(my/leader-keys
  "r" 'my/startup-select-project)

(message "24")
