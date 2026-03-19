#!/usr/bin/env bash
echo "*** installing powerlevel10k"
# return 0
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
template=$(find "$P1_ROOT_UNIX" -name 'p10k_template.zsh' -not -path '.venv_p1/*')
cp "$template" "$HOME"/.p10k.zsh
echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME"/.zshrc
