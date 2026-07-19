#!/usr/bin/env bash

# sudo chsh -s /usr/bin/zsh "$P1_USER_UNIX" # done in install_zsh.sh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autocomplete

# plugins='plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-autosuggestions)'
# if ! grep -q "$plugins" ~/.zshrc; then
#     echo "$plugins" >> ~/.zshrc
# fi
