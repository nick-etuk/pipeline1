#!/usr/bin/env bash

install_vscode_wsl() {
    info "Installing Visual Studio Code in Windows from WSL..."
    # todo: implement this
}

install_vscode() {
    [ "$VM" = 'wsl' ] && install_vscode_wsl && return

    case "$MY_OS" in     
        macos)
            info "Installing Visual Studio Code in macOS..."
            brew install --cask visual-studio-code
            ;;
        ubuntu)
            info "Installing Visual Studio Code in Ubuntu..."
            sudo snap install --classic code
            ;;
        *)
            error "Unknown OS: $MY_OS"
    esac
}

install_vscode