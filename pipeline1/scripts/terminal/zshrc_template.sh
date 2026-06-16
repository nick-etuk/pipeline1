# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/{{P1_USER_UNIX}}/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [ -f "$HOME/.oh-my-zsh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
fi

if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    ZSH_THEME="powerlevel10k/powerlevel10k"
else
    ZSH_THEME="robbyrussell"
fi

plugins='plugins=(git zsh-syntax-highlighting zsh-autocomplete)'

[ -f "$ZSH/oh-my-zsh.sh" ] && source $ZSH/oh-my-zsh.sh

[ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"
