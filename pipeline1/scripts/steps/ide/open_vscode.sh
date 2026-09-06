#!/usr/bin/env bash

function open_vscode {
    case "$MY_OS" in     
        macos)
            open -na "Visual Studio Code.app" "$REPO_DIR/nhsapp/web"
            ;;
        *)
            code "$REPO_DIR/nhsapp/web"
            ;;
    esac
}

open_vscode