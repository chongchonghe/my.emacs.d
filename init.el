;; -*- mode: emacs-lisp -*-

;;(setq use-spacemacs t)   ; or nil
;;
;;(when use-spacemacs
;;  (setq user-emacs-directory "~/.spacemacs.d/"))   ; defaults to ~/.emacs.d/
;;
;;(load (expand-file-name "init.el" user-emacs-directory))

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))
;;(require 'popwin)

(add-to-list 'package-archives
             '("MELPA Stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
       '("elpy" . "http://jorgenschaefer.github.io/packages/"))

(add-to-list 'load-path "~/.emacs.d/pkgs")

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(require 'ein)
(require 'ein-notebook)
(require 'ein-subpackages)

(defvar myPackages
  '(better-defaults
    ein
    elpy
    flycheck
    spolky
    ;; py-autopep8
    ))

;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  (add-to-list 'load-path "../.emacs.d/elpa")
  (require 'use-package))

;;;; All my organized configurations
(defun my-general-config ()
  "General setup, just copy and paste"
  (setq inhibit-startup-message t) ;; hide the startup message
  ;; remove backup files (e.g. README.md~)
  (setq make-backup-files nil)
  ;; prevent pop-up window "Async Shell Command" when doing pdf->tex sync
  ;; (setq pop-up-windows nil)
  ;; (call-process-shell-command "okular&" nil 0)
  (add-to-list 'display-buffer-alist
	       (cons "\\*Async Shell Command\\*.*" (cons #'display-buffer-no-window nil)))
  (global-linum-mode t) ;; enable line numbers globally
  ;; Use cmd key for meta
  ;; https://superuser.com/questions/297259/set-emacs-meta-key-to-be-the-mac-key
  (setq mac-option-key-is-meta nil
	mac-command-key-is-meta t
	mac-command-modifier 'meta
	mac-option-modifier 'none)
  ;; (global-linum-mode t) ;; enable line numbers globally
  ;; (add-hook 'prog-mode-hook 'column-number-mode)
  ;; (add-hook 'prog-mode-hook 'linum-mode) ;; enable (line number, col number)
  (windmove-default-keybindings)          ;; e.g. Shift-arrow to swith windows
  (global-set-key (kbd "C-x p") (kbd "C-- C-x o")) ;; make swithing windows easier
  (global-set-key (kbd "C-x n") (kbd "C-x o"))
  (global-set-key (kbd "M-p") (kbd "C-- C-x o"))
  (global-set-key (kbd "M-n") (kbd "C-x o"))
  (global-set-key (kbd "M-j") 'windmove-down)
  (global-set-key (kbd "M-k") 'windmove-up)
  (global-set-key (kbd "M-h") 'windmove-left)
  (global-set-key (kbd "M-l") 'windmove-right)
  ;; (global-unset-key (kbd "C-x C-c"))
  ;; (global-unset-key (kbd "M-v"))
  (global-set-key (kbd "M-v") 'evil-paste-after)
  ;; Auto fill mode
  (setq default-fill-column 80)
  (add-hook 'text-mode-hook 'turn-on-auto-fill)
  ;; Turn off auto-fill-mode in markdown
  (defun my-markdown-mode-hook ()
    (auto-fill-mode 0))                   ; turn off auto-filling
  (add-hook 'markdown-mode-hook 'my-markdown-mode-hook)
  ;;(popwin-mode 1)
  ;; Method two: use emacs default
  (setq-default
   ;; Column Marker at 80
   whitespace-line-column 80
   whitespace-style       '(face lines-tail))
  (add-hook 'prog-mode-hook #'whitespace-mode)
  ;; dumb-jump
  (dumb-jump-mode)
  (global-set-key (kbd "C-M-o") 'dumb-jump-go)
  ;; Auto revert mode
  (global-auto-revert-mode 1)
  ;; kill/copy whole line
  (defun slick-cut (beg end)
    (interactive
     (if mark-active
	 (list (region-beginning) (region-end))
       (list (line-beginning-position) (line-beginning-position 2)))))
  (advice-add 'kill-region :before #'slick-cut)
  (defun slick-copy (beg end)
    (interactive
     (if mark-active
	 (list (region-beginning) (region-end))
       (message "Copied line")
       (list (line-beginning-position) (line-beginning-position 2)))))
  (advice-add 'kill-ring-save :before #'slick-copy)
  ;; Indentation
  ;;(setq-default indent-tabs-mode nil)
  (setq tab-width 4)
  (global-set-key (kbd "C-c c") 'compile)
  (global-set-key (kbd "C-c m") 'recompile)
  ;; (require 'insert-time)
  ;; (define-key global-map [(control c)(d)] 'insert-date-time)
  ;; (define-key global-map [(control c)(control v)(d)] 'insert-personal-time-stamp)
  ;; Ref: https://stackoverflow.com/questions/384284/how-do-i-rename-an-open-file-in-emacs
  ;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
  (defun rename-file-and-buffer (new-name)
    "Renames both current buffer and file it's visiting to NEW-NAME."
    (interactive "sNew name: ")
    (let ((name (buffer-name))
	  (filename (buffer-file-name)))
      (if (not filename)
	  (message "Buffer '%s' is not visiting a file!" name)
	(if (get-buffer new-name)
	    (message "A buffer named '%s' already exists!" new-name)
	  (progn
	    (rename-file filename new-name 1)
	    (rename-buffer new-name)
	    (set-visited-file-name new-name)
	    (set-buffer-modified-p nil))))))
  )

(defun my-yasnippet-config ()
  (require 'yasnippet)
  (setq yas-triggers-in-field t)
;;; https://superuser.com/questions/1006188/can-emacs-be-set-up-to-display-python-code-in-python-mode-and-display-docstrings
					;(add-to-list 'load-path "~/.emacs.d/python-docstring-mode")
					;(require 'python-docstring)
					;(add-hook 'python-mode-hook (lambda () (python-docstring-mode t)))
  (yas/initialize)
  (yas/load-directory "~/.emacs.d/snippets")
  (yas-minor-mode 1)
  ;; (defun my/autoinsert-yas-expand()
  ;;   "Replace text in yasnippet template."
  ;;   (yas/expand-snippet (buffer-string) (point-min) (point-max)))
  )

(defun my-neotree-config ()
  "Use M-x package-list-packages to install neotree before
applying this config. "
  (defun my-neotree-mode-config ()
    "For use in 'neotree-mode-hook'."
    (local-set-key (kbd "j") 'neotree-next-line)
    (local-set-key (kbd "k") 'neotree-previous-line)
    (local-set-key (kbd "C-j") 'neotree-window-down)
    (local-set-key (kbd "C-k") 'neotree-window-up)
    )
  (add-hook 'neotree-mode-hook 'my-neotree-mode-config)
  )

(defun my-flyspell-config ()
  ;; easy spell check
  (global-set-key (kbd "<f8>") 'ispell-word)
  (global-set-key (kbd "C-S-<f8>") 'flyspell-mode)
  (global-set-key (kbd "C-M-<f8>") 'flyspell-buffer)
  (global-set-key (kbd "C-<f8>") 'flyspell-check-previous-highlighted-word)
  (defun flyspell-check-next-highlighted-word ()
    "Custom function to spell check next highlighted word"
    (interactive)
    (flyspell-goto-next-error)
    (ispell-word)
    )
  (global-set-key (kbd "M-<f8>") 'flyspell-check-next-highlighted-word)
  ;; Enable flyspell mode for texts and flyspell-prog mode for C/Python...
  ;; https://stackoverflow.com/questions/15891808/how-to-enable-automatic-spell-check-by-default
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  )

(defun my-evil-config ()
  (add-to-list 'load-path "~/.emacs.d/evil")
  ;; This should give you org-mode Tab functionality back. Ref:
  ;; https://stackoverflow.com/questions/22878668/emacs-org-mode-evil-mode-tab-key-not-working
  ;; (setq evil-want-C-i-jump nil)
  (require 'evil)
  (evil-mode 1)
  ;; Use neotree with evil mode
  (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
  (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
  (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
  (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
  (with-eval-after-load 'evil
    (defalias #'forward-evil-word #'forward-evil-symbol))
  ;;Exit insert mode by pressing j and then j quickly
					; reference: https://stackoverflow.com/questions/10569165/how-to-map-jj-to-esc-in-emacs-evil-mode
  (setq key-chord-two-keys-delay 0.4)
  (key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
  (key-chord-mode 1)
  ;; Add key-chord-mode to minor-mode-alist
  (if (not (assq 'key-chord-mode minor-mode-alist))
      (setq minor-mode-alist
	    (cons '(key-chord-mode " KeyC ")
		  minor-mode-alist)))
  ;; Ref: https://stackoverflow.com/questions/20882935/how-to-move-between-visual-lines-and-move-past-newline-in-evil-mode
  ;; Make movement keys work like they should: instead of go to next
  ;; logical line, pressing 'j' leads to the next visual line
  (define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
					; Make horizontal movement cross lines
  (setq-default evil-cross-lines t)
  )

(defun my-org-config ()
  ;; Enable Org mode
  (require 'org)
  ;; Make Org mode work with files ending in .org
  ;; (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  ;; The above is the default in recent emacs
  (setq truncate-lines 'nil)
  (defun my-org-mode-config ()
    (local-set-key "\M-n" 'outline-next-visible-heading)
    (local-set-key "\M-p" 'outline-previous-visible-heading)
    ;; table
    (local-set-key "\C-\M-w" 'org-table-copy-region)
    (local-set-key "\C-\M-y" 'org-table-paste-rectangle)
    (local-set-key "\C-\M-l" 'org-table-sort-lines)
    ;; display images
    (local-set-key "\M-I" 'org-toggle-iimage-in-org)
    ;; TODOlist
    (local-set-key (kbd "\C-c t") 'org-todo)
    ;; fix tab
    (local-set-key "\C-y" 'yank)
    (local-set-key "\M-h" 'windmove-left)
    (local-set-key (kbd "C-c c") 'org-capture)
    (local-set-key (kbd "C-c a") 'org-agenda)
    (local-set-key "\C-cl" 'grg-store-link)
    (local-set-key "\C-cb" 'org-switchb)
    )
  (add-hook 'org-mode-hook 'my-org-mode-config)
  (evil-define-key 'normal org-mode-map (kbd "SPC") 'org-todo)
  ;; https://orgmode.org/manual/Conflicts.html
  ;; Make windmove work in Org mode:
  (add-hook 'org-shiftup-final-hook 'windmove-up)
  (add-hook 'org-shiftleft-final-hook 'windmove-left)
  (add-hook 'org-shiftdown-final-hook 'windmove-down)
  (add-hook 'org-shiftright-final-hook 'windmove-right)
  (define-key org-mode-map (kbd "M-h") nil) ;; org conflicts
  (define-key org-mode-map (kbd "M-h") 'windmove-left) ;; org conflicts
  (setq org-startup-folded nil)
  ;; <tab> for 'indent-for-tab-command'
  ;; (evil-define-key 'normal org-mode-map (kbd "SPC") #'org-cycle)
  (evil-define-key 'insert org-mode-map (kbd "C-t") #'indent-for-tab-command)
  ;; org compile python
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)))
  (setq word-wrap 'nil)

  ;; ;; org-agenda
  ;; (setq org-agenda-files (quote ("/Users/chongchonghe/TODOs.org")))
  ;; (setq org-default-priority ?A)
  ;; ;;set colours for priorities
  ;; ;; (setq org-priority-faces '((?A . (:foreground "#F0DFAF" :weight bold))
  ;; ;;                            (?B . (:foreground "LightSteelBlue"))
  ;; ;;                            (?C . (:foreground "OliveDrab"))))
  ;; ;;open agenda in current window
  ;; (setq org-agenda-window-setup (quote current-window))
  ;; set key for agenda
  ;; (require 'org-projectile)
  ;; (setq org-projectile-projects-file "/Users/chongchonghe/TODOs.org")
  ;; (push (org-projectile-project-todo-entry) org-capture-templates)
  ;; (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
  ;; (global-set-key (kbd "C-c c") 'org-capture)
  ;; ;; (global-set-key (kbd "C-c n p") 'org-projectile-project-todo-completing-read)
  ;; (global-set-key (kbd "C-c a") 'org-agenda)
  (setq org-agenda-files "~/Dropbox/notes/agenda.org")
  (setq org-default-notes-file "~/Dropbox/notes/work.org")
  (use-package org-projectile
    :bind (("C-c n p" . org-projectile-project-todo-completing-read)
	   ;; ("C-c c" . org-capture)
	   ("C-c a" . org-agenda)
	   )
    :config
    (progn
      ;; (setq org-projectile-projects-file "~/Dropbox/notes/tasks.org")
      (setq org-projectile-projects-file "~/Dropbox/notes/work.org")
      (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
      (push (org-projectile-project-todo-entry) org-capture-templates))
    :ensure t)
  ;; (setq org-capture-templates
  ;; 	'(("g" "General todo" entry (file+headline "/Users/chongchonghe/tasks.org" "Tasks")
  ;; 	   "* TODO [#B] %?")
  ;; 	  ("t" "Task" entry (file+headline "" "Tasks")
  ;; 	   "* TODO %?\n  %u\n  %a")
  ;; 	  )
  ;; 	)
  ;; Exporting to LaTeX and PDF, formatting
  ;; http://pragmaticemacs.com/emacs/org-mode-basics-v-exporting-your-notes/
  (with-eval-after-load 'ox-latex
    (add-to-list 'org-latex-classes
		 '("bjmarticle"
		   "\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{graphicx}
\\usepackage{longtable}
\\usepackage{hyperref}
\\usepackage{natbib}
\\usepackage{amssymb}
\\usepackage{amsmath}
\\usepackage{geometry}
\\geometry{a4paper,margin=0.5in,marginparsep=7pt, marginparwidth=.6in}"
		   ("\\section{%s}" . "\\section*{%s}")
		   ("\\subsection{%s}" . "\\subsection*{%s}")
		   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
		   ("\\paragraph{%s}" . "\\paragraph*{%s}")
		   ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
  )

(defun my-hs-config ()
  ;; (hs-minor-mode 1)
  (defun my-hideshow-config ()
    "For use in 'hs-minor-mode-hook'."
    ;;(local-set-key (kbd "C-c p") 'hs-toggle-hiding)
    ;; (local-set-key (kbd "SPC") 'hs-toggle-hiding)
    (local-set-key (kbd "C-c h") 'hs-hide-all)
    (local-set-key (kbd "C-c s") 'hs-show-all)
    (local-set-key (kbd "C-c l") 'hs-hide-level)
    )
  (add-hook 'hs-minor-mode-hook 'my-hideshow-config)
  (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
  (evil-define-key 'normal hs-minor-mode-map (kbd "SPC") 'hs-toggle-hiding)
  )

(defun my-folding-mode-config ()
  ;; https://www.emacswiki.org/emacs/FoldingMode#toc6
  (setq folding-default-keys-function
	'folding-bind-backward-compatible-keys)
  (if (load "folding" 'nomessage 'noerror)
      (folding-mode-add-find-file-hook))

  ;; The following is included in the default
  (folding-add-to-marks-list 'python-mode "#<<<" "#>>>" nil t)
  (folding-add-to-marks-list 'LaTeX-mode "%{{{" "%}}}" nil t)
  ;; (folding-add-to-marks-list 'emacs-list-mode ";;{{{" ";;}}}" nil t) ; default?
  ;; (add-hook 'folding-mode
  ;; 	    '(local-set-key (kbd "<F9>") (kbd "C-c @ C-q"))
  ;; 	    )
  )

(defun my-python-config ()
  (elpy-enable)
  (elpy-use-ipython)
  (setq elpy-rpc-backend "jedi")
  ;; Disable elpy Vertical Guide Lines for Indentation
  (add-hook 'elpy-mode-hook (lambda () (highlight-indentation-mode -1)))
  (when (require 'flycheck nil t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  ;;(require 'py-autopep8)
  ;; (add-hook 'elpy-mode-hook) ;;'py-autopep8-enable-on-save)
  (setq python-shell-interpreter "ipython"
	python-shell-interpreter-args "--simple-prompt -i")
  (define-key ein:notebook-mode-map (kbd "C-c C-x d")
    'ein:worksheet-delete-cell)
  ;; Autoinsert Python comments
  (global-set-key (kbd "<f5>") 'my-insert-comments)
  (defun my-insert-comments (string)
    "Insert \label{ARG} \index{\nameref{ARG}} at point"
    (interactive "sString for \\label and \\nameref: ")
    (insert "##### "  string  " #####"))
  ;;(global-set-key (kbd "<f6>") 'my-insert-docstring)
  ;;(defun my-insert-docstring (string)
  ;;  "Insert \label{ARG} \index{\nameref{ARG}} at point"
  ;;  (interactive "sString for \\label and \\nameref: ")
  ;;  (insert '""" '  string  ' """'))
  (add-hook 'python-mode-hook 'hs-minor-mode)
  ;; jedi, replaced by (setq elpy-rpc-backend "jedi")
  ;; (add-hook 'python-mode-hook 'jedi:setup)
  ;; (setq jedi:complete-on-dot t)
  (setq elpy-rpc-ignored-buffer-size 204800)
  ;; https://emacs.stackexchange.com/questions/36721/evil-mode-interacting-with-python-el-invoking-skeletons
  (setq python-skeleton-autoinsert 1)
  ;; ref: https://www.webscalability.com/blog/2018/07/auto-insert-snippet-for-python-emacs/
  ;; insert python skeleton with auto-insert
  (eval-after-load 'autoinsert
    '(define-auto-insert
       '("\\.\\py\\'" . "python skeleton")
       '(""
	 "#!/usr/bin/env python" \n
	 "\"\"\" "
	 (file-name-nondirectory (buffer-file-name)) \n \n
	 "Author: Chong-Chong He (che1234@umd.edu)" \n
	 "Written on " (format-time-string "%a, %e %b %Y.") \n
	 "\"\"\"" \n
	 \n
  	 "import numpy as np" \n
  	 "import matplotlib.pyplot as plt" \n
  	 \n
	 > _ \n
	 \n
	 "if __name__ == '__main__':" \n
	 "pass" \n \n)))
  )

(defun my-latex-config ()
  ;; ---------------------------------------------------------------
  ;; AucTeX
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil) ;; Make emacs aware of multi-file projects
  ;; CDLaTeX
  (add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)   ; with AUCTeX LaTeX mode
  ;; (add-hook 'latex-mode-hook 'turn-on-cdlatex)   ; with Emacs latex mode
  (autoload 'helm-bibtex "helm-bibtex" "" t)
  (electric-pair-mode)
  (add-hook 'LaTeX-mode-hook
	    '(lambda ()
	       (define-key LaTeX-mode-map (kbd "$") 'self-insert-command)
	       ))
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  ;; (setq reftex-plug-into-auctex t)
  (setq reftex-plug-into-AUCTeX t)
  ;; (setq reftex-default-bibliography '("~/Dropbox/Bib_bibdesk.bib") )
  ;; (setq helm-bibtex-bibliography '("~/Dropbox/Bib_bibdesk.bib") )
  ;; (setq reftex-default-bibliography '("/Users/chongchonghe/Documents/bib_tmp.bib"))
  ;; (setq helm-bibtex-bibliography '("/Users/chongchonghe/Documents/bib_tmp.bib"))
  ;; Enable the clicking feature of the sync
  (add-hook 'LaTeX-mode-hook
	    (lambda () (local-set-key (kbd "<S-s-mouse-1>") #'TeX-view))
	    )
  (setq TeX-PDF-mode t)	      ;; Compile documents to PDF by default
  ;; Use Skim as viewer, enable source <-> PDF sync
  ;; make latexmk available via C-c C-c
  ;; Note: SyncTeX is setup via ~/.latexmkrc (see below)
  (add-hook 'LaTeX-mode-hook (lambda ()
			       (push
				'("latexmk" "latexmk -pdf %s" TeX-run-TeX nil t :help "Run latexmk on file")
				TeX-command-list)))
  (add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))
  ;; use Skim as default pdf viewer
  ;; Skim's displayline is used for forward search (from .tex to .pdf)
  ;; option -b highlights the current line; option -g opens Skim in the background
  (setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
  (setq TeX-view-program-list
	'(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))

  ;; start emacs in server mode so that skim can talk to it
  (server-start)

  ;; Auto-raise Emacs on activation
  ;; https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/
  (defun raise-emacs-on-aqua()
    (shell-command "osascript -e 'tell application \"Emacs\" to activate' &"))
  (add-hook 'server-switch-hook 'raise-emacs-on-aqua)

  (add-hook 'LaTex-mode-hook 'LaTeX-math-mode)

  (require 'smartparens-config)
  (add-hook 'LaTex-mode-hook #'smartparens-mode)

  ;; keybindings
  ;; (define-key outline-mode-map [M-left] 'outline-hide-body)
  ;; (define-key outline-mode-map [M-right] 'outline-show-all)
  ;; (define-key outline-mode-map [M-up] 'outline-previous-heading)
  ;; (define-key outline-mode-map [M-down] 'outline-next-heading)
  ;; (define-key outline-mode-map [C-M-left] 'outline-hide-sublevels)
  ;; (define-key outline-mode-map [C-M-right] 'outline-show-children)
  ;; (define-key outline-mode-map [C-M-up] 'outline-previous-visible-heading)
  ;; (define-key outline-mode-map [C-M-down] 'outline-next-visible-heading)

  (defun turn-on-outline-minor-mode () (outline-minor-mode 1))
  (add-hook 'LaTeX-mode-hook 'turn-on-outline-minor-mode)
  (add-hook 'latex-mode-hook 'turn-on-outline-minor-mode)

  (defun turn-on-flycheck-mode () (flycheck-mode 1))
  (add-hook 'LaTeX-mode-hook 'turn-on-flycheck-mode)
  (add-hook 'latex-mode-hook 'turn-on-flycheck-mode)

  (global-set-key [M-left] 'outline-hide-body)
  (global-set-key [M-right] 'outline-show-all)
  (global-set-key [M-up] 'outline-previous-heading)
  (global-set-key [M-down] 'outline-next-heading)
  (global-set-key [C-M-left] 'outline-hide-sublevels)
  (global-set-key [C-M-right] 'outline-show-children)
  (global-set-key [C-M-up] 'outline-previous-visible-heading)
  (global-set-key [C-M-down] 'outline-next-visible-heading)

  (setq TeX-save-query nil)

  (evil-define-key 'normal outline-minor-mode-map (kbd "SPC") 'evil-toggle-fold)
					;(evil-define-key 'normal latex-mode-map (kbd ", l") 'TeX-command-master)
  ;; (evil-define-key 'normal LaTeX-mode-map (kbd ", l") 'TeX-command-master)
  (evil-define-key 'normal LaTeX-mode-map (kbd ", l") 'TeX-command-run-all)
  (evil-define-key 'normal LaTeX-mode-map (kbd ", v") 'TeX-view)
  (evil-define-key 'normal LaTeX-mode-map (kbd "M-w") 'LaTeX-fill-region)

  ;; ;; (setq TeX-command-force "XeLaTeX")
  ;; (setq TeX-command-force "latexmk")

  ;;
  (add-hook 'LaTeX-mode-hook #'visual-line-mode)
  (defun disable-auto-fill-mode () (auto-fill-mode -1))
  (add-hook 'LaTeX-mode-hook 'disable-auto-fill-mode)
  (add-hook 'LaTeX-mode-hook
	    (lambda()
	      (local-set-key [C-tab] 'TeX-complete-symbol)))
  )

(defun my-html-config ()
  ;; (setq sgml-quick-keys 'close)
  )

(defun my-mu4e-config ()
  ;; ;; My old offlineimap config
  ;; (require 'mu4e)
  ;; (setq mail-user-agent 'mu4e-user-agent)
  ;; (setq mu4e-maildir "~/mail")
  ;; ;; (setq mu4e-get-mail-command "offlineimap -u quiet")
  ;; (setq mu4e-get-mail-command "offlineimap")
  ;; (setq mu4e-update-interval 60)
  ;; (setq mu4e-search-result-limit 5000)
  ;; (setq mu4e-sent-folder   "/astro/f.Sent Messages")
  ;; (setq mu4e-drafts-folder "/astro/f.Drafts")
  ;; (setq mu4e-trash-folder  "/astro/f.Deleted Messages")
  ;; (setq mu4e-refile-folder  "/astro/f.Archive")

  ;; My new mbsync config
  (when (eq system-type 'darwin)
    (add-to-list
     'load-path "/usr/local/Cellar/mu/1.2.0_1/share/emacs/site-lisp/mu/mu4e"))
  (require 'mu4e)
  (setq mail-user-agent 'mu4e-user-agent)
  (setq mu4e-maildir (expand-file-name "~/mbsync2/umdastro"))
  (setq mu4e-get-mail-command "mbsync -a")
  ;; mu4e requires to specify drafts, sent, and trash dirs a smarter
  ;; configuration allows to select directories according to the
  ;; account (see mu4e page)
  (setq mu4e-sent-folder    "/Sent Messages")
  (setq mu4e-drafts-folder  "/Drafts")
  (setq mu4e-trash-folder   "/Trash")
  (setq mu4e-refile-folder  "/Archive")
  ;; don't save message to Sent Messages, IMAP takes care of this
  ;; (setq mu4e-sent-messages-behavior 'delete)
  ;; Save message to Sent Messages, astro IMAP server fails to take care of this
  (setq mu4e-sent-messages-behavior 'sent)
  (setq mu4e-update-interval 60)
  (setq mu4e-search-result-limit 500)
  (setq mu4e-headers-results-limit 200)
  (setq mu4e-change-filenames-when-moving t)
  ;; (define-key mu4e-headers-mode-map (kbd "d") nil)
  ;; tell mu4e to use w3m for html rendering.
  ;; (setq mu4e-html2text-command "w3m -T text/html")
  (setq mu4e-html2text-command "w3m -dump -T text/html -o display_link_number=true")
  (setq mu4e-alert-interesting-mail-query "flag:unread AND maildir:/INBOX")
  ;;https://emacs.stackexchange.com/questions/52487/mu4e-how-to-stop-the-unarchiving-of-entire-threads-when-new-message-arrives
  (setq mu4e-headers-include-related nil)
  (setq mu4e-maildir-shortcuts
	'( ("/INBOX"               . ?i)
	   ("/Sent Messages"       . ?s)
	   ("/Trash"               . ?t)
	   ("/Drafts"              . ?d)
	   ("/Archive"             . ?a)
	   ("/Reference"           . ?r)
	   ;; ("/Waiting"             . ?w)
	   ;; ("/Action Items"        . ?c)
	   ))
  ;; sending emails
  (setq user-mail-address "chongchong@astro.umd.edu"
	user-full-name  "ChongChong He"
	smtpmail-default-smtp-server "gaia.astro.umd.edu"
	;; smtpmail-local-domain "account1.example.com"
	smtpmail-smtp-server "gaia.astro.umd.edu"
	;; smtpmail-stream-type 'starttls
	;; smtpmail-smtp-service 587
	smtpmail-debug-info t)
  ;; show images
  (setq mu4e-view-show-images t)
  ;; use imagemagick, if available
  (when (fboundp 'imagemagick-register-types) (imagemagick-register-types))
  ;; from: http://cachestocaches.com/2017/3/complete-guide-email-emacs-using-mu-and-/#getting-set-up-with-mu-and-offlineimap
  (setq sendmail-program "/usr/local/bin/msmtp"
	send-mail-function 'smtpmail-send-it
	message-sendmail-f-is-evil t
	message-sendmail-extra-arguments '("--read-envelope-from")
	message-send-mail-function 'message-send-mail-with-sendmail)
  ;; from: https://www.djcbsoftware.nl/code/mu/mu4e/Compose-hooks.html
  ;; 1) messages to me@foo.example.com should be replied with From:me@foo.example.com
  ;; 2) messages to me@bar.example.com should be replied with From:me@bar.example.com
  ;; 3) all other mail should use From:me@cuux.example.com
  (add-hook 'mu4e-compose-pre-hook
	    (defun my-set-from-address ()
	      "Set the From address based on the To address of the original."
	      (let ((msg mu4e-compose-parent-message)) ;; msg is shorter...
		(when msg
		  (setq user-mail-address
			(cond
			 ((mu4e-message-contact-field-matches msg :to "chongchong@astro.umd.edu")
			  "chongchong@astro.umd.edu")
			 (t "chongchong@astro.umd.edu")))))))
  ;; ;; Reply from the same address: not needed since astro is the default
  ;; (defun my-mu4e-set-account ()
  ;;   "Set the account for composing a message."
  ;;   (if mu4e-compose-parent-message
  ;;       (let ((mail (cdr (car (mu4e-message-field mu4e-compose-parent-message :to)))))
  ;; 	(if (member mail mu4e-user-mail-address-list)
  ;; 	    (setq user-mail-address mail)
  ;;       (setq user-mail-address "chongchong@astro.umd.edu")))
  ;;     ;; (helm :sources
  ;;     ;;   `((name . "Select account: ")
  ;;     ;;     (candidates . mu4e-user-mail-address-list)
  ;;     ;;     (action . (lambda (candidate) (setq user-mail-address candidate)))))
  ;;   )
  ;; )
  ;; spell check
  (add-hook 'mu4e-compose-mode-hook
	    (defun my-do-compose-stuff ()
	      "My settings for message composition."
	      (set-fill-column 72)
	      (flyspell-mode)))
  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)
  ;; Ref: https://emacs.stackexchange.com/questions/21723/how-can-i-delete-mu4e-drafts-on-successfully-sending-the-mail
  (defun draft-auto-save-buffer-name-handler (operation &rest args)
    "for `make-auto-save-file-name' set '.' in front of the file name; do nothing for other operations"
    (if
	(and buffer-file-name (eq operation 'make-auto-save-file-name))
	(concat (file-name-directory buffer-file-name)
		"."
		(file-name-nondirectory buffer-file-name))
      (let ((inhibit-file-name-handlers
	     (cons 'draft-auto-save-buffer-name-handler
		   (and (eq inhibit-file-name-operation operation)
			inhibit-file-name-handlers)))
	    (inhibit-file-name-operation operation))
	(apply operation args))))
  ;; automatically cc myself
  (setq mu4e-compose-keep-self-cc t)
  (setq mu4e-compose-dont-reply-to-self nil) ;; trying because the above doesn't work
  ;; (setq mu4e-compose-dont-reply-to-self t) ; ?
  ;; from: https://emacs.stackexchange.com/questions/52608/how-to-add-a-value-for-cc-or-reply-to-in-each-new-message/52609
  (add-hook 'mu4e-compose-mode-hook
	    (defun my-add-bcc ()
	      "Add a cc: header."
	      (save-excursion (message-add-header "cc: chongchong@astro.umd.edu\n"))))
  ;;
  (add-to-list 'file-name-handler-alist '("Drafts/cur/" . draft-auto-save-buffer-name-handler))
  ;; the headers to show in the headers list -- a pair of a field
  ;; and its width, with `nil' meaning 'unlimited'
  ;; (better only use that for the last field.
  ;; These are the defaults:
  (setq mu4e-headers-fields
	'( (:human-date    . 12)    ;; alternatively, use :human-date
	   (:flags         . 6)
	   (:from-or-to    . 25)
	   (:cc            . 25)
	   (:subject       . nil))) ;; alternatively, use :thread-subject
  ;;
  (setq message-citation-line-function 'message-insert-formatted-citation-line)
  (setq message-citation-line-format "On %a, %b %d %Y, %f wrote:\n")
  ;; (defun enable-mu4e-notification ()
  ;;   ;; Desktop notifications for unread emails
  ;;   ;; Choose the style you prefer for desktop notifications
  ;;   ;; If you are on Linux you can use
  ;;   ;; 1. notifications - Emacs lisp implementation of the Desktop Notifications API
  ;;   ;; 2. libnotify     - Notifications using the `notify-send' program, requires `notify-send' to be in PATH
  ;;   ;;
  ;;   ;; On Mac OSX you can set style to
  ;;   ;; 1. notifier      - Notifications using the `terminal-notifier' program, requires `terminal-notifier' to be in PATH
  ;;   ;; 1. growl         - Notifications using the `growl' program, requires `growlnotify' to be in PATH
  ;;   (add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
  ;;   (mu4e-alert-set-default-style 'notifier)
  ;;   ;; Mode Line display of unread emails
  ;;   ;; Display of the unread email count in the mode-line
  ;;   ;; (add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display)
  ;;   (add-hook 'after-init-hook #'mu4e-alert-disable-mode-line-display)
  ;;   ;; adding the following snippet to your init file, will instruct
  ;;   ;; mu4e-alert to only display the number of unread emails.
  ;;   ;; (setq mu4e-alert-email-notification-types '(subjects))
  ;;   (setq mu4e-alert-email-notification-types '(count))
  ;;   )
  ;; ;; Uncomment the following line and the defun above to enable notification
  ;; (enable-mu4e-notification)
  ;; ;; signatures.
  ;; Ref: https://www.macs.hw.ac.uk/~rs46/posts/2014-11-16-mu4e-signatures.html
  ;; (setq mu4e-compose-signature
  ;;    "ChongChong He\n")
  (defun my-mu4e-choose-signature ()
    "Insert one of a number of sigs"
    (interactive)
    (let ((message-signature
	   (mu4e-read-option "Signature:"
			     '(("formal" .
				(concat
				 "Chong-Chong He\n"
				 "PhD Student, Department of Astronomy\n"
				 "University of Maryland, College Park\n"
				 "E: chongchong@astro.umd.edu\n"
				 "W: https://chongchonghe.github.io/"))
			       ("informal" .
				(concat
				 "Best,\n"
				 "ChongChong\n")
				)
			       ))))
      (message-insert-signature)))
  (add-hook 'mu4e-compose-mode-hook
	    (lambda () (local-set-key (kbd "C-c C-w") #'my-mu4e-choose-signature)))
  (message "This message appears in the echo area!")
  )

(defun my-CC++-config ()
  (setq-default c-basic-offset 4)
  (add-hook 'c-mode-common-hook
	    (lambda ()
	      (when (and (derived-mode-p 'c-mode 'c++-mode 'java-mode) (require 'ggtags nil 'noerror))
		(ggtags-mode 1))
	      (global-set-key (kbd "M-j") 'windmove-down)
	      ))
  ;; (define-skeleton 'c++-throwaway
  ;;   "Throwaway C skeleton"
  ;;   nil
  ;;   "#include <iostream>\n"
  ;;   "#include <string>\n"
  ;;   "#include <fstream>\n"
  ;;   "\n"
  ;;   "using namespace std;\n"
  ;;   "\n"
  ;;   "int main(void){\n"
  ;;   "  \n"
  ;;   "  return 0;\n"
  ;;   "}\n")
  ;; '("\\.\\(CC?\\|cc\\|cxx\\|cpp\\|c++\\)\\'" . "C++-throwaway")
  (eval-after-load 'autoinsert
    '(define-auto-insert
       '("\\.\\(CC?\\|cc\\|cxx\\|cpp\\|c++\\)\\'" . "C++ skeleton")
       '("Short description: "
	 "/*" \n
	 (file-name-nondirectory (buffer-file-name))
	 " -- " str \n
	 " */" > \n \n
	 "#include <iostream>" \n \n
	 "using namespace std;" \n \n
	 "int main()" \n
	 -4 "{" \n
	 > _ \n
	 > _ "return 0;" \n
	 -4 "}" > \n)))
  ;; https://www.emacswiki.org/emacs/AutoInsertMode
  (eval-after-load 'autoinsert
    '(define-auto-insert '("\\.c\\'" . "C skeleton")
       '(
	 "Short description: "
	 "/**\n * "
	 (file-name-nondirectory (buffer-file-name))
	 " -- " str \n
	 "*" \n
	 "* Written on " (format-time-string "%a, %e %b %Y.") \n
	 "*/" > \n \n
	 "#include <stdio.h>" \n
	 \n
	 "int main()" \n
	 "{" > \n
	 > _ \n
	 "}" > \n)))
  )

(defun my-fortran-config ()
  (require 'f90-namelist-mode)
  (autoload 'f90-mode "f90" "Fortran 90 mode" t)
  (defun my-f90-mode-hook ()
    (setq f90-font-lock-keywords f90-font-lock-keywords-3)
    (abbrev-mode 1)                       ; turn on abbreviation mode
    (turn-on-font-lock)                   ; syntax highlighting
    (auto-fill-mode 0))                   ; turn off auto-filling
  (add-hook 'f90-mode-hook 'my-f90-mode-hook)
  (add-hook 'f90-mode-hook 'auto-fill-mode)
  (add-to-list 'auto-mode-alist '("\\.f9\\'" . f90-mode))
  ;; From https://gist.github.com/aradi/68a4ff8430a735de13f13393213f0ea8
  ;;
  ;; Add this settings to your ~/.emacs file
  ;;
  ;; Fortran settings
  (setq fortran-continuation-string "&")
  (setq fortran-do-indent 2)
  (setq fortran-if-indent 2)
  (setq fortran-structure-indent 2)
  ;; Fortran 90 settings
  (setq f90-do-indent 2)
  (setq f90-if-indent 2)
  (setq f90-type-indent 2)
  (setq f90-program-indent 2)
  (setq f90-continuation-indent 4)
  (setq f90-smart-end 'blink)
  ;; Set Fortran and Fortran 90 mode for appropriate extensions
  (setq auto-mode-alist
	(cons '("\\.F90$" . f90-mode) auto-mode-alist))
  (setq auto-mode-alist
	(cons '("\\.pf$" . f90-mode) auto-mode-alist))
  (setq auto-mode-alist
	(cons '("\\.fpp$" . f90-mode) auto-mode-alist))
  (setq auto-mode-alist
	(cons '("\\.F$" . fortran-mode) auto-mode-alist))
  ;; Swap Return and C-j in Fortran 90 mode
  (add-hook 'f90-mode-hook
	    '(lambda ()
	       (define-key f90-mode-map [return] 'f90-indent-new-line)
	       (define-key f90-mode-map "\C-j" 'newline)
	       (setq fill-column 100)
	       (abbrev-mode)
	       (setq-default indent-tabs-mode nil)
	       (setq whitespace-line-column 100)
	       (setq whitespace-style '(face tabs lines-tail empty))
	       (whitespace-mode)
	       ;; (add-to-list 'write-file-functions 'delete-trailing-whitespace)
	       )
	    )
  )

(defun my-julia-config ()
  (add-to-list 'load-path "~/.emacs.d/julia-emacs")
  (require 'julia-mode)
  )

(defun my-other-config ()
  (require 'epa-file)
  (epa-file-enable)
  ;; tramp: speed up
  (setq tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*")
  )

(defun my-theme-config ()
  ;; Customize solarized-light theme

  ;; make the fringe stand out from the background
  (setq solarized-distinct-fringe-background t)

  ;; Don't change the font for some headings and titles
  (setq solarized-use-variable-pitch nil)

  ;; make the modeline high contrast
  (setq solarized-high-contrast-mode-line t)

  ;; Use less bolding
  (setq solarized-use-less-bold t)

  ;; Use more italics
  (setq solarized-use-more-italic t)

  ;; Use less colors for indicators such as git:gutter, flycheck and similar
  (setq solarized-emphasize-indicators nil)

  ;; Don't change size of org-mode headlines (but keep other size-changes)
  (setq solarized-scale-org-headlines nil)

  ;; Avoid all font-size changes
  ;; (setq solarized-height-minus-1 1.0)
  ;; (setq solarized-height-plus-1 1.0)
  ;; (setq solarized-height-plus-2 1.0)
  ;; (setq solarized-height-plus-3 1.0)
  ;; (setq solarized-height-plus-4 1.0)

  ;; (load-theme 'solarized-light t)
  (load-theme 'gruvbox t)

  ;; ---------------------------------------------------------------
  ;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
  ;; (load-theme 'spolsky t)
  ;; (set-face-attribute 'default nil :font "SF Mono 12")
  ;; (set-face-attribute 'default nil :font "Source Code Pro 14")
  ;; set font size
  (set-face-attribute 'default (selected-frame) :height 150)

;;; right 2/3, two columns
					;(set-face-attribute 'default (selected-frame) :height 122)
					;(add-to-list 'default-frame-alist '(height . 71))
					;(add-to-list 'default-frame-alist '(width . 177))
					;(add-to-list 'default-frame-alist '(left . 784))
					;(add-to-list 'default-frame-alist '(top . 0))

  ;; center, large, two columns
  ;; (set-face-attribute 'default (selected-frame) :height 122)
  (add-to-list 'default-frame-alist '(height . 68))
  (add-to-list 'default-frame-alist '(width . 180))
					;(add-to-list 'default-frame-alist '(left . (- 0)))
  (add-to-list 'default-frame-alist '(right . 0))
  (add-to-list 'default-frame-alist '(top . 0))

  ;; Customed theme, be careful. Just copy and paste
  ;; ---------------------------------------------------------------
  ;; (custom-set-faces
  ;;  ;; custom-set-faces was added by Custom.
  ;;  ;; If you edit it by hand, you could mess it up, so be careful.
  ;;  ;; Your init file should contain only one such instance.
  ;;  ;; If there is more than one, they won't work right.
  ;;  '(default ((t (:inherit nil :stipple nil :background "#dcc7b4" :foreground "#1e1e1e" :vertical-boarder "#1e1e1e" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 274 :width normal :foundry "nil" :family "MONACO")))))

  ;; :background "#dcc7b4" :foreground "#1e1e1e"

  ;;  :background "#D4A984" :foreground "#38302B"

  ;; https://stackoverflow.com/questions/52521587/emacs-error-when-i-call-it-in-the-terminal
  ;;(delete-file "~/Library/Colors/Unnamed 3.clr")
  )

;;;; Enable all the configs
(my-general-config)
(my-evil-config)
(my-yasnippet-config)
(my-neotree-config)
(my-flyspell-config)
(my-python-config)
(my-org-config)
(my-hs-config)
(my-folding-mode-config)
(my-latex-config)
(my-html-config)
(my-mu4e-config)
(my-CC++-config)
(my-fortran-config)
(my-julia-config)
(my-theme-config)

(defun test02 ()
  (global-set-key (kbd "<f8>") 'back-to-indentation)
  )
(test02)


;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(LaTeX-indent-environment-list
;;    (quote
;;     (("verbatim" current-indentation)
;;      ("verbatim*" current-indentation)
;;      ("tabular")
;;      ("tabular*")
;;      ("align")
;;      ("align*")
;;      ("array")
;;      ("eqnarray")
;;      ("eqnarray*")
;;      ("displaymath")
;;      ("equation")
;;      ("equation*")
;;      ("picture")
;;      ("tabbing"))))
;;  '(TeX-source-correlate-method (quote synctex))
;;  '(TeX-source-correlate-mode t)
;;  '(auto-insert (quote other))
;;  ;; '(auto-insert-alist (quote nil))
;;  '(custom-safe-themes
;;    (quote
;;     ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
;;  '(org-startup-truncated nil)
;;  '(package-selected-packages
;;    (quote
;;     (org gruvbox-theme magit mu4e-alert helm solarized-theme htmlize ein jedi key-chord popwin yasnippet goto-last-change evil auctex evil-visual-mark-mode markdown-mode flycheck neotree elpy)))
;;  '(send-mail-function (quote mailclient-send-it)))

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(TeX-source-correlate-method (quote synctex))
;;  '(TeX-source-correlate-mode t)
;;  '(auto-insert (quote other))
;;  '(auto-insert-alist (quote nil))
;;  '(auto-insert-directory "~/.emacs.d/snippets/auto_insert")
;;  '(custom-safe-themes
;;    (quote
;;     ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
;;  '(org-startup-truncated nil)
;;  '(package-selected-packages
;;    (quote
;;     (solarized-theme htmlize ein jedi key-chord popwin yasnippet goto-last-change evil auctex evil-visual-mark-mode markdown-mode flycheck neotree elpy)))
;;  '(send-mail-function (quote mailclient-send-it)))

;; ;; Auto insert mode
;; (require 'autoinsert)
;; (auto-insert-mode)
;; (setq auto-insert-directory "~/.emacs.d/snippets/auto_insert")
;; ;; (setq auto-insert-query nil) ;;; If you don't want to be prompted before insertion
;; (define-auto-insert "\.py" "template.py")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-indent-environment-list
   (quote
    (("verbatim" current-indentation)
     ("verbatim*" current-indentation)
     ("tabular")
     ("tabular*")
     ("align")
     ("align*")
     ("array")
     ("eqnarray")
     ("eqnarray*")
     ("displaymath")
     ("equation")
     ("equation*")
     ("picture")
     ("tabbing"))))
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
 '(org-startup-truncated nil)
 '(package-selected-packages
   (quote
    (org-projectile-helm org-projectile vimrc-mode julia-mode org gruvbox-theme magit mu4e-alert helm solarized-theme htmlize ein jedi key-chord popwin yasnippet goto-last-change evil auctex evil-visual-mark-mode markdown-mode flycheck neotree elpy)))
 '(send-mail-function (quote mailclient-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
