#!/usr/bin/env bash
read -r -d '' zshrc_content <<'EOF'
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
EOF

sudo apt-get install -y zsh
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Failed to install zsh. Exit status: $exit_status"
    exit $exit_status
fi

# sudo chsh -s /usr/bin/zsh "$P1_USER_UNIX"
sudo chsh -s /usr/bin/zsh

template_content=$(<"$template_file")
    zshrc_content=${zshrc_content//'{{P1_USER_UNIX}}'/"$P1_USER_UNIX"}
echo "$zshrc_content" > "$HOME"/.zshrc
edit_login_profile
