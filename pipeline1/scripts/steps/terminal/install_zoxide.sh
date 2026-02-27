#!/usr/bin/env bash

function add_zoxide_to_profile {
    local target
    target=$1

    [ -f "$target" ] || return 0

    echo 'export PATH=\"$PATH:$HOME/.local/bin\"' >> "$target"
    case "$target" in
        ~/.zshrc)
            echo 'eval "$(zoxide init zsh --cmd cd)"' >> "$target"
            ;;
        ~/.config/fish/config.fish)
            echo 'zoxide init fish --cmd cd | source' >> "$target"
            ;;
        *)
            echo 'eval "$(zoxide init bash --cmd cd)"' >> "$target"
            ;;
    esac
    info "Added zoxide to $target"
}
echo "*** installing zoxide"
# return 0
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

add_zoxide_to_profile ~/.bashrc
add_zoxide_to_profile ~/.zshrc
add_zoxide_to_profile ~/.config/fish/config.fish
