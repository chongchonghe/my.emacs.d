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
  ;; make swithing windows easier
  (global-set-key (kbd "C-x p") (kbd "C-- C-x o")) 
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
  ;; https://emacsredux.com/blog/2013/05/18/instant-access-to-init-dot-el/
  (defun er-find-user-init-file ()
    "Edit the `user-init-file', in another window."
    (interactive)
    ;; (find-file-other-window user-init-file)
    (find-file user-init-file)
    )
  (global-set-key (kbd "C-c i") #'er-find-user-init-file)

  ;; set encoding
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-buffer-file-coding-system 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8-unix)
  (set-file-name-coding-system 'utf-8-unix)
  (set-keyboard-coding-system 'utf-8-unix)
  (set-next-selection-coding-system 'utf-8-unix)
  (set-selection-coding-system 'utf-8-unix)
  (set-terminal-coding-system 'utf-8-unix)
  (setq locale-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
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

(defun my-langtool-config ()
  ;; Check grammar after saving a text file with LanguageTools
  ;; https://alhassy.github.io/init/
  ;; (use-package langtool
  ;;   :config
  ;;   (setq langtool-language-tool-jar
  ;;         "~/local/LanguageTool-4.8/languagetool-commandline.jar")
  ;;   (setq langtool-default-language "en-US")
  ;;   )

  ;; https://simpleit.rocks/lisp/emacs/writing-in-emacs-checking-spelling-style-and-grammar/
  (setq langtool-language-tool-jar "~/local/LanguageTool-4.8/languagetool-commandline.jar")
  (require 'langtool)
  ;; (add-hook 'markdown-mode-hook
  ;;         (lambda () 
  ;;            (add-hook 'after-save-hook 'langtool-check nil 'make-it-local)))
  ;; (add-hook 'org-mode-hook
  ;;         (lambda () 
  ;;            (add-hook 'after-save-hook 'langtool-check nil 'make-it-local)))

  ;; Quickly check, correct, then clean up /region/ with M-^
  (add-hook 'langtool-error-exists-hook
            (lambda ()
              (langtool-correct-buffer)
              (langtool-check-done)
              ))
  
  ;; ;; (global-set-key "\M-^" 'langtool-check)
  ;; (global-set-key "\C-x4w" 'langtool-check)
  ;; (global-set-key "\C-x4W" 'langtool-check-done)
  ;; (global-set-key "\C-x4l" 'langtool-switch-default-language)
  ;; (global-set-key "\C-x44" 'langtool-show-message-at-point)
  ;; (global-set-key "\C-x4c" 'langtool-correct-buffer)

  (global-set-key "\C-cgw" 'langtool-check)
  (global-set-key "\C-cgW" 'langtool-check-done)
  (global-set-key "\C-cgc" 'langtool-correct-buffer)
  (global-set-key "\C-cgn" 'langtool-goto-next-error)
  (global-set-key "\C-cgp" 'langtool-goto-previous-error)
  ;; (global-set-key "\C-x4l" 'langtool-switch-default-language)
  ;; (global-set-key "\C-x44" 'langtool-show-message-at-point)
  
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

  ;; load shared .el followed by Emacs specific config
  (load-file "~/.my-elips/org.el")

  ;; Make Org mode work with files ending in .org
  ;; (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  ;; The above is the default in recent emacs
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (setq truncate-lines 'nil)
  (evil-define-key 'normal org-mode-map (kbd "t") 'org-todo)

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
    ;; (local-set-key (kbd "C-c c") 'org-capture)
    ;; (local-set-key (kbd "C-c a") 'org-agenda)
    (local-set-key "\C-cl" 'grg-store-link)
    (local-set-key "\C-cb" 'org-switchb)
    (org-indent-mode)
    )
  (add-hook 'org-mode-hook 'my-org-mode-config)
  ;; https://orgmode.org/manual/Conflicts.html
  ;; Make windmove work in Org mode:
  (add-hook 'org-shiftup-final-hook 'windmove-up)
  (add-hook 'org-shiftleft-final-hook 'windmove-left)
  (add-hook 'org-shiftdown-final-hook 'windmove-down)
  (add-hook 'org-shiftright-final-hook 'windmove-right)
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

  ; ;; org-agenda
  (use-package org-projectile
    :bind (("C-c n p" . org-projectile-project-todo-completing-read)
	   ;; ("C-c c" . org-capture)
	   ;; ("C-c a" . org-agenda)
	   )
    :config
    (progn
      (setq org-projectile-projects-file "~/Dropbox/orgfiles/tasks.org")
      (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
      (push (org-projectile-project-todo-entry) org-capture-templates))
    :ensure t)

  (require 'org-mu4e)

  (require 'org-bullets)
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

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
  (setq python-skeleton-autoinsert nil)
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
  (when (eq system-type 'darwin)
    (add-to-list
     'load-path "/usr/local/Cellar/mu/1.2.0_1/share/emacs/site-lisp/mu/mu4e"))

  (mu4e-maildirs-extension)
  (global-set-key (kbd "C-c e") 'mu4e)
  (load-file "~/.my-elips/mail.el")

  ;; Emacs specific (not on Spacemacs)
  ;; (global-set-key (kbd "mu") (kbd "mu4e"))
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
  ;; (set-face-attribute 'default (selected-frame) :height 150)
  (set-face-attribute 'default nil :height 150)

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
;; (my-yasnippet-config)
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
 '(org-export-backends (quote (ascii beamer html icalendar latex man md odt)))
 '(org-startup-truncated nil)
 '(package-selected-packages
   (quote
    (langtool mu4e-maildirs-extension org-projectile-helm org-projectile vimrc-mode julia-mode org gruvbox-theme magit mu4e-alert helm solarized-theme htmlize ein jedi key-chord popwin yasnippet goto-last-change evil auctex evil-visual-mark-mode markdown-mode flycheck neotree elpy)))
 '(send-mail-function (quote mailclient-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
