#!/usr/bin/env bash
echo "*** installing powerlevel10k"
# return 0
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
template_file=$(find "$P1_ROOT_UNIX" -name 'p10k_template.zsh' -not -path '.venv_p1/*')
if [ ! -f "$template_file" ]; then
    echo "Powerlevel10k template not found at $template_file"
    return
fi
cp "$template_file" "$HOME"/.p10k.zsh
# echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME"/.zshrc
