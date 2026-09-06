#!/usr/bin/env bash

install_text_editor_wsl() {
    info "Installing text editor in Windows from WSL..."
    # todo: implement this
}

function install_text_editor {
    debug "bp1: Installing text editor..."
    return 0
    [ "$VM" = 'wsl' ] && install_text_editor_wsl && return
    case "$MY_OS" in
        macos)
            # todo: install coteditor
            ln -s /Applications/CotEditor.app/Contents/SharedSupport/bin/cot /usr/local/bin/cot
            ;;
        ubuntu)
            # todo: install nano if needed
            ;;
        wsl)
            # todo: install notepad ++
            ;;
        *)
            error "Unnown OS $MY_OS"
    esac
}

install_text_editor