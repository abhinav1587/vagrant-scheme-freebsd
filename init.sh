#!/bin/sh
set -x
# echo Get the base system up to date
# sudo pkg update && sudo pkg -y upgrade && sudo pkg autoclean -y && sudo pkg autoremove -y

echo Install required apps
sudo pkg install -y git screen wget curl emacs25 guile2

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
mkdir ~/lisp
cd ~/lisp
git clone http://git.sv.gnu.org/r/geiser.git
git clone http://mumble.net/~campbell/git/paredit.git
wget https://raw.githubusercontent.com/emacsmirror/emacswiki.org/master/lacarte.el

echo configure .emacs to load geiser on start

cat <<EOF > ~/.emacs
(load-file "~/lisp/geiser/elisp/geiser.el")
(setq geiser-active-implementations '(guile))

(load-file "~/lisp/paredit/paredit.el")
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

(load-file "~/lisp/lacarte.el")
(global-set-key [?\e ?\M-x] 'lacarte-execute-command)
(global-set-key [?\M-`] 'lacarte-execute-command)
EOF
