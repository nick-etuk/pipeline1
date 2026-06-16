#!/usr/bin/env bash
# shellcheck disable=SC1091

if ! dpkg --get-selections | grep -q zsh; then
    sudo apt-get -y install zsh zsh-autosuggestions zsh-syntax-highlighting
fi

sudo chsh -s /usr/bin/zsh

echo "Configuring zshrc..."
template_file=$(find "$P1_ROOT_UNIX" -name 'zshrc_template.sh' -type f -not -path '.venv_p1/*')

if [ ! -f "$template_file" ]; then
    echo "zshrc template not found at $template_file"
    return
fi

template_content=$(<"$template_file")
template_content=${template_content//'{{P1_USER_UNIX}}'/"$P1_USER_UNIX"}
echo "$template_content" > "$HOME"/.zshrc
# sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autocomplete)/' ~/.zshrc
source "$HOME/.zshrc"

edit_login_profile
