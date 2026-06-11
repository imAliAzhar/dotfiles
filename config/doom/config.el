;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-rose-pine-moon)

(setq doom-font (font-spec :family "Victor Mono" :size 17 :weight 'medium))

(add-to-list 'default-frame-alist '(alpha . (90 85)))

;; Use bash internally so fish doesn't break child processes (TRAMP, diff-hl, etc.)
(setq shell-file-name (executable-find "bash"))
(setq eat-shell "/opt/homebrew/bin/fish")

(defun my/cycle-window-buffer (direction)
  "Cycle between the file-buffer group (1 slot) and each eat terminal (individual slots).
DIRECTION: 1 = next, -1 = previous."
  (let* ((terms (cl-remove-if-not
                 (lambda (b) (eq (buffer-local-value 'major-mode b) 'eat-mode))
                 (buffer-list)))
         (in-term (eq major-mode 'eat-mode))
         (term-pos (when in-term (cl-position (current-buffer) terms))))
    (cond
     ((null terms) nil)
     ((not in-term)
      (switch-to-buffer (if (= direction 1) (car terms) (car (last terms)))))
     (t
      (let ((next (+ term-pos direction)))
        (if (and (>= next 0) (< next (length terms)))
            (switch-to-buffer (nth next terms))
          (switch-to-buffer
           (or (cl-find-if #'buffer-file-name (buffer-list))
               (current-buffer)))))))))

(defun my/next-window-buffer ()
  (interactive)
  (my/cycle-window-buffer 1))

(defun my/previous-window-buffer ()
  (interactive)
  (my/cycle-window-buffer -1))

(defun my/eat-switch-or-create ()
  "Switch to the most recent eat buffer full-screen, or create one if none exists."
  (interactive)
  (let ((terms (cl-remove-if-not
                (lambda (b) (eq (buffer-local-value 'major-mode b) 'eat-mode))
                (buffer-list))))
    (if terms
        (switch-to-buffer (car terms))
      (eat))))

(map!
 ;; File picker — Cmd+P (mirrors SPC SPC / project file search)
 "s-p"  #'projectile-find-file

 ;; Live grep — Cmd+F (mirrors SPC / search project)
 "s-f"  #'+default/search-project

 ;; File explorer — Cmd+E (mirrors <Leader>e → yazi/dired)
 "s-e"  #'dired-jump

 ;; Save — Cmd+S / Cmd+Shift+S (mirrors <Leader>s and <Leader>S)
 "s-s"  #'save-buffer
 "s-S"  (cmd! (let ((before-save-hook nil) (after-save-hook nil)) (save-buffer)))

 ;; Git — Cmd+G (mirrors <Leader>gg → DiffviewOpen/lazygit)
 "s-g"  #'magit-status

 ;; Comment toggle — Cmd+/ (mirrors <Leader>/)
 "s-/"  #'evilnc-comment-or-uncomment-lines

 ;; Window cycling — Cmd+H/L: file buffers = 1 slot, each vterm = own slot
 "s-h"  #'my/previous-window-buffer
 "s-l"  #'my/next-window-buffer

 ;; Jump to terminal — Cmd+J (switch to last eat terminal, or create one)
 "s-j"  #'my/eat-switch-or-create

 ;; New terminal — Cmd+T (always spawns a fresh terminal, like tmux new-window)
 "s-t"  (cmd! (eat nil t))

 ;; Window splits — Cmd+- and Cmd+\ (mirrors tmux prefix+- and prefix+\)
 "s--"  #'split-window-below
 "s-\\" #'split-window-right

 ;; Zoom window — Cmd+Z (mirrors tmux prefix+z)
 "s-z"  #'doom/window-maximize-buffer

 ;; Projects/workspaces — mirrors tmux sessions
 "s-r"  #'+workspace/switch-to
 "s-J"  #'+workspace/switch-right
 "s-K"  #'+workspace/switch-left

 ;; Font size — Cmd+= / Cmd+_ (from wezterm shared bindings)
 "s-="  #'doom/reset-font-size
 "s-+"  #'doom/increase-font-size
 "s-_"  #'doom/decrease-font-size)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
