#!/bin/sh

echo Install required apps
sudo pkg install -y git screen wget curl emacs25 guile2 texinfo tree en-aspell

echo Install zsh oh-my-zsh
sudo pkg install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo chsh -s /usr/local/bin/zsh vagrant

echo Fix repeated characters in zsh
cat <<EOF >> ~/.zshrc

# Fix repeated characters at the start of commands
export LC_CTYPE=en_US.UTF-8
EOF

echo Install emacs utilities
mkdir ~/.lisp
cd ~/.lisp
git clone http://git.sv.gnu.org/r/geiser.git
git clone http://mumble.net/~campbell/git/paredit.git
git clone https://github.com/sabof/org-bullets.git
wget https://raw.githubusercontent.com/emacsmirror/emacswiki.org/master/lacarte.el

echo configure .emacs to load geiser on start

cat << "EOF" > ~/.emacs
(menu-bar-mode -1)

(load-theme 'wombat t)

;; Scroll one line at a time past the top or bottom window
(setq scroll-conservatively 10000)

(load-file "~/.lisp/geiser/elisp/geiser.el")
(setq geiser-active-implementations '(guile))

(load-file "~/.lisp/paredit/paredit.el")
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'company-mode)

(add-hook 'org-mode-hook           #'org-indent-mode)
(add-hook 'org-mode-hook           #'visual-line-mode)

(load-file "~/.lisp/lacarte.el")
(global-set-key [?\e ?\M-x] 'lacarte-execute-command)
(global-set-key [?\M-`] 'lacarte-execute-command)

;; Don’t ask before evaluating code blocks.
(setq org-confirm-babel-evaluate nil)

(load-file "~/.lisp/org-bullets/org-bullets.el")
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(setq org-ellipsis "⤵")

;; Use syntax highlighting in source blocks while editing
(setq org-src-fontify-natively t)

;; When editing a code snippet, use the current window rather
;; than popping open a new one (which shows the same information).
(setq org-src-window-setup 'current-window)

;; Enable spell-checking in Org-mode.
(add-hook 'org-mode-hook 'flyspell-mode)


(org-babel-do-load-languages
 'org-babel-load-languages
 '((scheme . t)
   (emacs-lisp . nil)
   ))

EOF

echo install SICP Texinfo
wget https://github.com/abhinav1587/vagrant-scheme-freebsd/raw/master/sicp.info.gz
sudo cp sicp.info.gz /usr/local/info/
sudo chmod 644 /usr/local/info/sicp.info.gz
sudo install-info /usr/local/info/sicp.info.gz /usr/local/info/dir
rm sicp.info.gz
