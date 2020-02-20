(require 'autoinsert)
(auto-insert-mode)
(setq auto-insert-directory "~/.emacs.d/snippets/auto_insert")
(define-auto-insert "\.py" "template.py")
