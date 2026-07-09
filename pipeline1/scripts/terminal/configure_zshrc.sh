#!/usr/bin/env bash

# inspect .zshrc
# if it contains the text 'ZSH_THEME="robbyrussell"'
# then replace it with 'ZSH_THEME="powerlevel10k/powerlevel10k"'
if grep -q 'ZSH_THEME="robbyrussell"' "$HOME/.zshrc"; then
    echo 'Changing ZSH_THEME to powerlevel10k/powerlevel10k in .zshrc'
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    source "$HOME/.zshrc"
fi

# inspect .zshrc
# if it contains the text "plugins='plugins=(git)'"
# then replace it with "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)'"
if grep -q 'plugins=(git)' "$HOME/.zshrc"; then
    echo 'Adding zsh-syntax-highlighting and zsh-autosuggestions to plugins in .zshrc'
    sed -i "s/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" "$HOME/.zshrc"
    source "$HOME/.zshrc"
fi
